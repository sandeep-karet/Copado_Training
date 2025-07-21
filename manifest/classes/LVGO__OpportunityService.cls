public class OpportunityService {
    public static Map<Id, List<OpportunityLineItem__c>> oppLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
    public static void updateClientARR (List<Opportunity__c> oppList, Set<Id> accIdSet){
        List<Account__c> updateAccList = New List<Account__c>();
        Map<Id, List<Opportunity__c>> accIdWithOppListMap = new Map<Id, List<Opportunity__c>>();
        //Get Account Details for Current Opportunity
        List<Opportunity__c> oppWAccList = [SELECT Id, Account__c, Account__r.Client_Arr__c, Type__c, Adjusted_Annual_Renewal_Value_Enrolled__c, 
                                         Gross_ARR__c, CloseDate__c FROM Opportunity__c WHERE Id IN: oppList];
        
        // Find all the Opportunities under this Opportunity's Account
        for(Account__c acc: [SELECT Id, (SELECT Id, Type__c, Adjusted_Annual_Renewal_Value_Enrolled__c, Gross_ARR__c, CloseDate__c FROM LVGO_Opportunities__r
                                      WHERE StageName__c = 'Closed Won' ORDER BY CloseDate__c DESC) FROM Account__c WHERE Id IN: accIdSet]) {
                                          accIdWithOppListMap.put(acc.Id, acc.LVGO_Opportunities__r);
                                      }
        
        //Find all OpportunityLineItems under this account and map it with opportunities
        for(Opportunity__c opp1: [SELECT Id, (SELECT Id, Product2__r.Name FROM LGVO_OpportunityProducts__r) FROM Opportunity__c WHERE Account__c IN: accIdSet]) {
            oppLineItemMap.put(opp1.Id, opp1.LGVO_OpportunityProducts__r);
        }
        
        //Process the opportunities
        for(Opportunity__c opp: oppWAccList) {
            processOpportunties(opp.Account__r, accIdWithOppListMap.get(opp.Account__c));
            updateAccList.add(opp.Account__r);
        }
        
        if(updateAccList.size() > 0) {
            try {
                update updateAccList;
            }
            catch(DMLException e) {
                system.debug('The following exception has occurred:' + e.getMessage());
            }
        }
    }
    public static void processOpportunties(Account__c acc, List<Opportunity__c> accountOppList) {
        Opportunity__c opp = new Opportunity__c();
        List<Opportunity__c> relatedOppList = New List<Opportunity__c>();
        List<Opportunity__c> relatedRenewalOpps = New List<Opportunity__c>();
        List<Opportunity__c> relatedContractPathChangeOpps = New List<Opportunity__c>();
        List<Opportunity__c> relatedCrossSellOpps = New List<Opportunity__c>();
        List<Opportunity__c> relatedExpansionOpps = New List<Opportunity__c>();
        List<Opportunity__c> relatedNonRenewalOpps = New List<Opportunity__c>();
        List<Opportunity__c> oppList = New List<Opportunity__c>();
        List<String> stringList1 = New List<String>();
        List<String> stringList2 = New List<String>();
        Opportunity__c closestOpp = new Opportunity__c();
        Decimal nonRenewalARR = 0;
        
        // If there is only Opporuntiy of Type either Renewal or any Non-Renewal
        If(accountOppList.Size() == 1) {
            opp = accountOppList[0];
            If(opp.Type__c == 'Renewal') {
                acc.Client_Arr__c = opp.Adjusted_Annual_Renewal_Value_Enrolled__c;
            }
            else {
                acc.Client_Arr__c = opp.Gross_ARR__c ;        
            }
        }
        
        // If thre are Multiple Opportunities
        else If(accountOppList.Size() > 1) {
            for(Opportunity__c relOpp: accountOppList) {
                if(relOpp.Type__c == 'Renewal') {
                    relatedRenewalOpps.add(relOpp);
                }
                else if(relOpp.Type__c == 'Contract Path Change') {
                    relatedContractPathChangeOpps.add(relOpp);
                }
                else {
                    relatedNonRenewalOpps.add(relOpp);
                }
            }
            
            // Renewal Opportunity Logics
            
            // If Type = Renewal + Contract Path Change
            // a. If Contract Path Change opportunity close date is greater than Renewal opportunity close date
            // 	  then Client ARR = Contract Path Change ARR(Gross ARR)
            // b. If Renewal opportuntiy close date is greater than Contract Path Change opportunity close date
            //    then Client ARR = Renewal ARR(Adjusted Annual Renewal Value Enrolled)
            if(relatedRenewalOpps.Size() > 0 && relatedContractPathChangeOpps.Size() > 0) {
                oppList.clear();
                oppList.addAll(relatedRenewalOpps); 
                oppList.addAll(relatedContractPathChangeOpps);
                closestOpp = findClosestOpp(oppList);
                if(closestOpp.Type__c == 'Renewal') {
                    acc.Client_Arr__c = closestOpp.Adjusted_Annual_Renewal_Value_Enrolled__c ;
                }
                else{
                    acc.Client_Arr__c = closestOpp.Gross_ARR__c;
                }
            }
            
            // If Type = Renewal + Expansion/Cross-Sell
            // If There is a Expansion or Cross-Sell opportuntiy for which the close date is greater than
            // renewal opportuntiy. The Client ARR = Expansion or Cross-sell opportunity's ARR (Gross ARR) + Renewal opportunity's ARR.
            else if(relatedRenewalOpps.Size() > 0 && relatedNonRenewalOpps.Size() > 0) {
                Opportunity__c renewalClosestOpp = findClosestOpp(relatedRenewalOpps);
                Opportunity__c nonRenewalClosestOpp = findClosestOpp(relatedNonRenewalOpps);
                Boolean isProdutsMatched = findIfOppProductsMatch(renewalClosestOpp, nonRenewalClosestOpp);
                nonRenewalARR = 0;
                
                for(Opportunity__c nonRenOpp: relatedNonRenewalOpps) {
                    if((nonRenOpp.Type__c == 'Cross-sell (New product)' || nonRenOpp.Type__c == 'Expansion') && 
                       nonRenOpp.CloseDate__c >= renewalClosestOpp.CloseDate__c) {
                           nonRenewalARR += nonRenOpp.Gross_ARR__c;
                       }
                }
                
                if((nonRenewalClosestOpp.Type__c == 'Cross-sell (New product)' || nonRenewalClosestOpp.Type__c == 'Expansion') &&
                   nonRenewalClosestOpp.CloseDate__c >= renewalClosestOpp.CloseDate__c) {
                       acc.Client_Arr__c = nonRenewalARR + renewalClosestOpp.Adjusted_Annual_Renewal_Value_Enrolled__c;
                   }
                else if((nonRenewalClosestOpp.Type__c == 'Cross-sell (New product)' || nonRenewalClosestOpp.Type__c == 'Expansion') &&
                        renewalClosestOpp.CloseDate__c >= nonRenewalClosestOpp.CloseDate__c && !isProdutsMatched) {
                            acc.Client_Arr__c = nonRenewalClosestOpp.Gross_ARR__c + renewalClosestOpp.Adjusted_Annual_Renewal_Value_Enrolled__c;
                        }
                
                // If Type = Renewal
                // If there are any other Renewal opportunities left.
                else if(relatedRenewalOpps.Size() > 0) {
                    closestOpp = findClosestOpp(relatedRenewalOpps);
                    acc.Client_Arr__c = closestOpp.Adjusted_Annual_Renewal_Value_Enrolled__c;
                }
            }
            
            
            
            // Non-Renewal Opportunity Logics
            
            else {
                if(relatedContractPathChangeOpps.Size() > 0) {
                    closestOpp = findClosestOpp(relatedContractPathChangeOpps);
                    acc.Client_Arr__c = closestOpp.Gross_ARR__c;
                }
                else {
                    nonRenewalARR = 0;
                    for(Opportunity__c nonRenewalOpp: relatedNonRenewalOpps) {
                        nonRenewalARR += nonRenewalOpp.Gross_ARR__c ;
                    }
                    acc.Client_Arr__c = nonRenewalARR;
                }   
            }
        }
    }
    
    //Finds the closest opportunity based on opportuntiy close date near to today.
    public static Opportunity__c findClosestOpp(List<Opportunity__c> oppList) {
        Opportunity__c closestOpp = new Opportunity__c();
        Map<Date, Opportunity__c> oppMap = new Map<Date, Opportunity__c>();
        Set<Date> closedDateSet = new Set<Date>();
        List<Date> closedDateList;
        
        if(oppList.Size() > 0) {
            for(Opportunity__c opp: oppList) {
                oppMap.put(opp.CloseDate__c, opp);
            }
            closedDateSet = oppMap.keySet();
            closedDateList = new List<Date>(closedDateSet);
            closedDateList.sort();
            closestOpp = oppMap.get(closedDateList[closedDateList.size() - 1]);
        }
        return closestOpp;
    }
    
    public static Boolean findIfOppProductsMatch(Opportunity__c opp1, Opportunity__c opp2) {
        List<String> stringList1 = new List<String>();
        List<String> stringList2 = new List<String>();
        for(OpportunityLineItem__c Oli1: oppLineItemMap.get(opp1.Id)) {
            stringList1.add(Oli1.Product2__r.Name);
        }
        for(OpportunityLineItem__c Oli2: oppLineItemMap.get(opp2.Id)) {
            stringList2.add(Oli2.Product2__r.Name);
        }
        return stringList1.equals(stringList2);
    }
    
    public static void handleClientARRUpdateFromAccount(Set<Id> accIdSet){
        Map<Id, List<Opportunity__c>> accIdWithOppListMap = new Map<Id, List<Opportunity__c>>();
        List<Account__c> accList = new List<Account__c>();
        List<Account__c> accUpdateList = new List<Account__c>();
        
        for(Account__c acc: [SELECT Id, Client_Arr__c, (SELECT Id, Type__c, Adjusted_Annual_Renewal_Value_Enrolled__c, Gross_ARR__c, CloseDate__c FROM LVGO_Opportunities__r
                                                     WHERE StageName__c = 'Closed Won' ORDER BY CloseDate__c DESC) FROM Account__c WHERE Id IN: accIdSet]) {
                                                         accList.add(acc);
                                                         accIdWithOppListMap.put(acc.Id, acc.LVGO_Opportunities__r);
                                                     }
        oppLineItemMap.clear();
        //Find all OpportunityLineItems under this account and map it with opportunities
        for(Opportunity__c opp1: [SELECT Id, (SELECT Id, Product2__r.Name FROM LGVO_OpportunityProducts__r) FROM Opportunity__c WHERE Account__c IN: accIdSet]) {
            oppLineItemMap.put(opp1.Id, opp1.LGVO_OpportunityProducts__r);
        }
        
        for(Account__c acc1: accList) {
            processOpportunties(acc1, accIdWithOppListMap.get(acc1.Id));
            accUpdateList.add(acc1);
        }
        
        if(accUpdateList.size() > 0) {
            try {
                update accUpdateList;
            }
            catch(DMLException e) {
                system.debug('The following exception has occurred:' + e.getMessage());
            }
        }
    }
    
    public static void updateHealthScores(List<Opportunity__c> newOpportunities) {
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, List<Opportunity__c>> accToOppMap = new Map<Id, List<Opportunity__c>>();
        List<Health_Score__c> hsListToUpdate = new List<Health_Score__c>();
        for (Opportunity__c opp : newOpportunities) {
            if (opp.Type__c == 'Renewal') {
                accIdSet.add(opp.Account__c);
            }
        }
        if (accIdSet.size() > 0){
            List<Account__c> accList = [SELECT Id, (SELECT Id, CloseDate__c FROM LVGO_Opportunities__r WHERE Type__c = 'Renewal') FROM Account__c WHERE Id IN :accIdSet];
            for (Account__c acc : accList) {
                accToOppMap.put(acc.Id, acc.LVGO_Opportunities__r);
            }
            List<Health_Score__c> hsList = [SELECT Id, Account__c, Actual_Result__c FROM Health_Score__c 
                                            WHERE Account__c IN :accIdSet AND RecordType.Name = 'Account Health Score' 
                                            AND Health_Segment__c = 'Renewal Timing'];
            if (hsList.size() > 0) {
                for (Health_Score__c hs : hsList) {
                    Opportunity__c closestOpp = findClosestOpp(accToOppMap.get(hs.Account__c));
                    if (Date.today().monthsBetween(closestOpp.CloseDate__c) < 6) {
                        hs.Actual_Result__c = '<6 months';
                    }
                    else if (Date.today().monthsBetween(closestOpp.CloseDate__c) >= 6 && Date.today().monthsBetween(closestOpp.CloseDate__c) <= 12) {
                        hs.Actual_Result__c = '6 months - 1 year';
                    }
                    else if (Date.today().monthsBetween(closestOpp.CloseDate__c) > 12) {
                        hs.Actual_Result__c = '>1 year';
                    }
                    hsListToUpdate.add(hs);
                } 
            }
            if (hsListToUpdate.size() > 0) {
                try {
                    update hsListToUpdate;
                }
                catch(DMLException e){
                    system.debug('The following exception has occurred:' + e.getMessage());
                }
            }
        }
    }
    public static void updateOppRevFlag(Map<Id,Opportunity__c> oppMap, List<String> oppIds){
        List<Opportunity__c> oppList = [SELECT Id, Name, Account__r.Acct_Rev_Synergy_Flag__c, 
                                     (SELECT Id, Product2__r.Name,Program_Family__c,ProductCode__c FROM LGVO_OpportunityProducts__r) FROM Opportunity__c 
                                      WHERE Id IN : OppIds];
        for(Opportunity__c opp: oppList){
            Boolean isLv = false;
            Boolean isTd = false;
            Boolean isNewMH = false;
            for(OpportunityLineItem__c oppItem: opp.LGVO_OpportunityProducts__r){
                if (oppItem.Product2__r.Name == 'myStrength' || oppItem.Product2__r.Name == 'myStrength Complete') {
                    isNewMH = true;
                } else if (oppItem.Program_Family__c == 'Teladoc') {
                    isTd= true;
                } else {
                    isLv = true;
                }  
            }
            
            if(opp.LGVO_OpportunityProducts__r.size() > 0){
                switch on opp.Account__r.Acct_Rev_Synergy_Flag__c {
                    when 'Legacy Combined TD/LV Client' {
                        if(isNewMH) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
                        }
                        else {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
                        }
                    }
                    when 'Legacy LV Client' {
                        if (isLv && !isNewMH && !isTd) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
                        }
                        else if ((isLv && isTd && !isNewMH) || (isTd && !isLv && !isNewMH)) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV';
                        }
                        else if ((isNewMH && !isTd && !isLv) || (isNewMH && isLv && !isTd)) {
                             oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';        
                        }
                        else if((isTd && isNewMH && !isLv) || (isLv && isTd && isNewMH)){
                             oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)';       
                        }
                     }
                    when 'Legacy TD Client' {
                        if ((isLv && !isTd && !isNewMH) || (isLv && isTd && !isNewMH)) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD';
                        }
                        else if (isTd && !isLv && !isNewMH){
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
                        }
                        else if ((isNewMH && !isTd && !isLv) || (!isLv && isTd && isNewMH)) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
                        }
                        else if ((isLv && isNewMH && !isTd) || (isLv && isTd && isNewMH)) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)';
                        }
                    }
                    when 'Net New Client (All Solutions)' {
                        if ((isLv && !isTd && !isNewMH) || (isTd && !isLv && !isNewMH)) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
                        }
                        else if (isNewMH && !isLV && !isTd) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
                        }
                        else if (isLv && isTd) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
                        }
                        else if (isLv && isNewMH && !isTd) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)';
                        }
                        else if (isTd && isNewMH && !isLv) {
                            oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)';
                        }
                    }
                }        
            }
        }
    }
}