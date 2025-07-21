/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class MergeWebService {
    global MergeWebService() {

    }
    webService static Boolean appendToHeaderFooter(Id docId, String headerText, String footerText, String sessionId, String serverUrl) {
        return null;
    }
    webService static Boolean appendToHeaderFooter2(Id docId, String headerText, String footerText, String pLevel, String sessionId, String serverUrl) {
        return null;
    }
    webService static Boolean applyPDFSecurity(Id docId, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertAgreementWordDoc(Id agreementId, Id docId, String docFileName, String docFormat, String pLevel, Boolean addWatermark, Boolean removeWatermark, String agreementNbr, String dateFormat, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertAgreementWordDoc2(Id agreementId, Id docId, String docFileName, String docFormat, String pLevel, Boolean addWatermark, Boolean removeWatermark, String agreementNbr, String dateFormat, Boolean removeComments, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertWordDoc(Id docId, String docFileName, String docFormat, Id sObjectId, String pLevel, Boolean addWatermark, Boolean removeWatermark, String headerText, String footerText, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertWordDocForAgreement(Id agreementId, Id docId, String docFileName, String docFormat, String pLevel, Boolean addWatermark, Boolean removeWatermark, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertWordDocForAgreement2(Id agreementId, Id docId, String docFileName, String docFormat, String pLevel, Boolean addWatermark, Boolean removeWatermark, Boolean removeComments, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertWordDocToPDF(Id docId, String docFileName, Boolean addWatermark, Boolean removeWatermark, String headerText, String footerText, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id convertWordDocToPDF2(Id docId, String docFileName, Id sObjectId, String pLevel, Boolean addWatermark, Boolean removeWatermark, String headerText, String footerText, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id createPDF(Apttus.CustomClass.ActionParams params) {
        return null;
    }
    webService static Id createWordPackage(Apttus.CustomClass.ActionParams params) {
        return null;
    }
    webService static Boolean enableAuthoring(Id sObjectId, String pLevel, List<Id> docIds, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateCustomDoc(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateCustomDoc2(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, String outputFileName, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateDoc(Id templateId, Id agreementId, String pLevel, String docFormat, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateDoc2(Id templateId, Id agreementId, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateSupportingDoc(Id templateId, Id agreementId, String pLevel, String docFormat, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id generateSupportingDoc2(Id templateId, Id agreementId, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    global static Map<Id,List<Apttus.ClauseRefInfo>> getDynamicSectionClauses(Id contextId, Id templateId, List<Apttus__TemplateDynamicSection__c> sections) {
        return null;
    }
    global static Map<Id,Apttus.CustomClass.DynamicSectionContents> getDynamicSectionContents2(Id contextId, Id templateId, List<Apttus__TemplateDynamicSection__c> sections, Map<String,String> sortSpecsByType) {
        return null;
    }
    global static Map<Id,Apttus.CustomClass.DynamicSectionContents> getDynamicSectionContents(Id contextId, Id templateId, List<Apttus__TemplateDynamicSection__c> sections) {
        return null;
    }
    webService static Id mergeDocsToPDF2(Apttus.CustomClass.ActionParams mergeParams) {
        return null;
    }
    webService static Id mergeDocsToPDF(Id parentId, List<Id> docIds, String docFileName, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id mergeDocuments(Apttus.CustomClass.ActionParams params) {
        return null;
    }
    webService static Id regenerateDocWithRedlines(Apttus.CustomClass.DocGenParam params) {
        return null;
    }
    webService static Id submitGenerateCustomDoc(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateCustomDoc2(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, String outputFileName, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateCustomLargeDoc(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateCustomLargeDoc2(Id templateId, Id sObjectId, String sObjectType, String pLevel, String docFormat, String outputFileName, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateDoc(Id templateId, Id agreementId, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateLargeDoc(Id templateId, Id agreementId, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
    webService static Id submitGenerateSupportingDoc(Id templateId, Id agreementId, String pLevel, String docFormat, Boolean isDraft, String sessionId, String serverUrl) {
        return null;
    }
}
