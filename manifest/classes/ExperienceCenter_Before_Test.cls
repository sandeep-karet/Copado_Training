@isTest
private class ExperienceCenter_Before_Test {
  @testSetup
  static void setupdata() {
    Account accObj = TestDataFactory.createAccountUMR();

    Id pricebookId = Test.getStandardPricebookId();

    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunityWithPriceBook(
      accObj.Id,
      pricebookId,
      null
    );
    oppObj.LeadSource = 'Sales';
    insert oppObj;

    //create Gen Med product
    Product2 prod2 = TestDataFactory.createSingleProduct(
      'General Medical',
      'General Medical',
      'GM'
    );
    insert prod2;

    PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prod2 },
      pricebookId
    )[0];
    insert pbEntry;

    //Create a quote record
    SBQQ__Quote__c quoObj = TestDataFactory.createQuote(oppObj.Id);
    insert quoObj;
  }
  @isTest
  static void experienceCenterTriggerTest() {
    test.startTest();
    Opportunity oppObj = [SELECT Id FROM Opportunity];
    SBQQ__Quote__c q = [SELECT Id FROM SBQQ__Quote__c];
    Product2 prod = [SELECT Id FROM Product2];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
    SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
      q.Id,
      prod.Id
    );
    insert quoline1;

    OpportunityLineItem opl = TestDataFactory.createOLI(
      oppObj.Id,
      pbEntry.Id,
      null
    );
    opl.TotalPrice = 500 * pbEntry.UnitPrice;

    insert opl;

    Briefing__c ecbr = new Briefing__c();
    ecbr.opportunity__c = oppObj.Id;
    ecbr.location__c = 'Virtual';
    ecbr.Preferred_Date__c = DateTime.newInstance(2021, 6, 6, 3, 3, 3);
    ecbr.Request_Time_Zone__c = 'Eastern';
    insert ecbr;

    Briefing__c testEcbr = [
      SELECT Products2__c, Briefing_Name__c
      FROM Briefing__c
    ];
    system.assertEquals(
      'General Medical, General Medical',
      testEcbr.Products2__c
    );
    system.assertEquals(
      'TestAmendAccount Virtual ' +
        Date.today().month() +
        '-' +
        Date.today().year(),
      testEcbr.Briefing_Name__c
    );
    test.stoptest();
  }
}