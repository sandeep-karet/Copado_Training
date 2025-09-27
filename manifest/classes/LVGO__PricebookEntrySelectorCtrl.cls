/**
* This class serves as the Apex controller for the PricebookEntrySelector Lightning Component bundle.
* Created : 06/28/2019
* @author Connor Gallaher - Slalom
*/

public class PricebookEntrySelectorCtrl {
    @AuraEnabled
    public static List<PricebookEntry> getPricebookEntriesForPricebook(Id pricebookId) {
        List<PricebookEntry> pricebookEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, IsActive FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND IsActive = TRUE];
        return pricebookEntries;
    }
}