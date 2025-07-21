public class DeveloperAlertAction {
    @InvocableMethod(label='Alert Developer After Static Code Analysis')
    public static void alertDeveloper(List<Id> userStoryIds) {
        List<copado__User_Story__c> stories = [SELECT Id, copado__Developer__c, Name FROM copado__User_Story__c WHERE Id IN :userStoryIds];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (copado__User_Story__c story : stories) {
            if (story.copado__Developer__c != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(story.copado__Developer__c);
                email.setSaveAsActivity(false);
                email.setSubject('Static Code Analysis Completed for User Story: ' + story.Name);
                email.setPlainTextBody('Static Code Analysis has been completed for User Story: ' + story.Name + 
                                       '. Please review the results in Copado.');
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}