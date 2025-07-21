/**
* Created by jpatel on 4/25/19.
* Edited by emartinez on 2019-06-08: Trigger does not account for blank guid on existing records
*/

trigger Mbr_Grp_Trigger on Mbr_Group__c (before insert, before update, after insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        MemberGroupTriggerHelper.setGUID(Trigger.new);
        
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
            MemberGroupTriggerHelper.validateLogoUrls(Trigger.new, Trigger.oldMap);
            MemberGroupTriggerHelper.autopopulatefieldvalues(Trigger.new,Trigger.oldMap);
        }
        
        if(Trigger.isInsert && Trigger.isAfter) {
            if(OpportunityTriggerHelper.isFirstTime) {
                OpportunityTriggerHelper.isFirstTime = false;
                //Auto-create Member Group Role of billing role type																																																																		
                MemberGroupTriggerHelper.createMemberGroupRole(Trigger.new);
            }
        }
    }
}