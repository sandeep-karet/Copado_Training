/**
* Company : PwC.
* @description : Test Class for L2O_OrderTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 02/08/2023
* @author Neha Sheikh
*/

@istest
public class L2O_OrderTriggerHandler_Test {
    /**
	* @name  testcatchException()
	* @description Tests L2O_OrderTriggerHandler class catch block
	* @params  none
	*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_OrderTriggerHandler helper = new L2O_OrderTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        helper.afterUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Name != '' LIMIT 1];
        // Case testing
        System.assertEquals('L2O_OrderTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }

}