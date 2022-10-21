trigger ClientMemberCodeTrigger on ClientMemberCode__c (after insert, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ClientMemberCodeTriggerHandler.handleCMCAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isDelete){
        ClientMemberCodeTriggerHandler.handleAfterCMCUpdate(Trigger.old);
    }
}