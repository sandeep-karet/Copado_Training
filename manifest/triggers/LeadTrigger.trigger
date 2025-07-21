trigger LeadTrigger on Lead (Before insert, Before Update, After update) {
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        if (Trigger.isUpdate && Trigger.isAfter) {
            //Update Opportunity and Contact to add Converted Lead reference
            LeadTriggerHelper.leadConvertionUpdate(Trigger.new);
        }
        
        if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
            //Capture LastStatus and LastStatusChangedDate
            LeadTriggerHelper.leadStatusChange(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate ) {
            LeadTriggerHelper.leadCurrencyChange(Trigger.new, Trigger.oldMap);            
        }
    }
}