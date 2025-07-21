public class F1bUtils_v2 {
  public static List<AcctGrpConParse_Exception__c> exceptionsFound { get; set; }
  public static Map<String, Account> existingMappedAccounts { get; set; }
  public static Mbr_Group__c existingGroup { get; set; }
  public static Map<Id, SBQQ__Subscription__c> existingSubs { get; set; }
  public static Map<Id, Asset> existingAssets { get; set; }
  public static Map<Id, Mbr_Group_Role__c> existingMbrGrl { get; set; }
  public static Map<String, String> existingDisclaimers { get; set; }
  public static Map<String, Plan_Specific_Fees__c> existingPsf { get; set; }
  public static Map<String, List<noneBhSubAssetWrapper>> NoneBhSubAssetMap {
    get;
    set;
  }

  public static void LogException(
    Id agcpid,
    String objectName,
    String exceptionType,
    String shortDesc,
    String fullDesc
  ) {
    if (exceptionsFound == null) {
      exceptionsFound = new List<AcctGrpConParse_Exception__c>();
    }
    exceptionsFound.add(
      new AcctGrpConParse_Exception__c(
        AGCPI__c = agcpid,
        Exception_Type__c = exceptionType,
        Short_Desc__c = shortDesc,
        SObject__c = objectName,
        Full_Desc__c = fullDesc
      )
    );
    system.debug(LoggingLevel.FINER, shortDesc + fullDesc);
  }

  public static void CommitDelta() {
    if (exceptionsFound != null) {
      try {
        insert exceptionsFound;
        exceptionsFound.clear();
      } catch (exception e) {
        system.debug(LoggingLevel.FINER, 'AGCPE insert failed');
      }
    }
  }

  // Get all records that can be found based on f1bp passed
  // Return: FALSE = errors were found
  public static Boolean FetchExistingData(F1BMainParser f1bp, Id agcpid) {
    // Load accounts
    Set<String> listedAccountGuids = new Set<String>();
    Set<String> listedUserIds = new Set<String>();
    Set<String> listedDisclaimer = new Set<String>();
    Set<String> listedPhoneUrl = new Set<String>();
    // First evaluate parent guid
    if (GlobalIdUtils.isGuid(f1bp.ParentGuid)) {
      listedAccountGuids.add(f1bp.ParentGuid);
    } else {
      LogException(
        agcpid,
        'ACCOUNT',
        'ERROR',
        'INVALID_PARENT_GUID',
        'Parent GUID [' + f1bp.ParentGuid + '] INVALID.'
      );
      return false;
    }

    // Add benefit sponsor guid if valid
    if (GlobalIdUtils.isGuid(f1bp.benefitSponsor.Guid__c)) {
      listedAccountGuids.add(f1bp.benefitSponsor.Guid__c);
    } else {
      LogException(
        agcpid,
        'ACCOUNT',
        'WARNING',
        'BSP_GUID_INVALID',
        'Benefit Sponsor [' + f1bp.benefitSponsor.Guid__c + '] INVALID.'
      );
    }

    // Validate UserId is valid
    if (f1bp.benefitSponsor.OwnerId != null)
      listedUserIds.add(f1bp.benefitSponsor.OwnerId);
    if (f1bp.benefitSponsor.Account_Manager__c != null)
      listedUserIds.add(f1bp.benefitSponsor.Account_Manager__c);
    if (FindUser(listedUserIds, agcpid) == false)
      return false;

    //  Validate welcomeKit disclaimer is valid
    if (f1bp.f1bmg != null && f1bp.f1bmg.f1bpwk != null) {
      if (f1bp.f1bmg.f1bpwk.DisclaimerTeladoc != null)
        listedDisclaimer.add(f1bp.f1bmg.f1bpwk.DisclaimerTeladoc);
      if (f1bp.f1bmg.f1bpwk.DisclaimerClient != null)
        listedDisclaimer.add(f1bp.f1bmg.f1bpwk.DisclaimerClient);
      if (FindDisclaimer(listedDisclaimer, agcpid) == false)
        return false;
    }

    // Fetch Account Data
    if (FetchAccounts(listedAccountGuids, agcpid) == false)
      return false;

    // Confirm ParentGUID was specified AND found
    if (!existingMappedAccounts.containsKey(f1bp.ParentGuid)) {
      LogException(
        agcpid,
        'ACCOUNT',
        'ERROR',
        'INVALID_PARENT_GUID',
        'No valid PARENT GUID has been provided.'
      );
      return false;
    }

    fetchSubsAssets(existingMappedAccounts.get(f1bp.ParentGuid).Id, agcpid);

    // Fetch Groups mentioned by GUID
    FetchGroup(f1bp, agcpid);

    if (existingGroup == null) {
      return true; // it is valid for the group not to exist
    }

    // if there is an existing group lets get all supporting data
    return true;
  }

  private static void fetchSubsAssets(Id parentId, Id agcpid) {
    // TODO: Will need to find a way to deal with identical pricing with different consult type

    // can use some refactor, but still need sub list
    existingSubs = new Map<Id, SBQQ__Subscription__c>(
      [
        SELECT
          id,
          fee_type__c,
          SBQQ__Product__r.ProductCode,
          Current_Membership_Fee__c,
          sbqq__quoteline__r.Membership_Fee__c,
          SBQQ__Account__r.OwnerId
        FROM sbqq__subscription__c
        WHERE
          sbqq__account__c = :parentId
          AND (SBQQ__SubscriptionStartDate__c <= today
          OR Termination_Date__c = NULL)
        ORDER BY SBQQ__SubscriptionStartDate__c DESC
      ]
    );
    if (existingSubs.size() == 0) {
      LogException(
        agcpid,
        'SBQQ__SUBCRIPTION__C',
        'ERROR',
        'NO_SUBS_FOUND',
        'No subscriptions for ' + parentId + ' found.'
      );
      return;
    }

    existingAssets = new Map<Id, Asset>(
      [
        SELECT
          id,
          name,
          SBQQ__RequiredBySubscription__c,
          Consult_Fees__c,
          SBQQ__RequiredBySubscription__r.SBQQ__Product__r.ProductCode,
          SBQQ__RequiredBySubscription__r.Fee_Type__c,
          SBQQ__RequiredBySubscription__r.Current_Membership_Fee__c
        FROM Asset
        WHERE
          SBQQ__RequiredBySubscription__r.sbqq__account__c = :parentId
          AND (SBQQ__RequiredBySubscription__r.SBQQ__SubscriptionStartDate__c <= today
          OR SBQQ__RequiredBySubscription__r.Termination_Date__c = NULL)
        ORDER BY
          SBQQ__RequiredBySubscription__r.SBQQ__SubscriptionStartDate__c DESC
      ]
    );

    if (existingAssets.size() == 0) {
      LogException(
        agcpid,
        'ASSET',
        'ERROR',
        'NO_ASSETS_FOUND',
        'No assets or subscriptions under ' + parentId + ' found.'
      );
      return;
    }
  }

  private static void FetchGroup(F1BMainParser f1bp, Id agcpid) {
    if (
      f1bp.f1bmg != null && GlobalIdUtils.isGuid(f1bp.f1bmg.ephMbrGroup.Guid__c)
    ) {
      List<Mbr_Group__c> existingGroups = [
        SELECT
          id,
          Card_Name__c,
          Allow_Conversion_To_Retail__c,
          Allow_Caregiver_Program__c,
          Sexual_Health_Opt_Out__c,
          Termination_date__c,
          Consult_Billing_Method__c,
          Status__c,
          Eligibility_Option__c,
          Shipping_Class__c,
          Wk_Template__c,
          Wk_Retroactive__c,
          Any_Special_Instructions__c,
          WK_Send_Card_Date__c,
          Wk_Retroactive_Date__c,
          WK_Card_Includes_Logo__c,
          WK_Mail_to__c,
          WK_Includes_Insert__c,
          Allow_Geo_Fencing__c,
          Card_Template__c,
          Co_Brand_With_Logo__c,
          Communication_Mode__c,
          Disclaimer_Client__c,
          Disclaimer_Teladoc__c,
          Mk_Idcardfront1__c,
          GUID__c,
          Name__c,
          Client_Account__c,
          Group_Number__c,
          Domestic_Country__c,
          Active_Date__c,
          Logo1_ID__c,
          Health_Assistant__c,
          OneAppAccess__c,
          Service_Brand__c,
          Logo_Tag_ID__c,
          Elig_Dep_Inc_In_File__c,
          F1BReporting_Category__c,
          Consult_Message_on_WK__c,Cross_Billing__c,Disclaimer_Custom__c,Welcome_Letter_Consult_Message__c,
          Logo3_ID__c,Logo4_ID__c,AltLogo1_ID__c,AltLogo2_ID__c,MK_consultarea__c,Admin_Line_of_Business__c,LV_Client_Member_Code__c,
          Livongo_Registration_code__c,Enable_Livongo_Combined_Eligibility__c,Enable_Chronic_Care_Referrals__c								 //SCDEV:5872
        FROM Mbr_Group__c
        WHERE GUID__c = :f1bp.f1bmg.ephMbrGroup.Guid__c
      ];
      for (Mbr_Group__c tmpGroup : existingGroups) {
        existingGroup = tmpGroup;
      }
    } else {
      existingGroup = null;
      if (f1bp.f1bmg == null) {
        LogException(
          agcpid,
          'MBR_GROUP__C',
          'ERROR',
          'BLANK_GROUP_GUID',
          'Member group GUID is blank'
        );
      } else {
        LogException(
          agcpid,
          'MBR_GROUP__C',
          'ERROR',
          'INVALID_GROUP_GUID',
          f1bp.f1bmg.ephMbrGroup.Guid__c + 'not valid group GUID.'
        );
      }
    }
  }

  // Results: FALSE = errors finding account(s) parent guid must exist
  private static Boolean FetchAccounts(Set<String> accountGuids, Id agcpid) {
    List<Account> existingAccounts = [
      SELECT
        id,
        name,
        Account_Legal_Name__c,
        Friendly_Account_Name__c,
        BillingStreet,
        BillingCity,
        Business_Region__c,
        Language__c,
        Special_Instructions_for_Implementatio__c,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        revenue_effective_date__c,
        Account_Manager__c,
        Type,
        ownerId,
        CurrencyIsoCode,
        Total_US_Employees_Benefits_Enrolled__c,
        Members__c,
        Guid__c,
        Print_Url__c,
        Print_Phone__c,
        Standard_Print_Url__c,
        Custom_Print_Url__c,
        Custom_Print_Phone__c
      FROM Account
      WHERE GUID__c IN :accountGuids
    ];
    if (existingAccounts.size() == 0) {
      LogException(
        agcpid,
        'ACCOUNT',
        'ERROR',
        'NO_ACCOUNTS_FOUND',
        'No accounts found.'
      );
      return false;
    } else {
      for (Account tmpAccount : existingAccounts) {
        if (existingMappedAccounts == null) {
          existingMappedAccounts = new Map<String, Account>();
        }
        existingMappedAccounts.put(tmpAccount.GUID__c, tmpAccount);
      }
    }
    return true;
  }

  public static Acct_Rel__c Create_AcctRel(
    Account parentAccount,
    Account bspAccount,
    Id acctGrpConParsingId,
    F1BMainParser f1bp
  ) {
    Date startDate = Date.valueOf(f1bp.startDate);
    if (parentAccount.Guid__c == '1BB95CCB-765E-17A8-6778-6846FB556025') {
      Acct_Rel__c umrAcctRel = UmrExc.Create_UMR_AcctRel(
        parentAccount,
        bspAccount,
        acctGrpConParsingId,
        startDate
      );
      return umrAcctRel;
    } else {
      List<Acct_Rel__c> existing_AcctRel = [
        SELECT id
        FROM Acct_Rel__c
        WHERE
          Svc_Acct__c = :parentAccount.Id
          AND Benefit_Sponsor__c = :bspAccount.Id
          AND Relationship_Type__c = 'Contractee'
          AND Contract_Type__c = 'Reseller'
          AND (End_Date__c = NULL
          OR End_Date__c > Today)
        ORDER BY createddate DESC
        LIMIT 1
      ];

      if (existing_AcctRel.size() > 0) {
        return existing_AcctRel[0];
      } else {
        Acct_Rel__c new_AcctRel = new Acct_Rel__c(
          Svc_Acct__c = parentAccount.Id,
          Benefit_Sponsor__c = bspAccount.Id,
          Relationship_Type__c = 'Contractee',
          Contract_Type__c = 'Reseller',
          Start_Date__c = startDate
        );
        try {
          insert new_AcctRel;
          return new_AcctRel;
        } catch (Exception sinx) {
          LogException(
            acctGrpConParsingId,
            'ACCOUNT_REL__C',
            'DML_ERROR',
            'CANNOT_CREATE_ACCT_REL',
            sinx.getMessage()
          );
          return null;
        }
      }
    }
  }

  public static Mbr_Group_Role__c createMbrGroupRole(
    F1BMainParser f1bp,
    Account parentAccount,
    Account sourceAccount,
    Mbr_Group__c mbrGroup,
    Id acctGrpConParsingId,
    String roleType
  ) {
    // Check for  existing member role
    try {
      Mbr_Group_Role__c existing_group_role = [
        SELECT id, Source_Account__c, Role_Type__c, Mbr_Group__c
        FROM mbr_group_role__c
        WHERE
          Mbr_Group__r.GUID__c = :f1bp.f1bmg.ephMbrGroup.Guid__c
          AND Source_Account__c = :sourceAccount.Id
          AND Role_Type__c = :roleType
      ];
      return existing_group_role;
    } catch (Exception sx) {
      Mbr_Group_Role__c new_group_role = new Mbr_Group_Role__c(
        mbr_group__c = mbrGroup.id,
        Source_Account__c = sourceAccount.id,
        Role_Type__c = roleType
      );
      try {
        insert new_group_role;
        return new_group_role;
      } catch (Exception sinx) {
        LogException(
          acctGrpConParsingId,
          'Mbr_Group_Role__c',
          'DML_ERROR',
          'CANNOT_CREATE_MBR_GROUP_ROLE',
          sinx.getMessage()
        );
        return null;
      }
    }
  }

  public static void createPayer(
    F1BMainParser f1bp,
    Account subscriptionAccount,
    Mbr_Group__c mbrGroup,
    Id acctGrpConParsingId
  ) {
    // First confirm Payer exists
    Mbr_Group_Role__c mbrPayerRole = null;
    List<Account> payerAccounts = [
      SELECT
        id,
        name,
        Account_Legal_Name__c,
        Friendly_Account_Name__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        revenue_effective_date__c,
        Account_Manager__c,
        Total_US_Employees_Benefits_Enrolled__c,
        Members__c
      FROM Account
      WHERE guid__c = :f1bp.f1bmg.SfdcPayerGuid
    ];
    if (payerAccounts.size() == 1) {
      mbrPayerRole = createMbrGroupRole(
        f1bp,
        subscriptionAccount,
        payerAccounts[0],
        mbrGroup,
        acctGrpConParsingId,
        'Payer'
      );
    } else {
      LogException(
        acctGrpConParsingId,
        'Mbr_Group_Role__c',
        'DML_ERROR',
        'PAYER_NOT_FOUND',
        'Payer Account [' + f1bp.f1bmg.SfdcPayerGuid + '] was not found.'
      );
    }
  }

  public static void createContacts(
    F1BMainParser f1bp,
    Account parentAccount,
    Account bspAccount,
    Id MbrGrpId,
    Id acctGrpConParsingId
  ) {
    Map<String, contactWrapper> newContacts = new Map<String, contactWrapper>();
    Map<String, Contact> existingContact = new Map<String, Contact>();
    Map<String, List<Acct_Rel__c>> acctRelMap = new Map<String, List<Acct_Rel__c>>();
    Set<String> emailSet = new Set<String>();
    List<Contact> updateList = new List<Contact>();
    List<Contact> insertList = new List<Contact>();
    List<Mkt_Site_User__c> mktList = new List<Mkt_Site_User__c>();
    if (f1bp.f1bcp != null && f1bp.f1bcp.bspContacts.size() > 0) {
      for (Map<String, Contact> con : f1bp.f1bcp.bspContacts) {
        for (String keyType : con.keySet()) {
          con.get(keyType).AccountId = bspAccount.Id;
          if (keyType == 'SAE')
            con.get(keyType).AccountId = parentAccount.Id;
          if (keyType == 'Marketing')
            con.get(keyType).Marketing_Site_User__c = true;
          contactWrapper contactWrapper = new contactWrapper(
            con.get(keyType),
            keyType
          );
          newContacts.put(
            (con.get(keyType).Email +
              '_' +
              con.get(keyType).FirstName +
              '_' +
              con.get(keyType).LastName)
              .toLowercase(),
            contactWrapper
          );
          emailSet.add(con.get(keyType).Email);
        }
      }
      // TODO: Discuss 80/20 rule for evaluating distro-list emails vs contact emails
      // TODO: Need to figure a way to evaluate more than 2000 records on an account
      List<Id> parentAccountIdList = new List<Id>();
      for (Contact contact : [
        SELECT id, email, FirstName, LastName, Marketing_Site_User__c, AccountId
        FROM Contact
        WHERE email IN :emailSet
      ]) {
        parentAccountIdList.add(contact.AccountId);
        String key = (contact.email +
          '_' +
          contact.FirstName +
          '_' +
          contact.LastName)
          .toLowercase();
        existingContact.put(key, contact);
      }

      List<Acct_Rel__c> acctRel = [
        SELECT Id, Benefit_Sponsor__c
        FROM Acct_Rel__c
        WHERE
          Svc_Acct__c = :parentAccount.Id
          AND Benefit_Sponsor__c IN :parentAccountIdList
          AND Relationship_Type__c = 'Contractee'
      ];
      for (String con : existingContact.keyset()) {
        List<Acct_Rel__c> acctRelMapValues = new List<Acct_Rel__c>();
        for (Acct_Rel__c ar : acctRel) {
          if (ar.Benefit_Sponsor__c == existingContact.get(con).AccountId) {
            acctRelMapValues.add(ar);
          }
        }
        acctRelMap.put(con, acctRelMapValues);
      }

      for (String newKey : newContacts.keySet()) {
        if (existingContact.containsKey(newKey)) {
          if (
            newContacts.get(newKey).keyType == 'Marketing' &&
            existingContact.get(newKey).Marketing_Site_User__c == false
          ) {
            existingContact.get(newKey).Marketing_Site_User__c = true;
            updateList.add(existingContact.get(newKey));
          } else if (
            newContacts.get(newKey).keyType == 'Marketing' &&
            bspAccount.Id != existingContact.get(newKey).AccountId
          ) {
            if (acctRelMap.get(newKey).size() > 0) {
              Mkt_Site_User__c mktUser = new Mkt_Site_User__c();
              mktUser.Contact__c = existingContact.get(newKey).Id;
              mktUser.Mbr_Group__c = MbrGrpId;
              mktList.add(mktUser);
            }
          } else if (
            newContacts.get(newKey).keyType == 'SAE' &&
            existingContact.get(newKey).Marketing_Site_User__c == true
          ) {
            LogException(
              acctGrpConParsingId,
              'Contact',
              'ERROR',
              'CANNOT_UPDATE_CONTACT',
              'Can not change existing contact to SAE type'
            );
          }
        } else {
          insertList.add(newContacts.get(newKey).contact);
        }
      }
      Database.SaveResult[] insertResult = Database.insert(insertList, false);
      for (Database.SaveResult saveResult : insertResult) {
        for (Database.Error error : saveResult.getErrors()) {
          LogException(
            acctGrpConParsingId,
            'Contact',
            'ERROR',
            'CANNOT_CREATE_CONTACT',
            error.getMessage()
          );
        }
      }

      Database.SaveResult[] updateResult = Database.update(updateList, false);
      for (Database.SaveResult saveResult : updateResult) {
        for (Database.Error error : saveResult.getErrors()) {
          LogException(
            acctGrpConParsingId,
            'Contact',
            'ERROR',
            'CANNOT_UPDATE_CONTACT',
            error.getMessage()
          );
        }
      }

      Database.SaveResult[] mktResult = Database.insert(mktList, false);
      for (Database.SaveResult saveResult : mktResult) {
        for (Database.Error error : saveResult.getErrors()) {
          if (!error.getMessage().contains('GROUP + CONTACT')) {
            LogException(
              acctGrpConParsingId,
              'Mkt_Site_User__c',
              'ERROR',
              'CANNOT_CREATE_MKTSITE_USER',
              error.getMessage()
            );
          }
        }
      }
    }
  }

  public class contactWrapper {
    public Contact contact { get; set; }
    public String keyType { get; set; }
    public contactWrapper(Contact contact, String keyType) {
      this.contact = contact;
      this.keyType = keyType;
    }
  }

  // Results: FALSE = errors finding User(s) must exist
  private static Boolean FindUser(Set<String> userIds, Id agcpid) {
    List<User> existingUser = [
      SELECT Id
      FROM USER
      WHERE Id IN :userIds AND IsActive = TRUE
    ];
    if (existingUser.size() < userIds.size()) {
      LogException(
        agcpid,
        'USER',
        'ERROR',
        'INVALID_USER_ID',
        'One or more UserId is Invalid.'
      );
      return false;
    }
    return true;
  }

  // Results: FALSE = errors finding User(s) must exist
  private static Boolean FindDisclaimer(
    Set<String> disclaimerNames,
    Id agcpid
  ) {
    List<Disclaimers__c> existingDisclaimer = [
      SELECT Id, Name
      FROM Disclaimers__c
      WHERE Name IN :disclaimerNames
    ];
    if (existingDisclaimer.size() < disclaimerNames.size()) {
      LogException(
        agcpid,
        'DISCLAIMER__C',
        'ERROR',
        'INVALID_DISCLAIMER_NAME',
        'One or more Disclaimers name is Invalid.'
      );
      return false;
    } else {
      for (Disclaimers__c tmpDisclaimer : existingDisclaimer) {
        if (existingDisclaimers == null) {
          existingDisclaimers = new Map<String, String>();
        }
        existingDisclaimers.put(tmpDisclaimer.Name, tmpDisclaimer.Id);
      }
      return true;
    }
  }

  public static void updateSObjectList(
    Date endDate,
    Id agcpid,
    Map<String, sObject> objMap,
    String fieldName,
    String ObjApiName
  ) {
    List<sObject> objList = new List<sObject>();
    for (sObject sObj : objMap.values()) {
      sObj.put(fieldName, endDate);
      objList.add(sObj);
    }
    Database.SaveResult[] sr = Database.update(objList, false);
    for (Database.SaveResult rowSr : sr) {
      if (!rowSr.isSuccess()) {
        for (Database.Error rowError : rowSr.getErrors()) {
          LogException(
            agcpid,
            ObjApiName,
            'ERROR',
            'END_DATE_UPDATE_FAILED',
            rowError.getMessage()
          );
        }
      }
    }
  }

  public static void updateEndDate(F1BMainParser f1bp, Id agcpid) {
    // Update Account Relationship Record
    if (f1bp.ParentGuid == '1BB95CCB-765E-17A8-6778-6846FB556025') {
      UmrExc.updateAcctRelEndDate(
        f1bp.ParentGuid,
        f1bp.benefitSponsor.Guid__c,
        f1bp.EndDate,
        agcpid
      );
    } else {
      Map<String, Acct_Rel__c> AcctRelMap = new Map<String, Acct_Rel__c>(
        [
          SELECT Id
          FROM Acct_Rel__c
          WHERE
            Svc_Acct__r.Guid__c = :f1bp.ParentGuid
            AND Benefit_Sponsor__r.Guid__c = :f1bp.benefitSponsor.Guid__c
            AND Relationship_Type__c = 'Contractee'
            AND Contract_Type__c = 'Reseller'
            AND (End_Date__c = NULL
            OR End_Date__c > Today)
          ORDER BY createddate DESC
          LIMIT 1
        ]
      );
      updateSObjectList(
        Date.valueOf(f1bp.EndDate),
        agcpid,
        AcctRelMap,
        'End_Date__c',
        'ACCT_REL__C'
      );
    }
  }

  public static void PsfRoles(Id groupId, Id agcpid) {
    List<Plan_Specific_Fees__c> currentPsf = [
      SELECT
        Id,
        Subscription__r.Fee_Type__c,
        PSF_ProductCode__c,
        Subscription__r.Current_Membership_Fee__c,
        Subscription__r.SBQQ__Product__r.ProductCode,
        Actual_Copay_May_Be_Less__c,
        Product_Start_Date__c,
        Product_End_Date__c,
        Consult_Fee_Mbr_Pd__c,
        Consult_Fee_Plan_Pd__c,
        USGH_APP_Opt_Out__c
      FROM Plan_Specific_Fees__c
      WHERE Member_Group__c = :groupId
    ];
    if (currentPsf.size() == 0) {
      return;
    }

    if (existingPsf == null) {
      existingPsf = new Map<String, Plan_Specific_Fees__c>();
    }

    List<Plan_Specific_Fees__c> bhList = new List<Plan_Specific_Fees__c>();
    List<Plan_Specific_Fees__c> mhList = new List<Plan_Specific_Fees__c>();
    for (Plan_Specific_Fees__c psf : currentPsf) {
      if (psf.Subscription__r.SBQQ__Product__r.ProductCode == 'BH') {
        bhList.add(psf);
      } else if (psf.Subscription__r.SBQQ__Product__r.ProductCode == 'MH') {
        mhList.add(psf);
      } else {
        String key = creatingPsfKey(psf);
        existingPsf.put(key, psf);
      }
    }
    BundleClass bhBundle = new BundleClass();
    bhBundle.createExistingKey('BH', bhList);
    bhBundle.createExistingKey('MH', mhList);

    existingMbrGrl = new Map<Id, Mbr_Group_Role__c>(
      [
        SELECT id, name
        FROM Mbr_Group_Role__c
        WHERE Mbr_Group__c = :groupId
      ]
    );
  }

  public static String creatingPsfKey(Plan_Specific_Fees__c psf) {
    if (psf.Consult_Fee_Mbr_Pd__c == null)
      psf.Consult_Fee_Mbr_Pd__c = 0;
    String key =
      String.valueOf(psf.Product_Start_Date__c) +
      '__' +
      String.valueOf(psf.Subscription__c) +
      '__' +
      String.valueOf(psf.Product_End_Date__c) +
      '__' +
      String.valueOf(psf.Actual_Copay_May_Be_Less__c) +
      '__' +
      String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2))+
        '__' +
      String.valueOf(psf.USGH_APP_Opt_Out__c);
    return key;
  }

  public class noneBhSubAssetWrapper {
    public SBQQ__Subscription__c sub { get; set; }
    public Asset asset { get; set; }
    public String oppGUID { get; set; }
    public noneBhSubAssetWrapper(
      SBQQ__Subscription__c sub,
      Asset asset,
      String oppGUID
    ) {
      this.sub = sub;
      this.asset = asset;
      this.oppGUID = oppGUID;
    }
  }

  public static void createNoneBhSubAssetMap(String parentGUID) {
    List<noneBhSubAssetWrapper> subAssetList = new List<noneBhSubAssetWrapper>();
    if (NoneBhSubAssetMap == null) {
      NoneBhSubAssetMap = new Map<String, List<noneBhSubAssetWrapper>>();
    }
    List<SBQQ__Subscription__c> listSubscriptions = [
      SELECT
        Id,
        Oportunity_Id__c,
        Fee_Type__c,
        SBQQ__Product__r.ProductCode,
        Current_Membership_Fee__c,
        (SELECT Id, Consult_Fees__c FROM SBQQ__ChildAssets__r)
      FROM SBQQ__Subscription__c
      WHERE
        SBQQ__Account__r.Guid__c = :parentGUID
        AND SBQQ__Product__r.ProductCode != 'BH'
        AND (SBQQ__SubscriptionStartDate__c <= TODAY
        OR Termination_Date__c = NULL)
      ORDER BY SBQQ__SubscriptionStartDate__c DESC
    ];
    Map<String, String> mapOppGUIds = new Map<String, String>();
    Set<String> setOppIds = new Set<String>();
    for (SBQQ__Subscription__c sub : listSubscriptions) {
      if (sub.Oportunity_Id__c != null)
        setOppIds.add(sub.Oportunity_Id__c);
    }
    Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>(
      [
        SELECT Id, Opp_Guid__c
        FROM Opportunity
        WHERE Opp_Guid__c != NULL AND Id IN :setOppIds
      ]
    );
    for (SBQQ__Subscription__c sub : listSubscriptions) {
      Boolean hasAsset = false;
      String oppGUID = (sub.Oportunity_Id__c != null &&
        mapOpp.get(sub.Oportunity_Id__c) != null)
        ? mapOpp.get(sub.Oportunity_Id__c).Opp_Guid__c
        : null;
      for (Asset asset : sub.SBQQ__ChildAssets__r) {
        system.debug('Assets inside wrapper' + asset);
        hasAsset = true;
        subAssetList.add(new noneBhSubAssetWrapper(sub, asset, oppGUID));
      }
      if (!hasAsset) {
        subAssetList.add(new noneBhSubAssetWrapper(sub, null, oppGUID));
      }
    }
    for (noneBhSubAssetWrapper SA : subAssetList) {
      if (NoneBhSubAssetMap.containsKey(SA.sub.SBQQ__Product__r.ProductCode)) {
        NoneBhSubAssetMap.get(SA.sub.SBQQ__Product__r.ProductCode).add(SA);
        NoneBhSubAssetMap.put(
          SA.sub.SBQQ__Product__r.ProductCode,
          (NoneBhSubAssetMap.get(SA.sub.SBQQ__Product__r.ProductCode))
        );
      } else {
        List<noneBhSubAssetWrapper> newList = new List<noneBhSubAssetWrapper>();
        newList.add(SA);
        NoneBhSubAssetMap.put(SA.sub.SBQQ__Product__r.ProductCode, newList);
      }
    }
  }

  public static Plan_Specific_Fees__c findSub(
    String opportunityGUID,
    String ProductCode,
    Plan_Specific_Fees__c psf,
    SBQQ__Subscription__c sub
  ) {
    if (!NoneBhSubAssetMap.containsKey(ProductCode))
      return null;
    List<noneBhSubAssetWrapper> subAssetList = NoneBhSubAssetMap.get(
      ProductCode
    );
    for (noneBhSubAssetWrapper sa : subAssetList) {
      System.debug('sa wrapper' + sa + '/' + sub);
      Decimal consultFee = 0;
      String assetId;
      if (sa.asset != null) {
        if (sa.asset.Consult_Fees__c == null) {
          consultFee = 0;
        } else {
          consultFee = sa.asset.Consult_Fees__c;
          assetId = sa.asset.Id;
        }
      } else {
        assetId = null;
      }
      system.debug(
        'findsub CF' +
          consultFee +
          '/' +
          psf.Consult_Fee_Mbr_Pd__c +
          psf.Consult_Fee_Plan_Pd__c
      );
      system.debug(
        'findsub FEETYPE' + sa.sub.Fee_Type__c + '/' + sub.Fee_Type__c
      );
      system.debug(
        'findsub crrmemfee' +
          sa.sub.Current_Membership_Fee__c +
          '/' +
          sub.Current_Membership_Fee__c
      );
      if (
        ((opportunityGUID != null && opportunityGUID == sa.oppGUID) ||
        (opportunityGUID == null ||
        opportunityGUID == '')) &&
        sa.sub.Fee_Type__c == sub.Fee_Type__c &&
        sa.sub.Current_Membership_Fee__c == sub.Current_Membership_Fee__c &&
        consultFee == psf.Consult_Fee_Mbr_Pd__c + psf.Consult_Fee_Plan_Pd__c
      ) {
        psf.Subscription__c = sa.sub.Id;
        psf.Asset__c = assetId;
        break;
      }
    }
    if (psf.Subscription__c == null)
      return null;
    else
      return psf;
  }

  public static DateTime parseIsoDate(
    String dateString,
    String key,
    Map<String, String> localErrors
  ) {
    if (dateString == null)
      return null;
    DateTime newDateTime = null;
    try {
      dateString = dateString.replace('T', ' ').substring(0, 19);
      newDateTime = DateTime.valueOfGmt(dateString);
    } catch (Exception ex) {
      localErrors.put('INVALID_DATE_TIME', key + ': ' + ex);
      return null;
    }
    return newDateTime;
  }

  public static Mbr_Group__c wkDate(Mbr_Group__c mbrGroup) {
    if (!mbrGroup.WK_Retroactive__c) {
      mbrGroup.WK_Retroactive_Date__c = null;
      mbrGroup.WK_Send_Card_Date__c = null;
    } else if (
      mbrGroup.WK_Retroactive_Date__c == null ||
      mbrGroup.WK_Send_Card_Date__c == null
    ) {
      mbrGroup.WK_Retroactive__c = false;
      mbrGroup.WK_Retroactive_Date__c = null;
      mbrGroup.WK_Send_Card_Date__c = null;
    }
    return mbrGroup;
  }
}