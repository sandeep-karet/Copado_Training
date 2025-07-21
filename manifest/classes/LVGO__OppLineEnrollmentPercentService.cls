public class OppLineEnrollmentPercentService {
    
    public static final String DIABETES_W_CKD_AWARE_VARIANT = System.Label.Diabetes_w_CKD_Aware_Variant;
    public static final String HYPERTENSION_W_CKD_AWARE_VARIANT = System.Label.Hypertension_w_CKD_Aware_Variant;
    public static final String MYSTRENGTH = System.Label.myStrength;
    public static final String MYSTRENGTH_COMPLETE = System.Label.myStrength_Complete;
    
    public static List<OpportunityLineItem__c> updateEnrollmentPercentage(List<OpportunityLineItem__c> oppLineList) {
        System.debug('HERe::'+ oppLineList);
        Set<String> pricingStructureIds = new Set<String>();
        Set<String> productIds = new Set<String>();
        Set<String> OppIds = new Set<String>();
        List<OpportunityLineItem__c> oppLineItemsTobeUpdated = new List<OpportunityLineItem__c>();
        
        for(OpportunityLineItem__c oppLine : OppLineList) {
            if(oppLine.Pricing_Structure__c != null) {
                pricingStructureIds.add(oppLine.Pricing_Structure__c);
            }
            if(oppLine.Product2__c != null) {
                productIds.add(oppLine.Product2__c);
            }
            oppIds.add(OppLine.Opportunity__c);
        }
        
        Map <Id,Opportunity__c> oppMap = new Map<Id,Opportunity__c>([SELECT Id, Source__c, Opp_Owner_Role__c FROM Opportunity__c WHERE Id IN : OppIds]);
        Map <Id, Pricing_Structure__c> pricingStructureMap = new Map <Id, Pricing_Structure__c> ([Select Id, Name From Pricing_Structure__c Where Id IN: pricingStructureIds]);
        Map <Id, Product2> productMap = new Map <Id, Product2> ([Select Id, Name From Product2 Where Id IN: productIds]);
        
        List <Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTList = [SELECT Id, MasterLabel, DeveloperName, Opp_Owner_Role__c, Estimated_Enrollment__c, Program_Family__c FROM Estimated_Enrollment_Mapping__mdt];
        Map <String, Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTMap = new Map < String, Estimated_Enrollment_Mapping__mdt > ();
        if (!estimatedEnrollementMDTList.isEmpty()) {
            for (Estimated_Enrollment_Mapping__mdt enr : estimatedEnrollementMDTList) {
                estimatedEnrollementMDTMap.put(enr.Opp_Owner_Role__c + '' + enr.Program_Family__c, enr);
            }
        }
        for (OpportunityLineItem__c oli: oppLineList) {
            if(oppMap.get(oli.Opportunity__c).Source__c != 'TD') {
                
                String Opp_Owner_Role = oli.Opportunity__c != null && oppMap.get(oli.Opportunity__c).Opp_Owner_Role__c != null && oppMap.get(oli.Opportunity__c).Opp_Owner_Role__c.contains('Commercial') ? 'Commercial' : 'Other';
                
                String EstimatedEnrollmentKey = (Opp_Owner_Role != null && Opp_Owner_Role.contains('Commercial') ? 'Commercial' : 'Other')+oli.Program_Family__c;
               
                Decimal EstimatedEnrollmentPercent = estimatedEnrollementMDTMap.containsKey(EstimatedEnrollmentKey) && estimatedEnrollementMDTMap.get(EstimatedEnrollmentKey).Estimated_Enrollment__c != null ? estimatedEnrollementMDTMap.get(EstimatedEnrollmentKey).Estimated_Enrollment__c : 1;
            
                if (productMap.containsKey(oli.Product2__c) && productMap.get(oli.Product2__c).Name.equals(DIABETES_W_CKD_AWARE_VARIANT) || productMap.get(oli.Product2__c).Name.equals(HYPERTENSION_W_CKD_AWARE_VARIANT)) {
                    EstimatedEnrollmentPercent = 0.20;
                }
                
                Boolean myStrengthCalculation = false;
                
                if (oli.Pricing_Structure__c != null && oli.Product2__c != null &&
                    (pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('PPPM') || pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('PEPM') 
                     || pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('PMPM')) && productMap.containsKey(oli.Product2__c) && 
                    (productMap.get(oli.Product2__c).Name.equals(MYSTRENGTH) || productMap.get(oli.Product2__c).Name.equals(MYSTRENGTH_COMPLETE))) {
                        myStrengthCalculation = true;
                    }
                if (myStrengthCalculation) {
                    EstimatedEnrollmentPercent = oli.Pricing_Structure__c != null && (pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('DTE') ||
                                                                                      pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan ASO Opt IN') || 
                                                                                      pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('Broker') ||
                                                                                      pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('TPA/Reseller')) ? 0.05 :
                    oli.Pricing_Structure__c != null && (pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan FI') ||
                                                         pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan ASO Opt Out')) ? 0.025 : 0;
                }
                else if (oli.Pricing_Structure__c != null && pricingStructureMap.get(oli.Pricing_Structure__c).Name.containsIgnoreCase('PEPM') && oli.Program_Family__c != null && !myStrengthCalculation) {
                    EstimatedEnrollmentPercent = 1;  
                }
                oli.Enrollment_Percentage__c = EstimatedEnrollmentPercent * 100;
                oppLineItemsTobeUpdated.add(oli);
            }
        }
        return oppLineItemsTobeUpdated;
    }
}