global class OpportunityHSUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
   
    Exception[] errors = new Exception[0];
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Account__c, Type__c FROM Opportunity__c WHERE Type__c = \'Renewal\'');
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity__c> scope){
        OpportunityService.updateHealthScores(scope);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Batch process has been completed');
        mail.setPlainTextBody('Batch Process has completed. Please see the attached file for any errors');
        String[] toAddresses = new list<string> {'Virinchi.Bairisetty@livongo.com','saikalyani.jangala@livongo.com'};
        mail.setToAddresses(toAddresses);
        
        String finalstr = 'Message'+','+'Cause'+','+'Line Number'+'\n';
        
        for(Exception e: errors){
            String recordString = e.getMessage()+','+e.getCause()+','+e.getLineNumber()+'\n';
            finalstr = finalstr +recordString;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalstr);
        csvAttc.setFileName('Exceptions.csv');
        csvAttc.setBody(csvBlob);
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }
}