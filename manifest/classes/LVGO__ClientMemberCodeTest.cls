@isTest
public class ClientMemberCodeTest {
 
    @isTest(SeeAllData=true)
    static void insertClientMemberCode(){
        CollaborationGroup groupe = new CollaborationGroup(Name = 'TechOps', CollaborationType = 'Public');
        insert groupe;
        
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;        
        ClientMemberCode__c memberCode=TestFactory.createClientMemberCode();
        memberCode.Account__c=clientAccount.Id;
        Test.startTest();
        insert memberCode;
        Test.stopTest(); 
        String recordTypeId=Schema.SObjectType.ClientMemberCode__c.getRecordTypeInfosByDeveloperName().get('ClientMemberCode').getRecordTypeId();
        System.assertEquals(clientAccount.Id,memberCode.Account__c);
        System.assertEquals('CMCXYZ9000',membercode.ClientMemberCode__c);
        System.assertEquals(recordTypeId, membercode.RecordTypeId);  
    }
    
   
    @isTest(SeeAllData=true)
    static void deleteClientMemberCode(){
    
    CollaborationGroup groupe = new CollaborationGroup(Name = 'TechOps', CollaborationType = 'Public');
        insert groupe;
        
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;        
        ClientMemberCode__c memberCode=TestFactory.createClientMemberCode();
        memberCode.Account__c=clientAccount.Id;
        insert memberCode;
        Test.startTest();
        delete memberCode;
        Test.stopTest();     
        String recordTypeId=Schema.SObjectType.ClientMemberCode__c.getRecordTypeInfosByDeveloperName().get('ClientMemberCode').getRecordTypeId();
        System.assertEquals(clientAccount.Id,memberCode.Account__c);
        System.assertEquals('CMCXYZ9000',membercode.ClientMemberCode__c);
        System.assertEquals(recordTypeId, membercode.RecordTypeId); 
        
    }
}