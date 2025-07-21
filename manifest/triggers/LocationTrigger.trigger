trigger LocationTrigger on Location__c (before insert, before update) {
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        Set<String> former_guids = new Set<String>();
        for (Location__c tmpLoc : trigger.new) {
            former_guids.add(tmpLoc.former_guid__c);
        }
        Map<String, Id> conflicting_accts = new Map<String, Id>();
        for (Account tmpAcct : [select id, guid__c from account where guid__c in :former_guids]) {
            conflicting_accts.put(tmpAcct.Guid__c, tmpAcct.Id);
        }
        for (Location__c tmpLoc : trigger.new) {
            if (tmpLoc.Former_GUID__c != null && conflicting_accts.containsKey(tmpLoc.Former_GUID__c))
                tmpLoc.addError('CONFLICTING GUID: ' + tmpLoc.Former_GUID__c +
                        ' on Account:' + conflicting_accts.get(tmpLoc.Former_GUID__c));
        }
    }
}