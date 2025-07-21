global class CanadaOppUpdate_Bch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    List<User> userList = [
      SELECT Id
      FROM User
      WHERE DefaultCurrencyIsoCode = 'CAD'
    ];
    List<String> idList = new List<String>();
    for (user user : userList) {
      idList.add(user.Id);
    }
    string query = 'SELECT Id FROM Opportunity WHERE OwnerId IN: idList AND (Sub_Channel__c != \'International\' OR Country__c != \'Canada\' OR Business_Region__c != \'Canada\')';
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    for (Opportunity opp : scope) {
      opp.Sub_Channel__c = 'International';
      opp.Country__c = 'Canada';
      opp.Business_Region__c = 'Canada';
    }
    update scope;
  }
  global void finish(Database.BatchableContext BC) {
  }
}