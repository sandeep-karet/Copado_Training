trigger PreventDeletePQ on SBQQ__Quote__c (before delete) {
 // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
    for(SBQQ__Quote__c quot:trigger.old){
        If(quot.SBQQ__Primary__c){
            quot.adderror('This is a primary quote, please deselect the primary quote field to be able to eliminate it.');
        }
    }
}
}