global class Contact_Grp_Rollup_Bch implements Database.Batchable<sObject> {
  private final String query;

  global Contact_Grp_Rollup_Bch(String customQuery) {
    if (customQuery == null)
      query = 'SELECT Id, AccountId, Group_Count__c FROM Contact WHERE marketing_site_user__c = TRUE';
    else
      query = customQuery;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Contact> scope) {
    Set<Id> uniqueIds = new Set<Id>();
    List<Mbr_Group__c> allGroups = [
      SELECT id
      FROM Mbr_Group__c
      WHERE Client_Account__c = :scope[0].AccountId
    ];
    for (Mbr_Group__c tmpGrp : allGroups) {
      uniqueIds.add(tmpGrp.Id);
    }
    List<Mbr_Group_Role__c> allMbrGrpRoles = [
      SELECT Id, Mbr_Group__c
      FROM Mbr_Group_Role__c
      WHERE
        Source_Account__c = :scope[0].AccountId
        AND Role_Type__c IN ('Payer', 'Benefit Sponsor', 'MSU Access')
    ];
    for (mbr_group_role__c tmpMgr : allMbrGrpRoles) {
      uniqueIds.add(tmpMgr.mbr_group__c);
    }
    List<Mkt_Site_User__c> allMsu = [
      SELECT Id, Mbr_Group__c
      FROM Mkt_Site_User__c
      WHERE Contact__c = :scope[0].Id
    ];
    for (Mkt_Site_User__c tmpMsu : allMsu) {
      uniqueIds.add(tmpMsu.mbr_group__c);
    }
    if (scope[0].Group_Count__c != uniqueIds.size()) {
      scope[0].Group_Count__c = uniqueIds.size();
      update scope;
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}