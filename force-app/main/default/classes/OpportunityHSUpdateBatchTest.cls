@isTest
private class OpportunityHSUpdateBatchTest {
    @testSetup 
    static void setup() {
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
        
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        for (Account__c acc: accounts) {
            Opportunity__c opp = TestFactory.createOpportunity();
            opp.Account__c = acc.Id;
            oppList.add(opp);
        }
        insert oppList;
    }
    
    static testmethod void test() {  
        List<Account__c> accList = [Select Id FROM Account__c WHERE Name Like 'Test Batch Account%'];
        List<Opportunity__c> opportunityList = [SELECT Id, Account__c FROM Opportunity__c WHERE Type__c = 'Renewal'];
        Test.startTest();
        OpportunityHSUpdateBatch oppBatch = new OpportunityHSUpdateBatch();
        Id batchId = Database.executeBatch(oppBatch);
        Test.stopTest();
        System.assertNotEquals(NULL, [SELECT count() FROM Health_Score__c WHERE Account__c IN: accList AND LastModifiedDate =: System.Today()]);
    }
     
}