public class L2O_GenerateOrder_Controller {
    
    @auraEnabled(cacheable=true)
    Public Static integer getContracts(string oppId){
        
        integer ConlistSize;
        Set<ID> conIds = new Set<ID>();
        List<Contract> conList = new List<Contract>();
        List<Opportunity> oppList = [select Id, SBQQ__AmendedContract__c, SBQQ__RenewedContract__c, L2O_InitialOpportunityGUID__c, L2O_GUID__c from Opportunity where Id =: oppId limit 1];
        if(!oppList.isEmpty()){
            if(!String.IsBlank(oppList[0].SBQQ__AmendedContract__c)) {
               conIds.add(oppList[0].SBQQ__AmendedContract__c);
            }
            else if(!String.IsBlank(oppList[0].SBQQ__RenewedContract__c)) {
               conIds.add(oppList[0].SBQQ__RenewedContract__c); 
            }
            else {
                conList = [Select Id,Status from Contract where SBQQ__Opportunity__c =: oppId Limit 1];
                conIds.add(conList[0].Id);
            }
        }
        ConlistSize = conIds.size();
        return ConlistSize;        
    }
}