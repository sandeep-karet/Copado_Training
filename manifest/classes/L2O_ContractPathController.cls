/**
* Company : PwC.
* @description : L2O_ContractPathController will be used to handle Contract Path LWC on Opportunity detail page.
* *******************************************************************************************************************************************
* History : 
* @date 11/09/2022
* @author Lakshitha Salian
*/
public without sharing class L2O_ContractPathController {
    
    //Exception log variables
    public static String className = 'L2O_ContractPathController';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;
    
    /**
    * @name  getMetaDataSettings   
    * @description This method returns custom metadata texts for the Contract Path LWC
    * @return List of Metadata settings
    **/
    @AuraEnabled
    public static List<L2O_ContractPathUpdate__mdt> getMetaDataSettings(){
        
        methodName = 'getMetaDataSettings';
        List<L2O_ContractPathUpdate__mdt> lstAllMetadata = new  List<L2O_ContractPathUpdate__mdt>();
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            //Fetch CustomMetadata record for ContractPathUpdate
            lstAllMetadata = [SELECT MasterLabel, L2O_DirectContYes_EmpBsnYes__c,L2O_DirectContYes_EmpBsnNo__c,L2O_DirectContNo_EmpBsnNo__c
                    			FROM L2O_ContractPathUpdate__mdt WHERE DeveloperName ='L2O_ContractPath_Text'];
            //Return custom metadata texts for the Contract Path LWC
            return lstAllMetadata;
        } catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        // Return custom metadata texts for the Contract Path LWC
        return lstAllMetadata;
    }
    
    /**
    * @name  findTeladocAccount   
    * @description This method returns the specific Teladoc Health Inc account Id in the org
    * @return String of Teladoc Health Inc account Id in the org
    **/
    @AuraEnabled
    public static String findTeladocAccount(){
        
        methodName = 'findTeladocAccount';
        String response = '';
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
            	String teladocGUID = System.Label.L2O_TD_Teladoc_Account;
            	//Fetch Account record for specific GUID
                String teladocAccountId = [SELECT Id,Name,L2O_GUID__c FROM Account WHERE L2O_GUID__c =: teladocGUID LIMIT 1].Id;
                response = teladocAccountId;
            	//Return the specific Teladoc Health Inc account Id in the org
            	return response;
        } catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        //Return the specific Teladoc Health Inc account Id in the org
        return response;
    }
    
    /**
    * @name  getFilteredPricingModel   
    * @description This method returns custom metadata valid Pricing Model values as per Contracting Account
    * @param contractingAccId for Current Contracting account id
    * @return String of valid options
    **/
    @AuraEnabled
    public static String getFilteredPricingModel(String contractingAccId){
        
        methodName = 'getFilteredPricingModel';
        List<L2O_ContractingAccToPricingModel__mdt> validPricingModel = new List<L2O_ContractingAccToPricingModel__mdt>();
        String response = null;
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
            if(contractingAccId != null && contractingAccId !=''){
                String contractingAccountGUID = [SELECT Id, Name, L2O_GUID__c FROM Account WHERE Id =: contractingAccId LIMIT 1].L2O_GUID__c;
                
                
                validPricingModel = [SELECT MasterLabel,L2O_Contracting_Account_GUID__c, L2O_Pricing_Model_Values__c
                                      FROM L2O_ContractingAccToPricingModel__mdt
                                      WHERE L2O_Contracting_Account_GUID__c =: contractingAccountGUID
                                      LIMIT 1];
                response = validPricingModel[0].L2O_Pricing_Model_Values__c;
 
            }
            
            return response;
        } catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        return response;
    }
    
}