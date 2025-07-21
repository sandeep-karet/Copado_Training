@IsTest
public class F1bMbrGrp_Test {
  @TestSetup
  static void setup() {
    F1bp_Test.setup();
    Account acct = new Account();
    acct.Name = 'DOGANDCATCORP';
    acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    acct.Friendly_Account_Name__c = 'TestAmendAccount';
    acct.Source__c = 'HUB';
    acct.CurrencyIsoCode = 'USD';
    acct.Business_Region__c = 'USA';
    acct.Account_Type__c = 'Health Plan';
    acct.GUID__c = '45691c15-0a24-4798-ad76-e0af7085aa46';
    insert acct;

    Mbr_Group__c grp = new Mbr_Group__c();
    grp.Name__c = 'test';
    grp.GUID__c = '989f91c6-2535-4d3c-b44c-c386dab17e88';
    grp.Client_Account__c = acct.Id;
    grp.OneAppAccess__c = 'Yes';
    insert grp;
  }
  @isTest
  public static void grpUpdateTest() {
    Test.startTest();
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
     FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg.ephMbrGroup.Group_Number__c = '1314123';
    f1bp.f1bmg.ephMbrGroup.Name__c = 'NO KITTY COMPANY PPO';
    f1bp.f1bmg.ephMbrGroup.Active_Date__c = Date.parse('12/6/2020');
    f1bp.f1bmg.ephMbrGroup.Termination_Date__c = Date.parse('11/6/2028');
    f1bp.f1bmg.ephMbrGroup.Card_Name__c = 'test';
    f1bp.f1bmg.ephMbrGroup.Allow_Conversion_To_Retail__c = true;
    f1bp.f1bmg.ephMbrGroup.Allow_Caregiver_Program__c = true;
    f1bp.f1bmg.ephMbrGroup.Sexual_Health_Opt_Out__c = true;
    f1bp.f1bmg.ephMbrGroup.Consult_Billing_Method__c = 'Invoice';
    f1bp.f1bmg.ephMbrGroup.Status__c = 'ACTIVE';
    f1bp.f1bmg.ephMbrGroup.Eligibility_Option__c = 'Open';
    f1bp.f1bmg.ephMbrGroup.Shipping_Class__c = 'S';
    f1bp.f1bmg.ephMbrGroup.Logo_Tag_ID__c = '';
    f1bp.f1bmg.ephMbrGroup.Elig_Dep_Inc_In_File__c = true;
    f1bp.f1bmg.ephMbrGroup.Service_Brand__c = 'Teladoc (US)';
    f1bp.f1bmg.ephMbrGroup.Eligibility_Option__c = 'Open';
    f1bp.f1bmg.ephMbrGroup.Wk_Template__c = '10C100_HF';
    f1bp.f1bmg.ephMbrGroup.Wk_Retroactive__c = true;
    f1bp.f1bmg.ephMbrGroup.Wk_Send_Card_Date__c = Date.parse('12/6/2020');
    f1bp.f1bmg.ephMbrGroup.Wk_Retroactive_Date__c = Date.parse('12/6/2020');
    f1bp.f1bmg.ephMbrGroup.Wk_Card_Includes_Logo__c = true;
    f1bp.f1bmg.ephMbrGroup.Wk_Mail_To__c = 'Member';
    f1bp.f1bmg.ephMbrGroup.Wk_Includes_Insert__c = true;
    f1bp.f1bmg.ephMbrGroup.Card_Template__c = 'STND Card';
    f1bp.f1bmg.ephMbrGroup.Co_Brand_With_Logo__c = 'Yes';
    f1bp.f1bmg.ephMbrGroup.Communication_Mode__c = 'By phone';
    f1bp.f1bmg.ephMbrGroup.Mk_IdcardFront1__c = 'IDF1_Covered_txt';
    f1bp.f1bmg.ephMbrGroup.Allow_Geo_Fencing__c = false;
    f1bp.f1bmg.ephMbrGroup.OneAppAccess__c = 'Yes';
    f1bp.f1bmg.f1bpwk.DisclaimerClient = null;
    f1bp.f1bmg.f1bpwk.DisclaimerTeladoc = null;

    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    Mbr_Group__c updateGrp = [
      SELECT
        Group_Number__c,
        Name__c,
        Active_Date__c,
        Termination_Date__c,
        Card_Name__c,
        Allow_Conversion_To_Retail__c,
        Allow_Caregiver_Program__c,
        Sexual_Health_Opt_Out__c,
        Consult_Billing_Method__c,
        Status__c,
        Eligibility_Option__c,
        Shipping_Class__c,
        Wk_Template__c,
        Wk_Retroactive__c,
        Wk_Send_Card_Date__c,
        Wk_Retroactive_Date__c,
        Wk_Card_Includes_Logo__c,
        Wk_Mail_To__c,
        Wk_Includes_Insert__c,
        Card_Template__c,
        Co_Brand_With_Logo__c,
        Communication_Mode__c,
        Mk_IdcardFront1__c,
        Disclaimer_client__c,
        Disclaimer_Teladoc__c,
        Allow_Geo_Fencing__c,
        OneAppAccess__c,
        Logo_Tag_ID__c,
        Service_Brand__c,
        Elig_Dep_Inc_In_File__c
      FROM Mbr_Group__c
      WHERE Guid__c = :f1bp.f1bmg.ephMbrGroup.Guid__c
    ];
    System.assertEquals('1314123', updateGrp.Group_Number__c);
    System.assertEquals('NO KITTY COMPANY PPO', updateGrp.Name__c);
    System.assertEquals('test', updateGrp.Card_Name__c);
    //System.assertEquals(True, updateGrp.Allow_Conversion_To_Retail__c);
    //System.assertEquals(True, updateGrp.Allow_Caregiver_Program__c);
    //System.assertEquals(True, updateGrp.Sexual_Health_Opt_Out__c);
    System.assertEquals('Invoice', updateGrp.Consult_Billing_Method__c);
    System.assertEquals('ACTIVE', updateGrp.Status__c);
    System.assertEquals('Open', updateGrp.Eligibility_Option__c);
    System.assertEquals('S', updateGrp.Shipping_Class__c);
    System.assertEquals('10C100_HF', updateGrp.Wk_Template__c);
    //System.assertEquals(True, updateGrp.Wk_Retroactive__c);
  //  System.assertEquals(    '2020-12-06 00:00:00', string.valueOfGmt(updateGrp.Wk_Send_Card_Date__c));
    //System.assertEquals('2020-12-06 00:00:00',string.valueOfGmt(updateGrp.Wk_Retroactive_Date__c) );
    //System.assertEquals(True, updateGrp.Wk_Card_Includes_Logo__c);
    System.assertEquals('Member', updateGrp.Wk_Mail_To__c);
    //System.assertEquals(True, updateGrp.Wk_Includes_Insert__c);
    System.assertEquals('STND Card', updateGrp.Card_Template__c);
    System.assertEquals('Yes', updateGrp.Co_Brand_With_Logo__c);
    System.assertEquals('By phone', updateGrp.Communication_Mode__c);
    System.assertEquals('IDF1_Covered_txt', updateGrp.Mk_IdcardFront1__c);
    System.assertEquals(true, updateGrp.Elig_Dep_Inc_In_File__c);
    System.assertEquals('Yes', updateGrp.OneAppAccess__c);
    System.assertEquals(null, updateGrp.Logo_Tag_ID__c);
    System.assertEquals('Teladoc (US)', updateGrp.Service_Brand__c);
    //System.assertEquals(False, updateGrp.Allow_Geo_Fencing__c);
    Test.stopTest();
  }
  @isTest
  public static void falseGroupGuidTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg.ephMbrGroup.guid__c = 'this-is-a-bad-guid';
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(true, isParentGuidFalse);
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    Boolean isError = false;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      if (agcpe.Short_Desc__c == 'INVALID_GROUP_GUID') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }
  @isTest
  public static void nullDisclaimerTest() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg.f1bpwk.DisclaimerClient = null;
    f1bp.f1bmg.f1bpwk.DisclaimerTeladoc = null;
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(true, isParentGuidFalse);
    Test.stopTest();
  }
  @isTest
  public static void inValidDisclaimerTest() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg.f1bpwk.DisclaimerClient = 'test';
    f1bp.f1bmg.f1bpwk.DisclaimerTeladoc = null;
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(false, isParentGuidFalse);
    Boolean isError = false;
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      System.debug(agcpe);
      if (agcpe.Short_Desc__c == 'INVALID_DISCLAIMER_NAME') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }
  @isTest
  public static void noGroupData() {
    List<Mbr_Group__c> mbr = [SELECT Id FROM Mbr_Group__c];
    delete mbr;
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg = null;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Account WHERE Guid__c = :f1bp.benefitSponsor.Guid__c]
    );
    System.assertEquals(0, [SELECT COUNT() FROM Mbr_Group__c]);
    System.assertEquals(0, [SELECT COUNT() FROM Plan_Specific_Fees__c]);
    Test.stopTest();
  }

  @isTest
    public static void grpUpdateNullTest() {
        Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
        List<AcctGrpConParsing_Item__c> agcpiList = [
            SELECT Id, Item_Data__c
            FROM AcctGrpConParsing_Item__c
        ];
        system.debug('Step1');
        F1BMainParser f1bp = new F1BMainParser();
        f1bp.parse(
            '{"SpecialInstructions":"NOTHING","AccountStatus":"Prospect","EmployeeEstLives":"100","TotalEstLives":"100","MessageId":"18a7e8ca-6b16-407f-aaac-131f0faa3297","BenefitSponsorID":"11","GUID":"45691c15-0a24-4798-ad76-e0af7085aa46","BenefitSponsorLegalName":"DOGANDCATCORP","BenefitSponsorFriendlyName":"PARENTCATCOMPANY","Address1":"132PAWSTREET","Address2":null,"City":"KITTEN","State":"AZ","ZipPostal":"85001","Country":"US","StartDate":"2020-09-01T00:00:00.000Z","EndDate":null,"PreferredLanguage":"English","SalesRep":"005f4000003H8aHAAS","AccountManager":"005f4000003H8aHAAS","Group":{"GroupID":"","OneAppAccess":"Y","AllowGeoFencing":"Y","SFDCPayerGUID":"EEEE6262-C405-2C05-D7FB-BA54CE51C171","GUID":"989f91c6-2535-4d3c-b44c-c386dab17e65","GroupName":"DOGCATHMO","GroupStartDate":"2020-09-01T00:00:00.000Z","GroupEndDate":"2024-09-01T00:00:00.000Z","ReportCategory":"","CardName":"NYANCARD2","Status":"Active","WelcomeKit":{"DisclaimerClient":null,"DisclaimerTeladoc":"Aetna"},"Eligibility":"Staged Eligibility","Products":[]},"ParentOrganizationID":"1","ParentOrganizationName":"ExampleContracteeReseller","ParentGuid":"D17631CA-FA3A-A2D1-EE8F-6DC3F45BF4B4"}'
        );
        Test.startTest();
        system.debug('Step2');
        F1bp_Test.buildData(f1bp);
        system.debug('Step3');
        Test.stopTest();
        F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
        system.debug('Step4');
        Mbr_Group__c updateGrp = [
            SELECT
            Group_Number__c,
            Name__c,
            Active_Date__c,
            Termination_Date__c,
            Card_Name__c,
            Allow_Conversion_To_Retail__c,
            Allow_Caregiver_Program__c,
            Sexual_Health_Opt_Out__c,
            Consult_Billing_Method__c,
            Status__c,
            Eligibility_Option__c,
            Shipping_Class__c,
            Wk_Template__c,
            Wk_Retroactive__c,
            Wk_Send_Card_Date__c,
            Wk_Retroactive_Date__c,
            Wk_Card_Includes_Logo__c,
            Wk_Mail_To__c,
            Wk_Includes_Insert__c,
            Card_Template__c,
            Co_Brand_With_Logo__c,
            Communication_Mode__c,
            Mk_IdcardFront1__c,
            Disclaimer_client__c,
            Disclaimer_Teladoc__c,
            Allow_Geo_Fencing__c,
            OneAppAccess__c
            FROM Mbr_Group__c
            WHERE Guid__c = :f1bp.f1bmg.ephMbrGroup.Guid__c
        ];
        System.assertEquals(null, updateGrp.Group_Number__c);
        System.assertEquals(null, updateGrp.Disclaimer_client__c);
        
    }
}