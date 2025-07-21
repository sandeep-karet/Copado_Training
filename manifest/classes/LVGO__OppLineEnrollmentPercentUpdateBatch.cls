global class OppLineEnrollmentPercentUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    global String finalstr;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Enrollment_Percentage__c, Opportunity__c,Program_Family__c, Pricing_Structure__c, Product2__c, OpportunityProductName__c FROM ' +
                                        'OpportunityLineItem__c');
    }
    
    global void execute(Database.BatchableContext bc, List<OpportunityLineItem__c> scope){
        List<OpportunityLineItem__c> oppLines = OppLineEnrollmentPercentService.updateEnrollmentPercentage(scope);
        if (oppLines.size() > 0) {
            Database.SaveResult[] srList = Database.update(oppLines, false);
            finalstr = 'Id'+','+'Status Code'+','+'Message'+'\n';           
            for(Integer i=0; i < srList.size(); i++) {
                String recordString = '';
                if (srList.get(i).isSuccess()) {
                    recordString = oppLines.get(i).Id+','+ 'success'+ ',' + 'success' +'\n';
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : srList.get(i).getErrors()) {
                        recordString = oppLines.get(i).Id+','+ err.getStatusCode()+ ',' + err.getMessage()+'\n';   
                    }
                }
                finalstr = finalstr + recordString;
            }            
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Batch process has been completed');
        mail.setPlainTextBody('Batch Process has completed. Please see the attached file for any errors');
        String[] toAddresses = new list<string> {'saikalyani.jangala@teladochealth.com','virinchi.bairisetty@teladochealth.com'};
        mail.setToAddresses(toAddresses);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalstr);
        csvAttc.setFileName('Exceptions.csv');
        csvAttc.setBody(csvBlob);
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }
}