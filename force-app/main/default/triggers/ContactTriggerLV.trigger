trigger ContactTriggerLV on Contact__c (after insert, after update) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){

        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            ContactTriggerLVHelper.createAccountContactRel(trigger.new,trigger.newmap,trigger.oldmap);
            if(Trigger.isUpdate)
            ContactTriggerLVHelper.createAccountContactRel(trigger.old,trigger.newmap,trigger.oldmap);
        
        }
    }
}