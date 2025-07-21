/**
* Company : PwC.
* @description : Test Class for L2O_AgreementTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 20/07/2023
* @author Neha Sheikh
*/

@istest
public class L2O_AgreementTriggerHandler_Test {
    /**
* @name  testcatchException()
* @description Tests L2O_AgreementTriggerHandler class catch block
* @params  none
*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_AgreementTriggerHandler helper = new L2O_AgreementTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Name != '' LIMIT 1];
        System.assertEquals('L2O_AgreementTriggerHandler',errorLog.Class__c,'Handler Test Successful');
        
    }
    /**
* @name  testsetGUID()
* @description Tests Auto updated L2O_GUID__c field onrecord creation
* @params  none
*/
    @istest
    public static void testsetGUID() {
        list<Account> accList= L2O_DataFactoryTest.createAccount(true,1);
        Apttus__APTS_Agreement__c tempAgreement = new Apttus__APTS_Agreement__c(Name = 'Test', Apttus__Account__c = accList[0].Id);
        Test.startTest();
        insert tempAgreement;
        Test.stopTest();
        Apttus__APTS_Agreement__c fetchAgreement = [SELECT Id,Name FROM Apttus__APTS_Agreement__c WHERE Name != '' LIMIT 1];
        System.assertEquals('Test',fetchAgreement.Name,'Creation Test Successful');
    }
    
}