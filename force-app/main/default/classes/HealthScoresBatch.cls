global class HealthScoresBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static final Id ACCOUNT_HEALTH_SCORE_RECORD_TYPE_ID = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Account_Health_Score').getRecordTypeId();
    public static final Id PROGRAM_HEALTH_SCORE_RECORD_TYPE_ID = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Program_Health_Score').getRecordTypeId();
    public static List<Health_Score_Elements__mdt> hsElementsMDT {get; set;}
    
    static {
        Health_Score_Elements__mdt[] hsElementsMDT1 = [SELECT Id, Element_Section__c, Health_Score_Record_Type__c, 
                                                      Health_Segment__c, Program__c, Recommended_Action_Steps__c, Sort_Order__c, Display_Fields__c FROM Health_Score_Elements__mdt];
    	hsElementsMDT = hsElementsMDT1;
    }
    
    
    Exception[] errors = new Exception[0];
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Enrollment_Percentage_rPwDs__c, Enrollment_Percentage_rPwHs__c, ' +
                                        'Activation__c, Activated_Percent_HTN__c, Usage_Last_30_day_Diabetes__c, Usage_Last_30_day_HTN__c, ' +
                                        'Email_Coverage_Percentage_DM__c, Email_Coverage_Percentage_HTN__c ' +
                                        'FROM ACCOUNT__c WHERE (RecordType.Name = \'Client Account\' OR RecordType.Name = \'Partner Account\') ');
    }
    
    global void execute(Database.BatchableContext bc, List<Account__c> scope){
        List<Health_Score__c> hsListToCreate = new List<Health_Score__c>();       
        for (Account__c acc : scope) {
            for (Health_Score_Elements__mdt hsMdt: hsElementsMDT) {
                Health_Score__c hs = new Health_Score__c();
                hs.Account__c = acc.Id;
                hs.Health_Segment__c = hsMdt.Health_Segment__c;
                if (hsMdt.Health_Score_Record_Type__c == 'Program Health Score') {
                    hs.RecordTypeId = PROGRAM_HEALTH_SCORE_RECORD_TYPE_ID;
                    hs.Program__c = hsMdt.Program__c;
                    if (hs.Health_Segment__c == 'Enrollment' && hs.Program__c == 'Diabetes') {
                       hs.Actual_Result__c = String.valueOf(acc.Enrollment_Percentage_rPwDs__c); 
                    }
                    else if (hs.Health_Segment__c == 'Enrollment' && hs.Program__c == 'Hypertension') {
                       hs.Actual_Result__c = String.valueOf(acc.Enrollment_Percentage_rPwHs__c); 
                    }
                    else if (hs.Health_Segment__c == 'Activation' && hs.Program__c == 'Diabetes') {
                       hs.Actual_Result__c = String.valueOf(acc.Activation__c); 
                    }
                    else if (hs.Health_Segment__c == 'Activation' && hs.Program__c == 'Hypertension') {
                       hs.Actual_Result__c = String.valueOf(acc.Activated_Percent_HTN__c); 
                    }
                    else if (hs.Health_Segment__c == 'Active 30' && hs.Program__c == 'Diabetes') {
                       hs.Actual_Result__c = String.valueOf(acc.Usage_Last_30_day_Diabetes__c); 
                    }
                    else if (hs.Health_Segment__c == 'Active 30' && hs.Program__c == 'Hypertension') {
                       hs.Actual_Result__c = String.valueOf(acc.Usage_Last_30_day_HTN__c); 
                    }
                    else if (hs.Health_Segment__c == 'Email Coverage' && hs.Program__c == 'Diabetes') {
                       hs.Actual_Result__c = String.valueOf(acc.Email_Coverage_Percentage_DM__c); 
                    }
                    else if (hs.Health_Segment__c == 'Email Coverage' && hs.Program__c == 'Hypertension') {
                       hs.Actual_Result__c = String.valueOf(acc.Email_Coverage_Percentage_HTN__c); 
                    }
                }
                else {
                    hs.RecordTypeId = ACCOUNT_HEALTH_SCORE_RECORD_TYPE_ID;
                }
                hs.Element_Section__c = hsMdt.Element_Section__c;
                hs.Recommended_Action_Steps__c = hsMdt.Recommended_Action_Steps__c;
                hs.Sort_Order__c = hsMdt.Sort_Order__c;
                hs.Display_Fields__c = hsMdt.Display_Fields__c;
                hsListToCreate.add(hs);
            }
        }
        
        if (!hsListToCreate.isEmpty()) {
            Insert hsListToCreate;
        }
        
        List<Opportunity__c> oppList = [SELECT Id, Account__c, Type__c FROM Opportunity__c WHERE Account__c IN :scope];
        OpportunityService.updateHealthScores(oppList);
        
        List<Contract__c> conList = [SELECT Id, Account__c FROM Contract__c WHERE Account__c IN : scope];
        ContractService.updateHealthScores(conList);
        
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