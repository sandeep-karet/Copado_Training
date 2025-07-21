@isTest
private class OppCloseBatch_Test {
  @TestSetup
  static void setup() {
    //create an account record
    Account accObj = TestDataFactory.createAccount();
    insert accObj;

    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunity(accObj.Id);
    oppObj.CloseDate = Date.Today().addMonths(-3);
    oppObj.Benefit_Consultant_Involved_in_Deal__c = 'No';
    insert oppObj;
    //Bypass Contract path Validation
    //oppObj.Contract_Path__c = System.Label.TD_Teladoc_Account;
    update oppObj;
  }

  static testMethod void test() {
    Test.startTest();
    OppCloseBatch testing = new OppCloseBatch();
    DataBase.executeBatch(testing);
    Test.stopTest();
    Opportunity opp = [
      SELECT Id, StageName, Reason_for_Loss__c, sub_channel__c
      FROM Opportunity
    ];
    system.assertEquals('Closed Lost', opp.StageName);
    system.assertEquals('Other', opp.Reason_for_Loss__c);
    system.assertEquals('Undefined', opp.sub_channel__c);
  }

  static testMethod void test2() {
    Opportunity opp = [
      SELECT Id, StageName, Reason_for_Loss__c, sub_channel__c
      FROM Opportunity
    ];
    opp.Benefit_Consultant_Involved_in_Deal__c = null;
    update opp;
    Test.startTest();
    OppCloseBatch testing = new OppCloseBatch();
    DataBase.executeBatch(testing);
    Test.stopTest();
    opp = [
      SELECT Id, StageName, Reason_for_Loss__c, sub_channel__c
      FROM Opportunity
    ];
    system.assertEquals('Closed Lost', opp.StageName);
  }
}