/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Automations implements copado.CopadoDomain {
    global static copado.Automations.ConvertService ConvertService {
        get;
        set;
    }
    global Automations() {

    }
global class AutomationConfig {
    global Boolean active;
    global String automatedAction;
    global String automationConnector;
    global List<String> environments;
    global List<String> environmentsForBackPromotion;
    global Boolean isAppliedToPipeline;
    global String ruleId;
    global String ruleName;
    global String scope;
    global String sourceAction;
    global List<copado.Automations.StageConfig> stages;
    global AutomationConfig() {

    }
}
global class ConvertRequest implements copado.CopadoServiceRequest {
    global List<copado__Automation_Rule__c> automationRules;
    global ConvertRequest() {

    }
}
global class ConvertResult implements copado.CopadoServiceResult {
    global String configurationJson;
    global ConvertResult() {

    }
}
global class ConvertService implements copado.CopadoService {
    global ConvertService() {

    }
    global copado.Automations.ConvertResult convert(copado.Automations.ConvertRequest request) {
        return null;
    }
}
global class StageConfig {
    global List<String> environments;
    global List<String> environmentsForBackPromotion;
    global String id;
    global Boolean isAppliedToStage;
    global StageConfig() {

    }
}
}
