/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CPQUtilsBatchDeploy implements Database.Batchable<SObject> {
    global Map<String,String> dependentFields {
        get;
        set;
    }
    global String deployID {
        get;
        set;
    }
    global String deployType {
        get;
        set;
    }
    global String exportID {
        get;
        set;
    }
    global Date importDate {
        get;
        set;
    }
    global String obName {
        get;
        set;
    }
    global List<String> obNames {
        get;
        set;
    }
    global Map<String,String> parentIdLookup {
        get;
        set;
    }
    global Map<String,String> parentIdLookupNewToOld {
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
    global Integer thisObNameIndex {
        get;
        set;
    }
    global CPQUtilsBatchDeploy(String exportID, List<String> obNames, Integer thisObNameIndex, String deployID, String deployType) {

    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global Database.QueryLocator getData() {
        return null;
    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
