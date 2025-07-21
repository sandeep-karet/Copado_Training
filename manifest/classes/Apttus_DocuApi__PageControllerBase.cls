/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class PageControllerBase {
    global String attachemntIds {
        get;
        set;
    }
    global Boolean attachmentsFromRSPC {
        get;
        set;
    }
    global Boolean batchMode {
        get;
    }
    global String documentUploadProcessId;
    global String docuSignSendActionStatusMessage {
        get;
        set;
    }
    global String docuSignSenderViewURL {
        get;
        set;
    }
    global Apttus_DocuApi__DocuSignUser__c docuSignUserLookupOnly {
        get;
        set;
    }
    global Boolean enableDocumentPreviewInDocuSign {
        get;
        set;
    }
    global String envelopeParentId {
        get;
        set;
    }
    global Boolean hasAmendRenewAtt {
        get;
        set;
    }
    global Boolean hasAssociatedAtt {
        get;
        set;
    }
    global Boolean hasAttachments {
        get;
        set;
    }
    global Boolean hasChildrenAtt {
        get;
        set;
    }
    global Boolean hasParentAtt {
        get;
        set;
    }
    global Boolean hasRecipients {
        get;
        set;
    }
    global Boolean hasRelatedAtt {
        get;
        set;
    }
    global Boolean hasSiblingsAtt {
        get;
        set;
    }
    global Boolean includeAmendRenew {
        get;
        set;
    }
    global Boolean includeChildren {
        get;
        set;
    }
    global Boolean includeParent {
        get;
        set;
    }
    global Boolean includeRelated {
        get;
        set;
    }
    global Boolean includeSiblings {
        get;
        set;
    }
    global Boolean isDefaultRecipientEnabled {
        get;
        set;
    }
    global Boolean isDocuSignSendActionStatus {
        get;
        set;
    }
    global Boolean isDocuSignSendError {
        get;
        set;
    }
    global Boolean isInitial {
        get;
        set;
    }
    global Boolean isRecipientTabsEnabled {
        get;
        set;
    }
    global Boolean isUploadingAttachments {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignEnvelopeData objDocuSignEnvelopeData {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignProcessHelper objDocuSignProcessHelper {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignSynchronousCalloutHelper objDocuSignSynchronousCalloutHelper {
        get;
        set;
    }
    global Boolean oneClickSend {
        get;
        set;
    }
    global String parentStatusLable {
        get;
        set;
    }
    global String parentTypeNameLable {
        get;
        set;
    }
    global String parentTypeNumberLable {
        get;
        set;
    }
    global String reopenEnvelopeId {
        get;
        set;
    }
    global Boolean selectAllAttachments {
        get;
        set;
    }
    global String selectedEmail {
        get;
        set;
    }
    global String selectedObjectType {
        get;
        set;
    }
    global Boolean showContactLookup {
        get;
        set;
    }
    global Boolean showEmail {
        get;
        set;
    }
    global Boolean showPreview {
        get;
        set;
    }
    global Boolean showRoleNameInUI {
        get;
        set;
    }
    global Boolean showUserLookup {
        get;
        set;
    }
    global PageControllerBase() {

    }
    global PageControllerBase(Boolean initThis) {

    }
    global PageControllerBase(String envelopeParentId) {

    }
    global void afterComponentLoad() {

    }
    global virtual System.PageReference checkDocusignOneClickSendStatus() {
        return null;
    }
    global virtual void disableUICustom(String iUIName, Boolean iStatus) {

    }
    global virtual System.PageReference doCancel() {
        return null;
    }
    global System.PageReference doDocuSignSend() {
        return null;
    }
    global System.PageReference doDocuSignSendStatus() {
        return null;
    }
    global virtual System.PageReference doDocuSignSendStatusNew() {
        return null;
    }
    global virtual System.PageReference doDocuSignTagAndSend() {
        return null;
    }
    global virtual System.PageReference doSetupSelectRecipientUILookup() {
        return null;
    }
    global String docuSignSendActionStatusMessage() {
        return null;
    }
    global virtual String docuSignSendActionStatusMessageHeader() {
        return null;
    }
    global virtual System.PageReference getDocuSignPage() {
        return null;
    }
    global virtual String getDocuSignSendActionStatusMessageHeader() {
        return null;
    }
    global virtual List<System.SelectOption> getDocuSignTemplates() {
        return null;
    }
    global List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> getEnvelopeSelectedAttachmentWrapper() {
        return null;
    }
    global List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> getEnvelopeUnSelectedAttachmentWrapper() {
        return null;
    }
    global virtual System.PageReference getErrorPage() {
        return null;
    }
    global String getParentObjectTypeName() {
        return null;
    }
    global String getParentObjectTypeNameAsLabel() {
        return null;
    }
    global List<System.SelectOption> getRecipientObjectTypes() {
        return null;
    }
    global List<System.SelectOption> getRecipientRole() {
        return null;
    }
    global List<System.SelectOption> getSignerRoleSelectOption() {
        return null;
    }
    global List<System.SelectOption> getSignerTypeSelectOption() {
        return null;
    }
    global List<System.SelectOption> getSignerType() {
        return null;
    }
    global Apttus_DocuApi.PageControllerBase getThis() {
        return null;
    }
    global void initComponentsDefault() {

    }
    global void initDefault() {

    }
    global void initDocuSignEnvelopeData() {

    }
    global virtual void initDocuSignEnvelopeDataByListRecipientAttachment(List<Id> iListRecipientId, List<Id> iListAttachmentId) {

    }
    global virtual Boolean isEnvelopeReady() {
        return null;
    }
    global virtual void loadAttachemntsByAssociationType(List<Id> iListAttachmentParentId, String iDocumentAssociationType) {

    }
    global virtual void loadAttachemnts(List<Id> iListAttachmentId) {

    }
    global virtual void loadAttachmentsByAssociationType(List<Id> iListAttachmentParentId, String iDocumentAssociationType) {

    }
    global virtual void loadAttachments(List<Id> iListAttachmentId) {

    }
    global virtual void loadOneClickRecipient(List<Id> iListContactId) {

    }
    global virtual void loadRecipient(List<Id> iListContactId) {

    }
    global virtual void setDocuSignSendActionStatusMessageHeader(String messageHeader) {

    }
    global void setEmailBody(String iEmailBody) {

    }
    global void setEmailSubject(String iEmailSubject) {

    }
    global void setThis(Apttus_DocuApi.PageControllerBase instance) {

    }
    global virtual Id submitDocuSignBatchCreateEnvelopeJob() {
        return null;
    }
    global System.PageReference updateUIObjects(Apttus_DocuApi.PageControllerBase.UIStep currentUIStep) {
        return null;
    }
global enum UIStep {COMPLETED, PICK_DOCUMENTS, PICK_RECIPIENTS, PICK_SENDER, PROCESSING, RESET_ONLY, SHOW_PRIVEW, SHOW_TAG_AND_SEND}
}
