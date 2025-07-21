global class LinkQuotasAndOppBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT Id, Starting_Date__c, Ending_Date__c, Role__c, Quotas_Owner__c FROM Quotas__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quotas__c> scope){       
        List<Opportunity> oppList = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId=: scope[0].Quotas_Owner__c 
                                     AND StageName = 'Closed Won' 
                                     AND Contracted_Date__c >=: scope[0].Starting_Date__c
                                     AND Contracted_Date__c <=: scope[0].Ending_Date__c];
        for (Opportunity opp : oppList) {
            String userRole = [SELECT UserRole.Name FROM User WHERE Id  =: opp.OwnerId].UserRole.Name;
            if (userRole == scope[0].Role__c){
                opp.Quotas__c = scope[0].Id;
            }
        }
        
        update oppList;
      
    }    
    global void finish(Database.BatchableContext BC){     
    }
}