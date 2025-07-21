trigger AGCPI_PRE on AcctGrpConParsing_Item__c (before insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        for (AcctGrpConParsing_Item__c tmpAgcpi : Trigger.new) {
            tmpAgcpi.Batch_Time__c = DateTime.newInstance(Long.ValueOf(tmpAgcpi.Batch_Key__c));
        }
    }
}