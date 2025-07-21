global class subTerm_Bch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Id, Termination_Date__c , Status__c FROM SBQQ__Subscription__c WHERE Status__c != \'Terminated\' AND Termination_Date__c  != null AND Termination_Date__c  < TODAY';
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext BC,
    List<SBQQ__Subscription__c> scope
  ) {
    scope[0].Status__c = 'Terminated';
    update scope;
  }
  global void finish(Database.BatchableContext BC) {
  }
}