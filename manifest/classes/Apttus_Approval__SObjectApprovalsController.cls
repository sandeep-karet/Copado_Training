/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SObjectApprovalsController extends Apttus_Approval.AbstractSObjectApprovals {
    global SObjectApprovalsController() {

    }
    @RemoteAction
    global static Boolean cancelApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    global void doCancel() {

    }
    global void doPreview() {

    }
    global void doResubmit() {

    }
    global void doReturnInternal() {

    }
    global void doSubmit() {

    }
    global void doSubmitWithAttachments() {

    }
    global System.PageReference doneProcessEach() {
        return null;
    }
    global String getApprovalAction() {
        return null;
    }
    global String getApprovalReason() {
        return null;
    }
    global Boolean getCanCancel() {
        return null;
    }
    global Boolean getCanPreview() {
        return null;
    }
    global Boolean getCanResubmit() {
        return null;
    }
    global Boolean getCanSubmit() {
        return null;
    }
    global Id getContextHeaderSOId() {
        return null;
    }
    global Apttus_Approval.SObjectApprovalContextParam getContextParam() {
        return null;
    }
    global List<Apttus_Approval.SObjectApprovalsController.ContextTypeWrapper> getCtxTypeApprovals() {
        return null;
    }
    global List<String> getCustomColumnList() {
        return null;
    }
    global Boolean getDoProcessEach() {
        return null;
    }
    global Boolean getDoReturnIndicator() {
        return null;
    }
    global Boolean getInDialogMode() {
        return null;
    }
    global String getProcessAction() {
        return null;
    }
    global List<Id> getProcessIds() {
        return null;
    }
    global String getProcessedIds() {
        return null;
    }
    global Boolean getReadOnlyMode() {
        return null;
    }
    global String getRequestFieldSetName() {
        return null;
    }
    global Apttus_Approval.AbstractSObjectApprovals.RequestWrapper getRequestWrapper(Apttus_Approval__Approval_Request__c sObjRequest) {
        return null;
    }
    global String getReturnButtonLabel() {
        return null;
    }
    global List<Apttus_Approval.SObjectApprovalsController.SObjectWrapper> getSObjectApprovals() {
        return null;
    }
    global Boolean getShowComments() {
        return null;
    }
    @RemoteAction
    global static Boolean previewApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    global void setApprovalAction(String reqAction) {

    }
    global void setApprovalReason(String reason) {

    }
    global void setContextHeaderSOId(Id hdrSObjectId) {

    }
    global void setContextParam(Apttus_Approval.SObjectApprovalContextParam ctxParam) {

    }
    global void setContextSOIds(List<Id> sObjectIds) {

    }
    global void setProcessedIds(String sObjectIds) {

    }
    global void setReadOnlyMode(Boolean mode) {

    }
    global void setRequestFieldSetName(String fieldSetName) {

    }
    global void setReturnButtonLabel(String label) {

    }
    @RemoteAction
    global static Boolean submitApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
global class ContextTypeWrapper {
    global List<Apttus_Approval.SObjectApprovalsController.SObjectWrapper> ctxObjectList {
        get;
    }
    global String ctxTypeLabel {
        get;
    }
    global ContextTypeWrapper(String ctxLabel, List<Apttus_Approval.SObjectApprovalsController.SObjectWrapper> ctxObjList) {

    }
}
global class SObjectWrapper {
    global List<Apttus_Approval.AbstractSObjectApprovals.RequestWrapper> ctxApprovals {
        get;
    }
    global String ctxStatus {
        get;
    }
    global String ctxTitle {
        get;
    }
    global SObjectWrapper(String ctxTitle, String ctxStatus) {

    }
    global void addApprovalRequest(Apttus_Approval.AbstractSObjectApprovals.RequestWrapper requestWrapper) {

    }
}
}
