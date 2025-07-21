/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class AbstractSObjectApprovals {
    global AbstractSObjectApprovals() {

    }
    global String getCtxObjectType() {
        return null;
    }
    global String getQueueURL() {
        return null;
    }
global class RequestWrapper {
    global String addCommentLink {
        get;
    }
    global Apttus_Approval__Approval_Request__c approvalRequest {
        get;
    }
    global String approveRejectLink {
        get;
    }
    global Boolean enableAddComment {
        get;
    }
    global Boolean enableApproveReject {
        get;
    }
    global Boolean enableEscalate {
        get;
    }
    global Boolean enableReassign {
        get;
    }
    global String escalateLink {
        get;
    }
    global String reassignLink {
        get;
    }
    global RequestWrapper(Apttus_Approval__Approval_Request__c ar) {

    }
    global RequestWrapper(Apttus_Approval__Approval_Request__c ar, Id returnToObjId) {

    }
}
}
