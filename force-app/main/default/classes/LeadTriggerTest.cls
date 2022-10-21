@isTest
public class LeadTriggerTest {
	@TestSetup
    static void setupData() {
        Lead__c objlead = new Lead__c();
        objlead.Name = 'test';
        objlead.Status__c = 'AQL';
        objlead.Company__c = 'test';       
        insert objLead;
    }
    @isTest
    static void leadStatusChangeTest() {
     	Lead__c objLead = [Select Id From Lead__c Where Status__c = 'AQL' Limit 1];
        objLead.Status__c = 'MQL';
        Test.startTest();
	        update objLead;
        Test.stopTest();
        Lead__c objLeadUpdated = [Select Id, Last_Status__c From Lead__c Where Id =: objLead.Id Limit 1];
        System.assertEquals(objLeadUpdated.Last_Status__c, 'AQL');
    }
}