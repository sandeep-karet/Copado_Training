@isTest
private with sharing class CanadaOppUpdate_Bch_Test {
  @testSetup
  static void setupdata() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u4 = TestDataFactory.createUser(p.Id);
    u4.DefaultCurrencyIsoCode = 'CAD';
    u4.Country = 'United Kingdom';
    insert u4;
    //create an account record
    Account accObj = TestDataFactory.createUMR();

    //create an opportunity record
    Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
    oppObj2.LeadSource = 'Sales';
    insert oppObj2;

    oppObj2.OwnerId = u4.Id;
    update oppObj2;
  }

  static testMethod void test() {
    Test.startTest();
    Database.executeBatch(new CanadaOppUpdate_Bch());
    Test.stopTest();
    system.assertEquals(
      'International',
      [SELECT Sub_Channel__c FROM Opportunity].Sub_Channel__c
    );
    system.assertEquals(
      'Canada',
      [SELECT Country__c FROM Opportunity].Country__c
    );
    system.assertEquals(
      'Canada',
      [SELECT Business_Region__c FROM Opportunity].Business_Region__c
    );
  }
}