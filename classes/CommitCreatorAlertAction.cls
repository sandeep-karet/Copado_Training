public class CommitCreatorAlertAction {
    @InvocableMethod(label='Alert Commit Creator After Static Code Analysis')
    public static void alertCommitCreator(List<FlowInputs> inputs) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (FlowInputs input : inputs) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(input.createdById);
            email.setSaveAsActivity(false);
            email.setSubject('Static Code Analysis Completed for User Story: ' + input.userStoryName);
            email.setPlainTextBody('Static Code Analysis has been completed for User Story: ' + input.userStoryName + 
                                   '. Please review the results in Copado.');
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public class FlowInputs {
        @InvocableVariable(required=true)
        public Id createdById;

        @InvocableVariable(required=true)
        public String userStoryName;
    }
}