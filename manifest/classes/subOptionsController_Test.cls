@IsTest
private class subOptionsController_Test {
  @TestSetup
  static void setup() {
    Account testAcct = TestDataFactory.createParentAccount();
    Contact conObj = TestDataFactory.createContact(testAcct.Id);
    SBQQ__Quote__c quoteObj = TestDataFactory.createQuote();
    Opportunity oppObj = TestDataFactory.createCWOpportunity(
      quoteObj,
      testAcct.Id
    );
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
  }

  @isTest
  static void test() {
    Account acct = [SELECT guid__c FROM Account];
    subOptionsController.createSubAsset(acct.Guid__c);
    subOptionsController.accountName(acct.Guid__c);
    subOptionsController.accountName('acct.Guid__c');
  }
}