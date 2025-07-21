/**
* Company : PwC.
* @description : L2O_AssetTriggerHelperService_Test will be executed from the L2O_AssetTriggerHandler and will contain all the Asset logic.
* **********************************************************************************************************************************
* History : 
* @date 09/05/2023
* @author Lakshitha Salian
*/

@isTest
public class L2O_AssetTriggerHelperService_Test {
    
    /**
* @name testAssetSetGUID()
* @description Tests set GUID function before insert & before update
* @params  none
*/ 
    @isTest static void testAssetSetGUID(){ 
        
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,2);
        Id accId = accountList[0].Id;
        
        List<Product2> prodList = L2O_DataFactoryTest.createProduct();
        
        
        //Check Asset after before insert
        Test.startTest();
        List<Asset> asstList = L2O_DataFactoryTest.createAsset(true,accId,prodList);
        System.assert(asstList.size() > 0, 'Creation Test Successful');
        Test.stopTest();
    }
    /**
* @name  testcatchException()
* @description Tests L2O_AssetTriggerHandler class catch block
* @params  none
*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_AssetTriggerHandler helper = new L2O_AssetTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Name != '' LIMIT 1];
        System.assertEquals('L2O_AssetTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }
    
}