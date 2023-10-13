public class OppLineRevCalcHelper {
    public static final String DIABETES_W_CKD_AWARE_VARIANT = System.Label.Diabetes_w_CKD_Aware_Variant;
    public static final String HYPERTENSION_W_CKD_AWARE_VARIANT = System.Label.Hypertension_w_CKD_Aware_Variant;
    public static final String MYSTRENGTH = System.Label.myStrength;
    public static final String MYSTRENGTH_COMPLETE = System.Label.myStrength_Complete;
    
    public static void calculateArrFieldValues(List < OpportunityLineItem__c> lstOP) {
        if (lstOP != null && !lstOP.isEmpty()) {
            Set <String> setPS = new Set <String> ();
            Set <String> setP = new Set <String> ();
            Set <Id> setOppId = new Set <Id> ();
            
            for (OpportunityLineItem__c obj: lstOP) {
                if (obj.Pricing_Structure__c != null) {
                    setPS.add(obj.Pricing_Structure__c);
                }
                if (obj.Product2__c != null) {
                    setP.add(obj.Product2__c);
                }
                setOppId.add(obj.Opportunity__c);
            }
            Map <Id,Opportunity__c> oppMap = new Map<Id,Opportunity__c>([SELECT Id, Name, Source__c, Opp_Owner_Role__c FROM Opportunity__c WHERE 
                                                                   Id IN : setOppId]);
            Map <Id, Pricing_Structure__c> mapPS = new Map <Id, Pricing_Structure__c> ([Select Id, Name From Pricing_Structure__c Where Id IN: setPS]);
            Map <Id, Product2> mapP = new Map <Id, Product2> ([Select Id, Name From Product2 Where Id IN: setP]);
            
            //Getting Estimated Enrollment Percentage from custom metadata
            List <Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTList = [SELECT Id, MasterLabel, DeveloperName, Opp_Owner_Role__c, Estimated_Enrollment__c, Program_Family__c FROM Estimated_Enrollment_Mapping__mdt];
            Map <String, Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTMap = new Map < String, Estimated_Enrollment_Mapping__mdt > ();
            if (!estimatedEnrollementMDTList.isEmpty()) {
                for (Estimated_Enrollment_Mapping__mdt objMDA: estimatedEnrollementMDTList) {
                    estimatedEnrollementMDTMap.put(objMDA.Opp_Owner_Role__c + '' + objMDA.Program_Family__c, objMDA);
                }
            }
            
            for (OpportunityLineItem__c obj: lstOP) {
                //obj.Name = oppMap.get(obj.Opportunity__c).Name + ' ' + mapP.get(obj.Product2__c).Name;
                String oppName = mapP.get(obj.Product2__c).Name + ' ' + oppMap.get(obj.Opportunity__c).Name;
                obj.Name = oppName.length() > 80 ? oppName.substring(0,80):oppName;
                if(oppMap.get(obj.Opportunity__c).Source__c != 'TD') {
                    
                    Decimal Product_Participants = obj.Product_Participants__c != null ? obj.Product_Participants__c : 0.00;
                    Decimal Estimated_At_Risk_PPPM = obj.Estimated_At_Risk_PPPM__c != null ? obj.Estimated_At_Risk_PPPM__c : 0.00;
                    Decimal Estimated_Partner_Admin_Fees = obj.Estimated_Partner_Admin_Fees__c != null ? obj.Estimated_Partner_Admin_Fees__c : 0.00;
                    Decimal Up_Front_Per_Member = obj.Up_Front_Per_Member__c != null ? obj.Up_Front_Per_Member__c : 0.00;
                    Decimal Program_Term = obj.Quantity__c;
                    Decimal Currently_Enrolled_Members = obj.Currently_Enrolled_Members__c != null ? obj.Currently_Enrolled_Members__c : 0.00;
                    Decimal Incremental_Sales_Price = obj.Incremental_Sales_Price__c != null ? obj.Incremental_Sales_Price__c : 0.00;
                    Decimal Year_2_Price = obj.Year_2_Price__c != null ? obj.Year_2_Price__c : 0.00;
                    Decimal PMPM = obj.PMPM__c != null ? obj.PMPM__c : 0.00;
                    Decimal UnitPrice = obj.UnitPrice__c != null ? obj.UnitPrice__c : 0.00;
                    
                    //Identifying if the Owner Role is Commercial or Other
                    String Opp_Owner_Role = obj.Opportunity__c != null && oppMap.get(obj.Opportunity__c).Opp_Owner_Role__c != null && oppMap.get(obj.Opportunity__c).Opp_Owner_Role__c.contains('Commercial') ? 'Commercial' : 'Other';
                    //Creating unique key using  Opp_Owner_Role__c and Program_Family__c
                    String EstimatedEnrollmentKey = (Opp_Owner_Role != null && Opp_Owner_Role.contains('Commercial') ? 'Commercial' : 'Other')+obj.Program_Family__c;
                    //Assigning Estimated Enrollment Percentages from custom metadata    
                    Decimal EstimatedEnrollmentPercent = estimatedEnrollementMDTMap.containsKey(EstimatedEnrollmentKey) && estimatedEnrollementMDTMap.get(EstimatedEnrollmentKey).Estimated_Enrollment__c != null ? estimatedEnrollementMDTMap.get(EstimatedEnrollmentKey).Estimated_Enrollment__c : 1;
                    //Assigning Estimated Enrollment Percentages for Diabetes and Hypertension w/ CKD Aware Variants
                    if (mapP.containsKey(obj.Product2__c) && mapP.get(obj.Product2__c).Name.equals(DIABETES_W_CKD_AWARE_VARIANT) || mapP.get(obj.Product2__c).Name.equals(HYPERTENSION_W_CKD_AWARE_VARIANT)) {
                        EstimatedEnrollmentPercent = 0.20;
                    }
                    //obj.Opportunity_Owner_Role__c = mapOpp.get(obj.OpportunityId).Owner.UserRole.Name;
                    Boolean myStrengthCalculation = false;
                    
                    /*START***MYSTRENGTH AND MYSTRENGTH COMPLETE CALCULATION***/
                    
                    if (obj.Pricing_Structure__c != null && obj.Product2__c != null &&
                        (mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PPPM') || mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PEPM') 
                         || mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PMPM')) && mapP.containsKey(obj.Product2__c) && 
                        (mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH) || mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH_COMPLETE))) {
                            myStrengthCalculation = true;
                        }
                    if (myStrengthCalculation) {
                        Decimal myStrengthEstimatedEnrollmentRate = obj.Pricing_Structure__c != null && (mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('DTE') ||
                                                                                                         mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan ASO Opt IN') || 
                                                                                                         mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('Broker') ||
                                                                                                         mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('TPA/Reseller')) ? 0.05 :
                        obj.Pricing_Structure__c != null && (mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan FI') ||
                                                             mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('Health Plan ASO Opt Out')) ? 0.025 : 1;
                        
                        
                        /***MYSTRENGTH OR MYSTRENGTH COMPLETE FOR PPPM BASED CALCULATION***/
                        if(obj.Pricing_Structure__c != null && mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PPPM')) {
                            if(mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH) || mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH_COMPLETE)) {
                                obj.Gross_Program_ARR_Copy__c = UnitPrice  * myStrengthEstimatedEnrollmentRate * Product_Participants * 6;
                                obj.Program_ARR_Copy__c = Product_Participants * myStrengthEstimatedEnrollmentRate * ((UnitPrice - (Estimated_At_Risk_PPPM + Estimated_Partner_Admin_Fees)) * 6 + Up_Front_Per_Member);                               
                            }
                            EstimatedEnrollmentPercent =  myStrengthEstimatedEnrollmentRate;
                        }
                        /***MYSTRENGTH OR MYSTRENGTH COMPLETE FOR PEPM OR PMPM BASED CALCULATION***/
                        else if(obj.Pricing_Structure__c != null && mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PEPM') || mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PMPM')) {
                            if(mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH) || mapP.get(obj.Product2__c).Name.equals(MYSTRENGTH_COMPLETE)) {
                                obj.Gross_Program_ARR_Copy__c = UnitPrice * Product_Participants * 12;
                                obj.Program_ARR_Copy__c = Product_Participants * ((UnitPrice - (Estimated_At_Risk_PPPM + Estimated_Partner_Admin_Fees)) * 12 + Up_Front_Per_Member);
                            }
                           EstimatedEnrollmentPercent =  1;
                        }
                    }
                    /*END***MYSTRENGTH AND MYSTRENGTH COMPLETE CALCULATION***/
                    
                    /*START***ALL OTHER PROGRAMS CALCULATION***/
                    
                    else if (obj.Program_Family__c != null && !myStrengthCalculation) {
                        
                        /*START***GROSS PROGRAM ARR***/
                        
                        /***PEPM BASED CALCULATION***/
                        if (obj.Pricing_Structure__c != null && mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PEPM')) {
                            obj.Gross_Program_ARR_Copy__c = Product_Participants * UnitPrice * 12 + Currently_Enrolled_Members * Incremental_Sales_Price * 12;
                        }
                        /***MILESTONE BASED CALCULATION***/
                        else if ((obj.Program_Family__c == LABEL.Weight_Management || obj.Program_Family__c == LABEL.Prediabetes) && UnitPrice == 1) {
                            obj.Gross_Program_ARR_Copy__c = 608 * EstimatedEnrollmentPercent * Product_Participants;
                        }
                        /***STANDARD PPPM BASED CALCULATION***/
                        else if (obj.Program_Family__c != Label.Behavioral_Health){
                            obj.Gross_Program_ARR_Copy__c = EstimatedEnrollmentPercent * Product_Participants * UnitPrice * 12 
                                + Currently_Enrolled_Members * Incremental_Sales_Price * 12;
                        }
                        /***BH and DEFALUT CALCULATION***/
                        else {
                            obj.Gross_Program_ARR_Copy__c = Product_Participants * UnitPrice * 12 + Product_Participants * 0.02 * PMPM * 6;
                        }
                        /*END***GROSS PROGRAM ARR***/
                        
                        /*START***NET PROGRAM ARR***/
                        
                        /***PEPM BASED CALCULATION***/
                        if (obj.Pricing_Structure__c != null && mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PEPM')) {
                            obj.Program_ARR_Copy__c = Product_Participants * ((UnitPrice - (Estimated_At_Risk_PPPM + Estimated_Partner_Admin_Fees)) * 12 + Up_Front_Per_Member) 
                                + Currently_Enrolled_Members * Incremental_Sales_Price * 12;
                        }
                        /***MILESTONE BASED CALCULATION***/
                        else if ((obj.Program_Family__c == LABEL.Weight_Management || obj.Program_Family__c == LABEL.Prediabetes) && UnitPrice == 1) {
                            obj.Program_ARR_Copy__c = 608 * EstimatedEnrollmentPercent * Product_Participants;
                        }
                        /***STANDARD PPPM BASED CALCULATION***/
                        else if (obj.Program_Family__c != Label.Behavioral_Health){
                            obj.Program_ARR_Copy__c = EstimatedEnrollmentPercent * Product_Participants * ((UnitPrice - (Estimated_At_Risk_PPPM + Estimated_Partner_Admin_Fees)) * 12 + Up_Front_Per_Member) 
                                + Currently_Enrolled_Members * Incremental_Sales_Price * 12;
                        }
                        /***BH and DEFALUT CALCULATION***/
                        else {
                            obj.Program_ARR_Copy__c = Product_Participants * ((UnitPrice - (Estimated_At_Risk_PPPM + Estimated_Partner_Admin_Fees)) * 12 + Up_Front_Per_Member) 
                                + Product_Participants * 0.02 * PMPM * 6;
                        }
                        
                        /*END***NET PROGRAM ARR***/
                    }
                    if (obj.Pricing_Structure__c != null && mapPS.get(obj.Pricing_Structure__c).Name.containsIgnoreCase('PEPM') && obj.Program_Family__c != null && !myStrengthCalculation) {
                        EstimatedEnrollmentPercent = 1;  
                    }
                    obj.Enrollment_Percentage__c = EstimatedEnrollmentPercent * 100;       
                    /*END***ALL OTHER PROGRAMS CALCULATION****************/
                }
            }
        }
    } 
}
