trigger Task_Trigger on Task (before insert, before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        for(Task newTask : trigger.new){
            if (trigger.isInsert) {
                newTask.Due_Date__c = newTask.ActivityDate;
            }
            
            if (trigger.isUpdate) {
                if (newTask.Due_Date__c != newTask.ActivityDate) {
                    newTask.Due_Date__c = newTask.ActivityDate;
                }
            }
        }
    }
}