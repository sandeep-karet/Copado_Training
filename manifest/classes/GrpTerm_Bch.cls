global class GrpTerm_Bch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Id, Termination_Date__c, Status__c FROM Mbr_Group__c WHERE Status__c != \'TERMED\' AND Termination_Date__c != null AND Termination_Date__c < TODAY';
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Mbr_Group__c> scope) {
    scope[0].Status__c = 'TERMED';
    List<Plan_Specific_Fees__c> updatePSF = [
      SELECT Id, Product_End_Date__c
      FROM Plan_Specific_Fees__c
      WHERE Product_End_Date__c = NULL AND Member_Group__c = :scope[0].Id
    ];
    for (Plan_Specific_Fees__c psf : updatePSF) {
      psf.Product_End_Date__c = scope[0].Termination_Date__c;
    }
    if (updatePSF.size() > 0) {
      Database.update(updatePSF, false);
    }
    Database.update(scope, false);
  }
  global void finish(Database.BatchableContext BC) {
  }
}