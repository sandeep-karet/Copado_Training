/**
* Company : PwC.
* @description : Batch Job to calculate months account in client status
* ************************************************************************************************************************************
* History : 
* @date 27/09/2022
* @author Neha Sharma
*/
public class L2O_AccountClientStatusMonthsBatch  implements Database.Batchable<SObject>{
    public String query;
    public final List<Account> updatedAccounts;
    /**
* @name  start()
* @description Runs Query for Batch Job .
* @param bc to pass Database.BatchableContext
* @return Database.QueryLocator variable to return result of query
*/ 
    public Database.QueryLocator start(Database.BatchableContext bc ) {
        query = 'SELECT Id, L2O_Account_Status__c,L2O_Client_status_date__c,L2O_6_Month_passed_after_client_status__c from Account WHERE L2O_Account_Status__c = \'Client\' AND L2O_6_Month_passed_after_client_status__c = FALSE AND L2O_Client_status_date__c != null';
        return Database.getQueryLocator(query) ;
    }
    
    /**
* @name  Database.QueryLocator execute()
* @description Moves Acc Status to 'Former Client' for records with latest Contract older than 6 months .
* @param bc to pass Database.BatchableContext
* @param scope for passing List<Account> 
*/ 
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Date dateToday = system.today() ;
        Set<String> accIdSet  = new Set<String>();
        List<Account> accToUpdate = new List<Account>() ;
       
        L2O_RunTerritoryRulesQueueable job = new L2O_RunTerritoryRulesQueueable() ;
        for(Account acIterable : scope) {
            
            Date sixMonthAfterDay = acIterable.L2O_Client_status_date__c.addMonths(6) ;
            if(sixMonthAfterDay <  dateToday) {                   
                acIterable.L2O_6_Month_passed_after_client_status__c = true;
                accIdSet.add(acIterable.id);
                accToUpdate.add(acIterable) ;
                job.accntIds = accIdSet;
                
            }                        
        }
        if(accToUpdate.size()>0) {
            database.update(accToUpdate, false) ;
            System.enqueueJob(job);                                    
        }
    }
    
    /**
* @name  Database.QueryLocator finsih()
* @description Required for a Batch Class
* @param bc to pass Database.BatchableContext
*/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
}