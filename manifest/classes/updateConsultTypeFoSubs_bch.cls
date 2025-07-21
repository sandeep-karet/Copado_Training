global class updateConsultTypeFoSubs_bch implements Database.Batchable<sObject> {
  AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c(
    Batch_Key__c = String.valueOf(DateTime.now().getTime()),
    Item_Key__c = String.valueOf(DateTime.now().getTime() / 1000),
    Processed__c = false,
    Batch_Time__c = DateTime.now(),
    Source__c = 'FIX_SUB_CONSULT_TYPE'
  );
  global Database.QueryLocator start(Database.BatchableContext BC) {
    string query = 'SELECT Id, Consult_Type__c FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.Parent_Product_Code__c = \'BD-CANADA-BUNDLE\' or SBQQ__Product__r.ProductCode =\'BD-CANADA-BUNDLE\'';
    insert agcpi;
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext BC,
    List<SBQQ__Subscription__c> scope
  ) {
    for (SBQQ__Subscription__c sub : scope) {
      sub.Consult_Type__c = 'Included';
    }
    Database.SaveResult[] sr = Database.update(scope, false);
    List<AcctGrpConParse_Exception__c> agcpe_list = new List<AcctGrpConParse_Exception__c>();
    for (Integer i = 0; i < scope.size(); i++) {
      Database.SaveResult s = sr[i];
      SBQQ__Subscription__c oldSub = scope[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('SubId: ' +
          oldSub.Id +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('SubId: ' +
              oldSub.Id +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpi.Id,
            Exception_Type__c = 'DML_ERROR',
            Short_Desc__c = String.valueOf(rowError.getStatusCode()),
            SObject__c = 'SBQQ__SUBSCRIPTION__C',
            Full_Desc__c = fullDesc
          );
          agcpe_list.add(agcpe);
        }
      }
    }
    insert agcpe_list;
  }
  global void finish(Database.BatchableContext BC) {
  }
}