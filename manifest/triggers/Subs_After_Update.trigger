trigger Subs_After_Update on SBQQ__Subscription__c (after update) {    
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        if (Trigger.isAfter && Trigger.isUpdate) {
            List<Id> subIdList = new List<Id>();
            for(SBQQ__Subscription__c sub: Trigger.new) {
                SBQQ__Subscription__c oldSub = Trigger.oldMap.get(sub.Id);
                if(sub.Termination_Date__c != oldSub.Termination_Date__c){
                    //system.debug(sub.Id);
                    subIdList.add(sub.Id); 
                }
            }
            if(subIdList.size() > 0){
            	psfProductEndDateBch runPsfBch = new psfProductEndDateBch(subIdList);
            	Database.executeBatch(runPsfBch);  
            }
        }
    }        
}