/**
* Company : PwC.
* @description : Batch Job to move Account Status to 'Former Client' if required criteria are met .
* ************************************************************************************************************************************
* History : 
* @date 27/04/2022
* @author Aviral Dhodi
*/
public class L2O_AccountStatusFormerClientBatch implements Database.Batchable<SObject> {
    public String query;
    
    /**
* @name  start()
* @description Runs Query for Batch Job .
* @param bc to pass Database.BatchableContext
* @return Database.QueryLocator variable to return result of query
*/ 
    public Database.QueryLocator start(Database.BatchableContext bc ) {
        query = 'SELECT Id, L2O_Account_Status__c, (SELECT EndDate from Contracts ORDER BY EndDate DESC NULLS LAST LIMIT 1), (SELECT AccountId from Opportunities WHERE StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND StageName!= \'Prospect\' AND StageName != \'Discovery\' ) from Account WHERE L2O_Total_of_Won_Opportunities__c > 0 AND L2O_Account_Status__c = \'Client\'';
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
        Date sixMonthBeforeDay = dateToday.addMonths(-6) ;
        List<Account> accToUpdate = new List<Account>() ;
        Contract contIterable = new Contract();
        for(Account acIterable : scope) {
            contIterable = null;
            if(acIterable.Contracts.size() > 0) {
                contIterable = acIterable.Contracts[0] ;
            }
            if(contIterable != null && contIterable.EndDate<sixMonthBeforeDay && acIterable.Opportunities.size() <= 0 ) {                   
                acIterable.L2O_Account_Status__c = 'Former Client';
                accToUpdate.add(acIterable) ;                    
            }                        
        }
        if(accToUpdate.size()>0) {
            database.update(accToUpdate, false) ;
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