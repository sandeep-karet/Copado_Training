@istest
public class ContractStatusUpdateBatchTest {
    
	static testMethod void unitTest1() {
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
        Account__c partnerAccount = TestFactory.createPartnerAccount();
        insert partnerAccount;
        Contract__c clientOverview = TestFactory.createClientOverview();
        clientOverview.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Client Overview').getRecordTypeId();
        clientOverview.Account__c = clientAccount.Id;
        clientOverview.Contract_Path__c = partnerAccount.Id;
        clientOverview.CSM__c = System.UserInfo.getUserId();
        clientOverview.Status__c ='Draft';
        clientOverview.Contract_Effective_Date__c = Date.today();
        insert clientOverview;
        ContractStatusUpdateBatch sh1 = new ContractStatusUpdateBatch();
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
        system.schedule('Test Territory Check', sch, sh1);
        DataBase.executeBatch(sh1); 
        Test.stopTest();         
    }
    static testMethod void unitTest2() {
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
        Account__c partnerAccount = TestFactory.createPartnerAccount();
        insert partnerAccount;
        Contract__c clientOverview = TestFactory.createClientOverview();
        clientOverview.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Client Overview').getRecordTypeId();
        clientOverview.Account__c = clientAccount.Id;
        clientOverview.Contract_Path__c = partnerAccount.Id;
        clientOverview.CSM__c = System.UserInfo.getUserId();
        clientOverview.Status__c ='Draft'; 
        clientOverview.Client_Overview_Status__c = 'Active';
        clientOverview.Contract_Termination_Date__c = Date.today();
        insert clientOverview;
        ContractStatusUpdateBatch sh1 = new ContractStatusUpdateBatch();
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
        system.schedule('Test Territory Check', sch, sh1);
        DataBase.executeBatch(sh1); 
        Test.stopTest();         
    }
}