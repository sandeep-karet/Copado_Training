trigger EnrollmentCommunicationsTrigger on Enrollment_Communications_Survey__c (after update) {
        LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
        if(switchFlg != null && switchFlg.Triggers__c){
                EnrollmentCommunicationsTriggerHandler.updateContractrecords(Trigger.new);
        }
}