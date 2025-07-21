public with sharing class CreateContractController {   
    @AuraEnabled
    public static string errorCheck(Id recordId){
        boolean contracteeRel = false;
        boolean quoteApproved = true;
        
        String error;
        Opportunity opp = [SELECT Id, AccountId, StageName, Account.Primary_Billing_Contact__c, Initial_of_Lives__c,
                           (SELECT Id, Contact.Name FROM OpportunityContactRoles) FROM Opportunity WHERE Id =: recordId];
        
        List<SBQQ__Quote__c> sbqqQte = [SELECT Id, SBQQ__Primary__c, Approvals__c, SBQQ__Status__c FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Primary__c = TRUE 
                                  AND SBQQ__Opportunity2__c =:recordId];
        
        List<OpportunityLineItem> oppProd = [SELECT Id FROM OpportunityLineItem WHERE ProductCode='EMO2' AND OpportunityId =: recordId];
        
        if(sbqqQte.size() > 0){
            system.debug(sbqqQte[0].SBQQ__Status__c != 'Approved');
            if(sbqqQte[0].Approvals__c !=null && sbqqQte[0].SBQQ__Status__c != 'Approved') {
                quoteApproved = false;
            }
        }   
           
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        if (MyProflieName != 'System Administrator') {
            List<Acct_Rel__c> acctRelList = [SELECT Relationship_Type__c FROM Acct_Rel__c WHERE Benefit_Sponsor__c =: opp.AccountId AND (End_Date__c > today OR End_Date__c = null)];            
            for (Acct_Rel__c acctRel : acctRelList) {
                if (acctRel.Relationship_Type__c == 'Contractee') {
                    contracteeRel = true;
                }
            }
        } else {
            contracteeRel = true;
        }
        
        //Below values will be deprecated later for Contract Path LOB functionality
        /*if (contracteeRel == false) {
            error = 'No Contractee relationship exists on account';
            return error;
        }*/
        
        if (opp.Initial_of_Lives__c == null) {
            error = 'Number of Lives field missing, can not create a Contract';
            return error;
        } else if (opp.Account.Primary_Billing_Contact__c == null){
            error = 'Primary Billing Contact missing, can not create a Contract';
            return error;
        } else if (opp.OpportunityContactRoles.size() == 0) {
            error = 'Contact Role is missing, can not create a Contract';
            return error;
        } else if (oppProd.size() > 0){
            error = 'Can not create contract with EMS products are on the quote';
            return error;
        } else if (sbqqQte.size() == 0) {
            error = 'No Primary Quote for the Opportunity, Can not create a Contract';
            return error;
        } else if (!quoteApproved) {
            error = 'Primary Quote is not Approved, Can not create a Contract';
            return error;
        } else if(opp.StageName != 'Contracting') {
            error = 'The Opportunity must be in Contracting to create an Octiv Contract';
            return error;
        }
       
        return null;
    }     
}