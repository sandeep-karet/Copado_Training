trigger Case_Trg on Case (before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        if (Trigger.isUpdate && Trigger.isBefore) {
            for (Case c: Trigger.new) {
                Case oldCase = Trigger.oldMap.get(c.Id);
                if (oldCase.ownerId.getSObjectType().getDescribe().getName() == 'User') {
                    c.Previous_Owner__c = oldCase.ownerId;
                }
            } 
        }
    }
}