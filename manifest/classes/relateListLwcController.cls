public with sharing class relateListLwcController {
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQteLine(Id recordId) {
        List<SBQQ__QuoteLine__c> qteLineList  = [SELECT Id, SBQQ__Product__r.Name, Membership_Fee__c, SBQQ__Quantity__c, Participant_Quantity__c,
                                                 Initial_Utilization_Cap_Calculated__c, Consult_Fees__c, Monthly_Price__c, 
                                                 SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Name, SBQQ__Product__r.ProductCode
                                                 FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:recordId];
        return qteLineList;    
    }
    
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOppProd(Id recordId) {
        List<OpportunityLineItem > oppLineList  = [SELECT Id, Product__c, Consult_Type__c, Quantity, Membership_Fee__c, SBQQ__QuoteLine__r.Participant_Quantity__c,
                                                   Monthly_Price__c, Initial_Utlization_Cap__c, TotalPrice ,Consult_Fees__c, Net_ARR__c 
                                                   FROM OpportunityLineItem WHERE OpportunityId =:recordId];
        return oppLineList;    
    }
    
    @AuraEnabled
    public static List<SBQQ__Quote__c> getOppQte(Id recordId) {
        List<SBQQ__Quote__c> oppQteList  = [SELECT Id, Name, SBQQ__NetAmount__c, SBQQ__Status__c, SBQQ__Primary__c,
                                                   CreatedById, CreatedBy.Name
                                                   FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:recordId];
        return oppQteList;    
    }
    
    
}