/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AgreementGenerateController {
    global static String ACTION_CHECKIN;
    global static String ACTION_GENERATE;
    global static String ACTION_GENERATE_SUPPORTING_DOC;
    global static String ACTION_MERGE;
    global static String ACTION_PREVIEW;
    global static String ACTION_REGENERATE;
    global static String TEMPLATETYPE_AGREEMENT;
    global static String TEMPLATETYPE_SUPPORTING_DOC;
    global AgreementGenerateController(ApexPages.StandardController stdController) {

    }
    global static Apttus__DocumentVersionDetail__c createDocVersionSO(Id agreementId, Id templateId, String docAction, String outputFormat, String comments) {
        return null;
    }
    global Apttus.DocumentInfo generateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo generateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo generateSupportingDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo generateSupportingDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.AgreementGenerateController.OutputInfo getOutputInfoForAction(String docAction) {
        return null;
    }
    global Apttus.AgreementGenerateController.ProtectionInfo getProtectionInfoForAction(String docAction) {
        return null;
    }
    global List<Apttus__APTS_Template__c> getTemplatesForType(String templateType) {
        return null;
    }
    global Apttus.DocumentInfo previewDoc(Id templateId, Id parentId, String pLevel, String outputFormat, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo previewDoc(Id templateId, Id parentId, String pLevel, String outputFormat, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo regenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Apttus.DocumentInfo regenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitGenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitGenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitGenerateSupportingDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitGenerateSupportingDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitPreviewDoc(Id templateId, Id parentId, String pLevel, String outputFormat, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitPreviewDoc(Id templateId, Id parentId, String pLevel, String outputFormat, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitRegenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global Id submitRegenerateDoc(Id templateId, String pLevel, String outputFormat, Boolean isDraft, Id versionId, String sessionId, String serverUrl) {
        return null;
    }
global class OutputInfo {
    global Boolean IncludeWatermark {
        get;
    }
    global String OutputFormat {
        get;
    }
    global List<System.SelectOption> OutputFormatItems {
        get;
    }
    global Boolean ShowOutputFormats {
        get;
    }
    global Boolean ShowWatermark {
        get;
    }
    global OutputInfo() {

    }
}
global class ProtectionInfo {
    global String ProtectionLevel {
        get;
    }
    global List<System.SelectOption> ProtectionLevelItems {
        get;
    }
    global Boolean ShowProtectionLevels {
        get;
    }
    global ProtectionInfo() {

    }
}
}
