trigger ExperienceCenter_Before on Briefing__c (before insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        Set<Id> oppIds = new Set<Id>();
        for (Briefing__c tmpBrf : trigger.new) {
            oppIds.add(tmpBrf.Opportunity__c);
        } 
        if (Trigger.isBefore && Trigger.isInsert) {
            List<OpportunityLineItem> prodList = [SELECT Product2.Name, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: oppIds];
            List<Broker_Opp_Rel__c> brokerOppList = [SELECT Servicing_Account__c, Opp_Broker__c FROM Broker_Opp_Rel__c WHERE Opp_Broker__c IN: oppIds];
            for (Briefing__c brf: Trigger.new) {
                String prod = '';
                String brokeOpp='';
                for (OpportunityLineItem oli: prodList){
                    if (oli.OpportunityId == brf.opportunity__c) {
                        prod = prod + oli.Product2.Name + ', ';
                    }
                }
                for (Broker_Opp_Rel__c bopp: brokerOppList){
                    if (bopp.Opp_Broker__c == brf.opportunity__c) {
                        brokeOpp = bopp.Servicing_Account__c;
                    }
                }
                if (prod != ''){
                    prod = prod.substring(0,prod.length()-2);
                }
                brf.Consultant_Broker__c = brokeOpp;
                brf.Products2__c = prod;
                brf.Briefing_Name__c = brf.Customer_Name__c + ' ' + brf.Location__c + ' ' +  Date.today().month() + '-' + Date.today().year();        
            }
        }
    }        
}