trigger OppProductRevFlag_Trg on OpportunityLineItem (before insert,  before update) {   
   /* Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        SBQQ.TriggerControl.disable();
        Map<String, String> acctFlagMap = new Map<String, String>();
        Map<String, Product2> prodMap = new Map<String, Product2>([SELECT Id FROM Product2 WHERE SBQQ__SubscriptionPricing__c = null AND Family != 'Provider' and Family != 'Marketing']);
        List<String> oppIdList = new List<String>();
        for(OpportunityLineItem oppli: Trigger.new) {
            oppIdList.add(oppli.OpportunityId);
        }
        List<Opportunity> oppList = [SELECT Id, Account.Rev_Synergy__c FROM Opportunity WHERE Id IN: oppIdList];
        for (Opportunity opp: oppList) {        
            acctFlagMap.put(opp.Id, opp.Account.Rev_Synergy__c);
        }
        List<Product2> myStr = [SELECT Id FROM Product2 WHERE isActive = true AND ProductCode = 'MYSTR3'];
        String myStrId = myStr.isEmpty() ? null : myStr[0].Id;        
        for (OpportunityLineItem oppli: Trigger.New) {
            if (oppli.SBQQ__QuoteLine__c != null) {
                if (oppli.Product2Id == myStrId) {
                    oppli.Revenue_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
                } else if (!prodMap.isEmpty() && prodMap.containsKey(oppli.Product2Id)) {
                    oppli.Revenue_Synergy_Flag__c = null;
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy Combined TD/LV Client') {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Net New Client (All Solutions)') {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';    
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy LV Client' && oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy LV Client' && !oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'Cross-sell TD Products into LV';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy TD Client' && !oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy TD Client' && oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'Cross-sell LV Products into TD';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy HHS Client' && oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'Cross-sell LV to HHS';
                }  else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy HHS Client' && !oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                } else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy Combined HHS/LV Client' && oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                }  else if (acctFlagMap.get(oppli.OpportunityId) == 'Legacy Combined HHS/LV Client' && !oppli.Product_Family__c.Contains('Livongo')) {
                    oppli.Revenue_Synergy_Flag__c = 'No Synergy';
                }
            } 
        }
        SBQQ.TriggerControl.enable();
    } */
}