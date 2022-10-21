global class ClientARRUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    Exception[] errors = new Exception[0];
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM ACCOUNT__c');
    }
    global void execute(Database.BatchableContext bc, List<Account__c> scope){
        // process each batch of records
        Set<Id> accIdSet = new Set<Id>();
        for(Account__c acc: scope){
            accIdSet.add(acc.Id);
        }
        
        if(accIdSet.Size() > 0){
            try {
                OpportunityService.handleClientARRUpdateFromAccount(accIdSet);
            } 
            catch(Exception e) {
                errors.add(e);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Errors occurred during batch process.');
        mail.setPlainTextBody('Batch Process has completed');
        String[] toAddresses = new list<string> {'Virinchi.Bairisetty@livongo.com'};
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