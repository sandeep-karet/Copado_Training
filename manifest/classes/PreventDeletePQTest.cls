@isTest
public class PreventDeletePQTest {
  static testMethod void testPreventQTDel() {
    SBQQ__Quote__c QuoteRecord = new SBQQ__Quote__c();
    QuoteRecord.SBQQ__Primary__c = true;
    QuoteRecord.Business_Region__c = 'USA';
    QuoteRecord.Sales_Channels__c = 'US Employer';
    QuoteRecord.CPQ_Pricebook__c = 'Direct';
    QuoteRecord.SBQQ__StartDate__c = Date.today() + 3;
    QuoteRecord.HealthPlan_Opt_In__c = 'No';
    insert QuoteRecord;

    try {
      delete QuoteRecord;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage()
          .contains(
            'This is a primary quote, please deselect the primary quote field to be able to eliminate it.'
          ),
        'This is a primary quote, please deselect the primary quote field to be able to eliminate it.'
      );
    }
  }
}