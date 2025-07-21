@isTest
public class APTS_formData_Test {
    
    @isTest
    Public Static void testFormdate(){
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
        agmt.Name = 'Test - Agmt';
        insert agmt;
        
        Apttus_DocuApi__DocuSignEnvelope__c env = new Apttus_DocuApi__DocuSignEnvelope__c();
        env.Name = '4917f32e-ed9d-49f7-bf9e-ac0b7dadc89a';
        env.Apttus_CMDSign__Agreement__c = agmt.Id;
        env.Apttus_DocuApi__Status__c = 'Sent';
        insert env;
        
        Apttus_DocuApi__DocuSignEnvelope__c updateEnv = [Select Id, Name from Apttus_DocuApi__DocuSignEnvelope__c 
                                                        where Id =:env.Id];
        updateEnv.Apttus_DocuApi__Status__c = 'completed';
        update updateEnv;
        
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new APTS_getformDatamock_Test());        
        
        APTS_GetFormData.getFormData(new List<Id>{updateEnv.Id});
        System.assertNotEquals(null, updateEnv.Id, 'Records found successfully');
        Test.stopTest();
    }
    
}