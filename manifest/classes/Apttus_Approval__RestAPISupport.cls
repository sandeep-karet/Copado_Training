/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RestAPISupport {
    global RestAPISupport() {

    }
    global static void addAttachmentsToRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, List<Id> attachmentIds) {

    }
    global static void addCommentToRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, String sComment) {

    }
    global static void approveRequest(String requestId, String comments) {

    }
    global static void approveRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {

    }
    global static void canAddAdhocApprover(String userId, List<Apttus_Approval.BulkActionRequest> bulkActionRequests) {

    }
    global static void canApproveOrReject(String userId, List<Apttus_Approval.BulkActionRequest> bulkActionRequests) {

    }
    global static void canReassign(String userId, List<Apttus_Approval.BulkActionRequest> bulkActionRequests) {

    }
    global static void canRemoveAdhocApprover(String userId, List<Apttus_Approval.BulkActionRequest> bulkActionRequests) {

    }
    global static void canTakeOwnership(String userId, List<Apttus_Approval.BulkActionRequest> bulkActionRequests) {

    }
    global static void cancelApprovals(String sObjectType, Id sObjectId) {

    }
    global static void cancelApprovalsBulk(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {

    }
    global static void cancelApprovalsWithComments(String sObjectType, Id sObjectId, String comments) {

    }
    global static void createAdhocApproval(Id contextRequestId, String stepLabel, String assigneeType, Id assigneeId, String submissionComment, String relativeLocationToContext, List<String> dependsOnContextRequestIdList, List<String> dependsOnMeContextRequestIdList, Boolean sendEmail, Boolean notifyOnly) {

    }
    global static void createRuntimeAdhocApprovalProcess(Apttus_Approval.AdhocApprovalProcessDTO adhocApprovalProcessDTO) {

    }
    global static void createRuntimeAdhocApprovalProcessDTO(String sObjectType, Id sObjectId) {

    }
    global static void deleteAdhocApproval(Id requestId) {

    }
    global static void deleteAttachmentsFromRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, List<Id> attachmentIds) {

    }
    global static void deleteRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId) {

    }
    global static void getApprovals(String sObjectType, Id sObjectId) {

    }
    global static void getApprovalsBulk(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {

    }
    global static void getPackageVersion() {

    }
    global static void getRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId) {

    }
    global static void isApprovalRequired(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {

    }
    global static void previewAdhocApprovals(String sObjectType, Id sObjectId) {

    }
    global static void previewApprovals(String sObjectType, Id sObjectId) {

    }
    global static void reassignRequest(Id requestId, Id toAssigneeId, String comments) {

    }
    global static void rejectRequest(String requestId, String comments) {

    }
    global static void rejectRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {

    }
    global static void submitForAdhocApprovals(String sObjectType, Id sObjectId) {

    }
    global static void submitForAdhocApprovalsWithComments(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {

    }
    global static void submitForApprovals(String sObjectType, Id sObjectId) {

    }
    global static void submitForApprovalsBulk(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {

    }
    global static void submitForApprovalsForOrchestrate(String sObjectType, Id sObjectId, String taskId) {

    }
    global static void updateRuntimeAdhocApprovalProcess(Apttus_Approval.AdhocApprovalProcessDTO adhocApprovalProcessDTO) {

    }
}
