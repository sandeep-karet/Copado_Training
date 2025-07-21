/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RetentionPolicyEditController {
    global RetentionPolicyEditController(ApexPages.StandardController stdController) {

    }
    global void doAddRow() {

    }
    global System.PageReference doCancel() {
        return null;
    }
    global void doDeleteRow() {

    }
    global void doHideAdvancedOptions() {

    }
    global System.PageReference doOk() {
        return null;
    }
    global void doRemoveRow() {

    }
    global void doSetRetainForever() {

    }
    global void doShowAdvancedOptions() {

    }
    global String getAdvancedOptions() {
        return null;
    }
    global Apttus.RetentionPolicyEditController.AfterDate getAfterDate() {
        return null;
    }
    global List<System.SelectOption> getCompOperItems() {
        return null;
    }
    global List<System.SelectOption> getDateFieldItems() {
        return null;
    }
    global List<System.SelectOption> getFieldItems() {
        return null;
    }
    global Boolean getHasAfterDate() {
        return null;
    }
    global Boolean getHasErrors() {
        return null;
    }
    global Boolean getHasPeriod() {
        return null;
    }
    global Boolean getIsAdvancedOptionsMode() {
        return null;
    }
    global Boolean getOkToRemoveRow() {
        return null;
    }
    global Apttus.RetentionPolicyEditController.Period getPeriod() {
        return null;
    }
    global List<Apttus.RetentionPolicyEditController.Predicate> getPredicates() {
        return null;
    }
    global Boolean getRetainForever() {
        return null;
    }
    global List<System.SelectOption> getUomItems() {
        return null;
    }
    global Boolean isRetainForever() {
        return null;
    }
    global void setAdvancedOptions(String advOptions) {

    }
    global void setRetainForever(Boolean retainForever) {

    }
global class AfterDate {
    global String FieldLabel {
        get;
        set;
    }
    global String FieldName {
        get;
        set;
    }
}
global class Period {
    global String Uom {
        get;
        set;
    }
    global String Value {
        get;
        set;
    }
}
global class Predicate {
    global String BoolOper {
        get;
    }
    global String CompOper {
        get;
        set;
    }
    global Boolean CompOperInError {
        get;
    }
    global String ErrorMsg {
        get;
    }
    global Boolean FieldInError {
        get;
    }
    global String FieldLabel {
        get;
        set;
    }
    global String FieldName {
        get;
        set;
    }
    global String FieldType {
        get;
        set;
    }
    global String FieldValue {
        get;
        set;
    }
    global Boolean FieldValueInError {
        get;
    }
    global Integer RowNum {
        get;
    }
}
}
