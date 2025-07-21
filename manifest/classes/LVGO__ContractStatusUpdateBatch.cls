/*
* ClassName: BatchContractUpdate
* CalledFrom: Developer Console(Scheduled Job) 
* Description :This is a batch class which will update Contract Object on daily basis
*/
global class ContractStatusUpdateBatch implements Database.Batchable<SOBJECT>,Schedulable,Database.AllowsCallouts, Database.Stateful
{
    global String strResult = 'The Batch (ContractStatusUpdateBatch) is successfully executed:<br/><br/>';
    global String strResultCounts = '';
    global Integer processedRecords = 0, successRecords = 0, failRecords = 0;
    /***************************************************************
This method will fetch Contract record that needs to be processed 
**************************************************************** */
    global  Database.QueryLocator Start(Database.BatchableContext BC) 
    {   
        
        return Database.getQueryLocator('Select Id,RecordType.Name,Status__c,ContractNumber__c, Client_Overview__r.Status__c ,Contract_Effective_Date__c,Contract_Termination_Date__c,Program_Start_Date__c,Program_End_Date__c from Contract__c where Contract_Effective_Date__c=TODAY OR Contract_Termination_Date__c=TODAY OR Program_Start_Date__c=TODAY OR Program_End_Date__c = TODAY order by recordtype.name ASC');
        
    }
    /***************************************************************
This method will be used to Schedule this batch on timely basis
**************************************************************** */
    global void execute(SchedulableContext sc){
        ContractStatusUpdateBatch objBCM=new ContractStatusUpdateBatch();
        if(!test.isrunningtest())
            database.executebatch(objBCM,1);
    }
    /***************************************************************
This method update Contract record based on various date fields
**************************************************************** */
    global void Execute(Database.BatchableContext BC,List<Contract__c> listContracts)
    {
        System.debug('listContracts: '+listContracts);
        List<Contract__c> listUpdateContract=new List<Contract__c>();
        Map<Id,String> mapToContractsWithOldStatus = new  Map<Id,String>();
        Map<Id,String> mapToContractsWithNewStatus = new  Map<Id,String>();
        Map<Id,String> mapToContractsWithContractNumber = new Map<Id,String>();
        for(Contract__c recContr:listContracts)
        {
            mapToContractsWithOldStatus.put(recContr.Id,recContr.Status__c);
            mapToContractsWithContractNumber.put(recContr.Id,recContr.ContractNumber__c);
            if(recContr.RecordType.Name =='Client Overview' && recContr.Status__c=='Draft' 
               && recContr.Contract_Effective_Date__c != null && recContr.Contract_Effective_Date__c == Date.today()){
                recContr.Status__c='Activate';
                listUpdateContract.add(recContr);
            }else if(recContr.RecordType.Name =='Client Overview' && recContr.Status__c=='Active' 
                    && recContr.Contract_Termination_Date__c != null && recContr.Contract_Termination_Date__c == Date.today()){
                recContr.Status__c='Expired'; 
                listUpdateContract.add(recContr);  
            }else if(recContr.RecordType.Name =='Program Overview' && recContr.Status__c=='Draft' 
                    && recContr.Program_Start_Date__c != null && recContr.Client_Overview__r.Status__c =='Active' && recContr.Program_Start_Date__c == Date.today()){
                recContr.Status__c='Activate';
                listUpdateContract.add(recContr);
            }else if(recContr.RecordType.Name =='Program Overview' && recContr.Status__c=='Active' 
                    && recContr.Program_End_Date__c != null && recContr.Program_End_Date__c == Date.today()){
                recContr.Status__c='Expired';   
                listUpdateContract.add(recContr);
            }
            mapToContractsWithNewStatus.put(recContr.Id,recContr.Status__c);
            
        }
        if(listUpdateContract != null && listUpdateContract.size()>0) 
        {
            
            Database.SaveResult[] srList = Database.update(listUpdateContract, false);
            processedRecords += srList.size();
            Integer successCount = 0;
            Integer errorCount = 0;
            strResult += '<table border="1" style="border-collapse: collapse"><tr><th>Id</th><th>Contract Number</th><th>Previous Status</th><th>Updated Status</th><th>Result</th></tr>';
            for (Database.SaveResult sr : srList) {
                String contractNo = ' ';
                String previousStatus = ' ';
                String updatedStatus = ' ';
                if(mapToContractsWithContractNumber.containsKey(sr.getId())){
                    contractNo = mapToContractsWithContractNumber.get(sr.getId());
                } 
                if(mapToContractsWithContractNumber.containsKey(sr.getId())){
                    previousStatus = mapToContractsWithOldStatus.get(sr.getId());
                } 
                
                if(mapToContractsWithContractNumber.containsKey(sr.getId())){
                    updatedStatus = mapToContractsWithNewStatus.get(sr.getId());
                }
                
                if (sr.isSuccess()) {                   
                    
                    strResult += '<tr><td>' + sr.getId() + '</td><td>' + contractNo + '</td><td>' + previousStatus + '</td><td> '+ updatedStatus + '</td><td>' + 'Success' + '</td></tr> ' ;
                    successCount ++;
                } else {
                    errorCount ++;
                    for(Database.Error objErr : sr.getErrors()) {
                        String Error = '';
                        Error = objErr.getStatusCode() + ' : ' + objErr.getMessage() +':'+objErr.getFields();
                        strResult += '<tr><td>' + sr.getId() + '</td><td>' + contractNo + '</td><td>' + previousStatus + '</td><td> '+ updatedStatus + '</td><td> ' + Error + '</td></tr> ' ;
                        
                    }
                } 
            }
            strResult += '</table>';
            successRecords += successCount;
            failRecords += errorCount;
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        strResultCounts += 'Total Records Processed : '+ processedRecords + '<br/>';
        strResultCounts += 'Total Success : ' + successRecords + '<br/>';
        strResultCounts += 'Total Error : ' + failRecords + '<br/>';
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();  
        if(LABEL.ContractStatusUpdateBatchResultEmail.contains(';')) 
        {    
            sendTo = LABEL.ContractStatusUpdateBatchResultEmail.split(';');
        } 
        else 
        {
            sendTo.add(LABEL.ContractStatusUpdateBatchResultEmail);     
        }
        
        mail.setToAddresses(sendTo);
        List<String> ccTo = new List<String>();
        mail.setSubject('ContractStatusUpdateBatch Logs');
        mail.setHtmlBody(strResultCounts);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('ContractStatusUpdateBatch Logs.html');
        efa.setBody(Blob.valueOf(strResult));
        efa.setContentType('text/html');  
        fileAttachments.add(efa);
        mail.setFileAttachments(fileAttachments);
        mails.add(mail);
        if(!Test.isRunningTest()) 
            Messaging.sendEmail(mails);
    }
}