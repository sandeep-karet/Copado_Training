@isTest
private class GrpTermBchTest {
  @TestSetup
  static void setup() {
    SBQQ.TriggerControl.disable();
  
    Account umrAcct = TestDataFactory.createUMR();
    Account testAcct = TestDataFactory.createParentAccount();
    Contact conObj = TestDataFactory.createContact(testAcct.Id);
    SBQQ__Quote__c quoteObj = TestDataFactory.createQuote();
        Test.startTest();
    Opportunity oppObj = TestDataFactory.createCWOpportunity(
      quoteObj,
      testAcct.Id
    );
       Test.stopTest();
    TestDataFactory.CreateProduct();
    TestDataFactory.createQuoteLine(quoteObj.Id);
    product2 prodBH = [
      SELECT Id, Name, ProductCode
      FROM product2
      WHERE ProductCode = 'BH'
    ];
    product2 prodGM = [
      SELECT Id, Name, ProductCode
      FROM product2
      WHERE ProductCode = 'GM'
    ];
    product2 prodBHP1T = [
      SELECT Id, Name, ProductCode
      FROM product2
      WHERE ProductCode = 'BHP1T'
    ];
    product2 prodBHPOT = [
      SELECT Id, Name, ProductCode
      FROM product2
      WHERE ProductCode = 'BHPOT'
    ];
    product2 prodBHNPT = [
      SELECT Id, Name, ProductCode
      FROM product2
      WHERE ProductCode = 'BHNPT'
    ];

    Contract contObj = TestDataFactory.createContract(
      testAcct.Id,
      oppObj.Id,
      quoteObj.Id
    );
    SBQQ__QuoteLine__c objQL = [
      SELECT Id, Name, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__ListPrice__c
      FROM SBQQ__QuoteLine__c
      WHERE SBQQ__Product__r.ProductCode = 'BH'
    ];
    SBQQ__QuoteLine__c objQLGM = [
      SELECT Id, Name, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__ListPrice__c
      FROM SBQQ__QuoteLine__c
      WHERE SBQQ__Product__r.ProductCode = 'GM'
    ];
    SBQQ__Subscription__c subtest = new SBQQ__Subscription__c(
      SBQQ__Quantity__c = 1000,
      SBQQ__QuoteLine__c = objQL.Id,
      SBQQ__Account__c = testAcct.Id,
      SBQQ__Contract__c = contObj.Id,
      fee_type__c = 'PEPM',
      SBQQ__SubscriptionStartDate__c = system.today() - 1,
      SBQQ__Product__c = objQL.SBQQ__Product__c,
      Current_Membership_Fee__c = 10
    );
    SBQQ__Subscription__c subGMtest = new SBQQ__Subscription__c(
      SBQQ__Quantity__c = 1000,
      SBQQ__QuoteLine__c = objQLGM.Id,
      SBQQ__Account__c = testAcct.Id,
      SBQQ__Contract__c = contObj.Id,
      fee_type__c = 'PEPM',
      SBQQ__SubscriptionStartDate__c = system.today() - 1,
      SBQQ__Product__c = objQLGM.SBQQ__Product__c,
      Current_Membership_Fee__c = 10
    );

    insert subtest;
    insert subGMtest;
    TestDataFactory.createAsset(
      'Consult Fee- Psych/MD-1stvisitonly-Total',
      90,
      testAcct.Id,
      conObj.Id,
      prodBHP1T.Id,
      subtest.Id
    );
    TestDataFactory.createAsset(
      'Consult Fee- Non-Psychiatrist- Total',
      90,
      testAcct.Id,
      conObj.Id,
      prodBHPOT.Id,
      subtest.Id
    );
    TestDataFactory.createAsset(
      'Consult Fee- Psych/MD-ONGOING-Total',
      90,
      testAcct.Id,
      conObj.Id,
      prodBHNPT.Id,
      subtest.Id
    );
    TestDataFactory.createAsset(
      'GM - Consult Fee',
      45,
      testAcct.Id,
      conObj.Id,
      prodGM.Id,
      subGMtest.Id
    );

    Mbr_Group__c mgTest = new Mbr_Group__c();
    mgTest.name__c = 'testLogo';
    mgTest.Client_Account__c = testAcct.Id;
    mgTest.GUID__c = '0D2D00E4-3151-0287-DD24-2913C77F0659';
    mgTest.Status__c = 'Active';
    mgTest.Termination_Date__c = Date.newInstance(2016, 12, 9);
    mgTest.OneAppAccess__c = 'Yes';
    insert mgTest;

    SBQQ__Subscription__c sub = [
      SELECT SBQQ__ProductName__c, id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__ProductName__c = 'Product: BH'
    ];
    List<Plan_Specific_Fees__c> psfList = new List<Plan_Specific_Fees__c>();
    Plan_Specific_Fees__c psf1 = new Plan_Specific_Fees__c(
      Member_Group__c = mgTest.id,
      Subscription__c = sub.Id,
      Actual_Copay_May_Be_Less__c = false,
      Consult_Fee_Mbr_Pd__c = 90
    );
    psfList.add(psf1);
    Plan_Specific_Fees__c psf2 = new Plan_Specific_Fees__c(
      Member_Group__c = mgTest.id,
      Subscription__c = sub.Id,
      Actual_Copay_May_Be_Less__c = false,
      Consult_Fee_Mbr_Pd__c = 90
    );
    psfList.add(psf2);
    Plan_Specific_Fees__c psf3 = new Plan_Specific_Fees__c(
      Member_Group__c = mgTest.id,
      Subscription__c = sub.Id,
      Actual_Copay_May_Be_Less__c = false,
      Consult_Fee_Mbr_Pd__c = 90
    );
    psfList.add(psf3);
    insert psfList;

    SBQQ.TriggerControl.enable();
  }

  static testMethod void test() {
          Test.startTest();
    Mbr_Group__c testMbrGrp = [
      SELECT Status__c, Termination_Date__c
      FROM Mbr_Group__c
    ];
    system.assertEquals('ACTIVE', testMbrGrp.Status__c);

    GrpTerm_Bch testing = new GrpTerm_Bch();
    DataBase.executeBatch(testing);
       Test.stopTest();
    system.assertEquals(
      'TERMED',
      [SELECT Status__c FROM Mbr_Group__c].Status__c
    );
    system.assertEquals(
      testMbrGrp.Termination_Date__c,
      [SELECT Product_End_Date__c FROM Plan_Specific_Fees__c LIMIT 1]
      .Product_End_Date__c
    );
  }
}