// CORE CLASS
global class MB_Process_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public List<Q_Item__c> nextQItem = new List<Q_Item__c>();
  global MB_Process_Batch(List<Q_Item__c> QItemGet) {
    nextQItem = QItemGet;
  }
  global List<Q_Item__c> start(Database.BatchableContext BC) {
    return nextQItem;
  }
  global void execute(Database.BatchableContext BC, List<Q_Item__c> scope) {
    Map<String, Object> results = MB_QXfr_Process.processQ(scope[0]);
    if (
      JSON.serialize(results.get('dml_errors')).length() > 2 ||
      JSON.serialize(results.get('parsing_errors')).length() > 2
    ) {
      scope[0].Status__c = 'Processed with error';
      scope[0].Result__c = JSON.serializePretty(results);
    } else {
      scope[0].Status__c = 'Processed without error';
      scope[0].Result__c = JSON.serializePretty(results);
    }
    scope[0].Processed__c = true;
    update scope[0];
  }

  global void finish(Database.BatchableContext BC) {
    AsyncApexJob a = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :BC.getJobId()
    ];
    if (a.NumberOfErrors == 0) {
      List<Q_Item__c> nextQItemList = [
        SELECT
          Payload__c,
          Itemkey__c,
          Result__c,
          Type__c,
          Processed__c,
          Src__c,
          Dst__c,
          Parser_Name__c,
          Parser_Version__c,
          Livongo_Account_Id__c,
          Teladoc_Account_Id__c
        FROM Q_Item__c
        WHERE Processed__c = FALSE AND Type__c = 'Incoming'
        ORDER BY CreatedDate ASC
        LIMIT 1
      ];
      if (nextQItemList.size() > 0) {
        Database.executeBatch(new MB_Process_Batch(nextQItemList), 1);
      }
    }
  }
}