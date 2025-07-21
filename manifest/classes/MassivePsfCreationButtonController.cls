public with sharing class MassivePsfCreationButtonController {
    @AuraEnabled
    public static void callMassiveCreation(Id recordId){
        PsfMassCreate.CreateForSubscription(recordId);
    }
}