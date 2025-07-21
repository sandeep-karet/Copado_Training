/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class ApprovalsWebService {
    global ApprovalsWebService() {

    }
    webService static Boolean AddAttachmentsToRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, List<Id> attachmentIds) {
        return null;
    }
    webService static Boolean AddCommentToRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, String sComment) {
        return null;
    }
    webService static Apttus_Approval.AdhocApprovalProcessDTO CreateRuntimeAdhocApprovalProcess(Apttus_Approval.AdhocApprovalProcessDTO adhocApprovalProcessDTO) {
        return null;
    }
    webService static Apttus_Approval.AdhocApprovalProcessDTO CreateRuntimeAdhocApprovalProcessDTO(String ctxObjType, Id ctxObjId) {
        return null;
    }
    webService static Boolean DeleteAttachmentsFromRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId, List<Id> attachmentIds) {
        return null;
    }
    webService static Boolean DeleteRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Apttus_Approval.AdhocApprovalProcessDTO GetRuntimeAdhocApprovalProcess(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Apttus_Approval.AdhocApprovalProcessDTO UpdateRuntimeAdhocApprovalProcess(Apttus_Approval.AdhocApprovalProcessDTO adhocApprovalProcessDTO) {
        return null;
    }
    webService static Boolean addApprovalEmailAttachment(Id sObjectId, Id attId) {
        return null;
    }
    webService static Boolean addCommentsToRequest(Id requestId, String comments) {
        return null;
    }
    global static void addSObjectToCache(SObject modifiedSO) {

    }
    webService static Id approveContextRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean approveRequest(Id requestId, String comments) {
        return null;
    }
    webService static Id approveRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean areActionsSupported(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> canAddAdhocApprover(Id userId, List<Apttus_Approval__Approval_Request__c> requests) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> canApproveOrReject(Id userId, List<Apttus_Approval__Approval_Request__c> requests) {
        return null;
    }
    webService static Boolean canApproveRejectRequest(Id requestId) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> canReassign(Id userId, List<Apttus_Approval__Approval_Request__c> requests) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> canRemoveAdhocApprover(Id userId, List<Apttus_Approval__Approval_Request__c> requests) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> canTakeOwnership(Id userId, List<Apttus_Approval__Approval_Request__c> requests) {
        return null;
    }
    webService static Boolean cancelApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean cancelApprovalsAsync(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean cancelApprovalsBulk(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {
        return null;
    }
    webService static Boolean cancelApprovalsWithComments(String sObjectType, Id sObjectId, String comments) {
        return null;
    }
    webService static Id cancelApprovalsWithCommentsAsync(String sObjectType, Id sObjectId, String comments) {
        return null;
    }
    webService static List<String> checkIfApprovalRequired2(String headerIdStatus, List<String> childIdStatusList, List<Id> modifiedChildObjectIds) {
        return null;
    }
    webService static List<Boolean> checkIfApprovalRequired(List<Id> sObjectIds) {
        return null;
    }
    webService static List<Apttus_Approval.PermissionResponseDTO> checkIfApproveOrRejectCommentsRequired(List<String> itemIds, String actionName) {
        return null;
    }
    webService static Apttus_Approval.SubmissionComments checkIfCommentsRequired(Id ctxObjectId, String ctxObjectType) {
        return null;
    }
    webService static Apttus_Approval.SubmissionComments checkIfCommentsRequired2(Id ctxObjectId, String ctxObjectType) {
        return null;
    }
    webService static Id cloneEmailTemplate(Id originalId) {
        return null;
    }
    webService static Boolean copyAttachment(Id destParentId, Id attId) {
        return null;
    }
    webService static Boolean createAdhocApproval(Id contextRequestId, String stepLabel, String assigneeType, Id assigneeId, String submissionComment, String relativeLocationToContext, List<String> dependsOnContextRequestIdList, List<String> dependsOnMeContextRequestIdList, Boolean sendEmail, Boolean notifyOnly) {
        return null;
    }
    webService static Boolean deleteAdhocApproval(Id ctxRequestId) {
        return null;
    }
    webService static Boolean escalateRequest(Id requestId) {
        return null;
    }
    webService static String getAddCommentPageUrl(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static List<Attachment> getApprovalEmailAttachmentsWithName(Id sObjectId, String attName) {
        return null;
    }
    webService static List<Apttus_Approval__Approval_Request__c> getApprovalHistory(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static String getApproveRejectPageUrl(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static Boolean getContextObjHasRequests(String ctxObjType, Id userId) {
        return null;
    }
    webService static List<Id> getContextObjIds(String ctxObjType, Id userId) {
        return null;
    }
    webService static List<Apttus_Approval.AP.CriteriaFieldDO> getEntryCriteriaFields(String ctxObjectType) {
        return null;
    }
    webService static String getMyApprovalsPageUrl(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static String getPackageVersion() {
        return null;
    }
    webService static List<Id> getPendingRequestIdsForGivenContext(String ctxObjType, Id ctxObjId, Id userId) {
        return null;
    }
    webService static String getReassignPageUrl(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static List<Id> getRequestIdsForGivenContext(String ctxObjType, Id ctxObjId, Id userId) {
        return null;
    }
    webService static Boolean isApprovalRequired(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean isEmailApprovalResponseEnabled() {
        return null;
    }
    webService static Boolean isStatusCancelled(Apttus_Approval__Approval_Request__c requestSO) {
        return null;
    }
    webService static Boolean previewAdhocApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean previewApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean previewApprovalsAsync(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean reassignRequest(Id requestId, Id toAssigneeId, String comments) {
        return null;
    }
    webService static Id rejectContextRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean rejectRequest(Id requestId, String comments) {
        return null;
    }
    webService static Id rejectRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean replaceApprovalEmailAttachment(Id sObjectId, Id attId) {
        return null;
    }
    webService static Id selectApprovalProcess(String bizObjectType, Id bizObjectId) {
        return null;
    }
    webService static Boolean submitForAdhocApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    global static Boolean submitForAdhocApprovalsWithAttachments(String sObjectType, Id sObjectId, Id processId, Map<String,Id> templateFldNameIdMap) {
        return null;
    }
    global static Boolean submitForAdhocApprovalsWithAttachments(String sObjectType, Id sObjectId, Id processId, Map<String,String> templateFldName2NameMap) {
        return null;
    }
    webService static Boolean submitForAdhocApprovalsWithComments(String sObjectType, Id sObjectId, Apttus_Approval.SubmissionComments comments) {
        return null;
    }
    webService static Boolean submitForApprovals(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean submitForApprovalsAsync(String sObjectType, Id sObjectId) {
        return null;
    }
    webService static Boolean submitForApprovalsBulk(List<Apttus_Approval.BulkCtxObjectParam> ctxObjParams) {
        return null;
    }
    webService static Boolean submitForApprovalsForOrchestrate(String sObjectType, Id sObjectId, String taskId) {
        return null;
    }
    webService static Boolean submitForApprovalsWithAttachmentsAndComments(String sObjectType, Id sObjectId, Id processId, List<Id> attachmentIds, Apttus_Approval.SubmissionComments submissionComments) {
        return null;
    }
    webService static Boolean submitForApprovalsWithAttachments(String sObjectType, Id sObjectId, Id processId, List<Id> attachmentIds) {
        return null;
    }
    global static Boolean submitForApprovalsWithAttachments(String sObjectType, Id sObjectId, Id processId, Map<String,Id> templateFldNameIdMap) {
        return null;
    }
    global static Boolean submitForApprovalsWithAttachments(String sObjectType, Id sObjectId, Id processId, Map<String,String> templateFldName2NameMap) {
        return null;
    }
    webService static Boolean submitForApprovalsWithComments(String sObjectType, Id sObjectId, Apttus_Approval.SubmissionComments comments) {
        return null;
    }
    webService static Boolean submitForApprovalsWithCommentsAsync(String sObjectType, Id sObjectId, Apttus_Approval.SubmissionComments comments) {
        return null;
    }
    webService static Boolean submitForApprovalsWithCommentsJSON(String sObjectType, Id sObjectId, String commentsJSON) {
        return null;
    }
    webService static Boolean takeOwnershipOfContextRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean takeOwnershipOfRequestsBulk(List<Apttus_Approval.BulkActionRequest> actionRequests) {
        return null;
    }
    webService static Boolean updateApprovalData(Id instanceId, String sObjectType, Id contextObjId, List<Id> oldContextObjIds, List<Id> newContextObjIds) {
        return null;
    }
    webService static Boolean updateAutoReapprovalData(String sObjectType, Id contextObjId, List<Id> oldContextObjIds, List<Id> newContextObjIds) {
        return null;
    }
}
