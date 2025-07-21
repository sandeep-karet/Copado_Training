trigger MSU_Before on Mkt_Site_User__c (before update, before insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        // Fetch all the Member Group/Group Roles related to batched MSU
        List<Id> mbrGrpIds = new List<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Mkt_Site_User__c tmpMsu : trigger.new){
            contactIds.add(tmpMsu.Contact__c);
            mbrGrpIds.add(tmpMsu.Mbr_Group__c);
        }
        List<Mkt_Site_User__c> existingMsu = [select id, Mbr_Group__c, contact__c from Mkt_Site_User__c
                                              where Mbr_Group__c in :mbrGrpIds and contact__c in :contactIds];
        Set<String> existingMsuKeys = new Set<String>();
        for(Mkt_Site_User__c tmpMsu : existingMsu){
            existingMsuKeys.add(tmpMsu.Mbr_Group__c + '_' + tmpMsu.Contact__c);
        }
        
        //TODO: Optimize this check
        // Check for existing record
        for(Mkt_Site_User__c tmpMsu : trigger.new){
            if(existingMsuKeys.contains(tmpMsu.Mbr_Group__c + '_' + tmpMsu.Contact__c))
                tmpMsu.addError('An records for this GROUP + CONTACT already exists.');
        }
        
        Map<Id, Contact> scopedContacts = new Map<Id, Contact>([select id, accountid from contact where id in :contactIds]);
        List<Mbr_Group_Role__c> cur_grp_rls = [SELECT Id, Source_Account__c, Mbr_Group__c
                                               FROM Mbr_Group_Role__c
                                               where Mbr_Group__c in :mbrGrpIds
                                               and mbr_group__r.is_valid_msu_group__c = true 
                                               and role_type__c in ('Payer','Benefit Sponsor') order by Mbr_Group__c];
        
        // Load accounts related to member group roles
        Map<Id, Set<Id>> source_accounts_map = new Map<Id, Set<Id>>();
        for(Mbr_Group_Role__c tmpMgr : cur_grp_rls){
            Id mbrGrpId = tmpMgr.Mbr_Group__c;
            Id accountId = tmpMgr.Source_Account__c;
            if(source_accounts_map.containsKey(mbrGrpId)){
                source_accounts_map.get(mbrGrpId).add(accountId);
            } else {
                source_accounts_map.put(mbrGrpId, new Set<Id>{ accountId });
            }
        }
        System.debug(LoggingLevel.Fine,'account_map: ' + source_accounts_map);
        // Finally check if the contact's account is listed in the corresponding group roles
        for(Mkt_Site_User__c tmpMsu : trigger.new) {
            System.debug(LoggingLevel.Fine,'target group: ' + tmpMsu.Mbr_Group__c);
            Id accountId = scopedContacts.get(tmpMsu.Contact__c).AccountId;
            if(source_accounts_map.containsKey(tmpMsu.Mbr_Group__c)){
                System.debug(LoggingLevel.Fine,'tmpMsu.Contact__r.AccountId = ' + accountId);
                
                if(source_accounts_map.get(tmpMsu.Mbr_Group__c).contains(accountId))
                    tmpMsu.addError('Contact already has the requested access by group role.');
            }
        }
    }
}