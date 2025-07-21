/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class ActionProtocol {
    global ActionProtocol() {

    }
global class ActionDefinition {
    @AuraEnabled
    global List<String> categories;
    @AuraEnabled
    global String description;
    @AuraEnabled
    global Boolean isBulkAction;
    @AuraEnabled
    global String label;
    @AuraEnabled
    global String name;
    @AuraEnabled
    global Map<String,String> params;
    @AuraEnabled
    global String type;
    global ActionDefinition() {

    }
    global ActionDefinition(String name, String description, String type, String label) {

    }
    global ActionDefinition(String name, String description, String type, String label, List<String> categories) {

    }
}
global class ActionExecutionRequest {
    @AuraEnabled
    global Apttus_Base2.ActionProtocol.ActionDefinition action;
    @AuraEnabled
    global Map<String,String> context;
    @AuraEnabled
    global Apttus_Base2.DataProtocol.DescribeRecordObject describeRecord;
    @AuraEnabled
    global List<Apttus_Base2.ActionProtocol.ActionDefinition> nextActions;
    @AuraEnabled
    global Map<String,String> pageParams;
    @AuraEnabled
    global String records;
    global ActionExecutionRequest() {

    }
}
global class ActionExecutionResponse {
    @AuraEnabled
    global String message;
    @AuraEnabled
    global List<Apttus_Base2.ActionProtocol.ActionDefinition> nextActions;
    @AuraEnabled
    global Map<String,Object> payload;
    @AuraEnabled
    global Boolean success;
    global ActionExecutionResponse() {

    }
}
global class ActionListRequest {
    @AuraEnabled
    global List<String> categories;
    @AuraEnabled
    global Map<String,String> pageParams;
    global ActionListRequest() {

    }
}
global class ActionListResponse {
    @AuraEnabled
    global List<Apttus_Base2.ActionProtocol.ActionDefinition> actions;
    global ActionListResponse() {

    }
}
}
