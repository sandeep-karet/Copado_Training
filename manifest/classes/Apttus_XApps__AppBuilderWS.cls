/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AppBuilderWS {
    global AppBuilderWS() {

    }
    webService static Boolean checkRuntimeLicense() {
        return null;
    }
    webService static Id createApp(String name) {
        return null;
    }
    webService static Id createApplication(Apttus_XApps.AppBuilderWS.CreateAppRequest req) {
        return null;
    }
    webService static Boolean deactivateApp(Apttus_XApps.AppBuilderWS.SaveAppRequest req) {
        return null;
    }
    webService static String getClientVersion() {
        return null;
    }
    global static List<Apttus_XApps.CustomClass.EditionInfo> getEditionInfo() {
        return null;
    }
    webService static String getFeatureDetail(Apttus_XApps.CustomClass.ActionParams params) {
        return null;
    }
    webService static Apttus_XApps.AppBuilderWS.licenseResponse getLicenseAndFeatureDetail(Apttus_XApps.CustomClass.ActionParams params) {
        return null;
    }
    webService static String getLicenseDetail(Apttus_XApps.CustomClass.ActionParams params) {
        return null;
    }
    webService static String getLocalFeatureDetail() {
        return null;
    }
    webService static String getLocalLicenseDetail() {
        return null;
    }
    webService static Boolean isAdmin() {
        return null;
    }
    webService static Boolean isDesigner() {
        return null;
    }
    webService static Apttus_XApps.AppBuilderWS.LoadAppResult loadApp(Id id) {
        return null;
    }
    webService static Apttus_XApps.AppBuilderWS.LoadAppResult loadApplication(Apttus_XApps.AppBuilderWS.LoadAppRequest req) {
        return null;
    }
    global static void resetLocalLicenseAndFeatureDetail() {

    }
    webService static Boolean runningInASandbox() {
        return null;
    }
    webService static Boolean saveApp(Id id, Blob config, Blob template, String templateName) {
        return null;
    }
    webService static Boolean saveApplication(Apttus_XApps.AppBuilderWS.SaveAppRequest req) {
        return null;
    }
    webService static void submitSyncLicenseAndFeatureDetail(Apttus_XApps.CustomClass.ActionParams params) {

    }
    webService static void syncLicenseAndFeatureDetail(Apttus_XApps.CustomClass.ActionParams params) {

    }
    webService static Apttus_XApps.AppBuilderWS.UpsertAppResult upsertApplication(Apttus_XApps.AppBuilderWS.UpsertAppRequest req) {
        return null;
    }
    webService static Boolean validateAppAccess(String appUniqueId) {
        return null;
    }
global class CreateAppRequest {
    @WebService
    webService String name;
    @WebService
    webService String uniqueId;
    global CreateAppRequest() {

    }
}
global class LoadAppRequest {
    @WebService
    webService Id id;
    @WebService
    webService String uniqueId;
    global LoadAppRequest() {

    }
}
global class LoadAppResult {
    @WebService
    webService Blob config;
    @WebService
    webService String edition;
    @WebService
    webService Blob schema;
    @WebService
    webService String templateName;
    @WebService
    webService Blob xlstemplate;
    global LoadAppResult() {

    }
}
global class SaveAppRequest {
    @WebService
    webService Blob config;
    @WebService
    webService String edition;
    @WebService
    webService Blob googleSheetSchema;
    @WebService
    webService Id id;
    @WebService
    webService Blob schema;
    @WebService
    webService Blob template;
    @WebService
    webService String templateName;
    @WebService
    webService String uniqueId;
    global SaveAppRequest() {

    }
}
global class UpsertAppRequest {
    @WebService
    webService Blob config;
    @WebService
    webService String edition;
    @WebService
    webService Blob googleSheetSchema;
    @WebService
    webService Id id;
    @WebService
    webService String name;
    @WebService
    webService Blob schema;
    @WebService
    webService Blob template;
    @WebService
    webService String templateName;
    @WebService
    webService String uniqueId;
    global UpsertAppRequest() {

    }
}
global class UpsertAppResult {
    @WebService
    webService Id id;
    global UpsertAppResult() {

    }
}
global class licenseResponse {
    @WebService
    webService String licenseDetailXML;
    @WebService
    webService String licenseFeatureDetailXML;
    global licenseResponse() {

    }
}
}
