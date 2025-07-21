global class QuotasUpdateBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT Id FROM Quotas__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quotas__c> scope){
        Decimal arrTotal = 0;
        Decimal iyrTotal = 0;
        List<Opportunity> oppList = [SELECT Id, Ann_Rec_Rev__c, In_Year_Rec_Rev__c FROM Opportunity WHERE Quotas__c =: scope[0].Id];
        if (oppList.size() > 0){
            for (Opportunity opp : oppList) {
                arrTotal = opp.Ann_Rec_Rev__c + arrTotal;
                iyrTotal = opp.In_Year_Rec_Rev__c + iyrTotal;
            }
        }
        scope[0].Current_Total_ARR__c = arrTotal;
        scope[0].Current_Total_IYR__c = iyrTotal;
        update scope[0];
      
    }    
    global void finish(Database.BatchableContext BC){     
    }
}