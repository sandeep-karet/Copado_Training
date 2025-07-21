@isTest
private class Quotas_Test {
  @testSetup
  static void setupdata() {
    Account umrAcct = TestDataFactory.createUMR();

   Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
   User u1 = TestDataFactory.createUser(p.Id);
   insert u1;
    

    Quotas__c quotas = TestDataFactory.createQuotas(u1.Id);
    insert quotas;
    Account accObj = TestDataFactory.createAccountUMR();

    Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
    insert acctRel1;

    Id pricebookId = Test.getStandardPricebookId();
    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunityWithPriceBook(
      accObj.Id,
      pricebookId,
      u1.Id
    );
    insert oppObj;

    Product2 prod2 = TestDataFactory.createProducts(
      new List<String>{ 'General Medical' }
    )[0];
    insert prod2;

    PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prod2 },
      pricebookId
    )[0];
    insert pbEntry;

    //Create a quote record
    SBQQ__Quote__c quoObj = TestDataFactory.createQuote(oppObj.Id);
    quoObj.CPQ_Pricebook__c = 'Broker';
    insert quoObj;

    SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
      quoObj.Id,
      prod2.Id
    );
    insert quoline1;
  }
  @isTest
  static void updateOppForQuotas() {
     
    test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity oppObj = [SELECT Id, Pricebook2Id FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
    Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = TestDataFactory.createOLI(
      oppObj.Id,
      pbEntry.Id,
      null
    );
    opl.Quantity = 500;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    //Account accObj = [SELECT Id FROM Account WHERE Name = 'TestAmendAccount'];
   // User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    Quotas__c quotas = [SELECT Id FROM Quotas__c];

    oppObj.Contracted_Date__c = Date.Today();
    oppObj.Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
    oppObj.Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    oppObj.StageName = 'Closed Won';
	 update oppObj;
    system.assertEquals(
      quotas.Id,
      [SELECT quotas__c FROM Opportunity WHERE Id = :oppObj.Id].quotas__c
   );
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

}