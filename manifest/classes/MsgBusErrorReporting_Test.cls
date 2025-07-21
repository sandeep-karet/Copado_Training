@isTest
private class MsgBusErrorReporting_Test {
  @TestSetup
  public static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    Account accObj = TestDataFactory.createAccountUMR();
    Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
    oppObj2.Message_Bus_Error__c = true;
    insert oppObj2;

    String result = '{  "Parsing_Errors" : {    "OPPORTUNITY_LEVEL_BAD_DATA" : "Opportunity OwnerId : User Id is invalid in LVN."  },  "DML_Errors" : { }}';
    Q_Item__c qitem = new Q_Item__c(
      Opportunity__c = oppObj2.Id,
      Teladoc_Opp_Id__c = oppObj2.Id,
      Teladoc_Account_Id__c = '22222',
      Payload__c = '{}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB4',
      Status__c = 'Processed with error',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'parserName',
      Type__c = 'Outgoing',
      isSync__c = true,
      Result__c = result
    );
    insert qitem;
  }

  static testMethod void getQItem() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    system.assertEquals(
      1,
      MsgBusErrorReporting_Controller.getQItem(
          opp.Id,
          system.today(),
          system.today().addDays(3),
          null
        )
        .size()
    );
  }
}