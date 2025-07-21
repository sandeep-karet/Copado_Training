/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DocuSignUtil2 {
    global DocuSignUtil2() {

    }
global class DocuSignEnvelopRecipientsStausResponse {
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> agents {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> carbonCopies {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> certifiedDeliveries {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> editors {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> inPersonSigners {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> intermediaries {
        get;
        set;
    }
    global String recipientCount {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> signers {
        get;
        set;
    }
    global DocuSignEnvelopRecipientsStausResponse() {

    }
}
global class DocuSignEnvelopeStatus {
    global String completedDocumentDownloadStatus {
        get;
        set;
    }
    global String documentName {
        get;
        set;
    }
    global String envelopeContent {
        get;
        set;
    }
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
    global String processingErrorMessage {
        get;
        set;
    }
    global Boolean processingStatus {
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
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus> signersStatus {
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
    global String voidedReason {
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
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignMultiEnvelopeStatusResponse> envelopes {
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
global class DocuSignEnvelopeTemplateCarbonCopyRecipient {
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
    global String routingOrder {
        get;
        set;
    }
    global DocuSignEnvelopeTemplateCarbonCopyRecipient() {

    }
}
global class DocuSignEnvelopeTemplateDocument {
    global String documentId {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String order {
        get;
        set;
    }
    global String uri {
        get;
        set;
    }
    global DocuSignEnvelopeTemplateDocument() {

    }
}
global class DocuSignEnvelopeTemplateInPersonSignerRecipient {
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
    global String routingOrder {
        get;
        set;
    }
    global DocuSignEnvelopeTemplateInPersonSignerRecipient() {

    }
}
global class DocuSignEnvelopeTemplateRecipients {
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeTemplateCarbonCopyRecipient> carbonCopies {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeTemplateInPersonSignerRecipient> inPersonSigners {
        get;
        set;
    }
    global String recipientCount {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeTemplateSignerRecipient> signers {
        get;
        set;
    }
    global DocuSignEnvelopeTemplateRecipients() {

    }
}
global class DocuSignEnvelopeTemplateSignerRecipient {
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
    global String routingOrder {
        get;
        set;
    }
    global DocuSignEnvelopeTemplateSignerRecipient() {

    }
}
global class DocuSignGetSigningGroupInformation {
    global String created {
        get;
        set;
    }
    global String createdBy {
        get;
        set;
    }
    global String groupName {
        get;
        set;
    }
    global String groupType {
        get;
        set;
    }
    global String modified {
        get;
        set;
    }
    global String modifiedBy {
        get;
        set;
    }
    global String signingGroupId {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignSigningGroupMembers> users {
        get;
        set;
    }
    global DocuSignGetSigningGroupInformation() {

    }
}
global class DocuSignGetSigningGroups {
    global String errorCode {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignGetSigningGroupInformation> groups {
        get;
        set;
    }
    global String message {
        get;
        set;
    }
    global DocuSignGetSigningGroups() {

    }
}
global class DocuSignRecipientStatus {
    global String declinedReason {
        get;
        set;
    }
    global Datetime deliveredDateTime {
        get;
        set;
    }
    global String email {
        get;
        set;
    }
    global String hostEmail {
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
    global String signerName {
        get;
        set;
    }
    global String signingGroupId {
        get;
        set;
    }
    global String status {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil2.RecipientTabs tabs {
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
global class DocuSignSigningGroupMembers {
    global String email {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global DocuSignSigningGroupMembers() {

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
    global String voidedReason {
        get;
        set;
    }
    global DocuSignSingleEnvelopeStatusResponse() {

    }
}
global class DocuSignSingleTemplateResponse {
    global String description {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeTemplateDocument> documents {
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
    global String name {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeTemplateRecipients recipients {
        get;
        set;
    }
    global String templateId {
        get;
        set;
    }
    global String uri {
        get;
        set;
    }
    global DocuSignSingleTemplateResponse() {

    }
}
global class DocuSignTemplateQueryResponse {
    global Integer endPosition {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.DocuSignSingleTemplateResponse> envelopeTemplates {
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
    global DocuSignTemplateQueryResponse() {

    }
}
global class ListItem {
    global String selected {
        get;
        set;
    }
    global String text {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global ListItem() {

    }
}
global class RadioButton {
    global String anchorString {
        get;
        set;
    }
    global String selected {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global RadioButton() {

    }
}
global class RecipientTabs {
    global List<Apttus_DocuApi.DocuSignUtil2.approveTab> approveTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.checkboxTab> checkboxTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.companyTab> companyTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.dateSignedTab> dateSignedTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.dateTab> dateTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.declineTab> declineTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.emailAddressTab> emailAddressTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.emailTab> emailTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.envelopeIdTab> envelopeIdTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.firstNameTab> firstNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.formulaTab> formulaTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.fullNameTab> fullNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.initialHereTab> initialHereTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.lastNameTab> lastNameTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.listTab> listTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.noteTab> noteTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.numberTab> numberTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.radioGroupTab> radioGroupTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.signerAttachmentTab> signerAttachmentTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.signHereTab> signHereTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.ssnTab> ssnTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.textTab> textTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.titleTab> titleTabs {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.zipTab> zipTabs {
        get;
        set;
    }
    global RecipientTabs() {

    }
    global Boolean isEmpty() {
        return null;
    }
}
global class SFDCEnvelopeRecipientStatus {
    global Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeStatus envelopeStatus {
        get;
        set;
    }
    global Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus recipientStatus {
        get;
        set;
    }
    global String recipientType {
        get;
        set;
    }
    global SFDCEnvelopeRecipientStatus() {

    }
    global SFDCEnvelopeRecipientStatus(Apttus_DocuApi.DocuSignUtil2.DocuSignEnvelopeStatus iDocuSignEnvelopeStatus, Apttus_DocuApi.DocuSignUtil2.DocuSignRecipientStatus iDocuSignRecipientStatus) {

    }
}
global class approveTab {
    global String anchorString {
        get;
        set;
    }
    global String buttonText {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global approveTab() {

    }
}
global class checkboxTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String selected {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global checkboxTab() {

    }
}
global class companyTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global companyTab() {

    }
}
global class dateSignedTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global dateSignedTab() {

    }
}
global class dateTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global dateTab() {

    }
}
global class declineTab {
    global String anchorString {
        get;
        set;
    }
    global String buttonText {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global declineTab() {

    }
}
global class emailAddressTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global emailAddressTab() {

    }
}
global class emailTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global emailTab() {

    }
}
global class envelopeIdTab {
    global String anchorString {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global envelopeIdTab() {

    }
}
global class firstNameTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global firstNameTab() {

    }
}
global class formulaTab {
    global String anchorString {
        get;
        set;
    }
    global String formula {
        get;
        set;
    }
    global String isPaymentAmount {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global formulaTab() {

    }
}
global class fullNameTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global fullNameTab() {

    }
}
global class initialHereTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global initialHereTab() {

    }
}
global class lastNameTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global lastNameTab() {

    }
}
global class listTab {
    global String anchorString {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.ListItem> listItems {
        get;
        set;
    }
    global String mergeFieldXml {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global listTab() {

    }
}
global class noteTab {
    global String anchorString {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global noteTab() {

    }
}
global class numberTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global numberTab() {

    }
}
global class radioGroupTab {
    global String groupName {
        get;
        set;
    }
    global List<Apttus_DocuApi.DocuSignUtil2.RadioButton> radios {
        get;
        set;
    }
    global radioGroupTab() {

    }
}
global class signHereTab {
    global String anchorString {
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
    global String tabLabel {
        get;
        set;
    }
    global signHereTab() {

    }
}
global class signerAttachmentTab {
    global String anchorString {
        get;
        set;
    }
    global String recipientId {
        get;
        set;
    }
    global String tabLabel {
        get;
        set;
    }
    global signerAttachmentTab() {

    }
}
global class ssnTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global ssnTab() {

    }
}
global class textTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String value {
        get;
        set;
    }
    global textTab() {

    }
}
global class titleTab {
    global String anchorString {
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
    global String value {
        get;
        set;
    }
    global titleTab() {

    }
}
global class zipTab {
    global String anchorString {
        get;
        set;
    }
    global String mergeFieldXml {
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
    global String tabLabel {
        get;
        set;
    }
    global String value {
        get;
        set;
    }
    global zipTab() {

    }
}
}
