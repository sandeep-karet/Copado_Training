trigger EnrollmentCommunicationsTrigger on Enrollment_Communications_Survey__c (after update) {

        EnrollmentCommunicationsTriggerHandler.updateContractrecords(Trigger.new);

}