/**
* AccountTriggerHandler Class
* 
*/

public class AccountTriggerHandler {
    public static final Id CLIENT_ACCOUNT_RT = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
    public static final Id PARTNER_ACCOUNT_RT = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
    
    public static void handleAccountUpdate(Map<Id,Account__c> oldAccounts, List<Account__c> newAccounts) {
        List<Account__c> updatedAccounts = new List<Account__c>();
        List<Account__c> hsUpdateAccounts = new List<Account__c>();
        List<Account__c> hsProgramScoreAccounts = new List<Account__c>();
        for(Account__c acc : newAccounts){
            if(acc.Client_Risk_Notes__c != null && acc.Client_Risk_Notes__c != oldAccounts.get(acc.Id).Client_Risk_Notes__c){
                updatedAccounts.add(acc);
            }
            if ((acc.RecordTypeId == CLIENT_ACCOUNT_RT || acc.RecordTypeId == PARTNER_ACCOUNT_RT)
                &&
                (acc.Enrollment_Percentage_rPwDs__c != oldAccounts.get(acc.Id).Enrollment_Percentage_rPwDs__c ||
                 acc.Enrollment_Percentage_rPwHs__c != oldAccounts.get(acc.Id).Enrollment_Percentage_rPwHs__c || 
                 acc.Activation__c  != oldAccounts.get(acc.Id).Activation__c || 
                 acc.Activated_Percent_HTN__c != oldAccounts.get(acc.Id).Activated_Percent_HTN__c ||
                 acc.Usage_Last_30_day_Diabetes__c != oldAccounts.get(acc.Id).Usage_Last_30_day_Diabetes__c ||
                 acc.Usage_Last_30_day_HTN__c != oldAccounts.get(acc.Id).Usage_Last_30_day_HTN__c ||
                 acc.Email_Coverage_Percentage_DM__c != oldAccounts.get(acc.Id).Email_Coverage_Percentage_DM__c || 
                 acc.Email_Coverage_Percentage_HTN__c != oldAccounts.get(acc.Id).Email_Coverage_Percentage_HTN__c)) {
                     hsUpdateAccounts.add(acc);
                 }
        }
        if (!updatedAccounts.isEmpty()) {
            AccountService.autoCreateNote(updatedAccounts);           
        }
        if (!hsUpdateAccounts.isEmpty()) {
            AccountService.updateHealthScores(hsUpdateAccounts, oldAccounts);
        }
    }
    public static void handleAccountAfterInsert(List<Account__c> newAccounts) {
        List<Account__c> accList = new List<Account__c>();
        for (Account__c acc: newAccounts) {
            if (acc.RecordTypeId == CLIENT_ACCOUNT_RT || acc.RecordTypeId == PARTNER_ACCOUNT_RT) {
                accList.add(acc);
            }
        }
        if (!accList.isEmpty()) {
            AccountService.createHealthScores(accList);
        }
    }
    
    public static void updateState( Map<Id, Account__c> oldAccounts, List<Account__c> newAccounts ) {
        Map<String, String> mapStateCode = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){  
            mapStateCode.put(f.getValue(), f.getLabel());
        }
        for(Account__c objAcc: newAccounts) 
        { 
            if( String.isNotBlank(objAcc.Billing_State_Backend__c) &&
               ( oldAccounts.isEmpty() || ( !oldAccounts.isEmpty() && oldAccounts.get(objAcc.Id).Billing_State_Backend__c != objAcc.Billing_State_Backend__c))
               && mapStateCode.containsKey(objAcc.Billing_State_Backend__c) ) 
            {
                objAcc.Billing_State_Backend__c = mapStateCode.get(objAcc.Billing_State_Backend__c);
                objAcc.BillingState__c = objAcc.Billing_State_Backend__c;
            }
            if( String.isNotBlank(objAcc.Shipping_State_Backend__c) &&
               ( oldAccounts.isEmpty() || ( !oldAccounts.isEmpty() && oldAccounts.get(objAcc.Id).Shipping_State_Backend__c != objAcc.Shipping_State_Backend__c))
               && mapStateCode.containsKey(objAcc.Shipping_State_Backend__c) ) 
            {
                objAcc.Shipping_State_Backend__c = mapStateCode.get(objAcc.Shipping_State_Backend__c);
                //objAcc.ShippingState = objAcc.Shipping_State_Backend__c; 
            }
        }
    }
    
    public static void updateOppRevSynergyFlag(Map<Id,Account__c> accOldMap, List<Account__c> accList) {
        List<String> accIdList = new List<String>();
        Boolean isUpdate = true;
        for (Account__c acct: accList) {
            if(acct.Acct_Rev_Synergy_Flag__c != accOldMap.get(acct.Id).Acct_Rev_Synergy_Flag__c) {
                accIdList.add(acct.Id);
            }
        }
        List<Opportunity__c> oppUpdateList = [SELECT Id FROM Opportunity__c WHERE Account__c IN: accIdList];
        if(oppUpdateList.size() > 0) {
            update oppUpdateList;
        }
        
        List<OpportunityLineItem__c> oppLineItemUpdateList = [SELECT Id,Opportunity__c,Product2__r.Name,Product2__c,Program_Family__c,
                                                           Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Opportunity__r.Account__c IN: accIdList];
        if(oppLineItemUpdateList.size() > 0) {
            OpportunityLineItemTriggerHandler.updateRevSynergyFlag(oppLineItemUpdateList, true);
            //update oppLineItemUpdateList; /* Updating these Opp Line Items from OpportunityLineItemService */
        }  
        
    }
    
    public static void updateAccountHealthColor(Map<Id,Account__c> accOldMap, List<Account__c> accList) {
        for(Account__c acc : accList) {
            if (acc.Overall_Account_Score__c != NULL && acc.Overall_Account_Score__c != accOldMap.get(acc.Id).Overall_Account_Score__c) { 
                if (acc.Overall_Account_Score__c >= 75) {
                    acc.Account_Health_Score_Color__c = 'Green';
                }
                else if (acc.Overall_Account_Score__c >= 60) {
                    acc.Account_Health_Score_Color__c = 'Yellow';
                }
                else {
                    acc.Account_Health_Score_Color__c = 'Red';  
                }
            }
        }
    }
}