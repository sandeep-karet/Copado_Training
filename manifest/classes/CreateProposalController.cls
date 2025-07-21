public with sharing class CreateProposalController {
    @AuraEnabled
    public static string errorCheck(Id recordId){  
        String error;
        boolean quoteApproved = true;
        List<Opportunity> oppList = [SELECT Id, Proposal_Template__c FROM Opportunity WHERE Id =: recordId];
        List<SBQQ__Quote__c> sbqqQte = [SELECT Id, SBQQ__Primary__c, Approvals__c, SBQQ__Status__c, Include_in_Octiv_Proposal__c FROM SBQQ__Quote__c 
                                  WHERE Include_in_Octiv_Proposal__c = TRUE 
                                  AND SBQQ__Opportunity2__c =: recordId];
        
        if(sbqqQte.size() > 0){
            for(SBQQ__Quote__c qte : sbqqQte) {
                if(qte.Approvals__c !=null && qte.SBQQ__Status__c != 'Approved') {
                    quoteApproved = false;
                }
            }         
        }   
        String errorMsg = GlobalOppUtil.validProposalTemplate(oppList, false);  
        
        if (errorMsg != null) {
            error = errorMsg;
            return error;
        }
        if (sbqqQte.size() == 0) {
            error = 'No Quote is selected to include in Octiv Proposal for the Opportunity, Can not create a Proposal';
            return error;
        }
        if (!quoteApproved) {
            error = 'Quote Included in Octiv Proposal is not approved, Can not create a Proposal';
            return error;
        }
        
        return null;
    } 
}