@isTest
private class ContractHSUpdateBatchTest {
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
        
        List<Contract__c> conList = new List<Contract__c>();
        for (Account__c acc: accounts) {
            Contract__c co = TestFactory.createClientOverview();
            co.Account__c = acc.Id; 
            conList.add(co);
        }
        insert conList;
        
        List<Contract__c> poList = new List<Contract__c>();
        for(Contract__c co: conList){
            Contract__c po = TestFactory.createProgramOverview();
            po.Account__c = co.Account__c;
            po.Client_Overview__c = co.Id;
            po.Program_Name__c = 'Diabetes';
            poList.add(po);
        }
        insert poList;
    }
    
    static testmethod void test() {  
        List<Account__c> accList = [Select Id FROM Account__c WHERE Name Like 'Test Batch Account%'];
        List<Contract__c> poList = [SELECT Id, Account__c FROM Contract__c WHERE Account__c IN: accList AND RecordType.Name = 'Program Overview'];
        Test.startTest();
        ContractHSUpdateBatch poBatch = new ContractHSUpdateBatch();
        Id batchId = Database.executeBatch(poBatch);
        Test.stopTest();
        System.assertNotEquals(NULL, [SELECT count() FROM Health_Score__c WHERE Account__c IN: accList AND LastModifiedDate =: System.Today()]);
    }
     
}