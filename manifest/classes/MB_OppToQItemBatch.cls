// TDH SIDE
global class MB_OppToQItemBatch implements Database.Batchable<sObject> {
  private List<String> oppRecordId;
  global MB_OppToQItemBatch(List<String> oppId) {
    oppRecordId = oppId;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String Query = 'SELECT Id, Opp_Guid__c FROM Opportunity WHERE Id IN: oppRecordId';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    List<System.JSONGenerator> genlist = new List<System.JSONGenerator>();
    for (Opportunity opp : scope) {
      genlist.add(MB_OppJSONGenerator.generateJSONContent(opp.Opp_Guid__c));
    }
    MB_QXfr.CreateAsyncQItem('LVN', 'TDH', 'Opportunity_Parser', genlist);
  }

  global void finish(Database.BatchableContext BC) {
  }
}