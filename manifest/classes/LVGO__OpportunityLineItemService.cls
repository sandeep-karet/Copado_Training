public without sharing class OpportunityLineItemService {
    public static final String DM_SOLUTION = System.Label.DM_Solution;
    public static final String CV_SOLUTION = System.Label.CV_Solution;
    public static final String DP_SOLUTION = System.Label.DP_Solution;
    public static Map<String, Decimal> programToParticipantPercentMap = new Map<String, Decimal>();
    
    static {
        Map<String, Decimal> ppMap = new Map<String, Decimal>();
        Program_Participant__mdt[] ppMDT = [SELECT Program_Name__c, ParticipantPercentage__c FROM Program_Participant__mdt];
        for (Program_Participant__mdt pp: ppMDT) {
            ppMap.put(pp.Program_Name__c, pp.ParticipantPercentage__c);
        }
        programToParticipantPercentMap = ppMap;        
    }
    
    @InvocableMethod(label='Calculate Program Participant')
    public static List<List<OpportunityLineItem__c>> calculateProgramParticipants(List<List<OpportunityLineItem__c>> oliList) {
        
        //Get the OpportunityLineItem Information
        List<OpportunityLineItem__c> OppLineItemlist=new List<OpportunityLineItem__c>();
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>();
        Map<Id,String> oppLinePsMap = new Map<Id,String>();
        Map<Id,String> opplineNameMap = new Map<Id,String>();
        Map<Id,Integer> OppCoveredLivesMap = new Map<Id,Integer>();
        Set<Id> pricingStructureIds = new Set<Id>();
        Set<Id> oliIds = new Set<Id>();
        
        OppLineItemlist=oliList[0];         
        
        for (OpportunityLineItem__c l : OppLineItemlist) {
            oliIds.add(l.Id);
            pricingStructureIds.add(l.Pricing_Structure__c);
        }
        
        Map<Id,Pricing_Structure__c> pricingStructureMap = new Map <Id, Pricing_Structure__c> ([SELECT Id, Name From Pricing_Structure__c WHERE Id IN: pricingStructureIds]);
         
        for (OpportunityLineItem__c oli : OppLineItemlist) {
            if(oli.Pricing_Structure__c != NULL) {
              oppLinePsMap.put(oli.Id, pricingStructureMap.get(oli.Pricing_Structure__c).Name);  
            } 
        }
        
        List<OpportunityLineItem__c> lineItemList = [SELECT Id, Program_ID__c, OpportunityProductName__c,Pricing_Structure__c, Opportunity__r.Opportunity_Covered_Lives__c, Product_Participants__c,
                                                  Price_Book_ID__r.Name, Quantity__c, Product2__r.Whole_Person_Solution__c, Opportunity__c FROM OpportunityLineItem__c WHERE Id IN :oliIds];
        //Add Unique Programs to Set
        
        Set<String> programNameSet = new Set<String>();
        for (OpportunityLineItem__c lineItem: lineItemList) {
            programNameSet.add(lineItem.OpportunityProductName__c); 
            opplineNameMap.put(lineItem.Id,lineItem.OpportunityProductName__c);
            OppCoveredLivesMap.put(lineItem.Id,Integer.valueOf(lineItem.Opportunity__r.Opportunity_Covered_Lives__c));
        }
       
        for (OpportunityLineItem__c oli: OppLineItemlist) {
            if (OppCoveredLivesMap.get(oli.Id) != null) {                
                if (opplineNameMap.get(oli.Id) == CV_SOLUTION) {
                    if (programNameSet.contains(DM_SOLUTION) && programNameSet.contains(DP_SOLUTION)) {
                        oli.Product_Participants__c = programToParticipantPercentMap.get('CV + DM + DP') * OppCoveredLivesMap.get(oli.Id);                        
                    }
                    else if (programNameSet.contains(DM_SOLUTION)) {
                        oli.Product_Participants__c = programToParticipantPercentMap.get('CV + DM') * OppCoveredLivesMap.get(oli.Id); 
                    }
                    else if (programNameSet.contains(DP_SOLUTION)) {
                        oli.Product_Participants__c = programToParticipantPercentMap.get('CV + DP') * OppCoveredLivesMap.get(oli.Id); 
                    }
                    else {
                        oli.Product_Participants__c = programToParticipantPercentMap.get(opplineNameMap.get(oli.Id)) * OppCoveredLivesMap.get(oli.Id);
                    }
                }
                else if (programToParticipantPercentMap.get(opplineNameMap.get(oli.Id)) != null) {
                    oli.Product_Participants__c = programToParticipantPercentMap.get(opplineNameMap.get(oli.Id)) * OppCoveredLivesMap.get(oli.Id);
                }
                if(oppLinePsMap.get(oli.Id) != NULL) {
                    if(oppLinePsMap.get(oli.Id).containsIgnoreCase('PEPM')) {
                        oli.Product_Participants__c = OppCoveredLivesMap.get(oli.Id);
                    }  
                }
                if(oli.Product_Participants__c != null){
                   oli.Product_Participants__c = oli.Product_Participants__c.round();                   
                }
            }            
        }
        finalOppLineItemList.add(OppLineItemlist);
        return finalOppLineItemList;
    }    
      
    
    public static void updateRevSynergyOnPrograms(List<OpportunityLineItem__c> oppLineList, Boolean isUpdate) { 
        List<Id> oppIds = new List<Id>();
        Map<Id,String> oppAccRevFlag = new Map<Id,String>();
        List<OpportunityLineItem__c> oppLineItemsToBeUpdated = new List<OpportunityLineItem__c>();
        String myStrId = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3' LIMIT 1].Id;	
        String myStrCompleteId = [SELECT Id FROM Product2 WHERE ProductCode  = 'MYSTRPLUS' LIMIT 1].Id;
        for(OpportunityLineItem__c opli : oppLineList) {
            oppIds.add(opli.Opportunity__c);          
        }
        List<Opportunity__c> oppList = [SELECT Id, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID IN : OppIds];
        for(Opportunity__c opp : oppList) {
            oppAccRevFlag.put(opp.Id, opp.Account__r.Acct_Rev_Synergy_Flag__c);
        }
       
        for(OpportunityLineItem__c opli : oppLineList) {
            Boolean isLvPrgm = false;
            Boolean isTdPrgm = false;
            
            if (opli.Product2__c == myStrId || opli.Product2__c == myStrCompleteId ) { 
                opli.Program_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
            }
            else if (opli.Program_Family__c == 'Teladoc'){ 
                isTdPrgm = true;
            }
            else {
                isLvPrgm = true;
            }
            switch on oppAccRevFlag.get(opli.Opportunity__c) {
                when 'Legacy Combined TD/LV Client' {
                    if (isLvPrgm || isTdPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                }
                when 'Legacy LV Client' {
                    if (isLvPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                    else if (isTdPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV';
                    }  
                }
                when 'Legacy TD Client' {
                    if (isLvPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD';
                    }
                    else if(isTdPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                }
                when 'Net New Client (All Solutions)' { 
                    if (isLvPrgm || isTdPrgm) { 
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                }
                when 'Legacy HHS Client' {
                    if (isLvPrgm) {
                        opli.Program_Rev_Synergy_Flag__c = 'Cross-sell LV to HHS';
                    }
                    else if(isTdPrgm) {
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                }
                when 'Legacy Combined HHS/LV Client' {
                    if (isLvPrgm || isTdPrgm) {
                        opli.Program_Rev_Synergy_Flag__c = 'No Synergy';
                    }
                }
            }
            oppLineItemsToBeUpdated.add(opli);
        }
        if(isUpdate && oppLineItemsToBeUpdated.size() > 0) {
            update oppLineItemsToBeUpdated;
        }
    }
}