// CORE CLASS
/**
* Name: MB_QItem_After
*  
* JIRA          CHANGED DATE     CHANGED BY         DESCRIPTION      
*---------------------------------------------------------------------------------
* SCDEV-3337    06-June-2023     Rajalakshmi R      Message Bus Functionality enabling
*/
trigger MB_QItem_After on Q_Item__c (after insert, after update) {  
    if (Message_Bus_Toggle__c.getOrgDefaults().Enable_MB__c) {      
        Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
        if (!DS.Disable_Triggers__c) {
            List<String> statusList = new List<String>{'Queued', 'Preparing', 'Processing', 'Holding'};
            Boolean outgoingQ = false;
            Boolean incomingQ = false; 
            List<Q_Item__c> qTypeList = new List<Q_Item__c>();    
            for(Q_Item__c q: Trigger.New) {
                system.debug('q.type__c :'+q.type__c);
                if (q.type__c == 'Outgoing') { 
                    outgoingQ = true;
                    qTypeList.add(q);
                }
                if (q.type__c == 'Incoming') {
                    incomingQ = true;
                }
            } 
            // validation to make sure all q item are created via MB_QXfr class
            if (qTypeList.size() != 0 && qTypeList.size() != Trigger.New.Size()) {
                System.debug('Throwing MB_Exception');
                throw new MB_Exception('Please use the MB_QXfr class to create Q Item'); 
            }
            
            /*
            *  Qutgoing Insert q-item => queue up in MB_InsertQueueable class (Queueable Apex)
            *  Incoming Insert q-item => queue up in Qitem_Process_Batch class (Batch Apex)
            *  All update q-item => queue up in MB_UpdateQueueable class (Queueable Apex)
            */   
            
            if ((Trigger.isInsert) && trigger.isAfter) {          
                if (outgoingQ) {
                    System.debug('Creating Queueable Job MB_InsertQueueable');
                    List<Asyncapexjob> queuealbeJob = [SELECT Id, ApexClass.Name, status, JobItemsProcessed, TotalJobItems, Createddate 
                                                       FROM asyncapexjob 
                                                       WHERE ApexClass.Name ='MB_InsertQueueable' AND Status IN :statusList
                                                       ORDER BY Createddate];
                    if (queuealbeJob.size() == 0) {
                        List<Q_Item__c> nextQItem = [SELECT Payload__c, Itemkey__c, Type__c, Result__c, RecordTypeId,Processed__c, Src__c, Dst__c, Parser_Name__c, Parser_Version__c, Livongo_Account_Id__c, Teladoc_Account_Id__c
                                                     FROM Q_Item__c
                                                     WHERE Processed__c = false AND Type__c = 'Outgoing' AND IsSync__c = FALSE
                                                     ORDER BY CreatedDate ASC 
                                                     LIMIT 1];
                        if (nextQItem.size() != 0) {
                            //SCDEV-3337 changes begin
                            system.debug('Venu --nextQItem[0]'+nextQItem[0].Payload__c);
                            System.enqueueJob(new MB_InsertQueueable(nextQItem[0], nextQItem[0].Dst__c)); 
                            //SCDEV-3337 Changes End
                        }      
                    }   
                }

                if (incomingQ) {
                    List<Asyncapexjob> batchJob = [SELECT Id, ApexClass.Name, status, JobItemsProcessed, TotalJobItems, Createddate 
                                                   FROM asyncapexjob 
                                                   WHERE ApexClass.Name ='MB_Process_Batch' AND Status IN :statusList
                                                   ORDER BY Createddate];
                    if (batchJob.size() == 0) {
                        List<Q_Item__c> nextQItem = [SELECT Payload__c, RecordTypeId, Itemkey__c, Type__c, Result__c, Processed__c, Src__c, Dst__c, Parser_Name__c, Parser_Version__c, Livongo_Account_Id__c, Teladoc_Account_Id__c
                                                     FROM Q_Item__c
                                                     WHERE Processed__c = false AND Type__c = 'Incoming'
                                                     ORDER BY CreatedDate ASC
                                                     LIMIT 1];
                        Database.executeBatch(new MB_Process_Batch(nextQItem),1);
                    }    
                }
                
                List<Q_Item__c> errorList = new List<Q_Item__c>();
                List<Q_Item__c> penidngQ = [SELECT Id, Result__c, Status__c, isSync__c FROM Q_Item__c WHERE isSync__c = false];
                for (Q_Item__c q: penidngQ) {
                    if (q.Result__c != null && q.Result__c.contains('qItemError')) {
                        errorList.add(q);
                    }
                }
                
                // send warning email when more than 3 error show up in log and pile up 
                if (errorList.size() > 3) {
                    MB_QxfrUtils.sendSystemError();
                }
            }

            if ((Trigger.isUpdate) && trigger.isAfter) {
                List<Asyncapexjob> queuealbeJob = [SELECT Id, ApexClass.Name, status, JobItemsProcessed, TotalJobItems, Createddate 
                                                   FROM asyncapexjob 
                                                   WHERE ApexClass.Name ='MB_UpdateQueueable' AND Status IN :statusList
                                                   ORDER BY Createddate];
                if (queuealbeJob.size() == 0) {
                    List<Q_Item__c> nextQItem = [SELECT Payload__c, Itemkey__c, RecordTypeId, Result__c, Type__c, Processed__c, Src__c, Dst__c, Parser_Name__c, Parser_Version__c, Status__c, Livongo_Account_Id__c, Teladoc_Account_Id__c
                                                 FROM Q_Item__c
                                                 WHERE Processed__c = true AND isSync__c = false AND Type__c = 'Incoming' 
                                                 ORDER BY CreatedDate ASC
                                                 LIMIT 1];
                    if (nextQItem.size() != 0) {
                        System.enqueueJob(new MB_UpdateQueueable(nextQItem[0])); 
                    }      
                }  
            }
        }
    }
}