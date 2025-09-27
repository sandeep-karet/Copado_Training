public with sharing class ClientHandoffSummaryController {
    public static List<CHS_Contact_Roles__mdt> accConRolesMDT {get; set;}
    static {
        CHS_Contact_Roles__mdt[] conRoles = [SELECT Role__c FROM CHS_Contact_Roles__mdt];
        accConRolesMDT = conRoles;
    }
    @AuraEnabled(cacheable=true)
    public static List<Contract__c> getPrograms(Id clientHandoffId){
        Client_Handoff_Summary__c clientHandoffSummary = getClientHandoffSummaryRecord(clientHandoffId);
        Id clientOverviewId = clientHandoffSummary.Client_Overview__c;
        List<Contract__c> contractList = [SELECT Id, Program_Name__c FROM Contract__c WHERE Client_Overview__c =: clientOverviewId];
        return contractList;
    }
    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation__c> getAccountContactRelationships(Id clientHandoffId) {
        String roleString = '';
        for(CHS_Contact_Roles__mdt crm: accConRolesMDT) {
            roleString += '\'' + crm.Role__c + '\',';
        }
        roleString = roleString.removeEnd(',');
        Client_Handoff_Summary__c clientHandoffSummary = getClientHandoffSummaryRecord(clientHandoffId);
        Id taskRayAccountId = clientHandoffSummary.Account__c;
        String queryString = 'SELECT Id, Account__c, Contact__c, Account__r.Name, Contact__r.Name, Contact__r.Email__c, Contact__r.Phone__c, Contact__c.Description__c,'+ 
                                'Roles__c, Contact__r.Title__c, Contact__r.Account__r.Name,'+
                                'Contact__r.FirstName__c, Contact__r.LastName__c FROM AccountContactRelation__c WHERE Account__c =: taskRayAccountId AND Roles__c includes (' + roleString +')'; //Contact.Include_in_Client_Strategy_Calls_Emails__c, 
        List<AccountContactRelation__c> accConRelList = Database.Query(queryString);
        return accConRelList;
    }
    private static Client_Handoff_Summary__c getClientHandoffSummaryRecord(Id chsId) {
        return [SELECT Id, Client_Overview__c, Account__c
                 FROM Client_Handoff_Summary__c WHERE Id =: chsId LIMIT 1]; //TaskRay_Project__c,
    }
}