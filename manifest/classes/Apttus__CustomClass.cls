/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class CustomClass {
    global CustomClass() {

    }
global class ActionParams {
    global String ActionName {
        get;
    }
    webService Boolean AddAutoHeaderFooter {
        get;
        set;
    }
    webService Boolean AddFooter {
        get;
        set;
    }
    webService Boolean AddHeader {
        get;
        set;
    }
    webService Boolean AddWatermark {
        get;
        set;
    }
    webService List<Apttus.CustomClass.AttachmentInfo> Attachments {
        get;
        set;
    }
    global SObject ContextSO {
        get;
    }
    webService Boolean CumulativePageNumber {
        get;
        set;
    }
    webService String DocFileName {
        get;
        set;
    }
    webService List<Id> DocIds {
        get;
        set;
    }
    webService List<Apttus.CustomClass.ExternalLink> ExternalLinks {
        get;
        set;
    }
    webService String FooterAlignment {
        get;
        set;
    }
    webService String FooterFont {
        get;
        set;
    }
    webService Integer FooterFontSize {
        get;
        set;
    }
    webService String FooterMode {
        get;
        set;
    }
    webService String FooterText {
        get;
        set;
    }
    webService String HeaderAlignment {
        get;
        set;
    }
    webService String HeaderFont {
        get;
        set;
    }
    webService Integer HeaderFontSize {
        get;
        set;
    }
    webService String HeaderMode {
        get;
        set;
    }
    webService String HeaderText {
        get;
        set;
    }
    webService Id ParentId {
        get;
        set;
    }
    webService Boolean PreserveRedlines {
        get;
        set;
    }
    webService String ProtectionLevel {
        get;
        set;
    }
    webService Boolean ProtectOutputDoc {
        get;
        set;
    }
    webService Boolean RemoveWatermark {
        get;
        set;
    }
    webService Boolean RetainInputHeaderFooter {
        get;
        set;
    }
    webService String SessionId {
        get;
        set;
    }
    webService String SessionUrl {
        get;
        set;
    }
    webService Id SObjectId {
        get;
        set;
    }
    global Map<String,String> SortSpecsByType {
        get;
    }
    global List<Apttus__TemplateDynamicSection__c> TemplateDynamicSections {
        get;
    }
    global Apttus__APTS_Template__c TemplateSO {
        get;
    }
    global ActionParams() {

    }
}
global enum ActionType {ACTION_ACTIVATE, ACTION_AMEND, ACTION_CANCEL, ACTION_CLONE, ACTION_CREATE, ACTION_CREATE_CHILD, ACTION_CREATE_EXECUTED, ACTION_CREATE_FROM_OPPORTUNITY, ACTION_CREATE_OFFLINE, ACTION_EXPIRE, ACTION_RENEW, ACTION_TERMINATE}
global enum ActivationType {AMENDMENT, RENEWAL}
global class AttachmentInfo {
    webService String DocType {
        get;
        set;
    }
    webService Id RecordId {
        get;
        set;
    }
    webService String Title {
        get;
        set;
    }
    global AttachmentInfo() {

    }
}
global class ContentFieldInfo {
    global String FieldName {
        get;
    }
    global String FieldType {
        get;
    }
    global String ObjectType {
        get;
    }
    global Id RecordId {
        get;
    }
}
global enum DocAssemblyComponentType {ATTACHMENT, ATTACHMENT_PARENT, CLAUSE, CONTENT_FIELD}
global class DocGenParam {
    webService Boolean AcceptRedlines {
        get;
        set;
    }
    webService String DocFormat {
        get;
        set;
    }
    webService Boolean IsDraft {
        get;
        set;
    }
    webService String ProtectionLevel {
        get;
        set;
    }
    webService String ReviewerName {
        get;
        set;
    }
    webService String SessionId {
        get;
        set;
    }
    webService String SessionUrl {
        get;
        set;
    }
    webService Id SObjectId {
        get;
        set;
    }
    webService Id SourceDocumentId {
        get;
        set;
    }
    webService Id TemplateId {
        get;
        set;
    }
    webService Id VersionDetailId {
        get;
        set;
    }
    global DocGenParam() {

    }
}
global class DynamicSectionComponent {
    global Id AttachmentId {
        get;
    }
    global Id AttachmentParentId {
        get;
    }
    global Apttus.ClauseRefInfo Clause {
        get;
    }
    global Apttus.CustomClass.ContentFieldInfo ContentField {
        get;
    }
    global Boolean InsertPageBreak {
        get;
    }
    global Apttus.CustomClass.DocAssemblyComponentType Type {
        get;
    }
}
global class DynamicSectionContents {
    global List<Apttus.CustomClass.DynamicSectionComponent> Components {
        get;
    }
    global Map<String,String> DocGenParams {
        get;
    }
    global Boolean IsSectionForHeader {
        get;
    }
}
global class ExternalLink {
    webService String Title {
        get;
        set;
    }
    webService String Url {
        get;
        set;
    }
    global ExternalLink() {

    }
}
global interface IAgreementLifecycleCallback {
    void afterActivate(Apttus__APTS_Agreement__c param0, Apttus.CustomClass.ActivationType param1);
    void afterAmend(Apttus__APTS_Agreement__c param0, Apttus__APTS_Agreement__c param1);
    void afterCancel(Apttus__APTS_Agreement__c param0);
    void afterClone(Apttus__APTS_Agreement__c param0, Apttus__APTS_Agreement__c param1);
    void afterCreate(Apttus__APTS_Agreement__c param0);
    void afterCreateChild(Apttus__APTS_Agreement__c param0, Apttus__APTS_Agreement__c param1);
    void afterCreateExecuted(Apttus__APTS_Agreement__c param0);
    void afterCreateFromOpportunity(Apttus__APTS_Agreement__c param0);
    void afterCreateOffline(Apttus__APTS_Agreement__c param0);
    void afterExpire(Apttus__APTS_Agreement__c param0);
    void afterRenew(Apttus__APTS_Agreement__c param0, Apttus__APTS_Agreement__c param1);
    void afterTerminate(Apttus__APTS_Agreement__c param0);
}
global interface IAgreementLifecycleCallback2 extends Apttus.CustomClass.IAgreementLifecycleCallback {
    void afterComplete(Apttus__APTS_Agreement__c param0, Apttus.CustomClass.ActionType param1);
}
global interface IAsyncMergeCallback {
    void afterComplete(Apttus__AsyncMergeCall__c param0);
}
global interface IDynamicSectionCallback {
    Map<Id,List<Apttus.ClauseRefInfo>> getDynamicSectionClauses(Apttus.CustomClass.ActionParams param0);
}
global interface IDynamicSectionCallback2 {
    Map<Id,Apttus.CustomClass.DynamicSectionContents> getDynamicSectionContents(Apttus.CustomClass.ActionParams param0);
}
global interface IProcessUsageInput {
    void recognizeRatedUsageInput(List<Apttus.CustomClass.UsageInput> param0);
    void unrecognizeUnratedUsageInput(List<Apttus.CustomClass.UsageInput> param0);
}
global interface IPublishContentCallback {
    Id publishContentForAgreement(Id param0, Apttus.CustomClass.PublishRequest param1);
    void publishContentForAgreementLargeFile(Id param0, Apttus.CustomClass.PublishRequest param1);
}
global class MergeException extends Exception {
}
global class PublishRequest {
    webService Id AsyncCallId {
        get;
        set;
    }
    webService Id AttachmentId {
        get;
        set;
    }
    webService List<Id> FileIds {
        get;
        set;
    }
    webService String PrevStatus {
        get;
        set;
    }
    webService String PrevStatusCategory {
        get;
        set;
    }
    webService List<String> TagValues {
        get;
        set;
    }
    webService String WorkspaceName {
        get;
        set;
    }
    global PublishRequest() {

    }
}
global class UsageInput {
    global Id assetLineItemID {
        get;
        set;
    }
    global Decimal ratedAmount {
        get;
        set;
    }
    global Date usageDate {
        get;
        set;
    }
    global Id usageInputID {
        get;
        set;
    }
    global Decimal usageQuantity {
        get;
        set;
    }
    global String usageStatus {
        get;
        set;
    }
    global UsageInput() {

    }
}
}
