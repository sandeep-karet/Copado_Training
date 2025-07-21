trigger Mbr_Grp_Role_Before on Mbr_Group_Role__c (before insert, before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        // Disabling this functinality in order to give users the ability to add multiple Member Group Roles with same Role Type
        for(Mbr_Group_Role__c tmpMgr : trigger.new){
            tmpMgr.duplicate_key__c = tmpMgr.Source_Account__c + '_' + tmpMgr.Mbr_Group__c + '_' + tmpMgr.Role_Type__c;
            //tmpMgr.duplicate_Role__c = tmpMgr.Mbr_Group__c + '_' + tmpMgr.Role_Type__c;
        }
        
        List<Mbr_Group_Role__c> mbrrolesToCheck = new List<Mbr_Group_Role__c>();
        if (Trigger.isInsert) {
            for (Mbr_Group_Role__c mbr : Trigger.new) {
                mbrrolesToCheck.add(mbr);
            }
        }
        if(Trigger.isUpdate) {
            Map<Id,Mbr_Group_Role__c> oldMap = (Map<Id,Mbr_Group_Role__c>)Trigger.oldMap;
            for (Mbr_Group_Role__c mbr : Trigger.new) {
                
                mbrrolesToCheck.add(mbr);
                
            }
        }
        if(mbrrolesToCheck.size() > 0) {
            MemberGroupRoleController.validateExistingAccountRole(mbrrolesToCheck);
        }
    }
}