/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MyApprovalsController {
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> allApprovals;
    global String curTabSelection {
        get;
        set;
    }
    global Boolean isAdhoc;
    global Boolean isAdhocProcess;
    global static String PARAM_ADD_APPROVER_ASSIGNEE_ID;
    global static String PARAM_ADD_APPROVER_ASSIGNEE_NAME;
    global static String PARAM_ADD_APPROVER_ASSIGNEE_TYPE;
    global static String PARAM_ADD_APPROVER_COMMENT;
    global static String PARAM_ADD_APPROVER_MODE;
    global static String PARAM_ADD_APPROVER_REQUESTID;
    global static String PARAM_ADD_APPROVER_SEARCH_TYPE;
    global static String PARAM_ADD_APPROVER_SHOW_ACTION_ICONS;
    global static String PARAM_ADD_APPROVER_STEP_LABEL;
    global static String PARAM_ERROR_MESSAGE;
    global static String PARAM_HEADER_SOBJECT_TITLE;
    global static String PARAM_HEADER_SOBJECTID;
    global static String PARAM_ID;
    global static String PARAM_RETURNID;
    global static String PARAM_RETURNPAGE;
    global static String PARAM_SF1MODE;
    global static String PARAM_SOBJECTID;
    global static String PARAM_SOBJECTTYPE;
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> queueRoleApprovals;
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> userApprovals;
    global MyApprovalsController() {

    }
    global MyApprovalsController(ApexPages.StandardController stdController) {

    }
    global MyApprovalsController(String objectType, Id objectId, Id userId) {

    }
    global MyApprovalsController(String objectType, Id objectId, Id userId, Boolean includeMbrs) {

    }
    global System.PageReference doAddApprover() {
        return null;
    }
    global System.PageReference doAddComments() {
        return null;
    }
    global System.PageReference doApprove() {
        return null;
    }
    global System.PageReference doDone() {
        return null;
    }
    global System.PageReference doLoadAllApprovals() {
        return null;
    }
    global System.PageReference doLoadAllApprovals(List<Apttus_Approval__Approval_Request__c> ctxReqList) {
        return null;
    }
    global System.PageReference doLoadApprovals() {
        return null;
    }
    global System.PageReference doReassignApprover() {
        return null;
    }
    global System.PageReference doReject() {
        return null;
    }
    global System.PageReference doRemoveApprover() {
        return null;
    }
    global System.PageReference doShowApproverActionIcons() {
        return null;
    }
    global System.PageReference doTakeActionOnEachDone() {
        return null;
    }
    global System.PageReference doTakeOwnership() {
        return null;
    }
    global Boolean getAllApprovalsTabEnableActions() {
        return null;
    }
    global Set<Id> getAllApprovalsTabSelectedReqIds() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> getAllApprovals() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> getAllUserApprovals() {
        return null;
    }
    global String getApprovalComments() {
        return null;
    }
    global System.PageReference getApprovalRequestDrillDownDetail2() {
        return null;
    }
    global String getComment1Label() {
        return null;
    }
    global String getComment2Label() {
        return null;
    }
    global String getComment3Label() {
        return null;
    }
    global List<Apttus_Approval__Approval_Request__c> getCompletionComments() {
        return null;
    }
    global String getCtxObjApprovalStatus() {
        return null;
    }
    global String getCtxObjLabel() {
        return null;
    }
    global String getCtxObjLink() {
        return null;
    }
    global String getCtxObjName() {
        return null;
    }
    global String getCtxObjTitle() {
        return null;
    }
    global String getCtxObjType() {
        return null;
    }
    global Boolean getDoTakeActionOnEach() {
        return null;
    }
    global Boolean getEnableActions() {
        return null;
    }
    global Boolean getHasAllApprovalsTabErrors() {
        return null;
    }
    global Boolean getHasCustomReturnPage() {
        return null;
    }
    global Boolean getHasErrors() {
        return null;
    }
    global Boolean getHasMyApprovalsTabErrors() {
        return null;
    }
    global Boolean getHasQueueApprovalsTabErrors() {
        return null;
    }
    global Boolean getHasSelectableQueueRoleApprovals() {
        return null;
    }
    global Boolean getInSf1Mode() {
        return null;
    }
    global Boolean getIsActionTypeAddComments() {
        return null;
    }
    global Boolean getIsActionTypeApprove() {
        return null;
    }
    global Boolean getIsActionTypeReject() {
        return null;
    }
    global Boolean getIsAllApprovalsTabSelected() {
        return null;
    }
    global Boolean getIsCommunitiesUser() {
        return null;
    }
    global Boolean getIsMyApprovalsTabSelected() {
        return null;
    }
    global Boolean getIsQueueApprovalsTabSelected() {
        return null;
    }
    global Boolean getMyApprovalsTabEnableActions() {
        return null;
    }
    global Boolean getPageLoaded() {
        return null;
    }
    global String getPageURL() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> getQueueRoleApprovals() {
        return null;
    }
    global Set<Id> getSelectedReqIds() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.StepWrapper> getUserApprovals() {
        return null;
    }
    global void setApprovalComments(String comments) {

    }
    global void setInSf1Mode(Boolean mode) {

    }
    global void setSubmitCommentAndLabel(Apttus_Approval.MyApprovalsController.StepWrapper stepWrapper, Apttus_Approval__Approval_Request__c approvalReq) {

    }
global class DisplayFieldInfo {
    global DisplayFieldInfo(String dspFldName, String dspFldLabel) {

    }
    global Boolean getIsLocal() {
        return null;
    }
    global String getLabel() {
        return null;
    }
    global String getName() {
        return null;
    }
}
global class SelectApprovalRequest {
    global SelectApprovalRequest(Apttus_Approval__Approval_Request__c request) {

    }
    global SelectApprovalRequest(Apttus_Approval__Approval_Request__c request, Boolean selInd) {

    }
    global SelectApprovalRequest(Apttus_Approval__Approval_Request__c request, Boolean selInd, Boolean canAddInd) {

    }
    global Boolean getCanAddApprover() {
        return null;
    }
    global Boolean getCanReassignApprover() {
        return null;
    }
    global Boolean getCanRemoveApprover() {
        return null;
    }
    global String getDelegateNames() {
        return null;
    }
    global Boolean getEnableAdhocApproval() {
        return null;
    }
    global Boolean getEnableSelect() {
        return null;
    }
    global Boolean getHasActions() {
        return null;
    }
    global Apttus_Approval__Approval_Request__c getRequest() {
        return null;
    }
    global Boolean getSelected() {
        return null;
    }
    global Boolean getShowActions() {
        return null;
    }
    global void setCanAddApprover(Boolean canAdd) {

    }
    global void setCanAddApproverAtStep(Boolean canAddInd) {

    }
    global void setCanReassignApprover(Boolean canReassign) {

    }
    global void setCanReassignApproverAtStep(Boolean canReassignInd) {

    }
    global void setCanRemoveApprover(Boolean canRemove) {

    }
    global void setCanRemoveApproverAtStep(Boolean canRemoveInd) {

    }
    global void setEnableSelect(Boolean selectEnableInd) {

    }
    global void setSelected(Boolean selInd) {

    }
    global void setShowActions(Boolean show) {

    }
}
global class StepRequest {
    global StepRequest(SObject sObj, List<String> dspFlds) {

    }
    global StepRequest(SObject sObj, Set<String> dspFlds) {

    }
    global StepRequest(SObject sObj, List<String> dspFlds, Map<String,String> dspFldLabelsMap) {

    }
    global StepRequest(SObject sObj, Set<String> dspFlds, Map<String,String> dspFldLabelsMap) {

    }
    global StepRequest(SObject sObj, String headerDspFld, List<String> dspFlds, Map<String,String> dspFldLabelsMap) {

    }
    global StepRequest(SObject sObj, String headerDspFld, Set<String> dspFlds, Map<String,String> dspFldLabelsMap) {

    }
    global void addApprovalRequest(Apttus_Approval__Approval_Request__c apprReq) {

    }
    global void addSelectApprovalRequest(Apttus_Approval.MyApprovalsController.SelectApprovalRequest selReq) {

    }
    global List<Apttus_Approval__Approval_Request__c> getApprovalRequests() {
        return null;
    }
    global Boolean getCanAddApprovers() {
        return null;
    }
    global Boolean getCanReassignApprovers() {
        return null;
    }
    global Boolean getCanRemoveApprovers() {
        return null;
    }
    global SObject getCtxObject() {
        return null;
    }
    global String getCtxObjectApprovalStatusFieldName() {
        return null;
    }
    global String getCtxObjectType() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.DisplayFieldInfo> getDisplayFieldInfo() {
        return null;
    }
    global List<String> getDisplayFieldLabels() {
        return null;
    }
    global Map<String,String> getDisplayFieldsMap() {
        return null;
    }
    global List<String> getDisplayFields() {
        return null;
    }
    global Boolean getDoRenderDisplayFields() {
        return null;
    }
    global String getHeaderDisplayField() {
        return null;
    }
    global Apttus_Approval.MyApprovalsController.DisplayFieldInfo getHeaderDisplayFieldInfo() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.SelectApprovalRequest> getSelectApprovalRequests() {
        return null;
    }
    global void setCanAddApprovers(Boolean canAdd) {

    }
    global void setCanReassignApprovers(Boolean canReassign) {

    }
    global void setCanRemoveApprovers(Boolean canRemove) {

    }
    global void setDisplayFieldLabelsMap(Map<String,String> dspFldLabelsMap) {

    }
    global void setHeaderDisplayField(String headerDspFld) {

    }
}
global class StepWrapper {
    global StepWrapper(Apttus_Approval__Approval_Request__c approvalReq) {

    }
    global void addStepRequest(Apttus_Approval.MyApprovalsController.StepRequest stepReq) {

    }
    global Boolean getComment1Enabled() {
        return null;
    }
    global Boolean getComment2Enabled() {
        return null;
    }
    global Boolean getComment3Enabled() {
        return null;
    }
    global String getStepKey() {
        return null;
    }
    global String getStepLabel() {
        return null;
    }
    global String getStepName() {
        return null;
    }
    global List<Apttus_Approval.MyApprovalsController.StepRequest> getStepRequests() {
        return null;
    }
    global String getStepSequence() {
        return null;
    }
    global String getStepSequenceAndName() {
        return null;
    }
    global String getSubmitComment1Br() {
        return null;
    }
    global String getSubmitComment1Label() {
        return null;
    }
    global List<String> getSubmitComment1Lines() {
        return null;
    }
    global String getSubmitComment1Text() {
        return null;
    }
    global String getSubmitComment2Br() {
        return null;
    }
    global String getSubmitComment2Label() {
        return null;
    }
    global List<String> getSubmitComment2Lines() {
        return null;
    }
    global String getSubmitComment2Text() {
        return null;
    }
    global String getSubmitComment3Br() {
        return null;
    }
    global String getSubmitComment3Label() {
        return null;
    }
    global List<String> getSubmitComment3Lines() {
        return null;
    }
    global String getSubmitComment3Text() {
        return null;
    }
    global void setStepLabel(String label) {

    }
    global void setStepName(String name) {

    }
    global void setSubmitComment1Text(String comments) {

    }
    global void setSubmitComment2Text(String comments) {

    }
    global void setSubmitComment3Text(String comments) {

    }
}
}
