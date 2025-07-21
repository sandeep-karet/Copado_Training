/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class TelemetryLogger {
    global TelemetryLogger() {

    }
    global static Apttus_Base2.TelemetryLogger.LogResponseDO LogOperation(Apttus_Base2.TelemetryLogger.LogRequestDO request) {
        return null;
    }
global enum DataSourceType {LOG, METRIC, SPAN}
global class LogRequestDO {
    global String Attributes {
        get;
        set;
    }
    global String Body {
        get;
        set;
    }
    global String CodeFunction {
        get;
        set;
    }
    global String CodeLineNumber {
        get;
        set;
    }
    global Apttus_Base2.TelemetryLogger.DataSourceType DataSource {
        get;
        set;
    }
    global Datetime EndTimestamp {
        get;
        set;
    }
    global String MetricType {
        get;
        set;
    }
    global String OperationName {
        get;
        set;
    }
    global String PackageName {
        get;
        set;
    }
    global String PackageVersion {
        get;
        set;
    }
    global Id ParentSpanId {
        get;
        set;
    }
    global String Severity {
        get;
        set;
    }
    global Datetime Timestamp {
        get;
        set;
    }
    global String UnitOfMeasure {
        get;
        set;
    }
    global String Value {
        get;
        set;
    }
    global LogRequestDO() {

    }
    global LogRequestDO(Apttus_Base2.TelemetryLogger.DataSourceType sourceType, String packageName, String packageVersion, String operationName, Datetime timestamp) {

    }
}
global class LogResponseDO {
    global Apttus_Base2.TelemetryLogger.DataSourceType DataSource {
        get;
        set;
    }
    global String ErrorMessage {
        get;
        set;
    }
    global Boolean IsSuccess {
        get;
        set;
    }
    global Apttus_Base2__TelemetryLog__c LogSO {
        get;
        set;
    }
    global Apttus_Base2__TelemetryMetric__c MetricSO {
        get;
        set;
    }
    global Apttus_Base2__TelemetrySpan__c SpanSO {
        get;
        set;
    }
    global LogResponseDO() {

    }
}
}
