/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvocableCLMEOSSyncRequest {
    global InvocableCLMEOSSyncRequest() {

    }
    @InvocableMethod(label='Synchronize Docusign CLM Folders (EOS)' description='Docusign Contract Lifecycle Management External Object Storage Synchronization')
    global static void syncCLMEOS(List<dfsle.InvocableCLMEOSSyncRequest.InvocableCLMEOSSyncActionRequest> requests) {

    }
global class InvocableCLMEOSSyncActionRequest {
    @InvocableVariable(label='Current Record' description='Please select "Triggering [ObjectName]" from the dropdown. Required for both create and update flows.' required=true)
    global SObject currentRecord;
    @InvocableVariable(label='Prior Record' description='Please select "Prior values of Triggering [ObjectName]" from the dropdown and ensure the included checkbox is selected. Optional for create flows since prior values are null on record creation.' required=false)
    global SObject priorRecord;
    global InvocableCLMEOSSyncActionRequest() {

    }
}
}
