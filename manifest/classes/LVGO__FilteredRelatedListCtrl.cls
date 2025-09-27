/**
* This class serves as the Apex controller for the FilteredRelatedList_Custom Lightning Component bundle.
* Created : 06/11/2019
* @author Connor Gallaher - Slalom
*/

public class FilteredRelatedListCtrl {
    /*
    * Queries for the parent sObject; which then allows other objects
    * related to that parent sObject to be queried. (e.g. Contact -> Account; then Client Overview -> Account)
    */
    @AuraEnabled
    public static SObject getParentSObject(String queryString) {
        List<SObject> objs = Database.query(queryString);
        return objs.get(0);
    }

    /*
    * Performs query based on the query string passed in.
    */
    @AuraEnabled
    public static List<SObject> getRelated(String queryString) {
        return Database.query(queryString);
    }

    /*
    * Returns mapping of the field labels (from 'columns' list) to their data types.
    */
    @AuraEnabled
    public static Map<String, String> getMetadataForColumns(String objectName, List<String> columns) {
        Map<String, String> metadataForColumns = new Map<String, String>();
        String label, type;
        for (String column : columns) {
            label = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(column).getDescribe().getLabel();
            type = String.valueOf(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(column).getDescribe().getType());
            metadataForColumns.put(label, type);
        }
        return metadataForColumns;
    }
}