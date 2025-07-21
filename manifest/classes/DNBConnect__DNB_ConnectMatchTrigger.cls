/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DNB_ConnectMatchTrigger {
    global DNB_ConnectMatchTrigger() {

    }
    @InvocableMethod(label='D&B Transactional match' description='Apex class that initiates the DNB transactional match integration flow')
    global static void matchTrigger(List<DNBConnect.DNB_ConnectMatchTrigger.FlowInput> records) {

    }
global class FlowInput {
    @InvocableVariable( required=false)
    global List<Id> modifiedRecordsIds;
    global FlowInput() {

    }
}
}
