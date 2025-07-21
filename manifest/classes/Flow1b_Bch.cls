/**
 * Created by clin on 10/23/2019.
 */

global class Flow1b_Bch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    Id thisJobId = bc.getJobId();
    List<String> statusList = new List<String>{
      'Queued',
      'Preparing',
      'Processing',
      'Holding'
    };
    List<AsyncApexJob> lstJobs = [
      SELECT Id
      FROM AsyncApexJob
      WHERE
        status IN :statusList
        AND ApexClass.Name = 'Flow1b_Bch'
        AND Id != :thisJobId
    ];
    if (!lstJobs.IsEmpty()) {
      String nullQuery = 'SELECT id FROM AcctGrpConParsing_Item__c WHERE source__c = \'DONOTRUNFLOW1B\'';
      return Database.getQueryLocator(nullQuery);
    }
    String query = 'SELECT id, item_data__c, Parsing_results__c FROM AcctGrpConParsing_Item__c WHERE source__c = \'FLOW1b\' and processed__c = false';
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext BC,
    List<AcctGrpConParsing_Item__c> scope
  ) {
    for (AcctGrpConParsing_Item__c agcpi : scope) {
      F1BMainParser f1bp = new F1BMainParser();
      f1bp.parse(agcpi.Item_Data__c);
      F1BProcessor.ProcessEntry(f1bp, agcpi.Id);
    }
  }
  global void finish(Database.BatchableContext BC) {
    AsyncApexJob a = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :BC.getJobId()
    ];
    if (a.NumberOfErrors == 0) {
      List<AcctGrpConParsing_Item__c> agcpiList = [
        SELECT Id, Item_Data__c
        FROM AcctGrpConParsing_Item__c
        WHERE Source__c = 'FLOW1b' AND Processed__c = FALSE
      ];
      if (agcpiList.size() > 0) {
        Flow1b_Bch Flow1b = new Flow1b_Bch();
        Database.executeBatch(Flow1b, 1);
      }
    }
  }
}