@IsTest
private class UmrUploadService_Test {
  @TestSetup
  static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Product2> cpq_prods = new List<Product2>();
    Product2 prod_gm = new Product2(name = 'General Medical');
    Product2 prod_bh = new Product2(name = 'Behavioral Health Care');
    Product2 prod_derm = new Product2(name = 'Dermatology');

    Database.insert(new List<SObject>{ prod_gm, prod_bh, prod_derm });

    Account tmpAcct = new Account(
      Name = 'UMR',
      Account_Legal_Name__c = 'UMR',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA'
    );

    insert tmpAcct;
    List<SBQQ__Subscription__c> umr_subs = new List<SBQQ__Subscription__c>();
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2h60000001Rxg6AAC',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_gm.Id,
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0CAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_bh.Id,
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0DAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_derm.Id,
        SBQQ__Quantity__c = 100
      )
    );
    insert umr_subs;
    Disclaimers__c tmpDisclaimer = new Disclaimers__c(
      Name = 'STND',
      Disclaimer_Language__c = '© 2019 Teladoc Health, Inc. All rights reserved. Teladoc and the Teladoc logo are registered trademarks of Teladoc Health, Inc. and may not be used without written permission. Teladoc does not replace the primary care physician. Teladoc does not guarantee that a prescription will be written. Teladoc operates subject to state regulation and may not be available in certain states. Teladoc does not prescribe DEA controlled substances, non therapeutic drugs and certain other drugs which may be harmful because of their potential for abuse. Teladoc physicians reserve the right to deny care for potential misuse of services.'
    );
    insert tmpDisclaimer;

    Web_URLs__c tmpUrL = new Web_URLs__c(Name = 'Teladoc.com');
    insert tmpUrL;
  }

  @IsTest
  static void testFetchStatus() {
    Test.startTest();
    UmrUploadService.fetchStatus();
    Test.stopTest();
    system.assertEquals('Still queued.', UmrUploadService.fetchStatus());
  }

  @IsTest
  static void testSumbitData() {
    Integer queuedItems = [SELECT COUNT() FROM AcctGrpConParsing_Item__c];
    String incomingData = '[{"groupInfo":{"LEGACY_GROUP_ID":"176264","PATH":"949","ITEM_TYPE":"Ready","MODIFIED_BY":"Slamka, Tiffany A.","MODIFIED":"2018-10-31 12:56:58.000","BH_COUNSELING_VISIT__NON_MD_":"85","BH_FOLLOW_ON_VISIT_WITH_PSYCHIATRIST":"95","BH_INITIAL_EVAL___MEMBER_PORTION":"200","BH_SERVICE_OFFERING_EFFECTIVE_START_DATE":"2019-01-01","BEHAVIORAL_HEALTH_SERVICE_OFFERING__BH_":"Yes","DERM_VISIT_FEE___MEMBER_PORTION":"75","DERM_SERVICE_OFFERING_EFFECTIVE_START_DATE":"2019-01-01","DERMATOLOGY_SERVICE_OFFERING__DERM_":"Yes","ACTUAL_COPAY_MAY_BE_LESS_":"Yes","MEMBER_CO_PAY":"45","GEN_MED_SERVICE_OFFERING_EFFECTIVE_START_DATE":"2019-01-01","GENERAL_MEDICAL_SERVICE_OFFERING":"Yes","TELADOC_BENEFIT_EFFECTIVE_DATE":"2019-01-01","BENEFIT_PLAN_NAME":"Net Jets, Inc QHDHP","BENEFIT_PLANS__BP_":"003; 004; 005; 006; 007","CLASS_CODES":"A03; A04; A05; A06; A07; C03; C04; C05; C06; C07","PLAN_NUMBER___POLICY_NUMBER___PLAN_CONTRACT":"7670-00-413588","UMR_GROUP_EMPLOYER_GROUP_NAME":"NetJets, Inc.","UMR_GROUP__":"76-413588"},"groupId":"176264","accountInfo":{"ORGANIZATION_ID":"75249","PATH":"sites/UMRT/Lists/Employer Groups","ITEM TYPE":"Item","ANCILLARY SOLUTIONS USE ONLY":"Ready","ID":"949","MARKETING SITE CONTACT EMAILS":"amy.paul@umr.com;dlash@netjets.com;ctrivanovich@netjets.com;kgausepohl@netjets.com;lblessing@ejmjets.com;mromero@netjets.com;heather.heywood@mercer.com;caroline.susie@mercer.com;nicole.fernholz@mercer.com;joe.harten@mercer.com","MARKETING SITE CONTACT NAMES":"Amy Paul;Donna Lash;Charity Trivanovich;Katie Gausepohl;Linda Blessing;Marla Romero;Heather Heywood;Caroline Susie;Nicole Fernholz;Joe Harten","REPORT RECIPIENT EMAILS":"","REPORT RECIPIENT NAMES":"","IS THE EMPLOYER GROUP ON IVR BYPASS?":"No","SPECIAL INSTRUCTIONS":"Group needs 2 tags and instructions for call center to look under 2 names - NetJets, Inc. and Executive Jet Management (EJM) - Logos need to be seperated and this has been confirmed capable by Teladoc.  Benefit Plans 001-007 should be the logo that is named NetJets, Inc.  Benefit Plans 008-012 should be the logo that is named NetJets, Inc EMJ","GROUP PEPM FEE":"0","BROKER / CONSULTANT CONTACT EMAIL":"nicole.fernholz@mercer.com","BROKER / CONSULTANT CONTACT NAME":"Nicole Fernholz","BROKER / CONSULTANT COMPANY NAME":"Mercer","TOTAL EMPLOYEES COUNT":"4947","TOTAL LIVES COUNT":"13500","UMR SAE EMAIL":"patti.anderson@umr.com","UMR SAE PHONE":"513-619-3106","UMR SAE NAME":"Patti Anderson","EMPLOYER GROUP ZIP":"43219","EMPLOYER GROUP STATE":"OH","EMPLOYER GROUP CITY":"Columbus","EMPLOYER GROUP ADDRESS LINE 2":"","EMPLOYER GROUP ADDRESS LINE 1":"4151 Bridgeway Avenue","EMPLOYER GROUP CONTACT EMAIL":"dgerbec@netjets.com","EMPLOYER GROUP CONTACT PHONE":"614 849 7374","EMPLOYER GROUP CONTACT NAME":"Dan Gerbec","TELADOC EFFECTIVE START DATE":"2019-01-01","EMPLOYER GROUP NAME":"NetJets, Inc.","UMR GROUP #":"76-413588","COMPANY/TPA":"UMR"}}]';
    String fieldDefaultData = '{"EMPLOYER SPONSOR FOR GROUP":"","COMPANY/TPA":"UMR","EMPLOYER FLAG":"Employer","CARD LOGO FLAG":"TRUE","CARD FULFILMENT NAME":"","COMPANY TAGS":"","CARD ISSUED TO":"Member","WK LANGUAGE":"English","WK - INCLUDES INSERT?":"FALSE","WELCOME KIT - CUSTOM?":"FALSE","WK TEMPLATE":"10E100","LETTER TYPE":"S","PRINT URL":"a1Jf40000031QXoEAM","PRINT PHONE":"1-800-Teladoc","SEND WELCOMEKIT CARD FLAG":"No","UTILIZATION REPORT LEVEL":"Company","REPORT TYPE":"Large Health Plan Utilization","REPORT VERSION":"Standard_GM","SALES REP":"Jay Helmer","ACCOUNT MGR":"Rebecca Schulz","GROUP TYPE":"Company","PRIMARY MEMBER FEE":"0","PRIMARY COMPANY FEE":"0","PRIMARY MINIMUM AGE":"18","DEPENDENT MEMBER FEE":"0","DEPENDENT COMPANY FEE":"0","DEPENDENT MINIMUM AGE":"0","WEB ACCESS":"Yes","SEND CCR TO PCP":"No","DISABLE PATIENT EXCUSE NOTE":"No","ALLOW CONVERSION TO RETAIL":"FALSE","VIP MEMBERS":"No","CAREGIVER PROGRAM":"FALSE","ALLOW SEXUAL HEALTH":"FALSE","ELIGIBILITY TYPE":"Auto","ELIGIBLITY FILES SENT BY":"Third-party provided Eligibility File","THIRD-PARTY ELIGIBILITY FILE SOURCE":"001f400000dGS7yAAG","CONSULT BILLING METHOD":"Claims","ADD/UPDATE/DELETE TIMESTAMP":"Default/Provided from SharePoint modified date","CARD TEMPLATE":"Logo Card","CO-BRAND WITH LOGO":"Yes","COMMUNICATION MODE":"Default","DISCLAIMER - CLIENT":"a1Ff4000001IIPKEA4","DISCLAIMER - TELADOC":"a1Ff4000001IIPKEA4","ASO/TPA":"001f400000dGS7yAAG","STATUS-GRP OBJ":"Active","WK CARD INCLUDES LOGO?":"TRUE","ACCOUNT STATUS":"Customer","ELIGIBILITY OPTION":"","MK_IDCARDFRONT1":"IDF1_NoUserID"}';
    Test.startTest();
    UmrUploadService.submitData(incomingData, fieldDefaultData);
    Test.stopTest();
    Integer queuedItems2 = [SELECT COUNT() FROM AcctGrpConParsing_Item__c];
    system.assertNotEquals(queuedItems2, queuedItems);
    system.assertNotEquals(
      null,
      UmrUploadService.submitData(incomingData, fieldDefaultData)
    );
  }

  @IsTest
  static void testE2E() {
    AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c();
    agcpi.Batch_Key__c = '1561491697487';
    agcpi.CurrencyIsoCode = 'USD';
    agcpi.Item_Data__c = '{"groupInfo":{"LEGACY_GROUP_ID":"304735","PATH":"2038","ITEM_TYPE":"Ready","MODIFIED_BY":"Slamka, Tiffany A.","MODIFIED":"2020-02-19 15:41:31.000","BH_COUNSELING_VISIT__NON_MD_":"85","BH_FOLLOW_ON_VISIT_WITH_PSYCHIATRIST":"95","BH_INITIAL_EVAL___MEMBER_PORTION":"200","BH_SERVICE_OFFERING_EFFECTIVE_START_DATE":"","BEHAVIORAL_HEALTH_SERVICE_OFFERING__BH_":"No","DERM_VISIT_FEE___MEMBER_PORTION":"75","DERM_SERVICE_OFFERING_EFFECTIVE_START_DATE":"2020-04-01","DERMATOLOGY_SERVICE_OFFERING__DERM_":"Yes","ACTUAL_COPAY_MAY_BE_LESS_":"Yes","MEMBER_CO_PAY":"45","GEN_MED_SERVICE_OFFERING_EFFECTIVE_START_DATE":"2020-04-01","GENERAL_MEDICAL_SERVICE_OFFERING":"Yes","TELADOC_BENEFIT_EFFECTIVE_DATE":"2020-04-01","BENEFIT_PLAN_NAME":"Adena Corporation QHDHP","BENEFIT_PLANS__BP_":"003","CLASS_CODES":"A03; C03","PLAN_NUMBER___POLICY_NUMBER___PLAN_CONTRACT":"7670-00-414453","UMR_GROUP_EMPLOYER_GROUP_NAME":"Adena Corporation","UMR_GROUP__":"76-414453"},"groupId":"304735","accountInfo":{"ORGANIZATION_ID":"203524","PATH":"sites/UMRT/Lists/Employer Groups","ITEM TYPE":"Item","ANCILLARY SOLUTIONS USE ONLY":"Ready","ID":"2038","MARKETING SITE CONTACT EMAILS":"mpangborn@adenacorporation.com","MARKETING SITE CONTACT NAMES":"Melody Pangborn","REPORT RECIPIENT EMAILS":"","REPORT RECIPIENT NAMES":"","IS THE EMPLOYER GROUP ON IVR BYPASS?":"No","SPECIAL INSTRUCTIONS":"","GROUP PEPM FEE":"0","BROKER / CONSULTANT CONTACT EMAIL":"Laura.Emberger@Hylant.com","BROKER / CONSULTANT CONTACT NAME":"Laura Emberger","BROKER / CONSULTANT COMPANY NAME":"Hylant","TOTAL EMPLOYEES COUNT":"276","TOTAL LIVES COUNT":"415","UMR SAE EMAIL":"kelly.tamerlano@umr.com","UMR SAE PHONE":"614-698-3639","UMR SAE NAME":"Kelly Tamerlano","EMPLOYER GROUP ZIP":"44906","EMPLOYER GROUP STATE":"OH","EMPLOYER GROUP CITY":"Mansfield","EMPLOYER GROUP ADDRESS LINE 2":"","EMPLOYER GROUP ADDRESS LINE 1":"1310 West Fourth Street","EMPLOYER GROUP CONTACT EMAIL":"mpangborn@adenacorporation.com","EMPLOYER GROUP CONTACT PHONE":"419-529-4456 x228","EMPLOYER GROUP CONTACT NAME":"Melody Pangborn","TELADOC EFFECTIVE START DATE":"2020-04-01","EMPLOYER GROUP NAME":"Adena Corporation","UMR GROUP #":"76-414453","COMPANY/TPA":"UMR"}}	';
    agcpi.Item_Defaults__c = '{"EMPLOYER SPONSOR FOR GROUP":"","COMPANY/TPA":"UMR","EMPLOYER FLAG":"Employer","CARD LOGO FLAG":"TRUE","CARD FULFILMENT NAME":"","COMPANY TAGS":"","CARD ISSUED TO":"Member","WK LANGUAGE":"English","WK - INCLUDES INSERT?":"FALSE","WELCOME KIT - CUSTOM?":"FALSE","WK TEMPLATE":"10E100","LETTER TYPE":"S","PRINT URL":"a1Jf40000031QXoEAM","PRINT PHONE":"1-800-Teladoc","SEND WELCOMEKIT CARD FLAG":"No","UTILIZATION REPORT LEVEL":"Company","REPORT TYPE":"Large Health Plan Utilization","REPORT VERSION":"Standard_GM","SALES REP":"Jay Helmer","ACCOUNT MGR":"Rebecca Schulz","GROUP TYPE":"Company","PRIMARY MEMBER FEE":"0","PRIMARY COMPANY FEE":"0","PRIMARY MINIMUM AGE":"18","DEPENDENT MEMBER FEE":"0","DEPENDENT COMPANY FEE":"0","DEPENDENT MINIMUM AGE":"0","WEB ACCESS":"Yes","SEND CCR TO PCP":"No","DISABLE PATIENT EXCUSE NOTE":"No","ALLOW CONVERSION TO RETAIL":"FALSE","VIP MEMBERS":"No","CAREGIVER PROGRAM":"FALSE","ALLOW SEXUAL HEALTH":"FALSE","ELIGIBILITY TYPE":"Auto","ELIGIBLITY FILES SENT BY":"Third-party provided Eligibility File","THIRD-PARTY ELIGIBILITY FILE SOURCE":"001f400000dGS7yAAG","CONSULT BILLING METHOD":"Claims","ADD/UPDATE/DELETE TIMESTAMP":"Default/Provided from SharePoint modified date","CARD TEMPLATE":"Logo Card","CO-BRAND WITH LOGO":"Yes","COMMUNICATION MODE":"Default","DISCLAIMER - CLIENT":"a1Ff4000001IIPKEA4","DISCLAIMER - TELADOC":"a1Ff4000001IIPKEA4","ASO/TPA":"001f400000dGS7yAAG","STATUS-GRP OBJ":"Active","WK CARD INCLUDES LOGO?":"TRUE","ACCOUNT STATUS":"Customer","ELIGIBILITY OPTION":"","MK_IDCARDFRONT1":"IDF1_NoUserID"}';
    agcpi.Item_Key__c = '271459';
    agcpi.Source__c = 'UMR';
    insert agcpi;
    String result = UmrUploadService.umr_E2E();
    system.assertNotEquals('No Unprocessed UMR Record Found', result);
  }
}