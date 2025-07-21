/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CPQUtilsBatchExport implements Database.Batchable<SObject> {
    global Date exportDate {
        get;
        set;
    }
    global String exportID {
        get;
        set;
    }
    global String exportName {
        get;
        set;
    }
    global String obName {
        get;
        set;
    }
    global String obOrder {
        get;
        set;
    }
    global String orgID {
        get;
        set;
    }
    global List<String> pricebooks {
        get;
        set;
    }
    global List<String> productIds {
        get;
        set;
    }
    global Map<String,RecordType> recordTypesMap {
        get;
        set;
    }
    global String standardPricebookId {
        get;
        set;
    }
    global CPQUtilsBatchExport(String obName, Decimal obOrder, Map<String,Boolean> cOCV, Map<String,String> pricebooks, String exportID) {

    }
    global void execute(Database.BatchableContext info, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    @Deprecated
    global Database.QueryLocator getData() {
        return null;
    }
    global Database.QueryLocator getData(String limitString) {
        return null;
    }
    global void initialize() {

    }
    global Database.QueryLocator start(Database.BatchableContext info) {
        return null;
    }
}
