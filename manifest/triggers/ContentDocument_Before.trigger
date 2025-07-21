trigger ContentDocument_Before on ContentDocument (before insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
    Map<Id, Profile> mappedProfiles = new Map<Id, Profile>([select id from profile where name in ('Read Only - Teladoc', 'Read Only')]);
    if(mappedProfiles.containsKey(UserInfo.getProfileId()))
       {
           for(ContentDocument tmpCd : trigger.new){
               tmpCd.AddError('Saving this file is not permitted with Read Only profile.');
           }
       }
    }

}