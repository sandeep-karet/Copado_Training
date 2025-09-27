/**
* This class serves as the Apex controller for the RelatedClientAccounts Lightning Component bundle.
* Created : 06/11/2019
* @author Connor Gallaher - Slalom
*/

public class RelatedClientAccountsCtrl {
    /*
     * The partnerAccountId will be passed in from the Partner Agreement Wizard Flow;
     * Returns a list of Relationships that will be accessible and selectable within the Flow.
	 */
    @AuraEnabled
    public static List<Relationship__c> getRelatedClientAccounts(Id partnerAccountId) {
        Id contractPartnershipRT = Schema.SObjectType.Relationship__c.getRecordTypeInfosByDeveloperName().get('Contract_Partnership').getRecordTypeId();
        return [SELECT Id, RecordTypeId, RelationshipType__c, Master_Account__c, Master_Client_Account__c, Master_Client_Account_Name__c FROM Relationship__c WHERE Master_Account__c = :partnerAccountId AND RecordTypeId = :contractPartnershipRT ORDER BY RelationshipType__c ASC];
    }
}