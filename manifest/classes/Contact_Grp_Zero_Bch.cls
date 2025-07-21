global class Contact_Grp_Zero_Bch implements Database.Batchable<sObject> {
  private final String query;
  global Contact_Grp_Zero_Bch(String customQuery) {
    if (customQuery == null)
      query = 'SELECT Id FROM Contact WHERE marketing_site_user__c = FALSE AND group_count__c != NULL AND GROUP_Count__c > 0';
    else
      query = customQuery;
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Contact> scope) {
    scope[0].Group_Count__c = 0;
    update scope;
  }

  global void finish(Database.BatchableContext BC) {
  }
}