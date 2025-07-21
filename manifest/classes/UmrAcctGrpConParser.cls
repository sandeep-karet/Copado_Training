public without sharing class UmrAcctGrpConParser {
  public void ProcessPostingEntries(
    List<AcctGrpConParsing_Item__c> scopedAgcpi
  ) {
    // First lets wipe previous parsing issues
    System.debug(
      System.LoggingLevel.FINE,
      'Removing previous parsing issues/log for item(s)'
    );
    List<Id> parentParsingItems = new List<Id>();
    for (AcctGrpConParsing_Item__c tmpAgcpi : scopedAgcpi)
      parentParsingItems.add(tmpAgcpi.Id);
    List<AcctGrpConParse_Exception__c> agcpe2Del = [
      SELECT id
      FROM AcctGrpConParse_Exception__c
      WHERE agcpi__c IN :parentParsingItems
    ];
    delete agcpe2Del;

    // Housekeeping Maps
    Map<String, PostingEntry> invalidPe = new Map<String, PostingEntry>();
    Map<String, PostingEntry> mappedPe = new Map<String, PostingEntry>();
    // Used to process valid entries
    Map<String, PostingEntry> mappedPeByOrg = new Map<String, PostingEntry>();
    Map<String, PostingEntry> mappedPeByGrp = new Map<String, PostingEntry>();

    // Deserialize posting data
    for (AcctGrpConParsing_Item__c tmpAgcpi : scopedAgcpi) {
      PostingEntry tmpPe = new PostingEntry(tmpAgcpi);
      if (tmpPe.IsValidAccount()) {
        mappedPe.put(tmpPe.entryId, tmpPe);
        System.debug(System.LoggingLevel.DEBUG, 'Valid PE: ' + tmpPe.entryId);
      } else
        System.debug(System.LoggingLevel.DEBUG, 'Invalid PE: ' + tmpPe.entryId);
    }
    // Grab org/grp ids and find existing account/group__c
    Set<String> orgIds = new Set<String>();
    Set<String> grpIds = new Set<String>();

    for (PostingEntry tmpPe : mappedPe.values())
      if (tmpPe.IsValidAccount()) {
        orgIds.add(tmpPe.orgId);
        grpIds.add(tmpPe.grpId);
        // Queue for additional processing
        mappedPeByOrg.put(tmpPe.orgId, tmpPe);
        mappedPeByGrp.put(tmpPe.grpId, tmpPe);
      } else {
        // set these items aside for INTERNAL exception report
        invalidPe.put(tmpPe.entryId, tmpPe);
      }

    system.debug(orgIds);
    // Grab existing accounts based on org ids passed in with file
    List<Account> existingAccts = [
      SELECT id, OrgId__c
      FROM Account
      WHERE OrgId__c IN :orgIds
    ];
    System.debug(
      LoggingLevel.FINE,
      'orgs found/sought (' + existingAccts.size() + '/' + orgIds.size() + ')'
    );

    // Fetch existing groups based on group numbers in file
    List<Mbr_Group__c> existingGrps = [
      SELECT id, Group_Number__c
      FROM Mbr_Group__c
      WHERE Group_Number__c IN :grpIds
    ];
    System.debug(
      LoggingLevel.FINE,
      'groups found/sought (' + existingGrps.size() + '/' + grpIds.size() + ')'
    );

    // Assign sfid from accounts/groups that currently exists to prevent creation
    for (Account tmpAcct : existingAccts) {
      Account curAcct = mappedPeByOrg.get(tmpAcct.OrgId__c).tmpAcct;
      curAcct.Id = tmpAcct.Id;
    }
    for (Mbr_Group__c tmpGrp : existingGrps) {
      Mbr_Group__c curGrp = mappedPeByGrp.get(tmpGrp.Group_Number__c).tmpGrp;
      curGrp.Id = tmpGrp.Id;
    }

    // Compile candidate records for creation
    List<Account> candidateAccounts = new List<Account>();
    List<PostingEntry> candidatePe = new List<PostingEntry>();
    List<String> managerNames = new List<String>();

    // Use the existence of a non-null id on the PE to indicated we need to save it
    for (PostingEntry tmpPe : mappedPeByOrg.values()) {
      system.debug(!tmpPe.AccountExists());
      system.debug(tmpPe);
      if (!tmpPe.AccountExists()) {
        // TODO: Fix this tweak to provide ALL ids for current org.  For now just fix Account Manager
        //if (String.isNotBlank(tmpPe.tmpAcct.Account_Manager__c))
        //managerNames.add(tmpPe.tmpAcct.Account_Manager__c);
        candidateAccounts.add(tmpPe.tmpAcct);
        candidatePe.add(tmpPe);
      } else {
        tmpPe.createException(
          'INFO',
          'ACCOUNT',
          'EXISTS',
          'ORGID ' + tmpPe.orgId + ' [SKIPPED]'
        );
      }
    }
    // TODO: (20171101) - JK stated these should be the owner/mgr respectively for all accounts.
    Map<String, Id> mappedUsers = new Map<String, Id>();
    for (User tmpUser : [
      SELECT id, Name, IsActive
      FROM User
      WHERE name IN ('Jay Helmer', 'Rebecca Schulz')
    ]) {
      mappedUsers.put(tmpUser.Name, tmpUser.Id);
    }

    // Preflight Accounts for creation
    for (Account tmpAcct : candidateAccounts) {
      tmpAcct.Account_Manager__c = mappedUsers.get('Rebecca Schulz');
      tmpAcct.OwnerId = mappedUsers.get('Jay Helmer');
    }
    // Commit new accounts
    System.debug(
      LoggingLevel.FINE,
      '# of candidate accounts: ' + candidateAccounts.size()
    );
    Database.SaveResult[] sr = Database.insert(candidateAccounts, false);
    Integer arrayOffset = 0;
    for (Database.SaveResult tmpSr : sr) {
      PostingEntry errorAcct = candidatePe[arrayOffset];
      if (!tmpSr.isSuccess()) {
        for (Database.Error tmpError : tmpSr.errors) {
          errorAcct.createException(
            'ERROR',
            'ACCOUNT',
            'CREATE',
            'ORGID ' +
              errorAcct.orgId +
              '[' +
              tmpError.fields +
              ']: ' +
              tmpError.message
          );
          //System.debug(System.LoggingLevel.FINE, 'ORGID ' + errorAcct.orgId + '[' + tmpError.fields + ']: ' + tmpError.message);
        }
      } else {
        errorAcct.createException(
          'INFO',
          'ACCOUNT',
          'CREATE',
          'ORGID ' + errorAcct.orgId + ' [SUCCESS]'
        );
      }
      arrayOffset++;
    }

    List<Mbr_Group__c> candidateGroups = new List<Mbr_Group__c>();
    List<PostingEntry> candidateGrpPe = new List<PostingEntry>();
    List<Mbr_Group_Role__c> candidateMbrGroupRoles = new List<Mbr_Group_Role__c>();

    // Preflight Groups
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      Boolean isCandidate = !tmpPe.GroupExists() && tmpPe.IsValidGroup();
      System.debug(
        LoggingLevel.FINE,
        'group ' + tmpPe.entryId + ' is candidate: ' + isCandidate
      );
      if (isCandidate) {
        candidateGroups.add(tmpPe.tmpGrp);
        candidateGrpPe.add(tmpPe);
      } else {
        tmpPe.createException(
          'INFO',
          'GROUP__C',
          'EXISTS',
          'LEGACYGROUPID ' + tmpPe.grpId + ' [SKIPPED]'
        );
      }
    }
    System.debug(
      LoggingLevel.FINE,
      '# of candidate groups: ' + candidateGroups.size()
    );
    Database.SaveResult[] grpSr = Database.insert(candidateGroups, false);
    System.debug(LoggingLevel.FINEST, grpSr);

    // Create member group roles for each entry. Duplicates are prevented in trigger so create all entries.
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      tmpPe.populate_mbr_group_role();
      System.debug(LoggingLevel.FINEST, 'TMPMGRLS:' + tmpPe.tmpMgrls);
      if (tmpPe.tmpMgrls.size() > 0)
        candidateMbrGroupRoles.addAll(tmpPe.tmpMgrls);
    }
    System.debug(
      LoggingLevel.FINE,
      '# of candidate group roles: ' + candidateMbrGroupRoles.size()
    );
    Database.SaveResult[] grpRoleSr = Database.insert(
      candidateMbrGroupRoles,
      false
    );

    List<Acct_Rel__c> candidateRels = new List<Acct_Rel__c>();
    // Create account relationships for each entry. Duplicates are prevented in trigger so create all entries.
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      tmpPe.populate_acct_rels();
      if (tmpPe.tmpAcctRels.size() > 0)
        candidateRels.addAll(tmpPe.tmpAcctRels);
    }
    Database.SaveResult[] acctRelsSr = Database.insert(candidateRels, false);

    arrayOffset = 0;
    for (Database.SaveResult tmpSr : grpSr) {
      PostingEntry errorGrp = candidateGrpPe[arrayOffset];
      if (!tmpSr.isSuccess()) {
        for (Database.Error tmpError : tmpSr.errors) {
          errorGrp.createException(
            'ERROR',
            'GROUP__C',
            'CREATE',
            'LEGACYGROUPID ' +
              errorGrp.grpId +
              ' [' +
              tmpError.fields +
              ']: ' +
              tmpError.message
          );
          System.debug(
            System.LoggingLevel.FINE,
            'LEGACYGROUPID ' +
              errorGrp.grpId +
              '[' +
              tmpError.fields +
              ']: ' +
              tmpError.message
          );
        }
      } else {
        errorGrp.createException(
          'INFO',
          'GROUP__C',
          'CREATE',
          'LEGACYGROUPID ' + errorGrp.grpId + ' [SUCCESS]'
        );
        arrayOffset++;
      }
    }
    // Preflight Contacts
    Map<String, Contact> candidateContacts = new Map<String, Contact>();
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      for (Contact tmpCon : tmpPe.ValidContacts())
        candidateContacts.put(tmpCon.Email.toUpperCase(), tmpCon);
    }
    // Remove existing contacts from candidate list
    List<Contact> existingContacts = [
      SELECT id, email
      FROM Contact
      WHERE email IN :candidateContacts.keyset()
    ];
    for (Contact tmpCon : existingContacts) {
      candidateContacts.remove(tmpCon.Email.toUpperCase());
    }
    // Commit remaining contacts
    Database.SaveResult[] conSr = Database.insert(
      candidateContacts.values(),
      false
    );

    // TODO: Remove once sub is created dynamically in test
    //List<SBQQ__Subscription__c> umrGenMedSub = [select Id from SBQQ__Subscription__c where source_id__c = 'a2h60000001Rxg6AAC' limit 1];
    List<SBQQ__Subscription__c> umr_subs = [
      SELECT
        Id,
        SBQQ__Product__r.ProductCode,
        Source_Id__c,
        (
          SELECT Id, Consult_Fees__c, Product2.ProductCode
          FROM SBQQ__ChildAssets__r
        )
      FROM SBQQ__Subscription__c
      WHERE
        source_id__c IN (
          'a2hf2000002IW0DAAW',
          'a2hf2000002IW0CAAW',
          'a2h60000001Rxg6AAC'
        )
    ];
    // a2hf2000002IW0DAAW = DERM
    // a2hf2000002IW0CAAW = BH
    // a2h60000001Rxg6AAC = GM

    Map<String, Id> mappedAssets = new Map<String, Id>();
    Map<String, Id> mappedSubs = new Map<String, Id>();
    for (SBQQ__Subscription__c tmpSub : umr_subs) {
      for (Asset asset : tmpSub.SBQQ__ChildAssets__r) {
        mappedAssets.put(asset.Product2.ProductCode, asset.Id);
      }
      if (tmpSub.SBQQ__Product__r.ProductCode == 'GM') {
        mappedSubs.put('GM', tmpSub.Id);
        continue;
      }
      if (tmpSub.SBQQ__Product__r.ProductCode == 'BH') {
        mappedSubs.put('BH', tmpSub.Id);
        continue;
      }
      if (tmpSub.SBQQ__Product__r.ProductCode == 'DERM') {
        mappedSubs.put('DERM', tmpSub.Id);
        continue;
      }
    }

    /*
        boolean subFound = false;
        if (umrGenMedSub.size() > 0)
            subFound = true;

        System.Debug(LoggingLevel.FINER, 'Sub found: ' + subFound);
        System.Debug(LoggingLevel.FINER, 'candidateGrpPe: ' + candidateGrpPe.size());

        */
    List<Plan_Specific_Fees__c> newPsfs = new List<Plan_Specific_Fees__c>();
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      newPsfs.addAll(tmpPe.populatePsf(mappedSubs, mappedAssets));
      /*
if (subFound) {
tmpPe.tmpPsf.Subscription__c = umrGenMedSub[0].Id;
newPsfs.add(tmpPe.tmpPsf);
}
*/
    }
    system.debug(newPsfs.size());

    Database.SaveResult[] psfsr = Database.insert(newPsfs, false);
    for (Database.SaveResult rowSr : psfsr) {
      if (!rowSr.isSuccess()) {
        for (Database.Error rowError : rowSr.getErrors()) {
          system.debug(rowError.getMessage());
        }
      }
    }
    System.Debug(LoggingLevel.FINER, psfsr);

    //system.debug(System.LoggingLevel.FINE, mappedPeByGrp.size() + ' valid groups found.');
    // Finally commit parsing exceptions
    List<AcctGrpConParse_Exception__c> allAgcpe = new List<AcctGrpConParse_Exception__c>();
    for (PostingEntry tmpPe : mappedPeByGrp.values()) {
      if (tmpPe.parsingResults.size() > 0) {
        allAgcpe.addAll(tmpPe.parsingResults);
      }
    }
    System.debug(allAgcpe);
    if (allAgcpe.size() > 0) {
      Database.SaveResult[] agcpeSr = Database.insert(allAgcpe, true);
    }
  }
}