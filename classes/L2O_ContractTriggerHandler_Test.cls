/**
* Company : PwC.
* @description : Test Class for L2O_ContractTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 20/07/2023
* @author Neha Sheikh
*/

@istest
public class L2O_ContractTriggerHandler_Test {
    /**
	* @name  testcatchException()
	* @description Tests L2O_ContractTriggerHandler class catch block
	* @params  none
	*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_ContractTriggerHandler helper = new L2O_ContractTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        helper.afterInsert();
        Test.stopTest();
        //Fetch Error Log
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Name != '' LIMIT 1];
        System.assertEquals('L2O_ContractTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }

}