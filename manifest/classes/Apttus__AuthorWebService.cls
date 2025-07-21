/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class AuthorWebService {
    global AuthorWebService() {

    }
    webService static void activateTemplateVersion(Id templateId, Id templateVersionId) {

    }
    webService static void afterCheckInDocs(Id agreementId, List<Id> attIds) {

    }
    webService static void afterCheckinTemplate(Apttus.CM.TemplateParams params) {

    }
    webService static void afterImportOfflineDoc(Id agreementId) {

    }
    webService static void afterImportOfflineDocs(Id agreementId, List<Id> attIds) {

    }
    webService static Boolean afterSentForReview(Id agreementId) {
        return null;
    }
    webService static void beginReview(Id agreementId, String documentGuid, List<Apttus.CM.UserAttachments> userAttachments) {

    }
    webService static Boolean checkInAgreement(Id agreementId, Id docId) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDetailDO checkInDocument(Id contextObjectId, String documentGuid, String documentName, Apttus.CM.CheckinType cType, String checkedoutVersion, String comments, String action, String checkinFor) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDetailDO checkInDocument2(Id contextObjectId, String documentGuid, String documentName, Apttus.CM.CheckinType cType, String checkedoutVersion, String comments, String action, String checkinFor, String docInfo, List<String> tags) {
        return null;
    }
    webService static Id checkOutAgreement(Id agreementId, Boolean withLock) {
        return null;
    }
    webService static String checkOutDocument(Id contextObjectId, String documentGuid, String version) {
        return null;
    }
    webService static void checkOutDocument2(Id contextObjectId, String documentGuid, String version) {

    }
    webService static Apttus.CM.TemplateCheckoutStatus checkoutTemplate(Apttus.CM.TemplateParams params) {
        return null;
    }
    webService static Apttus__DocumentVersionDetail__c createDocVersionForAgreement(Id agreementId, Id templateId, String docAction, String outputFormat, String comments) {
        return null;
    }
    webService static void endParallelReview(Id reviewCycleId, String emailId, Id documentVersionDetailId, String comment) {

    }
    webService static void endReview(Id agreementId, String documentGuid, List<Apttus.CM.UserAttachments> userAttachments) {

    }
    webService static String generateCheckInDocFileName(Id agreementId, String templateName, Id templateId, String lcActionName, String docFormat, Apttus.CM.CheckinType checkinType, String checkoutVersion, String checkinOption) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDetailDO generateDocumentVersion(Id contextObjectId, String documentGuid, String documentName, String comments, String action) {
        return null;
    }
    webService static List<String> getAdditionalContextTypes() {
        return null;
    }
    webService static Apttus.CM.AgreementLockDO getAgreementLockDO(Id agreementId) {
        return null;
    }
    webService static Apttus__Agreement_Protection__c getAgreementProtectionSO(Id profileId, String actionName) {
        return null;
    }
    webService static List<Apttus.PageInfo> getAuthorPageInfos() {
        return null;
    }
    webService static Apttus__APTS_Template__c getClauseSO(Id clauseId) {
        return null;
    }
    webService static Apttus.CM.ClauseInfoTree getClauseTreeForType(String clauseType, Id agreementId) {
        return null;
    }
    webService static String getContextObjectForRuleset(String rulesetName) {
        return null;
    }
    webService static String getDefaultSortFieldExpr(String sObjectName) {
        return null;
    }
    webService static List<Apttus__DocAssemblyRuleset__c> getDocAssemblyRulesetsForTemplate(Id templateId) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDO getDocumentStatus(Id contextObjectId, String documentGuid) {
        return null;
    }
    webService static List<String> getDocumentTagsForParent(Id parentId) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDetailDO getDocumentVersionDetail(Id versionDetailId) {
        return null;
    }
    webService static List<Apttus.CM.DocumentVersionDetailDO> getDocumentVersionDetails(Id contextObjectId) {
        return null;
    }
    webService static List<Apttus.CM.DocumentVersionDO> getDocumentVersions(Id contextObjectId) {
        return null;
    }
    webService static List<Apttus.CM.DictionaryEntry> getLocalizedStringsForApp(String app) {
        return null;
    }
    webService static String getNextCheckinVersion(Id agreementId, String documentGuid, String checkedoutVersion, Apttus.CM.CheckinType checkinType, String action, String docInfo) {
        return null;
    }
    webService static String getOccAccessForAgreement(Id agreementId) {
        return null;
    }
    webService static Apttus.CM.VersionInfo getPackageVersion() {
        return null;
    }
    webService static String getReviewStatus(Id agreementId, String groupIdentifier) {
        return null;
    }
    webService static List<Apttus.CM.SentReviewStatus> getReviewStatus2(Id agreementId, String groupIdentifier) {
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
    webService static Apttus.CM.AuthorSettings getSettings() {
        return null;
    }
    webService static Id getTemplateIdForReference(String referenceId) {
        return null;
    }
    webService static Apttus.CM.TemplateCheckoutStatus getTemplateStatus(Apttus.CM.TemplateParams params) {
        return null;
    }
    webService static List<Apttus__APTS_Template__c> getTemplatesForSObject(Id sObjectId, String templateType, String queryTemplateType) {
        return null;
    }
    webService static List<ContentDocumentLink> getWordDocumentInfosForParentWithFiles(Id parentId) {
        return null;
    }
    webService static List<Attachment> getWordDocumentInfosForParent(Id parentId) {
        return null;
    }
    webService static Apttus.CM.DocumentVersionDetailDO importOfflineSupportingDocument(Id contextObjectId, String documentGuid, String documentName, String documentContent, String comments, String action, String docFormat) {
        return null;
    }
    webService static void initiateParallelReview(Id attachmentId, Id agreementId, Id documentVersionDetailId, String emailSubject, String emailBody, List<Apttus.ReviewerWrapper> reviewersInfo) {

    }
    webService static Boolean isAgreementLocked(Id agreementId) {
        return null;
    }
    webService static Boolean isAgreementLockedBy(Id agreementId, Id userId) {
        return null;
    }
    webService static Boolean isDocumentCheckedOut(Id contextObjectId, String documentGuid) {
        return null;
    }
    webService static Boolean isIDEEnabled() {
        return null;
    }
    webService static Boolean isMultipleCheckoutEnabled() {
        return null;
    }
    webService static Boolean isVersionControlInEffect() {
        return null;
    }
    webService static Boolean lockAgreement(Id agreementId) {
        return null;
    }
    webService static Id publishMergeEvent(String eventName, Id bObjectId, Id templateId, String pLevel, String docFormat, Boolean isDraft, Id resultDocId) {
        return null;
    }
    webService static Id publishMergeEvent2(String eventName, Id bObjectId, Id templateId, String pLevel, String docFormat, Boolean isDraft, Id resultDocId, Id versionId) {
        return null;
    }
    webService static Id publishMergeEvent3(String eventName, Id bObjectId, Id templateId, String pLevel, String docFormat, Boolean isDraft, Id resultDocId, Id versionId, Boolean isPrivate) {
        return null;
    }
    webService static Id publishMergeEvent4(String eventName, Id bObjectId, Id templateId, String pLevel, String docFormat, String docInfo, Boolean isDraft, Id resultDocId, Id versionId, Boolean isPrivate) {
        return null;
    }
    webService static Id publishTemplate(Id templateVersionId, Apttus.SessionInfo sessionInfo) {
        return null;
    }
    webService static void raiseIDERequestForStatusCheck(Id agreementId, String sourceSystem) {

    }
    webService static Id regenerateDocWithRedlines(Id templateId, Id agreementId, Id versionDetailId, String pLevel, String docFormat, Boolean isDraft, Id sourceDocumentId) {
        return null;
    }
    webService static void revertCheckOut(Id contextObjectId, String documentGuid) {

    }
    webService static void revertCheckOutDocument(Id contextObjectId, String documentGuid) {

    }
    webService static Apttus.CM.TemplateCheckoutStatus revertCheckoutTemplate(Apttus.CM.TemplateParams params) {
        return null;
    }
    webService static Boolean subscribeToDocumentLock(Id documentVersionId, Id agreementId, Id userId) {
        return null;
    }
    webService static Boolean unlockAgreement(Id agreementId) {
        return null;
    }
    webService static void updateDocumentVersionAttachmentContent(Apttus.CM.DocumentVersionDetailDO docVersionDetailDO, String documentContents) {

    }
    webService static void uploadIDE(Id agreementId, Id attachmentOrFileId, String attachmentOrFileName, String sourceSystem) {

    }
}
