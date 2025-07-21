/**
* A Trigger for the Account Object
*  
*/

trigger AccountTrigger on Account__c (before insert, before update, after insert, after update) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){
        if(Trigger.isBefore) 
        {
            if (Trigger.isInsert) {
                AccountTriggerHandler.updateState(new Map<Id, Account__c>(), Trigger.new);
            }
            if (Trigger.isUpdate) {
                AccountTriggerHandler.updateState(Trigger.oldmap,  Trigger.new);
                AccountTriggerHandler.updateAccountHealthColor(Trigger.oldMap, Trigger.New);
            }
        }
        if(Trigger.isAfter) 
        {
            if (Trigger.isInsert) {
                AccountTriggerHandler.handleAccountAfterInsert(Trigger.new);
            }
            if (Trigger.isUpdate) {
                AccountTriggerHandler.handleAccountUpdate(Trigger.oldmap,  Trigger.new);
            }
        }
        if (Trigger.isUpdate && Trigger.isAfter) {
            
            AccountTriggerHandler.updateOppRevSynergyFlag(Trigger.oldmap,  Trigger.new);
        }
    }
}