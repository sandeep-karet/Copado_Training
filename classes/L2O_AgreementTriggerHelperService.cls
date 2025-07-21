/**
* Company : PwC.
* @description : L2O_AgreementTriggerHelperService will be executed from the L2O_AgreementTriggerHandler and will update GUID Profile field on Agreement
* *****************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/

public without sharing class L2O_AgreementTriggerHelperService {
    
    /**
* @name  setGUID
* @description setGUID
* @param  newAgreements for trigger.new Agreement
**/
    public void setGUID(List<Apttus__APTS_Agreement__c> newAgreements) {
        
        Set<String> allGuids = new Set<String>();
        for (Apttus__APTS_Agreement__c tempAgreement : newAgreements) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempAgreement.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempAgreement.L2O_GUID__c)) {
                tempAgreement.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempAgreement.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempAgreement.L2O_GUID__c);
            }
            
        }
    }
}