global class LvnDataMigrationBch implements Database.Batchable<sObject> {
  AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c(
    Batch_Key__c = String.valueOf(DateTime.now().getTime()),
    Item_Key__c = String.valueOf(DateTime.now().getTime() / 1000),
    Processed__c = false,
    Batch_Time__c = DateTime.now(),
    Source__c = 'LVN_DATA_MIGRATION'
  );
  private final String agcpiId;
  private final String query;
  global LvnDataMigrationBch(String customQuery) {
    if (customQuery == null)
      query = 'SELECT Id,  StageName, Sub_Channel__c, LVN_Pricebook_Type__c, DM_Disable_BH__c, LVN_Pricebook__c, LVN_Contract_Path__c, LVN_Contract_Path_Account_Type__c, LVN_Pricing_Structure__c, Pricebook2Id, (SELECT Id, DM_LVN_Program_Id__c,DM_Gross_Program_ARR__c, DM_Net_Program_ARR__c, DM_Create_MSC__c, DM_PMPM__c,Product__c, DM_Admin_Fee__c, DM_At_Risk_Fee__c, DM_Up_Front_Fee__c, DM_Participant_Quantity__c, UnitPrice, DM_Fee_Type__c, DM_Enrollment_Percentage__c, DM_Participation_Percentage__c, Quantity, Product2Id, DM_Disable_Teletherapy__c, DM_Disable_Coaching__c, DM_Program_Term__c FROM OpportunityLineItems) FROM Opportunity WHERE LVN_Migration_Opp__c = true';
    else
      query = customQuery;
    insert agcpi;
    agcpiId = agcpi.id;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    Map<Opportunity, List<OpportunityLineItem>> dataMap = new Map<Opportunity, List<OpportunityLineItem>>();
    for (Opportunity opp : scope) {
      dataMap.put(opp, opp.OpportunityLineItems);
    }
    OppDataMigration.createQuote(dataMap, agcpiId);
  }
  global void finish(Database.BatchableContext BC) {
    List<AcctGrpConParsing_Item__c> lstAgcpi = [
      SELECT Id
      FROM AcctGrpConParsing_Item__c
      WHERE Source__c = 'LVN_DATA_MIGRATION' AND Id = :agcpiId
      LIMIT 1
    ];
    if (!lstAgcpi.isEmpty()) {
      agcpi = lstAgcpi[0];
      agcpi.processed__c = true;
      update agcpi;
    }
  }
}