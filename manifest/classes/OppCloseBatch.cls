global class OppCloseBatch implements Database.Batchable<sObject>, Database.Stateful {
  AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c(
    Batch_Key__c = String.valueOf(DateTime.now().getTime()),
    Item_Key__c = String.valueOf(DateTime.now().getTime() / 1000),
    Processed__c = false,
    Batch_Time__c = DateTime.now(),
    Source__c = 'FIX_OPP'
  );
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String target = string.valueOf(Date.today().addMonths(-2));
    String query =
      'SELECT Id, Sub_Channel__c FROM Opportunity WHERE (StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND StageName != \'Contracting\') AND CloseDate <=' +
      target;
    insert agcpi;
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    for (Opportunity opp : scope) {
      opp.StageName = 'Closed Lost';

      opp.Reason_for_Loss__c = 'Other';
      if (opp.Sub_Channel__c == null) {
        opp.Sub_Channel__c = 'Undefined';
      }
      Opp.Opportunity_Update__c = 'Closed by Batch';
    }

    Database.SaveResult[] sr = Database.update(scope, false);
    List<AcctGrpConParse_Exception__c> agcpe_list = new List<AcctGrpConParse_Exception__c>();

    for (Integer i = 0; i < scope.size(); i++) {
      Database.SaveResult s = sr[i];
      Opportunity oldOpp = scope[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          oldOpp.Id +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              oldOpp.Id +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpi.Id,
            Exception_Type__c = 'DML_ERROR',
            Short_Desc__c = String.valueOf(rowError.getStatusCode()),
            SObject__c = 'OPPORTUNITY',
            Full_Desc__c = fullDesc
          );
          agcpe_list.add(agcpe);
        }
      }
    }
    insert agcpe_list;
  }
  global void finish(Database.BatchableContext BC) {
    agcpi.processed__c = true;
    update agcpi;
  }
}