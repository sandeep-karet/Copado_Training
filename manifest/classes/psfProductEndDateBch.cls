global class psfProductEndDateBch implements Database.Batchable<sObject> {
  private List<Id> subList;
  global psfProductEndDateBch(List<Id> subIdList) {
    subList = subIdList;
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Product_End_Date__c,
          Subscription__c,
          Subscription__r.Termination_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Subscription__c IN :subList
      ]
    );
  }
  global void execute(
    Database.BatchableContext BC,
    List<Plan_Specific_Fees__c> scope
  ) {
    List<Plan_Specific_Fees__c> tempList = new List<Plan_Specific_Fees__c>();
    for (Plan_Specific_Fees__c psf : scope) {
      if (psf.Product_End_Date__c != psf.Subscription__r.Termination_Date__c) {
        psf.Product_End_Date__c = psf.Subscription__r.Termination_Date__c;
        tempList.add(psf);
      }
    }
    if (tempList.size() > 0) {
      update tempList;
    }
  }
  global void finish(Database.BatchableContext BC) {
  }
}