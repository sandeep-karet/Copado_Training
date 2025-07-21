/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class DataProtocol {
    global DataProtocol() {

    }
global class DataProviderException extends Exception {
    global String message {
        get;
    }
    global String stackTrace {
        get;
    }
    global String typeName {
        get;
    }
}
global class DescribeRecordField {
    @AuraEnabled
    global String apiName;
    @AuraEnabled
    global String dataType;
    @AuraEnabled
    global String label;
    @AuraEnabled
    global Integer length;
    @AuraEnabled
    global Integer precision;
    @AuraEnabled
    global Apttus_Base2.DataProtocol.DescribeRecordObject referenceTo;
    @AuraEnabled
    global Boolean required;
    @AuraEnabled
    global Integer scale;
    global DescribeRecordField() {

    }
    global DescribeRecordField(String apiName, String label) {

    }
    global DescribeRecordField(String apiName, String label, String dataType, String referenceTo, Boolean isReferenceSO) {

    }
}
global class DescribeRecordObject {
    @AuraEnabled
    global String apiName;
    @AuraEnabled
    global Map<String,Apttus_Base2.DataProtocol.DescribeRecordField> fields;
    @AuraEnabled
    global Boolean isSObject;
    @AuraEnabled
    global String label;
    @AuraEnabled
    global String labelPlural;
    @AuraEnabled
    global String name;
    @AuraEnabled
    global String sObjectInfo;
    global DescribeRecordObject(Boolean isSObject, String name) {

    }
}
global class FilterField {
    @AuraEnabled
    global String fieldLabel;
    @AuraEnabled
    global String fieldName;
    @AuraEnabled
    global String fieldValue;
    global Apttus_Base2.DataProtocol.FilterFieldType filterFieldType {
        get;
        set;
    }
    @AuraEnabled
    global String filterFieldTypeString;
    @AuraEnabled
    global List<Apttus_Base2.DataProtocol.FilterFieldValue> filterFieldValues;
    @AuraEnabled
    global String operator;
    global FilterField(String fieldName, String operator, String fieldValue) {

    }
}
global enum FilterFieldType {Bool, MultiPickList}
global class FilterFieldValue {
    @AuraEnabled
    global Boolean isSelected;
    @AuraEnabled
    global String label;
    @AuraEnabled
    global String value;
    global FilterFieldValue() {

    }
}
global class ListDataRequest {
    @AuraEnabled
    global List<String> categoryIds;
    @AuraEnabled
    global Map<String,String> extraParams;
    @AuraEnabled
    global List<String> fields;
    @AuraEnabled
    global String filterExpression;
    @AuraEnabled
    global List<Apttus_Base2.DataProtocol.FilterField> filters;
    @AuraEnabled
    global List<String> includeParams;
    @AuraEnabled
    global String objectApiName;
    @AuraEnabled
    global Integer page;
    @AuraEnabled
    global Map<String,String> pageParams;
    @AuraEnabled
    global Integer pageSize;
    @AuraEnabled
    global String query;
    @AuraEnabled
    global String searchText;
    @AuraEnabled
    global Apttus_Base2.DataProtocol.SortField sortBy;
    global ListDataRequest() {

    }
}
global class ListDataResponse {
    @AuraEnabled
    global List<Object> categories;
    global Apttus_Base2.DataProtocol.DescribeRecordObject describeRecord {
        get;
    }
    @AuraEnabled
    global Apttus_Base2.DataProtocol.DataProviderException error;
    @AuraEnabled
    global Map<String,String> extraParams;
    @AuraEnabled
    global List<Apttus_Base2.DataProtocol.FilterField> facetData;
    @AuraEnabled
    global Map<String,Object> headerData;
    @AuraEnabled
    global List<Object> records;
    @AuraEnabled
    global Integer totalRecords;
    global ListDataResponse(Apttus_Base2.DataProtocol.DescribeRecordObject describe) {

    }
}
global class RecordDataRequest {
    @AuraEnabled
    global Map<String,String> extraParams;
    @AuraEnabled
    global List<String> fields;
    @AuraEnabled
    global String objectApiName;
    @AuraEnabled
    global Map<String,String> pageParams;
    @AuraEnabled
    global String recordId;
    @AuraEnabled
    global List<String> recordIds;
    global RecordDataRequest() {

    }
}
global class RecordDataResponse {
    global Apttus_Base2.DataProtocol.DescribeRecordObject describeRecord {
        get;
    }
    @AuraEnabled
    global Apttus_Base2.DataProtocol.DataProviderException error;
    @AuraEnabled
    global Map<String,String> extraParams;
    @AuraEnabled
    global Object record;
    @AuraEnabled
    global List<Object> records;
    global RecordDataResponse(Apttus_Base2.DataProtocol.DescribeRecordObject describe) {

    }
}
global class SortField {
    @AuraEnabled
    global String dir;
    @AuraEnabled
    global String fieldName;
    global SortField(String fieldName, String dir) {

    }
}
}
