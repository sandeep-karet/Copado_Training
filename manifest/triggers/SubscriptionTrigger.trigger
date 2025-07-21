trigger SubscriptionTrigger on SBQQ__Subscription__c (before delete) {
    if(Trigger.isDelete && Trigger.isBefore) {
        Set<Id> subIdSet = Trigger.oldMap.keySet();
        Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());                
        if (!DS.Disable_Triggers__c) {
            AggregateResult[] psfResult = [SELECT COUNT(Id) psfCount, Subscription__c FROM Plan_Specific_Fees__c WHERE Subscription__c IN :subIdSet GROUP BY Subscription__c];
            AggregateResult[] assetResult = [SELECT COUNT(Id) assetCount, SBQQ__RequiredBySubscription__c FROM Asset 
                                             WHERE SBQQ__RequiredBySubscription__c IN :subIdSet GROUP BY SBQQ__RequiredBySubscription__c];
     
            // TODO: check if there is existing contract 
            // AggregateResult[] contResult = [SELECT Id, COUNT(SBQQ__Contract__c) contCount FROM SBQQ__Subscription__c 
            //                                  WHERE Id IN :subIdSet GROUP BY Id];
            // Map<Id, Integer> contMap = new  Map<Id, Integer>();
            // for(AggregateResult ar : contResult) {                
            //     contMap.put((Id)ar.get('Id'),(Integer)ar.get('contCount'));               
            // } 
            
            
            Map<Id, Integer> psfMap = new  Map<Id, Integer>();
            for(AggregateResult ar : psfResult) {                
                psfMap.put((Id)ar.get('Subscription__c'),(Integer)ar.get('psfCount'));               
            } 
            
            Map<Id, integer> assetMap = new Map<Id, Integer>();
            for(AggregateResult ar : assetResult) {                
                assetMap.put((Id)ar.get('SBQQ__RequiredBySubscription__c'),(Integer)ar.get('assetCount'));               
            } 
            system.debug(psfMap);
            system.debug(assetMap);
            
            for(SBQQ__Subscription__c sub : Trigger.old) {
                String errorMsg ='';
                if(psfMap.containsKey(sub.Id)) {
                    errorMsg += psfMap.get(sub.Id) + ' PSF ';
                }
                if(assetMap.containsKey(sub.Id)) {
                    errorMsg += assetMap.get(sub.id) + ' Asset ';
                }
                if(errorMsg != '') {                
                	errorMsg += 'associated to this subscription.'; 
                    sub.addError(errorMsg);
                }
            }       
        }                      
    }
}