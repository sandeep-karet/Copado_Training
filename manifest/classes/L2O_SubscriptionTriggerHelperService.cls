/**
* Company : PwC.
* @description : L2O_SubscriptionTriggerHelperService will be executed from the L2O_SubscriptionTriggerHandler and will update GUID field on Asset
* *****************************************************************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
public without sharing class L2O_SubscriptionTriggerHelperService {
    
    /**
    * @name  setGUID
    * @description setGUID
    * @param newSubscriptions for trigger.new Subscription
    **/
    public void setGUID(List<SBQQ__Subscription__c> newSubscriptions) {
        
        Set<String> allGuids = new Set<String>();
        for (SBQQ__Subscription__c tempSubscription : newSubscriptions) {
            
            // Create new GUID if subscription is new or has invalid GUID
            
            if (String.isBlank(tempSubscription.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempSubscription.L2O_GUID__c)) {
                tempSubscription.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempSubscription.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempSubscription.L2O_GUID__c);
            }
            
        }
    }

    /**
    * @name  updateContract
    * @description to update Contract start date & term during amendment Subscription
    * @params  none
    **/
    public void updateContract() {

        //Set Exception Log MethodName
        setExceptionVars('updateContract');
        
        Set<Id> setAmendContractIds = new Set<Id>();
        List<SBQQ__Subscription__c> newSubs = Trigger.new;
        Map<Id,SBQQ__Subscription__c> mapOldSubs = (Map<Id,SBQQ__Subscription__c>)Trigger.oldMap;
        
        for (SBQQ__Subscription__c newSub : newSubs) {
            
            //For Insert only Amend subscriptions
            if(Trigger.isInsert && newSub.SBQQ__TerminatedDate__c == null && newSub.SBQQ__Quantity__c > 0){
                setAmendContractIds.add(newSub.SBQQ__Contract__c);
            }
            //For Update when Amend subscriptions have Start Date updated
            if(Trigger.isUpdate && newSub.SBQQ__TerminatedDate__c == null && newSub.SBQQ__Quantity__c > 0 &&
               newSub.SBQQ__StartDate__c != mapOldSubs.get(newSub.Id).SBQQ__StartDate__c){
                setAmendContractIds.add(newSub.SBQQ__Contract__c);
            }
        }

        if(!setAmendContractIds.isEmpty()){
            Map<ID, Contract> mapContractStartDate = new Map<ID, Contract>([SELECT Id,StartDate,ContractTerm,
                                                                            (Select SBQQ__StartDate__c
                                                                                From SBQQ__Subscriptions__r
                                                                                Where SBQQ__TerminatedDate__c = null AND SBQQ__Quantity__c > 0
                                                                                ORDER BY SBQQ__StartDate__c ASC Limit 1)
                                                                            FROM Contract WHERE Id IN:setAmendContractIds]);
            
            Map<ID, Contract> mapContractEndDate = new Map<ID, Contract>([SELECT Id,
                                                                        (Select SBQQ__EndDate__c
                                                                            From SBQQ__Subscriptions__r
                                                                            Where SBQQ__TerminatedDate__c = null AND SBQQ__Quantity__c > 0
                                                                            ORDER BY SBQQ__EndDate__c DESC Limit 1)
                                                                        FROM Contract WHERE Id IN:setAmendContractIds]);
            List<Contract> lstUpdateContracts = new List<Contract>();

            for(Contract contract :  mapContractStartDate.Values()){

                //Check if Contract has the earliest Amendment Sub's Start date or not
                if(contract.StartDate != mapContractStartDate.get(contract.Id).SBQQ__Subscriptions__r[0].SBQQ__StartDate__c &&
                    contract.StartDate > mapContractStartDate.get(contract.Id).SBQQ__Subscriptions__r[0].SBQQ__StartDate__c){
                    
                    //Save Contract Start Date
                    Contract newContract = new Contract();
                    newContract.Id = contract.Id;
                    newContract.StartDate = mapContractStartDate.get(contract.Id).SBQQ__Subscriptions__r[0].SBQQ__StartDate__c;

                    //Calculate the term
                    Date startDate = mapContractStartDate.get(contract.Id).SBQQ__Subscriptions__r[0].SBQQ__StartDate__c;
                    Date endDate = mapContractEndDate.get(contract.Id).SBQQ__Subscriptions__r[0].SBQQ__EndDate__c;

                    Integer contractTerm = startDate.monthsBetween(endDate);
                    if(endDate.day() > startDate.day()) {
                        contractTerm++;
                    }
    
                    newContract.ContractTerm = contractTerm;
                    lstUpdateContracts.add(newContract);
                }
            } 
            if(!lstUpdateContracts.isEmpty()){
                update lstUpdateContracts;
            }
        }
    }
    
    /**
    * @name  updateSubscription
    * @description to update original Subscription with the amended subscriptions data
    * @params  none
    **/
    public void updateSubscription(){
        
        //CON-162092
        //Set Exception Log MethodName
        setExceptionVars('updateSubscription');
        
        List<SBQQ__Subscription__c> newSubs = Trigger.new;
        List<SBQQ__Subscription__c> lstUpdateOriginalSubs = new List<SBQQ__Subscription__c>();
        
        for (SBQQ__Subscription__c newAmendedSub : newSubs) {
            
            //Check if new sub is amended sub
            if(newAmendedSub.SBQQ__RevisedSubscription__c != null){
                
                //Update amended Participant Qty onto the Original Sub
                SBQQ__Subscription__c originalSub = new SBQQ__Subscription__c();
                originalSub.Id = newAmendedSub.SBQQ__RevisedSubscription__c;
                originalSub.L2O_Participant_Quantity__c = newAmendedSub.L2O_Participant_Quantity__c;
                
                lstUpdateOriginalSubs.add(originalSub);
            }
        }
        
        if(!lstUpdateOriginalSubs.isEmpty()){
            update lstUpdateOriginalSubs;
        }
    }

    /**
    * @name  setExceptionVars
    * @description To update Exception log variables ClassName & MethodName
    * @param methodName To pass the current MethodName
    **/
    public void setExceptionVars(String methodName){
        If (methodName != null){
            L2O_SubscriptionTriggerHandler.className = 'L2O_SubscriptionTriggerHelperService';
            L2O_SubscriptionTriggerHandler.methodName = methodName;
        }
    }

}