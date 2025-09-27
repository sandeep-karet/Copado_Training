trigger ClientMemberCodeTrigger on ClientMemberCode__c (after insert, after delete) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){
        if (Trigger.isAfter && Trigger.isInsert) {
            ClientMemberCodeTriggerHandler.handleCMCAfterInsert(Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isDelete){
            ClientMemberCodeTriggerHandler.handleAfterCMCUpdate(Trigger.old);
        }
    }
}