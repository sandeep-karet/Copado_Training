/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ApprovalHistoryController {
    global ApprovalHistoryController() {

    }
    global Id getCtxObjectId() {
        return null;
    }
    global List<Apttus_Approval.ApprovalHistoryController.ProcessWrapper> getHistory() {
        return null;
    }
    global void setCtxObjectId(Id ctxObjectId) {

    }
global class ProcessWrapper {
    global List<Apttus_Approval__Approval_Request_History__c> approvals {
        get;
    }
    global Datetime endDate {
        get;
    }
    global Integer procCount {
        get;
    }
    global String procName {
        get;
        set;
    }
    global Datetime startDate {
        get;
    }
    global String status {
        get;
        set;
    }
}
}
