/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CPQUtilsBatchDelete implements Database.Batchable<SObject> {
    global String deleteType {
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
    global Map<String,String> pricebooks {
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
    global CPQUtilsBatchDelete(List<String> obNames, Map<String,String> pricebooks, Integer thisObNameIndex, String deleteType) {

    }
    global void execute(Database.BatchableContext info, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
