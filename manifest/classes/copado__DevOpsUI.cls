/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DevOpsUI implements copado.CopadoDomain {
    global static copado.DevOpsUI.CommitExperience CommitExperience {
        get;
        set;
    }
    global DevOpsUI() {

    }
global class CommitExperience implements copado.CopadoService {
    global CommitExperience() {

    }
    global copado.DevOpsUI.DisableNewCommitExpSettingResult disable(copado.DevOpsUI.DisableNewCommitExpSettingRequest request) {
        return null;
    }
    global copado.DevOpsUI.EnableNewCommitExpSettingResult enable(copado.DevOpsUI.EnableNewCommitExpSettingRequest request) {
        return null;
    }
    global copado.DevOpsUI.NewCommitExpSettingStatusResult status(copado.DevOpsUI.NewCommitExpSettingStatusRequest request) {
        return null;
    }
}
global class DisableNewCommitExpSettingRequest implements copado.CopadoServiceRequest {
    global Id pipelineId;
    global DisableNewCommitExpSettingRequest() {

    }
}
global class DisableNewCommitExpSettingResult implements copado.CopadoServiceResult {
    global Boolean status;
    global DisableNewCommitExpSettingResult() {

    }
}
global class EnableNewCommitExpSettingRequest implements copado.CopadoServiceRequest {
    global Id pipelineId;
    global EnableNewCommitExpSettingRequest() {

    }
}
global class EnableNewCommitExpSettingResult implements copado.CopadoServiceResult {
    global Boolean status;
    global EnableNewCommitExpSettingResult() {

    }
}
global class NewCommitExpSettingStatusRequest implements copado.CopadoServiceRequest {
    global Id pipelineId;
    global NewCommitExpSettingStatusRequest() {

    }
}
global class NewCommitExpSettingStatusResult implements copado.CopadoServiceResult {
    global Boolean status;
    global copado__System_Property__c systemProperty;
    global NewCommitExpSettingStatusResult() {

    }
}
}
