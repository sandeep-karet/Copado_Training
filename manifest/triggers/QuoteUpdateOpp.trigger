trigger QuoteUpdateOpp on SBQQ__Quote__c (after insert, after update) {
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        Set<String> quote = new Set<String>();
        Map<Id, Date> QuoteStartDate = new Map<Id, Date>();

        for (SBQQ__Quote__c q : Trigger.new) {
            if (q.SBQQ__Type__c == 'Amendment') {
                quote.add(q.SBQQ__Opportunity2__c);
            }
            QuoteStartDate.put(q.SBQQ__Opportunity2__c, q.SBQQ__StartDate__c);
        }
        for (Opportunity opp : [select id, CloseDate from Opportunity where id in:quote]) {
            if (QuoteStartDate.containsKey(opp.Id)) {
                opp.CloseDate = QuoteStartDate.get(opp.Id);
                update opp;
            }
        }
    }
}