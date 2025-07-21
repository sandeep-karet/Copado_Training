@IsTest
private class Brkr_Opp_Tests {
  @IsTest
  static void SourceTest() {
    // Create rel accounts
    Account svc_account = TestDataFactory.createAccount('Servicing Account');
    Account bsp_account = TestDataFactory.createParentAccount();

    // create acct rel
    Acct_Rel__c tmpAr = TestDataFactory.createAcctRel(
      svc_account.id,
      bsp_account.id
    );

    // create opportunity
    Opportunity tmpOpp = TestDataFactory.createOpportunity(bsp_account.id);
    tmpOpp.stagename = 'Prospect';
    tmpOpp.closedate = Date.today() + 90;
    insert tmpOpp;

    // finally create broker / opp rel

    Broker_Opp_Rel__c tmpBor = TestDataFactory.createBrokerOppRel();
    tmpBor.opp_broker__c = tmpOpp.id;
    tmpBor.broker_rel__c = tmpAr.id;
    insert tmpBor;
    Broker_Opp_Rel__c bko = [
      SELECT
        Id,
        Chronic_Care_Broker_Flat_Rate__c,
        Chronic_Care_Broker_Percentage__c
      FROM Broker_Opp_Rel__c
    ];
    system.assertEquals(0.10, bko.Chronic_Care_Broker_Flat_Rate__c);
    system.assertEquals(0.10, bko.Chronic_Care_Broker_Percentage__c);
  }
}