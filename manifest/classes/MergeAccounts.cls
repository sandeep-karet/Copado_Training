public with sharing class MergeAccounts {
  public static void mergeAccounts(Map<String, String> accountsMap) {
    Account masterAccount, childAccount;

    List<String> errorList = new List<String>();

    List<Account> account2Update = new List<Account>();
    List<Acct_Rel__c> ServRel2Update = new List<Acct_Rel__c>();
    List<Acct_Rel__c> BenRel2Update = new List<Acct_Rel__c>();
    List<Location__c> Location2Update = new List<Location__c>();
    List<Contact> Contacts2Update = new List<Contact>();
    List<AccountContactRelation> acr2Insert = new List<AccountContactRelation>();
    List<Opportunity> opp2Update = new List<Opportunity>();
    List<Contract> cont2Update = new List<Contract>();
    List<SBQQ__Subscription__c> subs2Update = new List<SBQQ__Subscription__c>();
    List<Asset> assets2Update = new List<Asset>();
    List<Mbr_Group__c> mebGrp2Update = new List<Mbr_Group__c>();
    List<Case> case2Update = new List<Case>();
    List<Task> task2Update = new List<Task>();
    List<Event> event2Update = new List<Event>();

    Map<String, Account> masterAccountMap = new Map<String, Account>();
    Map<String, Account> childAccountMap = new Map<String, Account>();
    //Map<Id,String> childAccountIds = new Map<Id,String>();
    Map<String, Legacy_Id__c> legacyIdMap = new Map<String, Legacy_Id__c>();
    Map<String, List<Acct_Rel__c>> serRelationsMap = new Map<String, List<Acct_Rel__c>>();
    Map<String, List<Acct_Rel__c>> benRelationsMap = new Map<String, List<Acct_Rel__c>>();
    Map<String, List<Location__c>> locationMap = new Map<String, List<Location__c>>();
    Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
    Map<String, List<AccountContactRelation>> acrMap = new Map<String, List<AccountContactRelation>>();
    Map<String, List<Opportunity>> oppMap = new Map<String, List<Opportunity>>();
    Map<String, List<Contract>> contrMap = new Map<String, List<Contract>>();
    Map<String, List<SBQQ__Subscription__c>> subsMap = new Map<String, List<SBQQ__Subscription__c>>();
    Map<String, List<Asset>> assetMap = new Map<String, List<Asset>>();
    Map<String, List<Mbr_Group__c>> mbrGrpMap = new Map<String, List<Mbr_Group__c>>();
    Map<String, List<Case>> caseMap = new Map<String, List<Case>>();
    Map<String, List<Task>> taskMap = new Map<String, List<Task>>();
    Map<String, List<Event>> eventMap = new Map<String, List<Event>>();

    for (Account cAccount : [
      SELECT id, name, source__c, source_id__c, GUID__c
      FROM Account
      WHERE GUID__c IN :accountsMap.keySet()
    ]) {
      childAccountMap.put(cAccount.GUID__c, cAccount);
      //childAccountIds.put(cAccount.id,cAccount.GUID__c);
    }
    for (Account mAccount : [
      SELECT id, name, source__c, source_id__c, GUID__c
      FROM Account
      WHERE GUID__c IN :accountsMap.values()
    ]) {
      masterAccountMap.put(mAccount.GUID__c, mAccount);
    }
    for (Legacy_Id__c legacyId : [
      SELECT id, GUID__c
      FROM Legacy_Id__c
      WHERE Master_Account__r.guid__c IN :accountsMap.values()
    ]) {
      legacyIdMap.put(legacyId.GUID__c, legacyId);
    }
    for (Account sevAccount : [
      SELECT id, guid__c, (SELECT id, Svc_Acct__c FROM benefitsponsors__r)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      serRelationsMap.put(sevAccount.guid__c, sevAccount.benefitsponsors__r);
    }
    for (Account benAccount : [
      SELECT
        id,
        guid__c,
        (SELECT id, Benefit_Sponsor__c FROM servicingaccounts__r)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      benRelationsMap.put(benAccount.guid__c, benAccount.servicingaccounts__r);
    }
    for (Account locAccount : [
      SELECT id, guid__c, (SELECT id, Location_HQ__c FROM Locations__r)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      locationMap.put(locAccount.guid__c, locAccount.Locations__r);
    }
    for (Account contAccount : [
      SELECT id, guid__c, (SELECT id, accountId FROM Contacts)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      contactMap.put(contAccount.guid__c, contAccount.contacts);
    }
    for (Account acrAccount : [
      SELECT
        id,
        guid__c,
        (SELECT id, accountId, contactId FROM AccountContactRelations)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      acrMap.put(acrAccount.guid__c, acrAccount.AccountContactRelations);
    }
    for (Account oppAccount : [
      SELECT id, guid__c, (SELECT id, accountId FROM opportunities)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      oppMap.put(oppAccount.guid__c, oppAccount.opportunities);
    }
    for (Account contAccount : [
      SELECT id, guid__c, (SELECT id, accountId FROM Contracts)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      contrMap.put(contAccount.guid__c, contAccount.Contracts);
    }
    for (Account subAccount : [
      SELECT
        id,
        guid__c,
        (SELECT id, SBQQ__Account__c FROM SBQQ__Subscriptions__r)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      subsMap.put(subAccount.guid__c, subAccount.SBQQ__Subscriptions__r);
    }
    for (Account assetAccount : [
      SELECT id, guid__c, (SELECT id, accountId FROM Assets)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      assetMap.put(assetAccount.guid__c, assetAccount.Assets);
    }
    for (Account mbrAccount : [
      SELECT id, guid__c, (SELECT id, Client_Account__c FROM Member_Groups__r)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      mbrgrpMap.put(mbrAccount.guid__c, mbrAccount.Member_Groups__r);
    }
    for (Account caseAccount : [
      SELECT id, guid__c, (SELECT id, accountId, contactId FROM cases)
      FROM Account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      caseMap.put(caseAccount.guid__c, caseAccount.cases);
    }
    for (Account eventAccount : [
      SELECT Id, name, (SELECT id, whoid FROM events)
      FROM account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      eventMap.put(eventAccount.guid__c, eventAccount.events);
    }
    for (Account taskAccount : [
      SELECT Id, name, (SELECT id, whoid FROM tasks)
      FROM account
      WHERE guid__c IN :accountsMap.keySet()
    ]) {
      taskMap.put(taskAccount.guid__c, taskAccount.tasks);
    }

    for (String cGUID : accountsMap.keySet()) {
      if (childAccountMap.get(cGUID) == null) {
        errorList.add('Child account not found for the GUID : ' + cGUID + '\n');
        continue;
      }
      //update ChildAccount
      childAccount = childAccountMap.get(cGUID);
      childAccount.guid__c = null;
      account2Update.add(childAccount);

      // EEM: might use containsKey vs checking for null or ''
      if (masterAccountMap.get(accountsMap.get(cGUID)) == null) {
        errorList.add(
          'Master account not found for the GUID : ' +
            accountsMap.get(cGUID) +
            '\n'
        );
        continue;
      }
      masterAccount = masterAccountMap.get(accountsMap.get(cGUID));

      //Create a LegacyId on MasterAccount if not Present already
      Legacy_Id__c legacyId;
      if (legacyIdMap.get(cGUID) != null) {
        System.debug(
          'Legacy Id already present on the Master Account ' +
            masterAccount.guid__c +
            ' for the ChildAccount ' +
            childAccount.guid__c
        );
        legacyId = legacyIdMap.get(cGUID);
      } else {
        legacyId = new Legacy_Id__c(
          guid__c = cGUID,
          Master_Account__c = masterAccount.id,
          Original_Name__c = childAccount.name,
          Source__c = childAccount.source__c,
          Source_Id__c = childAccount.source_id__c
        );
        Database.SaveResult saveResult = Database.insert(legacyId, false);
        if (!saveResult.isSuccess()) {
          errorList.add(
            'Exception ' +
              saveResult.errors.get(0).getMessage() +
              ' on inserting LegacyId for the ChildAccount ' +
              childAccount.guid__c +
              '\n'
          );
          continue;
        }
      }

      //Merge ServicingAccount Relationships
      if (
        serRelationsMap.get(cGUID) != null &&
        serRelationsMap.get(cGUID).size() > 0
      ) {
        for (Acct_Rel__c serRel : serRelationsMap.get(cGUID)) {
          serRel.Svc_Acct__c = masterAccount.id;
          serRel.Legacy_Id__c = legacyId.Id;
          ServRel2Update.add(serRel);
        }
      }

      //Merge BenefitSponsor Relationships
      if (
        benRelationsMap.get(cGUID) != null &&
        benRelationsMap.get(cGUID).size() > 0
      ) {
        for (Acct_Rel__c benRel : benRelationsMap.get(cGUID)) {
          benRel.Benefit_Sponsor__c = masterAccount.id;
          benRel.legacy_Id__C = legacyId.id;
          BenRel2Update.add(benRel);
        }
      }

      //Merge Locations
      if (locationMap.get(cGUID) != null && locationMap.get(cGUID).size() > 0) {
        for (Location__c loc : locationMap.get(cGUID)) {
          loc.Location_HQ__c = masterAccount.id;
          loc.legacy_Id__C = legacyId.id;
          Location2Update.add(loc);
        }
      }

      //Merge Contact
      if (contactMap.get(cGUID) != null && contactMap.get(cGUID).size() > 0) {
        for (Contact contact : contactMap.get(cGUID)) {
          contact.AccountId = masterAccount.id;
          contact.legacy_Id__C = legacyId.id;
          Contacts2Update.add(contact);
        }
      }

      //Merge AccountContactRelationship
      if (acrMap.get(cGUID) != null && acrMap.get(cGUID).size() > 0) {
        for (AccountContactRelation acr : acrMap.get(cGUID)) {
          AccountContactRelation acr2 = acr.clone(false, true, true, false);
          acr2.AccountId = masterAccount.id;
          acr2.contactId = acr.contactId;
          acr2Insert.add(acr2);
        }
      }

      //Merge MemberGroup
      if (mbrGrpMap.get(cGUID) != null && mbrGrpMap.get(cGUID).size() > 0) {
        for (Mbr_Group__c mbrGroup : mbrGrpMap.get(cGUID)) {
          mbrGroup.Client_Account__c = masterAccount.id;
          mbrGroup.legacy_Id__C = legacyId.id;
          mebGrp2Update.add(mbrGroup);
        }
      }

      //Merge Opportunity
      if (oppMap.get(cGUID) != null && oppMap.get(cGUID).size() > 0) {
        for (Opportunity opp : oppMap.get(cGUID)) {
          opp.AccountId = masterAccount.id;
          opp.legacy_Id__C = legacyId.id;
          Opp2Update.add(opp);
        }
      }

      //Merge Contract
      if (contrMap.get(cGUID) != null && contrMap.get(cGUID).size() > 0) {
        for (Contract contract : contrMap.get(cGUID)) {
          contract.AccountId = masterAccount.id;
          contract.legacy_Id__C = legacyId.id;
          cont2Update.add(contract);
        }
      }

      //Merge Subscription
      if (subsMap.get(cGUID) != null && subsMap.get(cGUID).size() > 0) {
        for (SBQQ__Subscription__c sub : subsMap.get(cGUID)) {
          sub.SBQQ__Account__c = masterAccount.id;
          sub.legacy_Id__C = legacyId.id;
          subs2Update.add(sub);
        }
      }

      //Merge Assets
      if (assetMap.get(cGUID) != null && assetMap.get(cGUID).size() > 0) {
        for (Asset asset : assetMap.get(cGUID)) {
          asset.AccountId = masterAccount.id;
          asset.legacy_Id__C = legacyId.id;
          Assets2Update.add(asset);
        }
      }

      //Merge Cases
      if (caseMap.get(cGUID) != null && caseMap.get(cGUID).size() > 0) {
        for (Case c : caseMap.get(cGUID)) {
          c.AccountId = masterAccount.id;
          c.legacy_Id__C = legacyId.id;
          Case2Update.add(c);
        }
      }

      //Merge events
      if (eventMap.get(cGUID) != null && eventMap.get(cGUID).size() > 0) {
        for (Event event : eventMap.get(cGUID)) {
          event.whatId = masterAccount.id;
          event2Update.add(event);
        }
      }

      //Merge tasks
      if (taskMap.get(cGUID) != null && taskMap.get(cGUID).size() > 0) {
        for (Task task : taskMap.get(cGUID)) {
          task.whatId = masterAccount.id;
          task2Update.add(task);
        }
      }
    }

    List<Database.SaveResult> saveResultsSAccount = Database.update(
      account2Update,
      false
    );
    List<Database.SaveResult> saveResultsServRel = Database.update(
      ServRel2Update,
      false
    );
    List<Database.SaveResult> saveResultsBenRel = Database.update(
      BenRel2Update,
      false
    );
    List<Database.SaveResult> saveResultsLocation = Database.update(
      Location2Update,
      false
    );
    List<Database.SaveResult> saveResultsContact = Database.update(
      Contacts2Update,
      false
    );
    List<Database.SaveResult> saveResultsAcr = Database.Insert(
      acr2Insert,
      false
    );
    List<Database.SaveResult> saveResultsMbrGroup = Database.update(
      mebGrp2Update,
      false
    );
    List<Database.SaveResult> saveResultsOpp = Database.update(
      opp2Update,
      false
    );
    List<Database.SaveResult> saveResultsContract = Database.update(
      cont2Update,
      false
    );
    List<Database.SaveResult> saveResultsSubs = Database.update(
      subs2Update,
      false
    );
    List<Database.SaveResult> saveResultsAssets = Database.update(
      assets2Update,
      false
    );
    List<Database.SaveResult> saveResultsCase = Database.update(
      case2Update,
      false
    );
    List<Database.SaveResult> saveResultsEvent = Database.update(
      event2Update,
      false
    );
    List<Database.SaveResult> saveResultsTask = Database.update(
      task2Update,
      false
    );

    // EEM: May want to filter results by those that are NOT 'SUCCESS' otherwise debug will truncate log
    for (Database.SaveResult resulta : saveResultsSAccount) {
      System.debug(resulta);
    }
    for (Database.SaveResult result : saveResultsServRel) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsBenRel) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsLocation) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsContact) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsAcr) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsMbrGroup) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsOpp) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsContract) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsSubs) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsAssets) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsCase) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsEvent) {
      System.debug(result);
    }
    for (Database.SaveResult result : saveResultsTask) {
      System.debug(result);
    }

    System.debug(errorList);
  }
  // EEM: this process must be run one-each to prevent governor limits. tasks and events will prove to challenge the limits of 50k records read
}