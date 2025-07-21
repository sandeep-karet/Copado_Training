/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class ComplyWebService {
    global ComplyWebService() {

    }
    webService static Boolean afterAgreementClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Boolean afterAgreementRuleClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Boolean afterAmend(Id originalId, Id amendmentId) {
        return null;
    }
    webService static Boolean afterCreateChild(Id agreementId) {
        return null;
    }
    webService static Boolean afterCreateFromOpportunity(Id agreementId) {
        return null;
    }
    webService static Boolean afterCreateIntelligentImport(Id agreementId, String sourceUseCase, Id docId) {
        return null;
    }
    webService static Boolean afterCreateOffline(Id agreementId) {
        return null;
    }
    webService static Boolean afterEmailTemplateClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Boolean afterGenerateDoc(Id agreementId) {
        return null;
    }
    webService static Boolean afterGenerateSupportingDoc(Id agreementId) {
        return null;
    }
    webService static Boolean afterPreviewDoc(Id agreementId) {
        return null;
    }
    webService static Boolean afterPublish(Id agreementId, List<Id> attIds) {
        return null;
    }
    webService static Boolean afterQueryTemplateClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Boolean afterRegenerateDoc(Id agreementId) {
        return null;
    }
    webService static Boolean afterRenew(Id originalId, Id renewalId) {
        return null;
    }
    webService static Boolean afterSentForReview(Id agreementId) {
        return null;
    }
    webService static Boolean afterSentForSignatures(Id agreementId) {
        return null;
    }
    webService static Boolean afterStoreExecuted(Id agreementId) {
        return null;
    }
    webService static Boolean afterTemplateClone(Id originalId, Id cloneId) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c amendAgreement(Id originalId) {
        return null;
    }
    webService static String buildPageURL(List<String> paramNames, List<String> paramValues) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c cloneAgreement(Id originalId) {
        return null;
    }
    webService static Id cloneEmailTemplate(Id originalId) {
        return null;
    }
    webService static Boolean copyAgreementChildSObjects(Id sourceAgreementId, Id destAgreementId, List<String> relationshipNames) {
        return null;
    }
    webService static Boolean copyAttachment(Id destParentId, Id attId) {
        return null;
    }
    webService static List<Id> copyAttachments(Id destParentId, List<Id> attIds) {
        return null;
    }
    webService static void copyDocumentVersionAndDetails(Id sourceAgreementId, Id destAgreementId) {

    }
    webService static void copyDocumentsForLargeFileCase(Id destParentId, List<Id> docIds, String action) {

    }
    webService static Boolean copyTemplateChildSObjects(Id sourceTemplateId, Id destTemplateId, List<String> relationshipNames) {
        return null;
    }
    webService static Id createAgreementDocument(Id agreementId, Id attId) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c createAgreementFromOpportunity(Id opptyId, Id recordTypeId) {
        return null;
    }
    webService static Id createChatterFeedForAgreement(Id agreementId, Id attId) {
        return null;
    }
    webService static void createChatterFeedForAgreementLargeFile(Id agreementId, String previousStatusCategory, String previousStatus, Id asyncId, List<Id> fileIds) {

    }
    webService static String createContentDistributionLink(String fileName, Blob blobContent, String reasonForChange) {
        return null;
    }
    webService static Id createTemporaryObject() {
        return null;
    }
    webService static Boolean deleteAttachments(List<Id> attIds) {
        return null;
    }
    webService static Boolean deleteEmailTemplate(Id templateId) {
        return null;
    }
    webService static Id generateDoc(Id templateId, String templateName, Id agreementId, String agreementName, String pLevel, String docFormat) {
        return null;
    }
    webService static Id generateSupportingDoc(Id templateId, String templateName, Id agreementId, String agreementName, String pLevel, String docFormat) {
        return null;
    }
    webService static List<String> getAgreementChildRelationshipNamesForCloneAction(Id cloneAgreementId, String action) {
        return null;
    }
    webService static List<String> getAgreementChildRelationshipNamesForCloneId(Id cloneAgreementId) {
        return null;
    }
    webService static List<String> getAgreementChildRelationshipNamesForClone() {
        return null;
    }
    webService static List<Apttus.Property> getAgreementTagFieldValues(Id agreementId) {
        return null;
    }
    webService static List<String> getAttachmentFileForCopyDocuments(Id parentId, String action) {
        return null;
    }
    webService static List<String> getAttachmentFileForCopy(Id parentId) {
        return null;
    }
    webService static List<String> getAttachmentIDsForParent(Id parentId) {
        return null;
    }
    webService static Blob getAttachmentOrFileBody(Id attOrFileId) {
        return null;
    }
    webService static List<Apttus.DocumentWrapper> getFilesAttachmentDocumentBodyByIds(List<Id> docIds) {
        return null;
    }
    webService static List<String> getGlobalDescribe() {
        return null;
    }
    webService static Apttus.SObjectDescribeInfo getSObjectAttributeDescribe(String sObjectName) {
        return null;
    }
    webService static Apttus.SObjectDescribeInfo getSObjectChildDescribe(String sObjectName) {
        return null;
    }
    webService static Apttus.SObjectDescribeInfo getSObjectDescribe(String sObjectName) {
        return null;
    }
    webService static Apttus.SObjectDescribeInfo getSObjectFieldDescribe(String sObjectName) {
        return null;
    }
    webService static Apttus.SObjectDescribeInfo getSObjectPartialDescribe(String sObjectName) {
        return null;
    }
    webService static String getSitePrefix() {
        return null;
    }
    webService static List<String> getTemplateChildRelationshipNamesForClone() {
        return null;
    }
    webService static Boolean hasLargeFile(Id parentId) {
        return null;
    }
    webService static Boolean hasLargeFileDocument(Id parentId, String action) {
        return null;
    }
    webService static Boolean isAsyncCloneAmendRenewEnabled() {
        return null;
    }
    webService static Id previewDoc(Id templateId, Id agreementId, String agreementName, String pLevel, String docFormat) {
        return null;
    }
    webService static Boolean protectAgreementDocs(Id agreementId, String pLevel, List<Id> docIds) {
        return null;
    }
    webService static Boolean protectEmailDocs(Id templateId, String pLevel) {
        return null;
    }
    webService static Boolean protectTemporaryDocs(Id tobjectId, String pLevel) {
        return null;
    }
    webService static Id regenerateDoc(Id templateId, String templateName, Id agreementId, String agreementName, String pLevel, String docFormat) {
        return null;
    }
    webService static Apttus__APTS_Agreement__c renewAgreement(Id originalId) {
        return null;
    }
    webService static Boolean saveClauses(String agreementClauseDetails) {
        return null;
    }
    webService static String selectContentWorkspaceForAgreement(Id agreementId) {
        return null;
    }
    webService static String selectFirstTemplateNameForAgreement(Id agreementId, String templateType) {
        return null;
    }
    webService static Boolean unprotectAgreementDocs(Id agreementId, List<Id> docIds) {
        return null;
    }
    webService static Boolean unprotectEmailDocs(Id templateId) {
        return null;
    }
    webService static Boolean unprotectTemporaryDocs(Id tobjectId, String pLevel) {
        return null;
    }
    webService static Boolean updateAgreement(Apttus__APTS_Agreement__c agreement) {
        return null;
    }
    webService static Boolean updateAgreementDocs(Id agreementId) {
        return null;
    }
    webService static Boolean updateClonedAgreementDocs(Id agreementId) {
        return null;
    }
    webService static void updateIDEJobAfterUnzip(Id attachmentId, String ideJobId) {

    }
    webService static void updateIDEJobRecordAfterCreateIntelligentImport(Id agreementId, String previousStatus, String previousStatusCategory) {

    }
    webService static Boolean updateImportedAgreementDocs(Id agreementId) {
        return null;
    }
    webService static Boolean updateTemplateDocs(Id templateId) {
        return null;
    }
}
