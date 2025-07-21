/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DocuSignUtil {
    global static String AP_STEND_STATUS_REFRESH;
    global static String APTS_STATUS_COMPLETED;
    global static String APTS_STATUS_REASSIGNED;
    global static String ASSOCIATION_AMEND_RENEW_AGMT;
    global static String ASSOCIATION_AMEND_RENEW_ATT;
    global static String ASSOCIATION_CHILD_AGMT;
    global static String ASSOCIATION_CHILD_ATT;
    global static String ASSOCIATION_PARENT_AGMT;
    global static String ASSOCIATION_PARENT_ATT;
    global static String ASSOCIATION_PRIMARY_AGMT;
    global static String ASSOCIATION_PRIMARY_ATT;
    global static String ASSOCIATION_RELATED_AGMT;
    global static String ASSOCIATION_RELATED_ATT;
    global static String ASSOCIATION_SIBLING_AGMT;
    global static String ASSOCIATION_SIBLING_ATT;
    global static String BUTTON_BACK_TO_PARENT;
    global static String BUTTON_CANCEL;
    global static String BUTTON_DS_SENDERVIEW;
    global static String BUTTON_PREVIEW;
    global static String BUTTON_SELECT_ATTACHEMENTS;
    global static String BUTTON_SELECT_RECIPIENT;
    global static String BUTTON_SEND;
    global static String BUTTON_SEND_ON_BEHALF_OF;
    global static Integer MAX_ATTACHEMNTS;
    global static Integer MAX_ATTACHMENTS;
    global static Integer MAX_RECIPIENT;
    global static Boolean mockException;
    global static String OP_STEND_STATUS_MESSAGE;
    global static String PB_DS_SENDERVIEW;
    global static String PB_PICK_ATTACHMENTS;
    global static String PB_PICK_RECIPIENT;
    global static String PB_PRIEVIEW;
    global static String PB_PROCESSING_VIEW;
    global static String PB_SEARCH_FILDER_FIELDS;
    global static String PB_SEND_ON_BEHALF_OF;
    global static String PROP_SYSTEM_PROPERTIES;
    global static String RECIPIENT_TYPE_CORBON_COPY;
    global static String RECIPIENT_TYPE_IN_PERSON;
    global static String RECIPIENT_TYPE_SIGNER;
    global DocuSignUtil() {

    }
    global static void addMessageToLog(System.LoggingLevel iLogLevel, String messageToLog) {

    }
    global static Apttus_DocuApi__DocuSignSystemProperties__c getSystemProperties() {
        return null;
    }
global virtual class AbstractDSUserSetting {
    global String name {
        get;
        set;
    }
    global AbstractDSUserSetting() {

    }
}
global abstract class AbstractResult {
    global Boolean error {
        get;
        set;
    }
    global String errorCode {
        get;
        set;
    }
    global String errorMessage {
        get;
        set;
    }
    global Boolean success {
        get;
        set;
    }
    global AbstractResult() {

    }
}
global class AttachmentWrapper {
    global Attachment attachment {
        get;
        set;
    }
    global Apttus_DocuApi.AttachmentFileWrapper attachmentFileWrapper {
        get;
        set;
    }
    global Boolean canMoveDown {
        get;
        set;
    }
    global Boolean canMoveUp {
        get;
        set;
    }
    global String documentAssociationType {
        get;
    }
    global Boolean isChild {
        get;
        set;
    }
    global Boolean isParent {
        get;
        set;
    }
    global Boolean isSibling {
        get;
        set;
    }
    global Integer objectIndex {
        get;
        set;
    }
    global Id parentId {
        get;
        set;
    }
    global String parentName {
        get;
        set;
    }
    global String parentNumber {
        get;
        set;
    }
    global String parentStatus {
        get;
        set;
    }
    global String relationship {
        get;
    }
    global Boolean selected {
        get;
        set;
    }
    global List<Id> siblingsId {
        get;
        set;
    }
    global AttachmentWrapper(String docAssociationType, Apttus_DocuApi.AttachmentFileWrapper attachmentFileWrapper, Id pId, Boolean selected, Integer objectIndex) {

    }
    global AttachmentWrapper(String docAssociationType, Attachment attachment, Id pId, Boolean selected, Integer objectIndex) {

    }
}
global class AttachmentWrapperList {
    global Boolean hasAmendRenew {
        get;
    }
    global Boolean hasChild {
        get;
    }
    global Boolean hasParent {
        get;
    }
    global Boolean hasRelated {
        get;
    }
    global Boolean hasSibling {
        get;
    }
    global List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> listAttachmentWrapper {
        get;
    }
    global String parentName {
        get;
        set;
    }
    global String parentNumber {
        get;
        set;
    }
    global String parentStatus {
        get;
        set;
    }
    global AttachmentWrapperList() {

    }
    global void add(Apttus_DocuApi.DocuSignUtil.AttachmentWrapper objAttachmentWrapper) {

    }
    global void add(List<Apttus_DocuApi.AttachmentFileWrapper> attachments) {

    }
    global void add(List<Apttus_DocuApi.AttachmentFileWrapper> attachments, String iDocumentAssociationType) {

    }
    global void add(List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> attachmentWrappers) {

    }
    global void add(List<Attachment> attachments) {

    }
    global void add(List<Attachment> attachments, String iDocumentAssociationType) {

    }
    global List<Apttus_DocuApi.AttachmentFileWrapper> getAttachmentFileList() {
        return null;
    }
    global List<Attachment> getAttachmentList() {
        return null;
    }
    global Integer getSelectedDocumentCount() {
        return null;
    }
    global void moveDown(Integer attachmentWrapperIndex) {

    }
    global void moveUp(Integer attachmentWrapperIndex) {

    }
    global Apttus_DocuApi.DocuSignUtil.AttachmentWrapper remove(Integer attachmentWrapperIndex) {
        return null;
    }
    global void selectAllDocuments() {

    }
    global void selectDocument(Integer objectIndex) {

    }
    global void setSelectedDocumentAsListAttachmentWrapper(List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> listSelectedAttachmentWrapper) {

    }
    global Integer size() {
        return null;
    }
    global void unSelectAllDocuments() {

    }
    global void unSelectDocument(Integer objectIndex) {

    }
    global void updateIndexUpAndDown() {

    }
}
global class DSAccount {
    global String accountName {
        get;
        set;
    }
    global String distributorCode {
        get;
        set;
    }
    global String distributorPassword {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DSInitialUser initialUser {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DSPlanInformation planInformation {
        get;
        set;
    }
    global DSAccount() {

    }
}
global class DSCreateAccountResponse {
    global String accountId {
        get;
        set;
    }
    global String apiPassword {
        get;
        set;
    }
    global String baseUrl {
        get;
        set;
    }
    global String userId {
        get;
        set;
    }
    global DSCreateAccountResponse() {

    }
}
global class DSCreateAccountResult extends Apttus_DocuApi.DocuSignUtil.AbstractResult {
    global Apttus_DocuApi.DocuSignUtil.DSCreateAccountResponse response {
        get;
        set;
    }
    global DSCreateAccountResult() {

    }
}
global class DSCreateUserResponse {
    global List<Apttus_DocuApi.DocuSignUtil.DSUserInfo> newUsers {
        get;
        set;
    }
    global DSCreateUserResponse() {

    }
}
global class DSCreateUserResult extends Apttus_DocuApi.DocuSignUtil.AbstractResult {
    global Apttus_DocuApi.DocuSignUtil.DSCreateUserResponse response {
        get;
        set;
    }
    global DSCreateUserResult() {

    }
}
global class DSErrorMessage {
    global String errorCode {
        get;
        set;
    }
    global String message {
        get;
        set;
    }
    global DSErrorMessage() {

    }
}
global class DSForgottenPasswordInfo {
    global String forgottenPasswordAnswer1 {
        get;
        set;
    }
    global String forgottenPasswordQuestion1 {
        get;
        set;
    }
    global DSForgottenPasswordInfo() {

    }
}
global class DSInitialUser {
    global String email {
        get;
        set;
    }
    global String firstName {
        get;
        set;
    }
    global String lastName {
        get;
        set;
    }
    global String middleName {
        get;
        set;
    }
    global String password {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global DSInitialUser() {

    }
}
global class DSPlanInformation {
    global String planId {
        get;
        set;
    }
    global DSPlanInformation() {

    }
}
global class DSUser {
    global String email {
        get;
        set;
    }
    global String firstName {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DSForgottenPasswordInfo forgottenPasswordInfo {
        get;
        set;
    }
    global String lastName {
        get;
        set;
    }
    global String password {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.AbstractDSUserSetting> userSettings {
        get;
        set;
    }
    global DSUser() {

    }
    global void addDSUserSetting(Apttus_DocuApi.DocuSignUtil.AbstractDSUserSetting iAbstractDSUserSetting) {

    }
}
global class DSUserInfo {
    global String apiPassword {
        get;
        set;
    }
    global String email {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DSErrorMessage errorDetails {
        get;
        set;
    }
    global String uri {
        get;
        set;
    }
    global String userId {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global DSUserInfo() {

    }
}
global class DSUserSettingBoolean extends Apttus_DocuApi.DocuSignUtil.AbstractDSUserSetting {
    global Boolean value {
        get;
        set;
    }
    global DSUserSettingBoolean() {

    }
}
global class DSUserSettingString extends Apttus_DocuApi.DocuSignUtil.AbstractDSUserSetting {
    global String value {
        get;
        set;
    }
    global DSUserSettingString() {

    }
}
global class DSUsers {
    global List<Apttus_DocuApi.DocuSignUtil.DSUser> newUsers {
        get;
        set;
    }
    global DSUsers() {

    }
    global void addDSUser(Apttus_DocuApi.DocuSignUtil.DSUser iDSUser) {

    }
}
global class DocuSignAccessToken {
    global String accessToken {
        get;
        set;
    }
    global String distributorCode {
        get;
        set;
    }
    global String docuSignAccountId {
        get;
        set;
    }
    global String docuSignBaseURL {
        get;
        set;
    }
    global String docuSignCompanyName {
        get;
        set;
    }
    global String docuSignUserEmail {
        get;
        set;
    }
    global String docuSignUserId {
        get;
        set;
    }
    global String docuSignUserName {
        get;
        set;
    }
    global Boolean isApttusCreatedDocusignAccount {
        get;
        set;
    }
    global Boolean isDefault {
        get;
        set;
    }
    global String tokenScope {
        get;
        set;
    }
    global String tokenType {
        get;
        set;
    }
    global DocuSignAccessToken() {

    }
    global String getDecryptedAccessToken() {
        return null;
    }
    global void setDocuSignLoginAccountsData(Apttus_DocuApi.DocuSignUtil.DocuSignLoginAccountsData objDocuSignLoginAccountsData) {

    }
    global void setDocuSignOAuthTokenData(Apttus_DocuApi.DocuSignUtil.DocuSignOAuthTokenData objDocuSignOAuthTokenData) {

    }
}
global class DocuSignEnvelopRecipientsStausResponse {
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> agents {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> carbonCopies {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> certifiedDeliveries {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> editors {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> inPersonSigners {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> intermediaries {
        get;
        set;
    }
    global String recipientCount {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> signers {
        get;
        set;
    }
    global DocuSignEnvelopRecipientsStausResponse() {

    }
}
global class DocuSignEnvelopeData {
    global String brandId {
        get;
        set;
    }
    global String documentUploadProcessId {
        get;
        set;
    }
    global String emailBody {
        get;
        set;
    }
    global String emailSubject {
        get;
        set;
    }
    global String envelopeStatus {
        get;
        set;
    }
    global Boolean error {
        get;
        set;
    }
    global String errorCode {
        get;
        set;
    }
    global String errorMessage {
        get;
        set;
    }
    global String Id {
        get;
        set;
    }
    global Boolean isPreviewInDocusign;
    global Apttus_DocuApi.DocuSignUtil.DocuSignNotification notification {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.AttachmentWrapperList objAttachmentWrapperList {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.RecipientList objRecipientList {
        get;
        set;
    }
    global Boolean oneClickSend;
    global String parentId {
        get;
        set;
    }
    global String sendAsUserEmail {
        get;
        set;
    }
    global String senderViewURL {
        get;
        set;
    }
    global Boolean showPreview;
    global Boolean showSendAsAnotherUser;
    global Boolean showSendforESignature;
    global Boolean showTagAndSend;
    global Boolean success {
        get;
        set;
    }
    global String templateId {
        get;
        set;
    }
    global DocuSignEnvelopeData() {

    }
    global virtual void addRecipientTabs(Integer iRecipientId, Apttus_DocuApi.DocuSignUtil.RecipientTabs iTabs) {

    }
    global String getFCObjectReturnURL() {
        return null;
    }
    global virtual Integer getRecipientCount() {
        return null;
    }
    global Apttus_DocuApi.DocuSignUtil.RecipientList getRecipientList() {
        return null;
    }
    global Integer getSelectedDocumentCount() {
        return null;
    }
    global void selectAllDocuments() {

    }
    global void selectDocument(Integer objectIndex) {

    }
    global void unSelectAllDocuments() {

    }
    global void unSelectDocument(Integer objectIndex) {

    }
    global void updateIndexBySigningOrder() {

    }
    global void updateIndexUpAndDown() {

    }
}
global class DocuSignEnvelopeStatus {
    global String envelopeId {
        get;
        set;
    }
    global String envelopeOwnerId {
        get;
        set;
    }
    global Integer numberOfDocuments {
        get;
        set;
    }
    global String parentId {
        get;
        set;
    }
    global String parentTypeName {
        get;
        set;
    }
    global String recipientsUri {
        get;
        set;
    }
    global String sfdcEnvelopeId {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus> signersStatus {
        get;
        set;
    }
    global String status {
        get;
        set;
    }
    global Datetime statusChangedDateTime {
        get;
        set;
    }
    global DocuSignEnvelopeStatus() {

    }
}
global class DocuSignEnvelopeStatusQueryResponse {
    global Integer endPosition {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.DocuSignMultiEnvelopeStatusResponse> envelopes {
        get;
        set;
    }
    global String nextUri {
        get;
        set;
    }
    global String previousUri {
        get;
        set;
    }
    global Integer resultSetSize {
        get;
        set;
    }
    global Integer startPosition {
        get;
        set;
    }
    global Integer totalSetSize {
        get;
        set;
    }
    global DocuSignEnvelopeStatusQueryResponse() {

    }
}
global class DocuSignLoginAccountsData {
    global String accountId {
        get;
        set;
    }
    global String baseUrl {
        get;
        set;
    }
    global String email {
        get;
        set;
    }
    global String isDefault {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String siteDescription {
        get;
        set;
    }
    global String userId {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global DocuSignLoginAccountsData() {

    }
    global Boolean isDefaultAccountUser() {
        return null;
    }
}
global class DocuSignOAuthTokenData {
    global String access_token {
        get;
        set;
    }
    global String scope {
        get;
        set;
    }
    global String token_type {
        get;
        set;
    }
    global DocuSignOAuthTokenData() {

    }
    global String getAccessToken() {
        return null;
    }
    global String getTokenScope() {
        return null;
    }
    global String getTokenType() {
        return null;
    }
}
global class DocuSignRecipientStatus {
    global Datetime deliveredDateTime {
        get;
        set;
    }
    global String email {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String recipientIdGuid {
        get;
        set;
    }
    global String requireIdLookup {
        get;
        set;
    }
    global String roleName {
        get;
        set;
    }
    global String routingOrder {
        get;
        set;
    }
    global Datetime signedDateTime {
        get;
        set;
    }
    global String status {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.RecipientTabs tabs {
        get;
        set;
    }
    global String userId {
        get;
        set;
    }
    global DocuSignRecipientStatus() {

    }
}
global class DocuSignSingleEnvelopeStatusResponse {
    global String certificateUri {
        get;
        set;
    }
    global Datetime createdDateTime {
        get;
        set;
    }
    global String customFieldsUri {
        get;
        set;
    }
    global String documentsCombinedUri {
        get;
        set;
    }
    global String documentsUri {
        get;
        set;
    }
    global String emailBlurb {
        get;
        set;
    }
    global String emailSubject {
        get;
        set;
    }
    global String enableWetSign {
        get;
        set;
    }
    global String envelopeId {
        get;
        set;
    }
    global String envelopeUri {
        get;
        set;
    }
    global String notificationUri {
        get;
        set;
    }
    global String recipientsUri {
        get;
        set;
    }
    global Datetime sentDateTime {
        get;
        set;
    }
    global String status {
        get;
        set;
    }
    global Datetime statusChangedDateTime {
        get;
        set;
    }
    global String templatesUri {
        get;
        set;
    }
    global DocuSignSingleEnvelopeStatusResponse() {

    }
}
global class RadioButton {
    global String anchorString {
        get;
        set;
    }
    global String anchorXOffset {
        get;
        set;
    }
    global String anchorYOffset {
        get;
        set;
    }
    global Boolean selected {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global RadioButton(Boolean iValue, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class Recipient {
    global Boolean canMoveDown {
        get;
        set;
    }
    global Boolean canMoveUp {
        get;
        set;
    }
    global String email {
        get;
    }
    global Apttus_DocuApi.DocuSignUtil.RecipientEmailNotification emailNotification {
        get;
        set;
    }
    global Id emailTemplateId {
        get;
        set;
    }
    global String id {
        get;
    }
    global Boolean isRequired {
        get;
        set;
    }
    global String name {
        get;
    }
    global String note {
        get;
        set;
    }
    global Integer objectIndex {
        get;
        set;
    }
    global String objectType {
        get;
    }
    global Integer orderNumber {
        get;
        set;
    }
    global Boolean selected {
        get;
        set;
    }
    global String signerRole {
        get;
        set;
    }
    global String signerType {
        get;
        set;
    }
    global String signingGroupId {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.RecipientTabs tabs {
        get;
        set;
    }
    global Recipient(String id, String nam, String email, Integer orderNumber, Boolean selected, String objectType) {

    }
    global Recipient(String id, String nam, String email, Integer orderNumber, Boolean selected, String objectType, String iSignerRole, String iSignerType) {

    }
    global Recipient(String id, String nam, String email, Integer orderNumber, Boolean selected, String objectType, String iSignerRole, String iSignerType, Apttus_DocuApi.DocuSignUtil.RecipientEmailNotification emailNotification) {

    }
    global Recipient(String id, String nam, String email, Integer orderNumber, Boolean selected, String objectType, String iSignerRole, String iSignerType, Apttus_DocuApi.DocuSignUtil.RecipientEmailNotification emailNotification, String signingGroupId) {

    }
    global Recipient(String id, String nam, String email, Integer orderNumber, Boolean selected, String objectType, String iSignerRole, String iSignerType, Apttus_DocuApi.DocuSignUtil.RecipientEmailNotification emailNotification, String signingGroupId, String note) {

    }
    global virtual String getSignerTypeDisplayName() {
        return null;
    }
}
global class RecipientEmailNotification {
    global String emailBody {
        get;
        set;
    }
    global String emailSubject {
        get;
        set;
    }
    global String supportedLanguage {
        get;
        set;
    }
    global RecipientEmailNotification(String emailBody, String emailSubject, String supportedLanguage) {

    }
}
global class RecipientList {
    global List<Apttus_DocuApi.DocuSignUtil.Recipient> listRecipient {
        get;
    }
    global RecipientList() {

    }
    global void add(Apttus_DocuApi.DocuSignUtil.Recipient sfRecipient) {

    }
    global void addRecipientTabs(Integer iRecipientId, Apttus_DocuApi.DocuSignUtil.RecipientTabs iTabs) {

    }
    global void add(List<Apttus_DocuApi.DocuSignUtil.Recipient> recipients) {

    }
    global void moveDown(Integer recipientIndex) {

    }
    global void moveUp(Integer recipientIndex) {

    }
    global void remove(Integer recipientIndex) {

    }
    global void removeAll() {

    }
    global Integer size() {
        return null;
    }
}
global class RecipientTab {
    global String anchorString {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global Boolean required {
        get;
        set;
    }
    global String tapType {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global RecipientTab() {

    }
}
global class RecipientTabs {
    global List<Apttus_DocuApi.DocuSignUtil.approveTab> approveTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.checkboxTab> checkboxTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.companyTab> companyTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.dateSignedTab> dateSignedTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.dateTab> dateTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.declineTab> declineTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.emailAddressTab> emailAddressTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.emailTab> emailTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.envelopeIdTab> envelopeIdTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.firstNameTab> firstNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.fullNameTab> fullNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.initialHereTab> initialHereTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.lastNameTab> lastNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.listTab> listTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.noteTab> noteTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.numberTab> numberTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.radioGroupTab> radioGroupTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.signerAttachmentTab> signerAttachmentTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.signHereTab> signHereTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.ssnTab> ssnTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.textTab> textTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.titleTab> titleTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.zipTab> zipTabs {
        get;
        set;
    }
    global RecipientTabs() {

    }
    global void addCheckboxTab(Apttus_DocuApi.DocuSignUtil.checkboxTab iTab) {

    }
    global void addCompanyTab(Apttus_DocuApi.DocuSignUtil.companyTab iTab) {

    }
    global void addDateSignedTab(Apttus_DocuApi.DocuSignUtil.dateSignedTab iTab) {

    }
    global void addDateTab(Apttus_DocuApi.DocuSignUtil.dateTab iTab) {

    }
    global void addEmailAddressTab(Apttus_DocuApi.DocuSignUtil.emailAddressTab iTab) {

    }
    global void addEmailTab(Apttus_DocuApi.DocuSignUtil.emailTab iTab) {

    }
    global void addFirstNameTab(Apttus_DocuApi.DocuSignUtil.firstNameTab iTab) {

    }
    global void addFullNameTab(Apttus_DocuApi.DocuSignUtil.fullNameTab iTab) {

    }
    global void addLastNameTab(Apttus_DocuApi.DocuSignUtil.lastNameTab iTab) {

    }
    global void addNoteTabs(Apttus_DocuApi.DocuSignUtil.noteTab iTab) {

    }
    global void addNumberTab(Apttus_DocuApi.DocuSignUtil.numberTab iTab) {

    }
    global void addRadioGroupTab(Apttus_DocuApi.DocuSignUtil.radioGroupTab iTab) {

    }
    global void addSsnTab(Apttus_DocuApi.DocuSignUtil.ssnTab iTab) {

    }
    global void addTextTab(Apttus_DocuApi.DocuSignUtil.textTab iTab) {

    }
    global void addTitleTab(Apttus_DocuApi.DocuSignUtil.titleTab iTab) {

    }
    global void addZipTabs(Apttus_DocuApi.DocuSignUtil.zipTab iTab) {

    }
    global Boolean isEmpty() {
        return null;
    }
    global void setRecipientId(String iRecipientId) {

    }
}
global class SFDCEnvelopeRecipientStatus {
    global Apttus_DocuApi.DocuSignUtil.DocuSignEnvelopeStatus envelopeSataus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignEnvelopeStatus envelopeStatus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus recipeintSatus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus recipeintStatus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus recipientSatus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus recipientStatus {
        get;
        set;
    }
    global SFDCEnvelopeRecipientStatus() {

    }
    global SFDCEnvelopeRecipientStatus(Apttus_DocuApi.DocuSignUtil.DocuSignEnvelopeStatus iDocuSignEnvelopeStatus, Apttus_DocuApi.DocuSignUtil.DocuSignRecipientStatus iDocuSignRecipientStatus) {

    }
}
global class approveTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global approveTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class checkboxTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Boolean selected {
        get;
        set;
    }
    global checkboxTab() {

    }
    global checkboxTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class companyTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global String value {
        get;
        set;
    }
    global companyTab() {

    }
    global companyTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class dateSignedTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global String value {
        get;
        set;
    }
    global dateSignedTab() {

    }
    global dateSignedTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class dateTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global String value {
        get;
        set;
    }
    global dateTab() {

    }
    global dateTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class declineTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global declineTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class emailAddressTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global emailAddressTab() {

    }
    global emailAddressTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class emailTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global String value {
        get;
        set;
    }
    global emailTab() {

    }
    global emailTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class envelopeIdTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global envelopeIdTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class firstNameTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global firstNameTab() {

    }
    global firstNameTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class fullNameTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global fullNameTab() {

    }
    global fullNameTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class initialHereTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global initialHereTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class lastNameTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global lastNameTab() {

    }
    global lastNameTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class listTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global listTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class noteTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global noteTab() {

    }
    global noteTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class numberTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global numberTab() {

    }
    global numberTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class radioGroupTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global String groupName {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil.RadioButton> radios {
        get;
        set;
    }
    global radioGroupTab() {

    }
    global radioGroupTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
    global void addRadioButton(Apttus_DocuApi.DocuSignUtil.RadioButton iRadioButton) {

    }
}
global class signHereTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global signHereTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class signerAttachmentTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global signerAttachmentTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class ssnTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global ssnTab() {

    }
    global ssnTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global virtual class tabBase {
    global String anchorString {
        get;
        set;
    }
    global String anchorXOffset {
        get;
        set;
    }
    global String anchorYOffset {
        get;
        set;
    }
    global Boolean disableAutoSize {
        get;
        set;
    }
    global Boolean locked {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global Boolean required {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global String validationMessage {
        get;
        set;
    }
    global String validationPattern {
        get;
        set;
    }
    global String width {
        get;
        set;
    }
}
global class textTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global textTab() {

    }
    global textTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class titleTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global titleTab() {

    }
    global titleTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
global class zipTab extends Apttus_DocuApi.DocuSignUtil.tabBase {
    global Object value {
        get;
        set;
    }
    global zipTab() {

    }
    global zipTab(String iRecipientId, String iValue, String iWidth, String iAnchorXOffset, String iAnchorYOffset) {

    }
}
}
