trigger LeadTrigger on Lead__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        //Capture LastStatus and LastStatusChangedDate
        LeadTriggerHandler.leadStatusChange(Trigger.new, Trigger.oldMap);
    }
}