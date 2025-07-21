/*************************************************************************     
* @description This class is used to update the Launch status of a Quoteline
* @param NA
* @Author InfoSys Developer
https://teladochealthglobalcrm--gcrmdev.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#**************************************************************************/
public class QuotelineLaunchStatusBatch implements Database.Batchable<sObject>, Schedulable {
    
    Public Map<Id,String> mapOfErrOrRecords = New Map<Id,String>();
    Public static final String LAUNCHED = System.Label.Quoteline_Launched;
    Public static final String SCHEDULE_JOB_RECIPIENT = System.Label.QuotelineLaunchStatusBatchRecipient;
    
    /*************************************************************************
* @description This method is a Query locator to return the Quoteline Records
* @param bc is a Batcheable Context
* @return Returns the queried records
* @Author InfoSys Developer
**************************************************************************/
    Public Database.QueryLocator start(Database.BatchableContext bc) {
        
        string query = 'SELECT Id, Name, SBQQ__StartDate__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Status__c = \'Accepted\' AND SBQQ__EffectiveStartDate__c = TODAY';
        return Database.getQueryLocator(query);
        
    }
    
    /*************************************************************************
* @description This method is an executable method to update the Quotelines and Opportunity line items
* @param bc is a Batcheable Context
* @param quotelineList is the list of quried Quotelines
* @Author InfoSys Developer
**************************************************************************/
    @SuppressWarnings('PMD.AvoidDebugStatements, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    Public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quotelineList){
        for(SBQQ__QuoteLine__c quoteLine : quotelineList){            
            quoteLine.Launch_Status__c = LAUNCHED;
        }
      
        for(database.SaveResult sr1 :  database.update(quotelineList,false)){
            if(!sr1.isSuccess()){
                Database.Error errors =  sr1.getErrors().get(0);
                mapOfErrOrRecords.put(sr1.getId(),errors.getMessage());                
            }
        }                
    }
    
    /*************************************************************************
* @description Finish method to send an Email after the batch process is complete
* @param bc is the Batcheable context
* @Author Infosys Developer
**************************************************************************/
    Public void finish(Database.BatchableContext bc){ //Finish Method to send an Email        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Batch class - QuotelineLaunchStatusBatch ' + a.Status);
        String csvOfIds = 'ID,Errors\n';
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        if( mapOfErrOrRecords.size()>0){
            for (Id erroredRecord : mapOfErrOrRecords.keySet()) {
                csvOfIds += erroredRecord + ',' + mapOfErrOrRecords.get(erroredRecord) +  + '\n';
            }
            attachment.setFileName('[' + Date.today() + '] QuotelineLaunchStatusBatch.csv');
            attachment.setBody(Blob.valueOf(csvOfIds));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        }
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        String[] toAddresses = new String[] {SCHEDULE_JOB_RECIPIENT};
            mail.setToAddresses(toAddresses);        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    /*************************************************************************
     * @description - Method to schedule the batch job
     * @param sc Schedulable context
     * @Author Infosys Developer
    **************************************************************************/
    Public void execute(System.SchedulableContext sc){ //Schedulable interface
        QuotelineLaunchStatusBatch quotelineBatchjob = New QuotelineLaunchStatusBatch();
        database.executeBatch(quotelineBatchjob);
    }    
    
}