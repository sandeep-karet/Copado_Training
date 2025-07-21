global class OppliUpdate_bch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Id FROM OpportunityLineItem';
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext BC,
    List<OpportunityLineItem> scope
  ) {
    update scope;
  }
  global void finish(Database.BatchableContext BC) {
  }
}