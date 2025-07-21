@isTest
public class QuoteTriggerHelperTester {
  static private void createPriceInfo(String pSbqqType) {
    test.StartTest();
    SBQQ.TriggerControl.disable();
    //20171026 - Create instead of select
    //Account a = [select id from Account where Name = 'BioHorizons Implant Systems, Inc'];
    //Account aRef = new Account(ExternalSysId__c = 'TestAcct1234567890');
    //Account a = new Account(Name = 'BioHorizons Implant Systems, Inc', ExternalSysId__c = 'TestAcct1234567890');
    Account aRef = new Account(Source_Id__c = '123456789012345678');
    Account a = TestDataFactory.createAccountUMRNoInsert();
    a.Type = 'Employer';
    a.Source_Id__c = '123456789012345678';
    a.Phone = '111-283-2839';

    Opportunity o = TestDataFactory.createOpportunityWithPriceBook(
      null,
      null,
      null
    );
    o.Account = aRef;
    o.StageName = 'Prospect';
    o.LeadSource = 'Sales';
    //insert o;

    Contract c = new Contract();
    c.Account = aRef;
    c.SBQQ__Opportunity__c = o.id;

    //insert c;

    //insert aro;

    Database.SaveResult[] sr = Database.insert(new List<SObject>{ a, o, c });

    Opportunity aro = TestDataFactory.createOpportunityWithPriceBook(
      null,
      null,
      null
    );
    aro.Account = aRef;
    aro.StageName = 'Prospect';
    aro.SBQQ__AmendedContract__c = c.id;
    aro.SBQQ__RenewedContract__c = c.id;
    insert aro;
    SBQQ__Quote__c aq = TestDataFactory.createQuote(aro.Id);
    aq.SBQQ__Type__c = pSbqqType;
    aq.SBQQ__Primary__c = true;
    aq.CPQ_Pricebook__c = 'Broker'; //EEM: Carrier->ASO->UMR is no longer valid.
    aq.SBQQ__StartDate__c = Date.today();
    aq.HealthPlan_Opt_In__c = 'No';
    aq.SBQQ__Type__c = 'Amendment';
    insert aq;

    //20171026 - create instead of select
    //Product2 p = [select id from Product2 where ProductCode='GM'];

    Product2 tmpPrd = TestDataFactory.createSingleProduct(
      'Gen Med',
      'Gen Med',
      'GM'
    );
    insert tmpPrd;

    Id tmpPb = Test.getStandardPricebookId();

    PricebookEntry tmpPbe = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ tmpPrd },
      tmpPb
    )[0];
    insert tmpPbe;

    SBQQ__QuoteLine__c aql = TestDataFactory.createQuoteLine(aq.Id, tmpPrd.Id);

    insert aql;

    Map<id, SBQQ__QuoteLine__c> quoteLinesMap = new Map<id, SBQQ__QuoteLine__c>();
    quoteLinesMap.put(aql.Id, aql);
    QuoteTriggerHelper.addMissingFeeProductsToAmendments(quoteLinesMap);
    SBQQ.TriggerControl.enable();
    test.StopTest();
  }
  /*static testMethod void runAmendmentTest() {
        createPriceInfo('Amendment');
    }*/

  static testMethod void runRenewalTest() {
    createPriceInfo('Renewal');
  }
}