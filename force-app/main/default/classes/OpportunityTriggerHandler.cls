public class OpportunityTriggerHandler {
    public static Boolean isFirstTime = true;
    public static void handleOpportunityAfterUpdate(Map<Id, Opportunity__c> oldOpportunities, List<Opportunity__c> newOpportunities) {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        List<Opportunity__c> hsOppList = new List<Opportunity__c>();
        List<Account__c> updateAccList = new List<Account__c>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> setOppId = new Set<Id>();
        for(Opportunity__c opp: newOpportunities) {
            if(opp.StageName__c == 'Closed Won' && (opp.StageName__c != oldOpportunities.get(opp.Id).StageName__c)){
                oppList.add(opp);
                accIdSet.add(opp.Account__c);
            }
            if (opp.Type__c == 'Renewal' && opp.CloseDate__c != oldOpportunities.get(opp.Id).CloseDate__c) {
                hsOppList.add(opp);
            }
            if(opp.Owner__c != oldOpportunities.get(opp.Id).Opp_Owner_Role__c) {
                setOppId.add(opp.Id);
            }
        }
        if(oppList.Size() > 0) {
            OpportunityService.updateClientARR(oppList, accIdSet);
        }
        if (hsOppList.size() > 0) {
            OpportunityService.updateHealthScores(hsOppList);
        }
        if( !setOppId.isEmpty() ) {
            handleRevFieldsCalculationFromOpp(setOppId);
        }
    }
    
    public static void handleOpportunityAfterInsert(List<Opportunity__c> newOpportunities) {
        List<Opportunity__c> hsOppList = new List<Opportunity__c>();
        for(Opportunity__c opp: newOpportunities) {
            if (opp.Type__c == 'Renewal') {
                hsOppList.add(opp);
            } 
        }
        if (hsOppList.size() > 0) {
            OpportunityService.updateHealthScores(hsOppList);
        }
    }
    public static void handleOppRevSynergyflagUpdates(Map<Id,Opportunity__c> OppMap){
        List<String> OppIds = new List<String>();
        for(Opportunity__c opp : oppMap.values()){
            if(!opp.Opp_Rev_Flag_Overwrite__c){
                oppIds.add(opp.Id);
            }
        }
        if(oppIds.size() > 0) {
            OpportunityService.updateOppRevFlag(oppMap,oppIds);
        }
    }
    public static void handleRevFieldsCalculationFromOpp( Set<Id> setOppId ) {
        
        List<OpportunityLineItem__c> oliList = [SELECT Id, Opportunity__r.Opp_Owner_Role__c, Opportunity_Owner_Role__c, Opportunity__r.Owner__r.UserRole.Name
                                             FROM OpportunityLineItem__c WHERE Opportunity__c IN :setOppId];
        
        for (OpportunityLineItem__c oli: oliList) {
            oli.Opportunity_Owner_Role__c = oli.Opportunity__r.Owner__r.UserRole.Name; 
        } 
        if (oliList.size() > 0 ) {   
            update oliList;
        }
    }
    public static void updateProbability(List<Opportunity__c> lstOpp, Map<Id, Opportunity__c> mapOldOpp) {
        for(Opportunity__c opp: lstOpp) {
            if(opp.Net_ARR__c != null && (mapOldOpp.isEmpty() || ( !mapOldOpp.isEmpty() && (opp.StageName__c != mapOldOpp.get(opp.Id).StageName__c || opp.Net_ARR__c != mapOldOpp.get(opp.Id).Net_ARR__c)))) {
                
                if( opp.Net_ARR__c >= 2000000 && !mapOldOpp.isEmpty() ) {
                    opp.Probability__c = mapOldOpp.get(opp.Id).Probability__c;
                } 
                
                if( opp.Net_ARR__c < 2000000 ) { 
                    if(opp.StageName__c == 'Discovery') { 
                        opp.Probability__c = 30; 
                    }
                    else if(opp.StageName__c == 'Proposal') {
                        opp.Probability__c = 50;
                    }
                    else if(opp.StageName__c == 'Review/Negotiation') {
                        opp.Probability__c = 70;
                    }
                    else if(opp.StageName__c == 'Contracting') {
                        opp.Probability__c = 90;
                    }
                }
            }
            
            if(opp.StageName__c == 'Closed Won') {
                opp.Probability__c = 100;
            }  
            else if(opp.StageName__c == 'Closed Lost' || opp.StageName__c == 'Closed No Decision') {
                opp.Probability__c = 0;
            }
        }
    }
    
    public static void updateRevenueBucket(List<Opportunity__c> lstOpp, Map<Id, Opportunity__c> mapOldOpp){
        for(Opportunity__c opp: lstOpp) {
            if((mapOldOpp.isEmpty() && opp.CPQ_Price_Book__c != null) 
               || (!mapOldOpp.isEmpty() && opp.CPQ_Price_Book__c != null && mapOldOpp.get(opp.Id).CPQ_Price_Book__c != opp.CPQ_Price_Book__c) ){
                   if(opp.CPQ_Price_Book__c == 'HHS'){
                       opp.Revenue_Bucket__c = 'HHS';
                   }else{
                       opp.Revenue_Bucket__c = 'USGH'; 
                   }
               }
        }
        
    }
}