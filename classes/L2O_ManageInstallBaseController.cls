/**
* Company : PwC.
* @description : L2O_ManageInstallBaseController will be used to handle Manage Install Base flow from Account.
* *******************************************************************************************************************************************
* History : 
* @date 06/07/2022
* @author Lakshitha Salian
*/

public without sharing class L2O_ManageInstallBaseController{
    
    //Exception log variables
    public static String className = '';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;
 
    /**
    * @name  getAllContracts   
    * @description This method returns all valid Contracts of specific Account
    * @param accountId for the Account Id
    * @return List of Contracts
    **/
    @AuraEnabled
    public static List<Contract> getAllContracts(String accountId){

                
        className = 'L2O_ManageInstallBaseController';
        methodName = 'getAllContracts';
        List<Contract> lstAllContracts = new List<Contract>();
        try {
             if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
        
            lstAllContracts = [SELECT Id,Name, AccountId, StartDate, EndDate, ContractTerm, Status, ActivatedDate, ContractNumber,SBQQ__Opportunity__r.Name, SBQQ__Quote__r.Name, SBQQ__Quote__c
                               FROM Contract WHERE AccountId =:accountId AND EndDate > TODAY AND Status = 'Activated' ORDER BY CREATEDDATE DESC];
            return lstAllContracts; 
        }catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        // Return all valid Contracts of specific Account 
        return lstAllContracts;
    }
    
    /**
    * @name  getMetaDataSettings   
    * @description This method returns custom metadata texts for the Manage Install Base Flow
    * @return List of Metadata settings
    **/
    @AuraEnabled
    public static List<L2O_ManageInstallBase__mdt> getMetaDataSettings(){
        
        className = 'L2O_ManageInstallBaseController';
        methodName = 'getMetaDataSettings';
        List<L2O_ManageInstallBase__mdt> lstAllMetadata = new  List<L2O_ManageInstallBase__mdt>();
        
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            lstAllMetadata = [SELECT MasterLabel, L2O_AmendAssetsOnly__c, L2O_AmendBothOption__c,L2O_ExpansionOption__c,L2O_ChangeOrderOption__c,L2O_RecontractingOption__c, L2O_AmendOptionHeader__c,L2O_AmendSubTypeHeader__c,L2O_AllContractsHeader__c,L2O_ContractListNote__c,L2O_CpqContractAmendURL__c,L2O_CpqAccountAmendURL__c,L2O_ContractListNote2__c,L2O_ContractPathChangeOption__c
                    			FROM L2O_ManageInstallBase__mdt WHERE DeveloperName ='L2O_ManageInstallBase_FlowText'];
            return lstAllMetadata;
        } catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        // Return custom metadata texts for the Manage Install Base Flow
        return lstAllMetadata;
    }

    /**
    * @name  updateContract   
    * @description This method updates the sub type on Contract
    * @param contractId for the Contract Id
    * @param subtype for the Selected Subtype
    * @return This method returning response as String
    **/
    @AuraEnabled
    public static String updateContract(String contractId, String subtype){
        
        className = 'L2O_ManageInstallBaseController';
        methodName = 'updateContract';
        String response = '';  
        
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            // update Contract record
            Contract con = [SELECT Id,L2O_Amendment_Opportunity_SubType__c FROM Contract WHERE Id = :contractId];
            con.L2O_Amendment_Opportunity_SubType__c = subtype;
            update con;
           	response ='Success';
         } catch (Exception ex) {
             response = 'Error';
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
         } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
  
      	return response;
    }

}