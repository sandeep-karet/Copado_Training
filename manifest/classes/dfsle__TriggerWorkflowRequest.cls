/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class TriggerWorkflowRequest {
    global TriggerWorkflowRequest() {

    }
    @InvocableMethod(label='Start Docusign Workflow' description='Start Docusign Workflow')
    global static void triggerWorkflow(List<dfsle.TriggerWorkflowRequest.InvocableMethodRequest> requests) {

    }
global class InvocableMethodRequest {
    @InvocableVariable(label='Instance Name' description='Name of the Maestro workflow instance' required=true)
    global String instanceName;
    @InvocableVariable(label='Record ID' description='Pass Salesforce record ID to Maestro. Make sure the name of the variable in Maestro matches Record ID.' required=false)
    global String recordId;
    @InvocableVariable(label='Variable 1' description='Make sure the name of the variable in Maestro matches Variable 1.' required=false)
    global String variable1;
    @InvocableVariable(label='Variable 2' description='Make sure the name of the variable in Maestro matches Variable 2.' required=false)
    global String variable2;
    @InvocableVariable(label='Variable 3' description='Make sure the name of the variable in Maestro matches Variable 3.' required=false)
    global String variable3;
    @InvocableVariable(label='Variable 4' description='Make sure the name of the variable in Maestro matches Variable 4.' required=false)
    global String variable4;
    @InvocableVariable(label='Variable 5' description='Make sure the name of the variable in Maestro matches Variable 5.' required=false)
    global String variable5;
    @InvocableVariable(label='Variable 6' description='Make sure the name of the variable in Maestro matches Variable 6.' required=false)
    global String variable6;
    @InvocableVariable(label='Variable 7' description='Make sure the name of the variable in Maestro matches Variable 7.' required=false)
    global String variable7;
    @InvocableVariable(label='Variable 8' description='Make sure the name of the variable in Maestro matches Variable 8.' required=false)
    global String variable8;
    @InvocableVariable(label='Variable 9' description='Make sure the name of the variable in Maestro matches Variable 9.' required=false)
    global String variable9;
    @InvocableVariable(label='Workflow ID' description='Enter the Maestro workflow ID' required=true)
    global String workflowId;
    global InvocableMethodRequest() {

    }
}
}
