public class F1bAcct_Test {
  public static void AcctUpdateTest() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    Account oldacct = f1bp.benefitSponsor;
    oldacct.Name = 'test';
    insert oldacct;
   
    f1bp.benefitSponsor.Account_Legal_Name__c = 'NOT PARENT CAT COMPANY';
    f1bp.benefitSponsor.Friendly_Account_Name__c = 'Friendly Cat COMPANY';
    f1bp.benefitSponsor.BillingStreet = '123 Drive';
    f1bp.benefitSponsor.BillingCity = 'DALLAS';
    f1bp.benefitSponsor.BillingState = 'Texas';
    f1bp.benefitSponsor.BillingPostalCode = '75000';
    f1bp.benefitSponsor.BillingCountry = 'United States';
    f1bp.benefitSponsor.Revenue_Effective_Date__c = Date.parse('11/6/2020');
    f1bp.benefitSponsor.Type = 'Other';
    f1bp.benefitSponsor.Language__c = 'Spanish';
    f1bp.benefitSponsor.Total_US_Employees_Benefits_Enrolled__c = 3000;
    f1bp.benefitSponsor.Members__c = 3000;
    f1bp.benefitSponsor.Special_Instructions_for_Implementatio__c = 'test 12345';
    f1bp.PrintPhone = '1-800-Test (835-2362)';
    f1bp.PrintUrl = 'Teladoc.com/Test';
    f1bp.benefitSponsor.Members__c = 3000;
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
 Test.startTest();
    Account updateAcct = [
      SELECT
        Id,
        Account_Legal_Name__c,
        Friendly_Account_Name__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        Revenue_Effective_Date__c,
        Type,
        Language__c,
        Total_US_Employees_Benefits_Enrolled__c,
        Members__c,
        Special_Instructions_for_Implementatio__c,
        Name
      FROM Account
      WHERE Guid__c = :f1bp.benefitSponsor.Guid__c
    ];
    System.assertEquals('NOT PARENT CAT COMPANY', updateAcct.Name);
    System.assertEquals(
      'Friendly Cat COMPANY',
      updateAcct.Friendly_Account_Name__c
    );
    System.assertEquals('123 Drive', updateAcct.BillingStreet);
    System.assertEquals('DALLAS', updateAcct.BillingCity);
    System.assertEquals('Texas', updateAcct.BillingState);
    System.assertEquals('United States', updateAcct.BillingCountry);
    System.assertEquals('75000', updateAcct.BillingPostalCode);
    System.assertEquals(
      'NOT PARENT CAT COMPANY',
      updateAcct.Account_Legal_Name__c
    );
    System.assertEquals(3000, updateAcct.Members__c);
    System.assertEquals(
      3000,
      updateAcct.Total_US_Employees_Benefits_Enrolled__c
    );
    System.assertEquals('Other', updateAcct.Type);
    System.assertEquals('Spanish', updateAcct.Language__c);
    System.assertEquals(
      'test 12345',
      updateAcct.Special_Instructions_for_Implementatio__c
    );
    Test.stopTest();
  }

  public static void falseParentGuidTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.ParentGuid = 'this_is_not_guid';
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(false, isParentGuidFalse);
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    Boolean isError = false;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      if (agcpe.Short_Desc__c == 'INVALID_PARENT_GUID') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }

  public static void falseBSGuidTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.benefitSponsor.Guid__c = 'this-is-not-a-guid!!';
    Test.startTest();
    F1bUtils_v2.FetchExistingData(f1bp, agcpiList[0].Id);
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    Boolean isError = false;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      if (agcpe.Short_Desc__c == 'BSP_GUID_INVALID') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }

  public static void noAccountFoundTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.ParentGuid = 'D17631CA-FA3A-A2D1-EE8F-6DC3F45BF4BB';
    f1bp.benefitSponsor.Guid__c = 'D17631CA-FA3A-A2D1-EE8F-6DC3F45BF4BZ';
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(false, isParentGuidFalse);
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    Boolean isError = false;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      if (agcpe.Short_Desc__c == 'NO_ACCOUNTS_FOUND') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }

  public static void noUserIdFoundTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.benefitSponsor.ownerId = '005f40000056OccAAX';
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(false, isParentGuidFalse);
    List<AcctGrpConParse_Exception__c> agcpeList = F1bUtils_v2.exceptionsFound;
    Boolean isError = false;
    for (AcctGrpConParse_Exception__c agcpe : agcpeList) {
      System.debug(agcpe);
      if (agcpe.Short_Desc__c == 'INVALID_USER_ID') {
        isError = true;
      }
    }
    System.assertEquals(true, isError);
    Test.stopTest();
  }

  public static void nullUserIdTest() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.benefitSponsor.ownerId = null;
    f1bp.benefitSponsor.Account_Manager__c = null;
    Test.startTest();
    Boolean isParentGuidFalse = F1bUtils_v2.FetchExistingData(
      f1bp,
      agcpiList[0].Id
    );
    System.assertEquals(true, isParentGuidFalse);
    Test.stopTest();
  }

  public static void acctRelEndDate() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    f1bp.EndDate = Date.parse('11/6/2020');
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(1, [ SELECT Count() FROM Acct_Rel__c ]);
    //System.assertEquals('2020-11-06 00:00:00', string.valueOfGmt([ SELECT End_Date__c FROM Acct_Rel__c ].End_Date__c));
    Test.stopTest();
  }

  public static void AcctFailInsertTest() {
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    f1bp.benefitSponsor.Account_Legal_Name__c = null;
    f1bp.benefitSponsor.Name = null;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(1, [SELECT Count() FROM AcctGrpConParse_Exception__c WHERE Short_Desc__c = 'CANNOT_CREATE_ACCOUNT' ]);
    Test.stopTest();
  }

  public static void AccountRelationshipTest() {
    Account Umr = [SELECT Id, Guid__c FROM Account WHERE Name = 'UMR'];
    Account benefitAcct = new Account();
    benefitAcct.Name = 'testAcct';
    benefitAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    benefitAcct.Friendly_Account_Name__c = 'TestAmendAccount';
    benefitAcct.Source__c = 'HUB';
    benefitAcct.CurrencyIsoCode = 'USD';
    benefitAcct.Business_Region__c = 'USA';
    benefitAcct.Account_Type__c = 'Health Plan';
    insert benefitAcct;
    AcctGrpConParsing_Item__c agcpi = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpi.Item_Data__c);
    Acct_Rel__c newAcctRel1 = new Acct_Rel__c(
      Svc_Acct__c = Umr.Id,
      Benefit_Sponsor__c = benefitAcct.Id,
      Relationship_Type__c = 'Contractee',
      Contract_Type__c = 'Insurance',
      Line_of_Business__c = 'Commercial_Administrative_Services_Only_ASO',
      Start_Date__c = system.today() - 1
    );
    Acct_Rel__c newAcctRel2 = new Acct_Rel__c(
      Svc_Acct__c = Umr.Id,
      Benefit_Sponsor__c = benefitAcct.Id,
      Relationship_Type__c = 'Contractee',
      Contract_Type__c = 'Insurance',
      Line_of_Business__c = 'Commercial_Administrative_Services_Only_ASO',
      Start_Date__c = system.today()
    );
    insert newAcctRel1;
    insert newAcctRel2;
    Datetime older = Datetime.now().addDays(-30);
    Test.setCreatedDate(newAcctRel2.Id, older);
    Test.setCreatedDate(newAcctRel1.Id, Date.Today());
    Test.startTest();
    Acct_Rel__c acctRel = F1bUtils_v2.Create_AcctRel(
      Umr,
      benefitAcct,
      agcpi.Id,
      f1bp
    );
    system.assertEquals(acctRel.Id, newAcctRel1.Id);
    Test.stopTest();
  }
}