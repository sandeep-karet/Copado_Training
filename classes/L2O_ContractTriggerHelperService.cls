/**
* Company : PwC.
* @description : L2O_ContractTriggerHelperService will be executed from the L2O_ContractTriggerHandler and will update GUID Profile field on Contract
* *****************************************************************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/

public without sharing class L2O_ContractTriggerHelperService {
    
    /**
* @name  setGUID
* @description setGUID
* @param  newContracts for trigger.new Contract
**/
    public void setGUID(List<Contract> newContracts) {
        
        Set<String> allGuids = new Set<String>();
        for (Contract tempContract : newContracts) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempContract.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempContract.L2O_GUID__c)) {
                tempContract.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempContract.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempContract.L2O_GUID__c);
            }
            
        }
    }
}