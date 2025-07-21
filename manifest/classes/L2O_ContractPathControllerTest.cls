/**
* Company : PwC.
* @description : Test Class for L2O_ContractPathController
* ************************************************************************************************************************************
* History : 
* @date 11/11/2022
* @author Lakshitha Salian
*/
@isTest
public class L2O_ContractPathControllerTest {

    /**
    * @name  testGetMetaDataSettings
    * @description To test method which returns custom metadata texts for the Contract Path LWC
    * @params  none
    **/
    @isTest static void testGetMetaDataSettings(){

        Test.startTest();
        //Fetch custom metadata settings
        List<L2O_ContractPathUpdate__mdt> lwcMetadataList = new List<L2O_ContractPathUpdate__mdt>();
        lwcMetadataList = L2O_ContractPathController.getMetaDataSettings();
       
        System.assertEquals(1,lwcMetadataList.size(),'To check the size of returned Metadata List.');
        
        //To cover the catch block
        L2O_ContractPathController.isErrorFlag = true;
        L2O_ContractPathController.getMetaDataSettings();
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ContractPathController'];
        System.assertEquals('getMetaDataSettings',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();  
    }
    
    /**
    * @name testFindTeladocAccount
    * @description To test if method returns the specific Teladoc Health Inc account Id in the org
    * @params  none
    **/
    @isTest static void testFindTeladocAccount(){
        
        //String teladocGUID = System.Label.L2O_TD_Teladoc_Account;
        
        Test.startTest();
        
        //Fetch the Teladoc account via class method
        //L2O_ContractPathController.isErrorFlag = false;
        //String result = L2O_ContractPathController.findTeladocAccount();
        
        //To cover the catch block
        L2O_ContractPathController.isErrorFlag = true;
        L2O_ContractPathController.findTeladocAccount();
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ContractPathController' AND Reference__c = 'findTeladocAccount'];
        System.assertEquals('findTeladocAccount',lstErrorLog[0].Reference__c,'To check the method of error.');

        Test.stopTest();  
    }
    
    
    /**
    * @name  testGetFilteredPricingModel
    * @description To test return of custom metadata valid Pricing Model values as per Contracting Account
    * @params  none
    **/
    @isTest static void testGetFilteredPricingModel(){
        
        //Fetch any metadata row to test with.
        List<L2O_ContractingAccToPricingModel__mdt> validPricingModel = new List<L2O_ContractingAccToPricingModel__mdt>();
        validPricingModel = [SELECT MasterLabel,L2O_Contracting_Account_GUID__c, L2O_Pricing_Model_Values__c
                                      FROM L2O_ContractingAccToPricingModel__mdt
                                      WHERE L2O_Contracting_Account_GUID__c != null
                                      LIMIT 1];
        String existingContractingAccountGUID = validPricingModel[0].L2O_Contracting_Account_GUID__c;
        String existingPricingModelValues = validPricingModel[0].L2O_Pricing_Model_Values__c;
        
        Test.startTest();
        
        //Create Test account with specific guid.
        Account testContractingAcct = new Account ();
        testContractingAcct.Name = 'Test_ContractingAccount';
        testContractingAcct.BillingCity='city';
        testContractingAcct.BillingCountry='United States';
        testContractingAcct.BillingStreet='street';
        testContractingAcct.BillingState='California';
        testContractingAcct.BillingPostalCode='postalCode';
        testContractingAcct.L2O_GUID__c= existingContractingAccountGUID; 
        insert testContractingAcct;
        
        String testContractingAcctId = [SELECT Id,Name,L2O_GUID__c FROM Account WHERE L2O_GUID__c =: existingContractingAccountGUID LIMIT 1].Id;
        
        //Fetch the respective pricing model values via class method
        L2O_ContractPathController.isErrorFlag = false;
        String resultPricingModelValues = L2O_ContractPathController.getFilteredPricingModel(testContractingAcctId);
       
        System.assertEquals(existingPricingModelValues,resultPricingModelValues,'Pricing Model Values found.'); 
        
        //To cover the catch block
        L2O_ContractPathController.isErrorFlag = true;
        L2O_ContractPathController.getFilteredPricingModel(testContractingAcctId);
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ContractPathController' AND Reference__c = 'getFilteredPricingModel'];
        System.assertEquals('getFilteredPricingModel',lstErrorLog[0].Reference__c,'To check the method of error.');

        Test.stopTest();  
    }
    
}