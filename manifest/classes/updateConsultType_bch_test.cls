@isTest
private class updateConsultType_bch_test {
  @TestSetup
  static void setup() {
    Account testAcct = TestDataFactory.createParentAccount();
    SBQQ__Quote__c quoteObj = TestDataFactory.createQuote();
    Opportunity oppObj = TestDataFactory.createCWOpportunity(
      quoteObj,
      testAcct.Id
    );

    Product2 prod = new Product2(
      Name = 'Test',
      Family = 'Nutrition',
      ProductCode = 'BD-CANADA-BUNDLE',
      IsActive = true
    );
    insert prod;

    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = testAcct.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod.Id,
      Consult_Type__c = 'Standard',
      Termination_Date__c = Date.newInstance(2020, 12, 9)
    );
    insert sub;

    SBQQ__Quote__c qte = new SBQQ__Quote__c();
    qte.SBQQ__Type__c = 'Quote';
    qte.SBQQ__Opportunity2__c = oppObj.id;
    qte.SBQQ__Primary__c = true;
    qte.Sales_Channels__c = 'US Employer';
    qte.CPQ_Pricebook__c = 'Broker';
    qte.SBQQ__StartDate__c = Date.today();
    qte.HealthPlan_Opt_In__c = 'No';
    insert qte;

    SBQQ__QuoteLine__c aql = new SBQQ__QuoteLine__c();
    aql.SBQQ__Quote__c = qte.id;
    aql.SBQQ__Product__c = prod.Id;
    aql.Consult_Type__c = 'Standard';
    insert aql;
  }

  static testMethod void subtest() {
    Test.startTest();
    updateConsultTypeFoSubs_bch testing = new updateConsultTypeFoSubs_bch();
    DataBase.executeBatch(testing);
    Test.stopTest();
    system.assertEquals(
      'Included',
      [SELECT consult_type__c FROM SBQQ__Subscription__c].consult_type__c
    );
  }
  static testMethod void quotetest() {
    Test.startTest();
    updateConsultTypeForQuoteline_bch testing = new updateConsultTypeForQuoteline_bch();
    DataBase.executeBatch(testing);
    Test.stopTest();
    system.assertEquals(
      'Included',
      [SELECT consult_type__c FROM SBQQ__QuoteLine__c].consult_type__c
    );
  }
}