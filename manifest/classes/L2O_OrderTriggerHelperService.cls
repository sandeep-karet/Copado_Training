/**
* Company : PwC.
* @description : L2O_OrderTriggerHelperService will be executed from the L2O_OrderTriggerHandler and will update GUID Profile field on Order
* *****************************************************************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
 
public without sharing class L2O_OrderTriggerHelperService {
    
    // Variable to store string literal
    public static String strStatus = 'Status';
    
    /**
* @name  setGUID
* @description setGUID
* @param  newOrders for trigger.new Order
**/
    public void setGUID(List<Order> newOrders) {
        
        Set<String> allGuids = new Set<String>();
        for (Order tempOrder : newOrders) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempOrder.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempOrder.L2O_GUID__c)) {
                tempOrder.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempOrder.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempOrder.L2O_GUID__c);
            }
            
        }
    }
    
    /**
* @name  activateOrder
* @description activateOrder
* @param  newOrders for trigger.new Order
* @param  oldRecrdsMap for trigger.oldMap Orders
**/
    public void activateOrder(List<Order> newOrders,Map<Id,sObject> oldRecrdsMap) {
        
        
        for (Order tempOrder : newOrders) {
            // Activate Order if in Draft status for the USGH product first time only.
            if (oldRecrdsMap.get(tempOrder.Id).get(strStatus)== L2O_Constants.ORDER_STATUS_DRAFT 
                && tempOrder.Status == L2O_Constants.ORDER_STATUS_DRAFT && tempOrder.L2O_of_USGH_Order_Products__c > 0) {
                    tempOrder.Status = L2O_Constants.ORDER_STATUS_ACTIVATED; 
                }
            // Set L2O_Broadcast_Message__c to true for the USGH product first time only
            if(tempOrder.L2O_of_USGH_Order_Products__c == tempOrder.L2O_Number_of_Order_Products_Activated__c && !tempOrder.L2O_Broadcast_Message__c 
               && tempOrder.Status == L2O_Constants.ORDER_STATUS_ACTIVATED && tempOrder.L2O_of_USGH_Order_Products__c > 0 && 
              tempOrder.L2O_Last_Integration_Date__c == NULL){
                   tempOrder.L2O_Broadcast_Message__c = True; 
               }
        }
    }
    
    /**
* @name  publishPostSaleBroadcastPlatformEvent
* @description Publish Platform Event 'L2O_Post_sale_Broadcast__e'
* @param  updatedOrdrLst for trigger.new Orders
* @param  oldRecrdsMap for trigger.oldMap Orders
**/
    public void publishPostSaleBroadcastPlatformEvent(List<Order> updatedOrdrLst, Map<Id,sObject> oldRecrdsMap) {
        List<Id> ordIdList = new List<Id>();
        List<Order> ordRecList = new List<Order>();
        List<String> resultObjGUIDList = new List<String>();
        Map<String,List<String>> mapQryIndicator = new Map<String,List<String>>();
        Map<String,String> mapPltfmEntIndct = new Map<String,String>();
        String strPltfromEvntName = System.Label.L2O_Post_sale_Broadcast_PlatformEvent;
        String strPltfmEntIndct = '';
        
        // Calling L2O_PlatformEvent_MetadataHandler class to check if the Platform Event is Active
        L2O_PlatformEvent_MetadataHandler getmethodIns = new L2O_PlatformEvent_MetadataHandler();
        if(!getmethodIns.getMetadataPlatformEvents(strPltfromEvntName)){
            return;
        }
        for (Order tempOrd : updatedOrdrLst) { 
            // only for USGH/HHS first time.
            if(tempOrd.L2O_Broadcast_Message__c && tempOrd.L2O_Broadcast_Message__c != oldRecrdsMap.get(tempOrd.Id).get('L2O_Broadcast_Message__c') && 
               ((tempOrd.L2O_of_USGH_Order_Products__c == tempOrd.L2O_Number_of_Order_Products_Activated__c && tempOrd.L2O_of_USGH_Order_Products__c > 0) ||
                (tempOrd.L2O_of_USGH_Order_Products__c == 0 && tempOrd.L2O_of_Integrated_Backend_Order_Products__c == 0)
               )
              ){
                  strPltfmEntIndct = 'OI-I,'; // OI-I : Object Indicator (I : Insert)
                  mapPltfmEntIndct.put(tempOrd.L2O_GUID__c,strPltfmEntIndct);
                  ordIdList.add(tempOrd.Id);
              }
            // On updation on Broadcast Message? field
            if(tempOrd.L2O_of_Integrated_Backend_Order_Products__c > 0 && tempOrd.L2O_Broadcast_Message__c != oldRecrdsMap.get(tempOrd.Id).get('L2O_Broadcast_Message__c') && tempOrd.L2O_Broadcast_Message__c
               && tempOrd.Status == oldRecrdsMap.get(tempOrd.Id).get(strStatus)){
                   strPltfmEntIndct = 'OI-U,'; // OI-I : Object Indicator (U : Update)
                   mapPltfmEntIndct.put(tempOrd.L2O_GUID__c,strPltfmEntIndct);
                   ordIdList.add(tempOrd.Id);
               }
        }
        if(!ordIdList.isEmpty()){
            ordRecList = [SELECT L2O_GUID__c, Account.L2O_Broadcast_Message__c, Opportunity.StageName, Opportunity.SBQQ__Ordered__c, Opportunity.Type,
                          L2O_Number_of_Order_Products_Activated__c
                          FROM Order
                          WHERE Id =: ordIdList AND L2O_Number_of_Order_Products_Activated__c > 0];
        }
        // setIndicators method will set the Indicaotr to map with custom metadata
        setIndicators(ordRecList, strPltfmEntIndct, mapQryIndicator, mapPltfmEntIndct);
        if(!ordRecList.isEmpty() && !mapQryIndicator.isEmpty() && !mapPltfmEntIndct.isEmpty()){
            // L2O_PlatFormEvent_Ctrl class to publish Platform event 
            L2O_PlatFormEvent_Ctrl helper = new L2O_PlatFormEvent_Ctrl();
            resultObjGUIDList = helper.publishPlatFormEvents(L2O_Constants.OBJECT_ORDER,strPltfromEvntName,ordIdList,mapQryIndicator,mapPltfmEntIndct);
            if(resultObjGUIDList.size()>0){
                // Method to update related object's records after the event publish
                updtRecrdsAfterEvntPublish(resultObjGUIDList); 
            }
        }
    }
    
    /**
* @name  setIndicators
* @description set the indicator variables 
* @param  ordRecList List of Order record
* @param  strPltfmEntIndct variable will hold the platform event indicator
* @param mapQryIndicator this will hold the map of current records GUID as key and the repective query indicator
* @param mapPltfmEntIndct this will hold the map of current records GUID as key and the repective field indicator
**/
    
    public void setIndicators(List<Order> ordRecList, String strPltfmEntIndct, Map<String,List<String>> mapQryIndicator, Map<String,String> mapPltfmEntIndct){
        for(Order tempOrd : ordRecList){
            if (tempOrd.Opportunity.StageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN && tempOrd.Opportunity.SBQQ__Ordered__c){
                if(!tempOrd.Account.L2O_Broadcast_Message__c){
                    strPltfmEntIndct += 'CUI-I,'; // CUI - Client Update Indicator 
                    mapPltfmEntIndct.put(tempOrd.L2O_GUID__c,strPltfmEntIndct);
                }
                if(tempOrd.Opportunity.Type == L2O_Constants.OPPTY_TYPE_NEWBUSINESS || tempOrd.Opportunity.Type == L2O_Constants.OPPTY_TYPE_RESIGNBUSINESS){
                    mapQryIndicator.put(tempOrd.L2O_GUID__c, new List<String>());
                    mapQryIndicator.get(tempOrd.L2O_GUID__c).add('New');
                }
                if(tempOrd.Opportunity.Type == L2O_Constants.OPPTY_TYPE_EXISTINGBUSINESS){
                    mapQryIndicator.put(tempOrd.L2O_GUID__c, new List<String>());
                    mapQryIndicator.get(tempOrd.L2O_GUID__c).add('Exist');
                }
            }
        }
        
    }
    
    /**
* @name  updtRecrdsAfterEvntPublish
* @description Update the Order/Opportunity/Account records after the 'L2O_Post_sale_Broadcast__e' Event publish
* @param  resultObjGUIDList hold all the GUID of Published Order records
**/
    public void updtRecrdsAfterEvntPublish(List<String> resultObjGUIDList){
        List<Id> oppIdList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Order> updOrdList = new List<Order>();
        List<Opportunity> updOppList = new List<Opportunity>();
        List<Account> updAccList = new List<Account>();
        
        for(Order tempOrd : [SELECT Id, L2O_Last_Integration_Date__c,
                             AccountId, Account.L2O_Broadcast_Message__c,
                             OpportunityId
                             FROM Order
                             WHERE L2O_GUID__c =: resultObjGUIDList]){
                                 tempOrd.L2O_Last_Integration_Date__c = DateTime.now();
                                 updOrdList.add(tempOrd);
                                 if(!oppIdList.contains(tempOrd.OpportunityId)){
                                     oppIdList.add(tempOrd.OpportunityId);
                                 }
                                 if(!accIdList.contains(tempOrd.AccountId) && !tempOrd.Account.L2O_Broadcast_Message__c){
                                     accIdList.add(tempOrd.AccountId);
                                 }
                             }
        for(Opportunity tempOpp : [SELECT Id, L2O_Last_Integration_Date__c FROM Opportunity WHERE Id =: oppIdList]){
            tempOpp.L2O_Last_Integration_Date__c = DateTime.now();
            updOppList.add(tempOpp);
        }
        for(Account tempAcc : [SELECT Id, L2O_Broadcast_Message__c FROM Account WHERE Id =: accIdList]){
            tempAcc.L2O_Broadcast_Message__c = true;
            updAccList.add(tempAcc);
        }
        if(!updOrdList.isEmpty() && !updOppList.isEmpty()){
            update updOrdList;
            update updOppList;
        }
        if(!updAccList.isEmpty()){
            update updAccList;
        }
    } 
    /**
* @name  holdOrderCheckMethod
* @description Update the OrderItem from Activated to Draft if the Hoold Order field is true
* @param  updatedOrdrLst for trigger.new Orders
* @param  oldRecrdsMap for trigger.oldMap Orders
**/
    public void holdOrderCheckMethod(List<Order> updatedOrdrLst, Map<Id,sObject> oldRecrdsMap){
        List<Order> updOrdList = new List<Order>();
        List<OrderItem> updOrdItmList = new List<OrderItem>();
        
        for (Order tempOrd : updatedOrdrLst) {
            if(tempOrd.Status == L2O_Constants.ORDER_STATUS_ACTIVATED && tempOrd.Status != oldRecrdsMap.get(tempOrd.Id).get(strStatus)){
                updOrdList.add(tempOrd);
            }
        } 
        if(!updOrdList.isEmpty()){
            for(OrderItem tempOrdItm : [SELECT Id, SBQQ__Activated__c 
                                        FROM OrderItem 
                                        WHERE L2O_Hold_Order__c = true AND OrderId =: updOrdList AND SBQQ__Activated__c = true]){
                                            tempOrdItm.SBQQ__Activated__c = false;
                                            updOrdItmList.add(tempOrdItm);
                                        } 
        }
        if(!updOrdItmList.isEmpty()){
            update updOrdItmList; 
        }
        
    }
}