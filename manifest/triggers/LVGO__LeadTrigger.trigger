trigger LeadTrigger on Lead__c (Before insert, Before Update) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){       
        if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
            //Capture LastStatus and LastStatusChangedDate
            LeadTriggerHandler.leadStatusChange(Trigger.new, Trigger.oldMap);
        }
    }
}