public class OpportunityContactRolesListCtrl {
    @AuraEnabled
    public static List<OpportunityContactRole> getOpportunityContactRoles(Id oppId) {
        List<OpportunityContactRole> oppContactRoles = [SELECT Id, ContactId, Contact.Name, Role, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = :oppId AND (Role = 'Business Decision Maker' OR Role = 'Sales Lead / POC')];
        return oppContactRoles;
    }
}