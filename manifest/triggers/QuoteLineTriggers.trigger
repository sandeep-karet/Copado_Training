trigger QuoteLineTriggers on SBQQ__QuoteLine__c (after insert, after update) {
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                QuoteLineTriggerHelper.addMissingFeeProductsToAmendments(Trigger.newMap);
            }
        }
    }
}