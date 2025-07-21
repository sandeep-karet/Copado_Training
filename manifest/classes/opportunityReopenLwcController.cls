public with sharing class opportunityReopenLwcController {
    @AuraEnabled
    public static List<Contract> getContract(Id recordId) {
       List<Contract> contractList  = [Select Id, ContractNumber, Name, SBQQ__Opportunity__c, SBQQ__Opportunity__r.Name, StartDate, EndDate, Status 
                                       FROM Contract WHERE SBQQ__Opportunity__c =:recordId];
       return contractList;
    }
    
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getSubs(Id recordId) {
       List<SBQQ__Quote__c> qteList = [SELECT Id, RecordtypeId FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:recordId AND SBQQ__Primary__c = TRUE];

       List<SBQQ__Subscription__c> subList  = [SELECT Id, Name, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Name, Fee_Type__c, SBQQ__ProductName__c, Membership_Fee__c, 
                                               Consult_Type__c, Current_Membership_Fee__c, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c 
											   FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c in :qteList];
       return subList;
    }
    
    @AuraEnabled
    public static List<Plan_Specific_Fees__c> getPsf(Id recordId) {
        List<SBQQ__Quote__c> qteList = [SELECT Id, RecordtypeId FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:recordId AND SBQQ__Primary__c = TRUE];
        Map<Id,SBQQ__Subscription__c> subscriptionMap = new Map<Id,SBQQ__Subscription__c>();
        subscriptionMap = new Map<Id,SBQQ__Subscription__c>([SELECT Id, Name, SBQQ__QuoteLine__c, Fee_Type__c, SBQQ__ProductName__c, Membership_Fee__c, 
                                                             Consult_Type__c, Current_Membership_Fee__c, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c 
                                                             FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c in :qteList]);
        List<Plan_Specific_Fees__c> psfList = [SELECT Id, Name, Product__c, CreatedDate, Member_Group__c, Member_Group__r.Name, Member_Group_Name__c, Product_End_Date__c, 
                                               Product_Start_Date__c, Subscription__c, Subscription__r.Name FROM Plan_Specific_Fees__c 
                                               WHERE Subscription__c in : subscriptionMap.keySet()];
        return psfList;                                                      
    }
    
    @AuraEnabled
    public static List<Asset> getAsset(Id recordId) {
        List<SBQQ__Quote__c> qteList = [SELECT Id, RecordtypeId FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:recordId AND SBQQ__Primary__c = TRUE];
        List<Asset> assetList = [SELECT Id, Name, Product2.Name, Status, Implementation_Status__c, Number_of_Lives__c, Teladoc_Net_Fee__c,
                                 SBQQ__RequiredBySubscription__c, SBQQ__RequiredBySubscription__r.Name, Fee_Type__c, Consult_Fees__c 
                                 FROM Asset WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c in :qteList];
        return assetList;                                                      
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordType() {
        List<RecordType> rtList = [SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity'];
        
        return rtList;
    } 
    
    @AuraEnabled
    public static void deleteChildRecord(List<Plan_Specific_Fees__c> psfList, List<Contract> contList, List<Asset> assetList, List<SBQQ__Subscription__c> subList){
      
        delete assetList;
        delete psfList;     
        delete subList;
        delete contList;

    }
    
    @AuraEnabled
    public static void editOppAccountQuote(Id recordId, Id recordTypeId){
        List<SBQQ__Quote__c> qteList = [SELECT Id, RecordtypeId FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:recordId AND SBQQ__Primary__c = TRUE];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id =: recordId];
        opp.SBQQ__Contracted__c= false;
        opp.CPQ_Contracted_Date__c = null;
        opp.recordtypeId = recordTypeId;
        opp.Is_Requested_Close__c = false;
        update opp;
        Map<Id,opportunity> oppMap = new Map<Id,opportunity>();
        for(opportunity oppRec : [select id,stageName,AccountId from opportunity where AccountId =: opp.AccountId and stageName = :'Closed Won'])
        {
            oppMap.put(oppRec.AccountId,oppRec);
        }
        Account acct = [SELECT Id, Type FROM Account WHERE Id =: opp.AccountId];
        if(!oppMap.containsKey(acct.Id) && acct.Type!= null && acct.Type == 'Customer') {     
            acct.type = 'Prospect';   
            update acct;
        }
        List<SBQQ__Quote__c> quote2Update = new List <SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : qteList) { 
            quote.recordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Teladoc').getRecordTypeId();   
            quote2Update.add(quote);
        } 
        update quote2Update;            
    }
    
    @AuraEnabled
    public static string checkOppReady(Id recordId){
        string errorMsg = null;
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;

        if(!userProfileName.contains('System Administrator')) {
            errorMsg = 'Only System Administrator can re-open an opportunity';
            return errorMsg;
        }
        Opportunity opp = [SELECT Id, stageName FROM Opportunity WHERE Id =: recordId];
		if(opp.stageName != 'Closed Won' && opp.stageName != 'Contracting'){
            errorMsg = 'Opportunity stage is not Closed Won or Contracting.';
            return errorMsg;
        }
        
        return errorMsg;
    }
    
    // TODO: rethink logic baesd on contract and not parents acct
    @AuraEnabled
    public static List<Opportunity> checkAmendOpp(Id recordId) {
        List<Opportunity> OppIdList = new List<Opportunity>();
        List<Contract> contList = [SELECT Id FROM Contract WHERE SBQQ__Opportunity__c =: recordId];
        if (contList.size() > 0) {
            List<Opportunity> amendOppList = [SELECT Id, Name FROM Opportunity WHERE SBQQ__AmendedContract__c =: contList[0].Id AND SBQQ__Contracted__c = true];
            if (amendOppList.size() > 0) {
                for(Opportunity opp: amendOppList) {
                    OppIdList.add(opp);
                }
                return OppIdList;
            } else {
                return OppIdList;
            }
        }
       
        return OppIdList;
       
    }
   
    @AuraEnabled
    public static void clearContractedField(Id recordId){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: recordId];
        opp.Contracted_Date__c = null;
        opp.Contract_Service_Agreement_Status__c = null;
        update opp;
    }
    
}