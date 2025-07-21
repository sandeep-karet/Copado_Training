@isTest
private class HealthScoresBatchTest {
    @testSetup 
    static void setup() {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        
        List<Account__c> accounts = new List<Account__c>();
        for (Integer i=0; i<10; i++) {
            Account__c testAccount = new Account__c();
            testAccount.RecordTypeId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
            testAccount.Name = 'Test Batch Account' + i;
            testAccount.Type__c = 'Self Funded Employer';
            testAccount.Account_Type__c = 'Client';
            accounts.add(testAccount);
        }
        insert accounts;
    }
    
    static testmethod void test() {  
        List<Account__c> accList = [SELECT Id FROM Account__c WHERE Name LIKE 'Test Batch Account%'];
        Test.startTest();
        HealthScoresBatch caub = new HealthScoresBatch();
        Id batchId = Database.executeBatch(caub);
        Test.stopTest();
        System.assertEquals(640, [SELECT count() FROM Health_Score__c WHERE Account__c IN: accList]);
    }
     
}