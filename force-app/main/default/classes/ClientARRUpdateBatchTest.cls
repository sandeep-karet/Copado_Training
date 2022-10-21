@isTest
private class ClientARRUpdateBatchTest {
    @testSetup 
    static void setup() {
        List<Account__c> accounts = new List<Account__c>();
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(TestFactory.createClientAccount());
        }
        insert accounts;
    }
    
    static testmethod void test() {        
        Test.startTest();
        ClientARRUpdateBatch caub = new ClientARRUpdateBatch();
        Id batchId = Database.executeBatch(caub);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10, [select count() from Account__c]);
    }
    
}