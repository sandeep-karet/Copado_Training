public without sharing class PostingEntry {
  private Account prnAcct = StaticInfo.AccountInfoFor('UMR');
  private Disclaimers__c tmpDisclaimer = StaticInfo.DisclaimerFor('STND');
  private Web_URLs__c tmpWebUrl = StaticInfo.WebUrlFor('Teladoc.com');

  public AcctGrpConParsing_Item__c sourceData = null;
  private Map<String, String> accountInfo = new Map<String, String>();
  private Map<String, String> groupInfo = new Map<String, String>();
  private Map<String, String> itemDefaults = new Map<String, String>();
  //public List<String> processingNotes = new List<String>();
  public List<AcctGrpConParse_Exception__c> parsingResults = new List<AcctGrpConParse_Exception__c>();
  private ResultData tmpRd = new ResultData();
  public String entryId = null;
  public String orgId = null;
  public String grpId = null;
  private Account refAcct = null;
  public Account tmpAcct = null;
  public Mbr_Group__c tmpGrp = null;
  public List<Mbr_Group_Role__c> tmpMgrls = new List<Mbr_Group_Role__c>();
  public List<Acct_Rel__c> tmpAcctRels = new List<Acct_Rel__c>();
  public Plan_Specific_Fees__c tmpGmPsf = null;
  public Plan_Specific_Fees__c tmpBHP1TPsf = null;
  public Plan_Specific_Fees__c tmpBHPOTPsf = null;
  public Plan_Specific_Fees__c tmpBHNPTPsf = null;
  public Plan_Specific_Fees__c tmpDermPsf = null;
  private List<Contact> tmpContacts = new List<Contact>();
  private Set<String> tmpConEmails = new Set<String>();

  public List<Contact> ValidContacts() {
    List<Contact> tmpCons = new List<Contact>();
    if (tmpAcct.Id != null)
      for (Contact tmpContact : tmpContacts) {
        // TODO: (20171101) ensure that @umr.com assigns user account to UMR and all others to the new account created

        if (tmpContact.email.toUpperCase().contains('@UMR.COM'))
          tmpContact.AccountId = prnAcct.Id;
        else
          tmpContact.AccountId = tmpAcct.Id;
        tmpCons.add(tmpContact);
      }
    return tmpCons;
  }

  public Boolean IsValidAccount() {
    return (orgId != null && grpId != null);
  }
  public Boolean IsValidGroup() {
    if (String.isNotBlank(tmpAcct.Id)) {
      tmpGrp.Client_Account__c = prnAcct.Id;
      return true;
    }
    return false;
  }
  public Boolean AccountExists() {
    return (tmpAcct.Id != null);
  }
  public Boolean GroupExists() {
    System.debug(LoggingLevel.FINER, 'tmpGrp.Id: ' + tmpGrp.Id);
    return (String.isNotBlank(tmpGrp.Id));
  }

  public PostingEntry(AcctGrpConParsing_Item__c tmpAgcpi) {
    sourceData = tmpAgcpi; // Store original data
    entryId = tmpAgcpi.Id;
    PostingData tmpPd = (PostingData) JSON.deserialize(
      tmpAgcpi.Item_Data__c,
      PostingData.class
    );
    accountInfo = tmpPd.accountInfo;
    groupInfo = tmpPd.groupInfo;
    if (!String.isBlank(tmpAgcpi.Item_Defaults__C))
      itemDefaults = (Map<String, String>) JSON.deserialize(
        tmpAgcpi.Item_Defaults__C,
        Map<String, String>.class
      );
    if (accountInfo.containsKey('ORGANIZATION_ID')) {
      orgId = accountInfo.get('ORGANIZATION_ID');
      createException(
        'INFO',
        'ACCOUNT',
        'EMPLOYER GROUP NAME',
        accountInfo.get('EMPLOYER GROUP NAME')
      );
    }
    if (groupInfo.containsKey('LEGACY_GROUP_ID')) {
      grpId = groupInfo.get('LEGACY_GROUP_ID');
      createException(
        'INFO',
        'Mbr_Group__c',
        'UMR_GROUP_EMPLOYER_GROUP_NAME',
        groupInfo.get('UMR_GROUP_EMPLOYER_GROUP_NAME')
      );
    }
    if (accountInfo.containsKey('SPECIAL INSTRUCTIONS'))
      if (String.isNotBlank(accountInfo.get('SPECIAL INSTRUCTIONS')))
        createException(
          'INFO',
          'ACCOUNT',
          'SPECIAL INSTRUCTIONS',
          accountInfo.get('SPECIAL INSTRUCTIONS').left(254)
        );

    // Prepopulate information assuming it is new
    populateAccount();
    populateGroup();
    List<Contact> entryContacts = null;
    entryContacts = ValidateNamesToEmails(
      'MARKETING',
      accountInfo.get('MARKETING SITE CONTACT NAMES'),
      accountInfo.get('MARKETING SITE CONTACT EMAILS'),
      true,
      true
    );
    if (entryContacts.size() > 0)
      tmpContacts.addAll(entryContacts);
    entryContacts = ValidateNamesToEmails(
      'UMR SAE',
      accountInfo.get('UMR SAE NAME'),
      accountInfo.get('UMR SAE EMAIL'),
      true,
      false
    );
    if (entryContacts.size() > 0) {
      if (!String.isBlank(accountInfo.get('UMR SAE PHONE')))
        entryContacts[0].Phone = accountInfo.get('UMR SAE PHONE');
      tmpContacts.addAll(entryContacts);
    }
  }

  public void createException(
    String exType,
    String sObjectName,
    String shortDesc,
    String fullDesc
  ) {
    AcctGrpConParse_Exception__c tmpAgcpe = new AcctGrpConParse_Exception__c();
    tmpAgcpe.Agcpi__c = sourceData.Id;
    tmpAgcpe.Exception_Type__c = exType.trim().toUpperCase();
    tmpAgcpe.sobject__c = sObjectName.trim().toUpperCase();
    tmpAgcpe.Short_Desc__c = shortDesc.trim().toUpperCase();
    if (fullDesc.length() > 255) {
      tmpAgcpe.Full_Desc__c = fullDesc.substring(0, 255);
    } else {
      tmpAgcpe.Full_Desc__c = fullDesc;
    }
    //system.debug(System.LoggingLevel.FINE, tmpAgcpe);
    parsingResults.add(tmpAgcpe);
  }

  public List<Mkt_Site_User__c> generateMsu() {
    // Now for MSU
    List<Mkt_Site_User__c> tmpMsu = new List<Mkt_Site_User__c>();
    for (Contact tmpCon : tmpContacts)
      if (tmpCon.Marketing_Site_User__c && tmpCon.Id != null) {
        tmpMsu.add(
          new Mkt_Site_User__c(Contact__c = tmpCon.Id, Mbr_Group__c = tmpGrp.Id)
        );
      }
    return tmpMsu;
  }
  public List<Plan_Specific_Fees__c> populatePsf(
    Map<String, Id> mappedSubs,
    Map<String, Id> mappedAsset
  ) {
    List<Plan_Specific_Fees__c> newPsfs = new List<Plan_Specific_Fees__c>();
    Decimal GMFee, BHNPTFee, BHPOTFee, BHP1tFee, DermFee;
    for (SBQQ__Subscription__c sub : [
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
    ]) {
      for (Asset asset : sub.SBQQ__ChildAssets__r) {
        switch on asset.Product2.ProductCode {
          when 'GMCF' {
            GMFee = asset.Consult_Fees__c;
          }
          when 'BHNPT' {
            BHNPTFee = asset.Consult_Fees__c;
          }
          when 'BHPOT' {
            BHPOTFee = asset.Consult_Fees__c;
          }
          when 'BHP1T' {
            BHP1tFee = asset.Consult_Fees__c;
          }
          when 'DERMFEE' {
            DermFee = asset.Consult_Fees__c;
          }
        }
      }
    }

    if (mappedSubs.containsKey('GM')) {
      tmpGmPsf = new Plan_Specific_Fees__c();
      tmpGmPsf.Member_Group__c = tmpGrp.Id; //GROUP\ ID=Mbr_Group__c
      tmpGmPsf.Asset__c = mappedAsset.get('GMCF');
      tmpGmPsf.Consult_Fee_Mbr_Pd__c = FetchDecimalFor(
        'MEMBER_CO_PAY',
        groupInfo,
        itemDefaults
      ); // Gen\ Med\ Member\ paid\ visit\ fee
      tmpGmPsf.Consult_Fee_Plan_Pd__c = GMFee - tmpGmPsf.Consult_Fee_Mbr_Pd__c; // Gen\ Med\ Plan\ paid\ visit\ fee
      tmpGmPsf.Product_Start_Date__c = FetchDateFor(
        'TELADOC_BENEFIT_EFFECTIVE_DATE',
        groupInfo,
        itemDefaults
      );
      tmpGmPsf.Subscription__c = mappedSubs.get('GM');
      newPsfs.add(tmpGmPsf);
    }
    if (
      mappedSubs.containsKey('BH') &&
      groupInfo.get('BEHAVIORAL_HEALTH_SERVICE_OFFERING__BH_') == 'Yes'
    ) {
      tmpBHP1TPsf = new Plan_Specific_Fees__c();
      tmpBHP1TPsf.Member_Group__c = tmpGrp.Id;
      tmpBHP1TPsf.Asset__c = mappedAsset.get('BHNPT');
      tmpBHP1TPsf.Subscription__c = mappedSubs.get('BH');
      tmpBHP1TPsf.Product_Start_Date__c = FetchDateFor(
        'BH_SERVICE_OFFERING_EFFECTIVE_START_DATE',
        groupInfo,
        itemDefaults
      );
      tmpBHP1TPsf.Consult_Fee_Mbr_Pd__c = FetchDecimalFor(
        'BH_COUNSELING_VISIT__NON_MD_',
        groupInfo,
        itemDefaults
      ); // BH\ Counseling\ Visit\ (Non-MD)\ -\ Member\ Portion - BH_NON_COUNSELING_VISIT__NON_MD_
      tmpBHP1TPsf.Consult_Fee_Plan_Pd__c =
        BHNPTFee - tmpBHP1TPsf.Consult_Fee_Mbr_Pd__c; // BH\ Counseling\ Visit\ (Non-MD)\ -\ Plan\ \ Portion
      newPsfs.add(tmpBHP1TPsf);

      tmpBHPOTPsf = new Plan_Specific_Fees__c();
      tmpBHPOTPsf.Member_Group__c = tmpGrp.Id;
      tmpBHPOTPsf.Asset__c = mappedAsset.get('BHPOT');
      tmpBHPOTPsf.Subscription__c = mappedSubs.get('BH');
      tmpBHPOTPsf.Product_Start_Date__c = FetchDateFor(
        'BH_SERVICE_OFFERING_EFFECTIVE_START_DATE',
        groupInfo,
        itemDefaults
      );
      tmpBHPOTPsf.Consult_Fee_Mbr_Pd__c = FetchDecimalFor(
        'BH_FOLLOW_ON_VISIT_WITH_PSYCHIATRIST',
        groupInfo,
        itemDefaults
      ); // BH\ Follow-On\ Visit\ with\ Psychiatrist\ -\ \ Member\ portion
      tmpBHPOTPsf.Consult_Fee_Plan_Pd__c =
        BHPOTFee - tmpBHPOTPsf.Consult_Fee_Mbr_Pd__c; // BH\ Follow-On\ Visit\ with\ Psychiatrist\ -\ \ Plan\ \ portion
      newPsfs.add(tmpBHPOTPsf);

      tmpBHNPTPsf = new Plan_Specific_Fees__c();
      tmpBHNPTPsf.Member_Group__c = tmpGrp.Id;
      tmpBHNPTPsf.Asset__c = mappedAsset.get('BHP1T');
      tmpBHNPTPsf.Subscription__c = mappedSubs.get('BH');
      tmpBHNPTPsf.Product_Start_Date__c = FetchDateFor(
        'BH_SERVICE_OFFERING_EFFECTIVE_START_DATE',
        groupInfo,
        itemDefaults
      );
      tmpBHNPTPsf.Consult_Fee_Mbr_Pd__c = FetchDecimalFor(
        'BH_INITIAL_EVAL___MEMBER_PORTION',
        groupInfo,
        itemDefaults
      ); // BH\ Initial\ Eval\ \u2013\ Member\ Portion
      tmpBHNPTPsf.Consult_Fee_Plan_Pd__c =
        BHP1tFee - tmpBHNPTPsf.Consult_Fee_Mbr_Pd__c; // BH\ Initial\ Eval\ \u2013\ Plan\ Portion
      newPsfs.add(tmpBHNPTPsf);
    }
    if (
      mappedSubs.containsKey('DERM') &&
      groupInfo.get('DERMATOLOGY_SERVICE_OFFERING__DERM_') == 'Yes'
    ) {
      tmpDermPsf = new Plan_Specific_Fees__c();
      tmpDermPsf.Member_Group__c = tmpGrp.Id;
      tmpDermPsf.Asset__c = mappedAsset.get('DERMFEE');
      tmpDermPsf.Product_Start_Date__c = FetchDateFor(
        'DERM_SERVICE_OFFERING_EFFECTIVE_START_DATE',
        groupInfo,
        itemDefaults
      );
      tmpDermPsf.Consult_Fee_Mbr_Pd__c = FetchDecimalFor(
        'DERM_VISIT_FEE___MEMBER_PORTION',
        groupInfo,
        itemDefaults
      );
      tmpDermPsf.Consult_Fee_Plan_Pd__c =
        DermFee - tmpDermPsf.Consult_Fee_Mbr_Pd__c; // Derm\ Visit\ Fee\ -\ Plan\ Portion
      tmpDermPsf.Subscription__c = mappedSubs.get('DERM');
      newPsfs.add(tmpDermPsf);
    }
    //newPsf.Actual_Copay_May_Be_Less__c = FetchBooleanFor('ACTUAL_COPAY_MAY_BE_LESS_',groupInfo, itemDefaults);
    if (Test.isRunningTest()) {
      System.debug('MAPPED SUBS:' + mappedSubs);
      System.debug('NEW PSFS[' + newPsfs.size() + '] ' + newPsfs);
    }

    system.debug('psf here ' + newPsfs);
    return newPsfs;
  }
  public void populate_mbr_group_role() {
    // TODO: REFACTOR-Code to reference child record Mbr_Group_Role (2018-11-14)
    Mbr_Group_Role__c tmp_mgrl = new Mbr_Group_Role__c(
      Role_Type__c = 'Benefit Sponsor',
      Source_Account__c = tmpAcct.Id,
      Mbr_Group__c = tmpGrp.Id
    );
    System.debug(
      'MGRL: ' + tmp_mgrl.Mbr_Group__c + '/' + tmp_mgrl.Source_Account__c
    );
    tmpMgrls.add(tmp_mgrl);
  }

  public void populate_acct_rels() {
    tmpAcctRels.add(
      new Acct_Rel__c(
        Svc_Acct__c = prnAcct.Id,
        Benefit_Sponsor__c = tmpAcct.Id,
        Relationship_Type__c = 'Contractee',
        Contract_Type__c = 'Insurance',
        Line_of_Business__c = 'Commercial_Administrative_Services_Only_ASO',
        Start_Date__c = FetchDateFor(
          'TELADOC_BENEFIT_EFFECTIVE_DATE',
          groupInfo,
          itemDefaults
        )
      )
    );
  }
  private void populateAccount() {
    List<String> mappedAccountInfo = new List<String>{
      'Employer Group Name::Name',
      'ORGANIZATION_ID::OrgId__c',
      'Special Instructions::Special_Instructions_for_Implementatio__c',
      'Employer Group Name::Account_Legal_Name__c',
      'Report Recipient Emails::Report_Recipient_emails__c',
      'Employer Group State::BillingState',
      'EMPLOYER GROUP ADDRESS LINE 1::BillingStreet',
      'Total Employees Count::NumberOfEmployees',
      'Total Lives Count::Members__c',
      'Employer Group Zip::BillingPostalCode',
      'Employer Group City::BillingCity',
      'Account Status::Type',
      //'EMPLOYER GROUP CONTACT PHONE::Phone',
      //'Third-Party Eligibility File Source::Eligibility_File_Source__c', // TODO: Enable (20171101)
      'Utilization Report Level::Utilization_Reporting_Level__c',
      'Employer Flag::Account_Type__c',
      //'Account Mgr::Account_Manager__c', // TODO: Enable
      'Company Tags::Company_Tags__c'
    };
    Account newAcct = new Account();
    populateSObject(
      'Account',
      (SObject) newAcct,
      accountInfo,
      itemDefaults,
      mappedAccountInfo
    );
    newAcct.Eligibility_File_Source__c = prnAcct.Id;
    newAcct.Source__c = 'HUB';
    //newAcct.ParentId = prnAcct.Id;
    tmpAcct = newAcct;
  }

  private void populateGroup() {
    List<String> mappedGroupInfo = new List<String>{
      'Logo Tag Id::Logo_Tag_ID__c',
      //'Teladoc_Benefit_Effective_Date::Active_Date__c',
      'LEGACY_GROUP_ID::Group_Number__c',
      'ACTUAL_COPAY_MAY_BE_LESS_::Actual_Copay_May_Be_Less__c',
      'Benefit_Plan_Name::Name__c',
      'Letter Type::Shipping_Class__c',
      'Company Tags::Other_Company_Names__c',
      //'Print URL::URL_for_Custom_WK_LU__c', // TODO: Enabled (20171101)
      //'Card Fulfilment Name::Card_Name__c',
      'Welcome Kit - Custom?::Welcome_Kit__c',
      //'Disclaimer - Teladoc::Disclaimer_Teladoc__c', // TODO: Enable (20171101)
      'Status-Grp Obj::Status__c',
      'Card Issued To::WK_Mail_to__c',
      'Co-Brand with Logo::Co_Brand_with_Logo__c',
      //'ASO/TPA::ASO_TPA__c', // TODO: Enable (20171101)
      'Consult Billing Method::Consult_Billing_Method__c',
      'Communication Mode::Communication_Mode__c',
      'WK Card Includes Logo?::WK_Card_Includes_Logo__c',
      'WK Language::Language__c',
      'Card Template::Card_Template__c',
      //'Employer Sponsor for Group::Employer_Plan_Sponsor_for_Mbr_Group__c',
      'Allow Conversion to Retail::Allow_conversion_to_retail__c',
      'Caregiver Program::Allow_Caregiver_Program__c',
      'Print Phone::Phone__c',
      'ELIGIBLITY FILES SENT BY::Eligibility_File_Source__c', // TODO: Enable : Map to ACCOUNT/TPA
      //'Eligibility Option::Eligibility_Option__c',
      'WK Template::WK_Template__c',
      'WK - Includes Insert?::WK_Includes_MHD_Insert__c',
      'Allow Sexual Health::Sexual_Health_Opt_Out__c',
      'Send CCR to PCP::CCR_CCDA__c',
      'MK_IDCARDFRONT1::MK_Idcardfront1__c'
    };
    Mbr_Group__c newGrp = new Mbr_Group__c();
    SObject tmpObj = (SObject) newGrp;
    populateSObject(
      'Mbr_Group__c',
      tmpObj,
      groupInfo,
      itemDefaults,
      mappedGroupInfo
    );
    //newGrp.GroupOpp__c
    newGrp.Eligibility_File_Source__c = prnAcct.Id;
    newGrp.URL_for_Custom_WK_LU__c = tmpWebUrl.Id;
    newGrp.Card_Name__c = tmpAcct.Name;
    newGrp.Disclaimer_Teladoc__c = tmpDisclaimer.Id;
    newGrp.Client_Account__c = prnAcct.Id;
    newGrp.Allow_Geo_Fencing__c = true;
    newGrp.Active_Date__c = Date.today();
    // TODO: FIXME ASAP - tweak data to fix dependent fields
    if (
      groupInfo.containsKey('ACTUAL_COPAY_MAY_BE_LESS_') &&
      groupInfo.get('ACTUAL_COPAY_MAY_BE_LESS_').toUpperCase() == 'YES'
    )
      newGrp.Actual_Copay_May_Be_Less__c = true;
    else
      newGrp.Actual_Copay_May_Be_Less__c = false;

    if (
      accountInfo.get('IS THE EMPLOYER GROUP ON IVR BYPASS?').toUpperCase() ==
      'YES'
    )
      newGrp.Eligibility_Option__c = 'Staged Eligibility';
    else
      newGrp.Eligibility_Option__c = 'Staged Eligibility & RTE';
    tmpGrp = newGrp;
  }
  private void populateSObject(
    String tmpObjectName,
    SObject tmpObj,
    Map<String, String> tmpInfo,
    Map<String, String> tmpDefaults,
    List<String> tmpMappings
  ) {
    //system.debug(System.LoggingLevel.FINER, tmpObjectName + '::' + tmpInfo.size() + '::' + tmpDefaults.size() + '::' + tmpMappings.size());
    for (String tmpKvp : tmpMappings) {
      String[] kvpStrings = tmpKvp.split('::');
      String dstFieldName = kvpStrings[1];
      String tmpKey = kvpStrings[0];
      String fieldTypeName = ObjectInfo.TypeForField(
        tmpObjectName,
        dstFieldName
      );
      //system.debug(System.LoggingLevel.FINER, 'dstFieldName:' + dstFieldName + ' / ' + 'fieldTypeName:' + fieldTypeName);
      //System.debug(System.LoggingLevel.DEBUG,'('+ tmpObjectName + '/'+ dstFieldName + ')-ftn: ' + fieldTypeName + ', tmpKey: ' + tmpKey + ', tmpInfo: ' + tmpInfo);
      if (fieldTypeName == 'STRING' || fieldTypeName == 'ID') {
        tmpObj.put(dstFieldName, FetchValueFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }
      if (fieldTypeName == 'BOOLEAN') {
        tmpObj.put(dstFieldName, FetchBooleanFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }
      if (fieldTypeName == 'DATE') {
        tmpObj.put(dstFieldName, FetchDateFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }
      if (fieldTypeName == 'INTEGER') {
        tmpObj.put(dstFieldName, FetchIntegerFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }
      if (fieldTypeName == 'DECIMAL') {
        tmpObj.put(dstFieldName, FetchDecimalFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }
      if (fieldTypeName == 'DOUBLE') {
        tmpObj.put(dstFieldName, FetchDoubleFor(tmpKey, tmpInfo, tmpDefaults));
        continue;
      }

      system.debug(
        LoggingLevel.FINEST,
        dstFieldName + '::' + fieldTypeName + '::TYPE NOT FOUND'
      );
    }
  }
  private Integer FetchIntegerFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    String tmpVal = FetchValueFor(fieldName, tmpPd, tmpDefaults);
    if (String.IsBlank(tmpVal))
      return 0;
    else
      return Integer.valueOf(tmpVal);
  }
  private Decimal FetchDoubleFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    String tmpVal = FetchValueFor(fieldName, tmpPd, tmpDefaults);
    if (String.IsBlank(tmpVal))
      return 0;
    else
      return Double.valueOf(tmpVal);
  }
  private Decimal FetchDecimalFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    String tmpVal = FetchValueFor(fieldName, tmpPd, tmpDefaults);
    if (String.IsBlank(tmpVal))
      return 0;
    else
      return Decimal.valueOf(tmpVal);
  }
  private Boolean FetchBooleanFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    String tmpVal = FetchValueFor(fieldName, tmpPd, tmpDefaults);
    if (String.IsBlank(tmpVal))
      return false;
    else
      return Boolean.valueOf(tmpVal);
  }
  private Date FetchDateFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    String tmpVal = FetchValueFor(fieldName, tmpPd, tmpDefaults);
    if (String.IsBlank(tmpVal))
      return null;
    if (tmpVal.contains('/')) {
      String[] date_parts = tmpVal.split('/');
      Date newDate = Date.newInstance(
        Integer.valueOf(date_parts[2]),
        Integer.valueOf(date_parts[0]),
        Integer.valueOf(date_parts[1])
      );
      return newDate;
    } else
      return Date.valueOf(tmpVal);
  }
  private String FetchValueFor(
    String fieldName,
    Map<String, String> tmpPd,
    Map<String, String> tmpDefaults
  ) {
    string tmpValue = null;
    String tmpFieldName = fieldName.toUpperCase();

    // If we were provided the value return it
    if (tmpPd.containsKey(tmpFieldName)) {
      String tmpString = tmpPd.get(tmpFieldName);
      //system.debug('Value for ' + tmpFieldName + '='+ tmpString);
      return tmpString.trim();
    }
    // If defaults has the value return it
    if (tmpDefaults != null && tmpDefaults.containsKey(tmpFieldName)) {
      String tmpString = tmpDefaults.get(tmpFieldName);
      //system.debug('Default for ' + tmpFieldName + '='+ tmpString);
      return tmpString.trim();
    }
    // Otherwise return null
    system.debug(
      System.LoggingLevel.FINEST,
      'Value for ' + tmpFieldName + '= NULL'
    );
    return tmpValue;
  }
  private List<Contact> ValidateNamesToEmails(
    String contextPrefix,
    String names,
    String emails,
    Boolean createContacts,
    Boolean isMarketing
  ) {
    List<Contact> resultingContacts = new List<Contact>();
    // Holds all errors found during parsing
    List<String> errorsFound = new List<String>();
    Boolean validRptRecipients = true;

    // Process Report Recipients
    if (String.isBlank(names) || String.isBlank(emails))
      validRptRecipients = false;
    String[] rptNames = names.split(';');
    String[] rptEmails = emails.split(';');

    // Did we get an email for each name
    Integer nameCnt = rptNames.size();
    Integer emailCnt = rptEmails.size();
    if (nameCnt != emailCnt) {
      createException(
        'ERROR',
        'CONTACT',
        'NAME_VS_EMAIL_COUNT',
        contextPrefix +
          ': ' +
          rptNames.size() +
          ' [' +
          names +
          '] vs ' +
          rptEmails.size() +
          ' [' +
          emails +
          '] (CHECK FOR COMMAS)'
      );
    }
    if ((validRptRecipients) && (nameCnt == emailCnt)) {
      // Do the names match the order of the emails provided
      Integer offsetCounter = 0;
      for (String tmpName : rptNames) {
        tmpName = tmpname.trim().toUpperCase();
        String tmpEmail = rptEmails[offsetCounter++].toUpperCase().trim();

        List<String> nameParts = new List<String>();
        for (String tmpNp : tmpName.split(' '))
          nameParts.add(tmpNp.trim());
        System.Debug(System.LoggingLevel.FINEST, 'Name Parts: ' + nameParts);
        boolean possibleMatch = false;

        for (String tmpNp : nameParts) {
          if (tmpNp.length() > 1) {
            if (tmpEmail.contains(tmpNp.Trim()))
              possibleMatch = true;
          }
        }
        if (!possibleMatch) {
          createException(
            'ERROR',
            'CONTACT',
            'NAME_VS_EMAIL_ADDR',
            contextPrefix +
              ': ' +
              'No part of the name [' +
              tmpName +
              '] is contained within email the address [' +
              tmpEmail +
              '].'
          );
        }
        if (
          possibleMatch &&
          createContacts &&
          !tmpConEmails.contains(tmpEmail)
        ) {
          tmpConEmails.add(tmpEmail);
          Contact newCon = new Contact(
            email = tmpEmail,
            Marketing_Site_User__c = isMarketing,
            FirstName = '',
            LastName = ''
          );
          Boolean firstName = true;
          String tmpFirstName = '';
          String tmpLastName = '';
          for (String tmpNp : nameParts)
            if (firstName) {
              newCon.FirstName = tmpNp;
              firstName = false;
            } else
              newCon.LastName += tmpNp;
          newCon.LastName = newCon.LastName.trim();
          resultingContacts.add(newCon);
        }
      }
    }
    return resultingContacts;
  }
}