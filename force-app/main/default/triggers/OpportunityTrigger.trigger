trigger OpportunityTrigger on Opportunity__c (after insert, after update, before insert, before update) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){
        if(OpportunityTriggerHandler.isFirstTime){
            if(!Test.isRunningTest())
            OpportunityTriggerHandler.isFirstTime = false;
            
            if(trigger.isBefore && trigger.isInsert) {
                OpportunityTriggerHandler.updateProbability(trigger.new, new Map<Id, Opportunity__c>());
                OpportunityTriggerHandler.updateRevenueBucket(trigger.new, new Map<Id, Opportunity__c>());
            }
            if(trigger.isAfter && trigger.isUpdate) {
                OpportunityTriggerHandler.handleOpportunityAfterUpdate(Trigger.oldMap, Trigger.new);
            }
            if(trigger.isAfter && trigger.isInsert) {
                OpportunityTriggerHandler.handleOpportunityAfterInsert(Trigger.new);
            } 
            if(trigger.isBefore && trigger.isUpdate){
                OpportunityTriggerHandler.handleOppRevSynergyflagUpdates(Trigger.newMap);
                OpportunityTriggerHandler.updateProbability(trigger.new, trigger.oldMap);
                OpportunityTriggerHandler.updateRevenueBucket(trigger.new, trigger.oldMap);
            }
        }
    }
}