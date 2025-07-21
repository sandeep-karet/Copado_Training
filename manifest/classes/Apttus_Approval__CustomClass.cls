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
global interface IInboundAttachmentCallback {
    Boolean handleActionAttachment(Id param0, String param1, Messaging.InboundEmail param2);
}
global interface IQueryCallback {
    List<SObject> doAddQueueQuery(Apttus_Approval__Approval_Request__c param0, String param1);
    List<SObject> doAddRoleQuery(Apttus_Approval__Approval_Request__c param0, String param1);
    List<SObject> doAddUserQuery(Apttus_Approval__Approval_Request__c param0, String param1);
    List<SObject> doReassignUserQuery(Apttus_Approval__Approval_Request__c param0, String param1);
}
global interface IQueryCallback2 extends Apttus_Approval.CustomClass.IQueryCallback {
    List<SObject> doReassignQueueQuery(Apttus_Approval__Approval_Request__c param0, String param1);
    List<SObject> doReassignRoleQuery(Apttus_Approval__Approval_Request__c param0, String param1);
}
}
