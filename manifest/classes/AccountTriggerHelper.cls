public with sharing class AccountTriggerHelper {
  public static void setGUID(List<Account> new_accounts) {
    Set<String> candidate_guids = new Set<String>();
    Set<String> all_guids = new Set<String>();
    for (Account tmp_account : new_accounts) {
      all_guids.add(tmp_account.guid__c);
      if (tmp_account.source__c != 'HUB')
        continue;
      // Create new GUID if account is new or has invalid GUID
      if (
        String.isBlank(tmp_account.GUID__c) ||
        !GlobalIdUtils.isGuid(tmp_account.GUID__c)
      ) {
        tmp_account.GUID__c = GlobalIdUtils.generateGuid();
        candidate_guids.add(tmp_account.guid__c);
      } else
        candidate_guids.add(tmp_account.guid__c);
    }
    List<Legacy_Id__c> legacy_guids = [
      SELECT
        guid__c,
        source__c,
        source_id__c,
        original_name__c,
        master_account__r.name
      FROM legacy_id__c
      WHERE guid__c IN :all_guids
    ];
    Map<String, Legacy_id__c> mapped_lguids = new Map<String, Legacy_Id__c>();
    for (Legacy_Id__c tmp_lguid : legacy_guids) {
      mapped_lguids.put(tmp_lguid.guid__c, tmp_lguid);
    }

    List<Location__c> location_guids = [
      SELECT
        id,
        Former_GUID__c,
        Location_HQ__r.source__c,
        Location_HQ__r.source_id__c
      FROM location__C
      WHERE Former_GUID__c IN :all_guids
    ];
    Map<String, Location__c> mapped_locGuids = new Map<String, Location__c>();
    for (Location__c loc : location_guids) {
      mapped_locGuids.put(loc.Former_GUID__c, loc);
    }

    for (Account tmp_account : new_accounts) {
      if (mapped_lguids.containsKey(tmp_account.guid__c)) {
        legacy_id__c tmp_lguid = mapped_lguids.get(tmp_account.guid__c);
        if (tmp_lguid.guid__c != null) {
          string error_msg =
            'LEGACY ID FOUND: ' +
            tmp_lguid.guid__c +
            '_' +
            tmp_lguid.source__c +
            '_' +
            tmp_lguid.source_id__c;
          tmp_account.addError(error_msg);
        }
      }
      if (mapped_locGuids.containsKey(tmp_account.guid__c)) {
        Location__c tem_loc = mapped_locGuids.get(tmp_account.guid__c);
        if (tem_loc.Former_GUID__c != null) {
          string error_msg =
            'Location ID FOUND: ' +
            tem_loc.Former_GUID__c +
            '_' +
            tem_loc.Location_HQ__r.source__c +
            '_' +
            tem_loc.Location_HQ__r.source_id__c;
          tmp_account.addError(error_msg);
        }
      }
    }
  }
}