/**
* Company : PwC.
* @description : L2O_OrderItemTriggerHelperService will be executed from the L2O_OrderItemTriggerHandler and will update GUID Profile field on Contact
* *****************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/

public without sharing class L2O_OrderItemTriggerHelperService {
    
    /**
* @name  setGUID
* @description setGUID
* @param  newOrderItems for trigger.new OrderItem
**/
    public void setGUID(List<OrderItem> newOrderItems) {
        
        Set<String> allGuids = new Set<String>();
        for (OrderItem tempOrderItem : newOrderItems) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempOrderItem.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempOrderItem.L2O_GUID__c)) {
                tempOrderItem.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempOrderItem.L2O_GUID__c);
            }
            // Else add exisiting OrderItem GUID 
            else {
                allGuids.add(tempOrderItem.L2O_GUID__c);
            }
            
        }
    }
     /**
* @name  setContractAction
* @description setContractAction
* @param  newOrderItems for trigger.new OrderItem
**/
     public void setContractAction(List<OrderItem> newOrderItems) {
        List<Id> lstQLI = new List<Id>();
        Map<Id,String> mapOrderItemIDQLI = new Map<Id,String>();
        for (OrderItem tempOrderItem : newOrderItems) {
            if (!String.isBlank(tempOrderItem.SBQQ__QuoteLine__c) ) {
                lstQLI.add(tempOrderItem.SBQQ__QuoteLine__c);
            }
         }
         if(lstQLI.size() > 0){
             // Map OrderItem record Id to associated QuoteLine ContractAction
             for(OrderItem orderItemRec : [SELECT Id,SBQQ__QuoteLine__r.L2O_Contract_Action__c 
                                          FROM OrderItem 
                                          WHERE SBQQ__QuoteLine__c =: lstQLI]){
                    mapOrderItemIDQLI.put(orderItemRec.Id,orderItemRec.SBQQ__QuoteLine__r.L2O_Contract_Action__c);                          
              }
             for (OrderItem tempOrderItem : newOrderItems) {
                if (!String.isBlank(tempOrderItem.SBQQ__QuoteLine__c) ) {
                    tempOrderItem.SBQQ__ContractAction__c = mapOrderItemIDQLI.get(tempOrderItem.Id);
                }
             }
         }
    }
    }