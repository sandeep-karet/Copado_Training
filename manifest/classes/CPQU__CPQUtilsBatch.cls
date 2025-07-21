/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CPQUtilsBatch implements Database.Batchable<String> {
    global String batchType {
        get;
        set;
    }
    global String exportID {
        get;
        set;
    }
    global Blob importContent {
        get;
        set;
    }
    global List<String> obAbrevs {
        get;
        set;
    }
    global List<String> obNames {
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
    global CPQUtilsBatch() {

    }
    global void execute(Database.BatchableContext info, List<String> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
