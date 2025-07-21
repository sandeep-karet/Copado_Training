/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class CM {
    global static String RULETYPE_AGREEMENT_TEMPLATE;
    global static String RULETYPE_AGREEMENT_TYPE;
    global static String RULETYPE_CONTENT_WORKSPACE;
    global static String RULETYPE_DOCUMENT_FOLDER;
    global static String RULETYPE_EMAIL_TEMPLATE;
    global static String RULETYPE_QUEUE_ASSIGNMENT;
    global static String RULETYPE_SUBMIT_REQUEST_MODE;
    global CM() {

    }
global class AgreementLockDO {
    webService Apttus__APTS_Agreement__c AgreementSO {
        get;
    }
    webService List<Apttus.CM.CheckoutDO> Checkouts {
        get;
    }
    webService Boolean HasMultipleCheckouts {
        get;
    }
    webService Boolean IsLocked {
        get;
    }
    webService Id LockedById {
        get;
    }
    webService String LockedByName {
        get;
    }
    webService Datetime LockedDate {
        get;
    }
}
global class AuthorSettings {
    webService String AgreementNumberFieldForImportedDocs {
        get;
    }
    webService Boolean AllowPDFSelectionOverride {
        get;
    }
    webService Boolean AllowPrivateSelectionOverride {
        get;
    }
    webService Boolean AllowReconcileSelectionOverride {
        get;
    }
    webService Boolean AllowRegenerateFromXAC {
        get;
        set;
    }
    webService Boolean AncestorSelectionForImportOffline {
        get;
        set;
    }
    webService String AsynchronousCheckinRecipient {
        get;
        set;
    }
    webService Boolean AutoEnableAsynchronousCheckin {
        get;
        set;
    }
    webService Boolean AutoEnablePDFForFinalDocs {
        get;
    }
    webService Boolean AutoEnablePrivateIndicator {
        get;
    }
    webService Boolean AutoEnableReconcilation {
        get;
    }
    webService Boolean AutoInsertHeaderFooterData {
        get;
    }
    webService Boolean ClauseApprovalsEnabled {
        get;
    }
    webService String DefaultDocumentTags {
        get;
    }
    webService String DocumentNamingConvention {
        get;
    }
    webService Boolean DocumentVersioningEnabled {
        get;
        set;
    }
    webService String DocumentVersionNamingConvention {
        get;
        set;
    }
    webService Boolean DocumentVersionTrim {
        get;
        set;
    }
    webService Boolean EnableFile {
        get;
        set;
    }
    webService Boolean EnableOnlineContractCollaboration {
        get;
        set;
    }
    webService Boolean EnablePDFSecurity {
        get;
        set;
    }
    webService String FooterDatetimeFormatForImportedDocs {
        get;
    }
    webService Boolean HideContentControlBorder {
        get;
        set;
    }
    webService Boolean ParallelReview {
        get;
        set;
    }
    webService String PlaybookDefaultFilter {
        get;
        set;
    }
    webService Boolean PublishAuthorEvents {
        get;
    }
    webService String RestrictCheckinOfDocuments {
        get;
        set;
    }
    webService Boolean TemplateVersioningEnabled {
        get;
        set;
    }
    webService Boolean UnlockSmartElements {
        get;
        set;
    }
    webService String XAJSEndPoint {
        get;
        set;
    }
    global AuthorSettings() {

    }
}
global enum CheckinType {MAJOR, MINOR, REVISION}
global class CheckoutDO {
    webService Id CheckoutById {
        get;
    }
    webService String CheckoutByName {
        get;
    }
    webService Datetime CheckoutDate {
        get;
    }
}
global class ClauseCategoryInfo {
    webService List<Apttus.CM.ClauseInfo> Clauses {
        get;
    }
    webService Boolean HasClauses {
        get;
    }
    webService Boolean HasSubCategories {
        get;
    }
    webService String Name {
        get;
    }
    webService List<Apttus.CM.ClauseSubCategoryInfo> SubCategories {
        get;
    }
}
global class ClauseInfo {
    webService Id ClauseId {
        get;
    }
    webService String ClauseName {
        get;
    }
}
global class ClauseInfoTree {
    webService List<Apttus.CM.ClauseCategoryInfo> Categories {
        get;
    }
    webService List<Apttus.CM.ClauseInfo> Clauses {
        get;
    }
    webService String ClauseType {
        get;
    }
    webService Boolean HasCategories {
        get;
    }
    webService Boolean HasClauses {
        get;
    }
    webService String RecordType {
        get;
    }
}
global class ClauseSubCategoryInfo {
    webService List<Apttus.CM.ClauseInfo> Clauses {
        get;
    }
    webService Boolean HasClauses {
        get;
    }
    webService String Name {
        get;
    }
}
global class DictionaryEntry {
    webService String Key {
        get;
    }
    webService String Value {
        get;
    }
}
global class DocumentVersionDO {
    webService Id AgreementId {
        get;
    }
    webService Id ContextObjectId {
        get;
    }
    webService String DocumentExternalId {
        get;
    }
    webService Id Id {
        get;
    }
    webService Boolean IsCheckedout {
        get;
    }
    webService Id LastCheckoutById {
        get;
    }
    webService String LastCheckoutByName {
        get;
    }
    webService Datetime LastCheckoutDate {
        get;
    }
    webService Id LastCheckoutVersionDetailId {
        get;
    }
    webService String LatestVersion {
        get;
    }
    webService String ReferenceId {
        get;
    }
    webService Id TemplateId {
        get;
    }
    webService List<Apttus.CM.DocumentVersionDetailDO> VersionDetails {
        get;
    }
}
global class DocumentVersionDetailDO {
    webService String Action {
        get;
    }
    webService String Comment {
        get;
    }
    webService Id DocumentAttachmentId {
        get;
    }
    webService String DocumentTitle {
        get;
    }
    webService Id DocumentVersionId {
        get;
    }
    webService Id Id {
        get;
    }
    webService String Version {
        get;
    }
}
global class SentReviewStatus {
    webService String DocumentName {
        get;
    }
    webService Id Id {
        get;
    }
    webService Id ReceivedAttachmentId {
        get;
    }
    webService Id SentAttachmentId {
        get;
    }
    webService Datetime TimeReceived {
        get;
    }
    webService Datetime TimeSent {
        get;
    }
    webService String UserEmail {
        get;
    }
}
global class TemplateCheckoutStatus {
    webService Id CheckedoutVersion {
        get;
    }
    webService String CheckoutByName {
        get;
    }
    webService Datetime CheckoutDate {
        get;
    }
    webService Boolean IsCheckedout {
        get;
    }
    webService Id TemplateId {
        get;
    }
}
global class TemplateClauseReferenceDO {
    webService Id ClauseId {
        get;
        set;
    }
    webService String ClauseReferenceId {
        get;
        set;
    }
    webService Id ClauseVersionId {
        get;
        set;
    }
    global TemplateClauseReferenceDO() {

    }
}
global class TemplateDynamicSectionDO {
    webService String FilterCriteria {
        get;
        set;
    }
    webService String RulesetName {
        get;
        set;
    }
    webService String SectionName {
        get;
        set;
    }
    global TemplateDynamicSectionDO() {

    }
}
global class TemplateParams {
    webService List<Apttus.CM.TemplateClauseReferenceDO> ClauseReferences {
        get;
        set;
    }
    webService List<Apttus.CM.TemplateDynamicSectionDO> DynamicSections {
        get;
        set;
    }
    webService String MergeFields {
        get;
        set;
    }
    webService String MergeFields2 {
        get;
        set;
    }
    webService Id TemplateId {
        get;
        set;
    }
    webService Id TemplateVersionId {
        get;
        set;
    }
    webService String TextContent {
        get;
        set;
    }
    global TemplateParams() {

    }
}
global class UserAttachments {
    webService List<Id> AttachmentIds {
        get;
        set;
    }
    webService String UserEmail {
        get;
        set;
    }
    global UserAttachments() {

    }
}
global class VersionInfo {
    webService Integer Major {
        get;
    }
    webService Integer Minor {
        get;
    }
}
}
