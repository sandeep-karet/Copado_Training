@IsTest
private class OppliUpdate_Bch_test {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createUMR();

    Id pricebookId = Test.getStandardPricebookId();

    Opportunity opp = TestDataFactory.createOpportunityWithPriceBook(
      acct.Id,
      pricebookId,
      UserInfo.getUserId()
    );
    insert opp;

    List<Product2> pd = new List<Product2>();
    Product2 prod1 = TestDataFactory.CreateProductWithDynamicVals(
      'MYSTR3',
      'MYSTR3'
    );
    prod1.SBQQ__SubscriptionPricing__c = 'Fixed';
    pd.add(prod1);
    Product2 prod2 = TestDataFactory.CreateProductWithDynamicVals(
      'Dermatology',
      'DERM'
    );
    prod2.SBQQ__SubscriptionPricing__c = 'Fixed';
    pd.add(prod2);
    Product2 prod3 = TestDataFactory.CreateProductWithDynamicVals(
      'Livongo',
      'LVN'
    );
    prod3.SBQQ__SubscriptionPricing__c = 'Fixed';
    pd.add(prod3);
    Product2 prod4 = TestDataFactory.CreateProductWithDynamicVals(
      'NOProvider',
      'TEST'
    );
    prod4.SBQQ__SubscriptionPricing__c = 'Fixed';
    pd.add(prod4);
    insert pd;

    SBQQ__Quote__c quoObj = TestDataFactory.createQuote(opp.Id);
    insert quoObj;
  }

  @IsTest
  static void LV_Product() {
    Test.startTest();
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
      qte.Id,
      prodLvn.Id
    );
    insert quoline1;
    PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prodLvn },
      pricebookId
    )[0];
    insert pbEntry;
    OpportunityLineItem oppli = TestDataFactory.createOLI(
      opp.Id,
      pbEntry.Id,
      quoline1.Id
    );
    insert oppli;
    Database.executeBatch(new OppliUpdate_bch());
    Test.stopTest();
  }
}