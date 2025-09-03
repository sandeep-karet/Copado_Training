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
    global static copado.Automations.DeleteEnvironmentService DeleteEnvironmentService {
        get;
        set;
    }
    global static copado.Automations.MatchingService MatchingService {
        get;
        set;
    }
    global static copado.Automations.UpdateEnvironmentService UpdateEnvironmentService {
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
global class DeleteEnvironmentRequest {
    global copado.Automations.MatchingRuleConfig matchingRuleConfig;
    global DeleteEnvironmentRequest() {

    }
}
global class DeleteEnvironmentService implements copado.CopadoService {
    global DeleteEnvironmentService() {

    }
    global void execute(copado.Automations.DeleteEnvironmentRequest request) {

    }
}
global class FindMatchingRulesRequest {
    global Set<Id> automationRuleIds {
        get;
        set;
    }
    global Set<Id> environmentIds {
        get;
        set;
    }
    global Id pipelineId {
        get;
        set;
    }
    global FindMatchingRulesRequest() {

    }
}
global class FindMatchingRulesResult {
    global copado.Automations.MatchingRuleConfig matchingRuleConfig;
    global FindMatchingRulesResult() {

    }
}
global class MatchingRule {
    global copado.Automations.AutomationConfig config;
    global Boolean isLastEnvironmentInAutomationRule;
    global Boolean isLastEnvironmentInStage;
    global Id ruleId;
    global String ruleName;
    global MatchingRule() {

    }
}
global class MatchingRuleConfig {
    global Id environmentId;
    global List<copado.Automations.MatchingRule> matchingRules;
    global Id stageId;
    global MatchingRuleConfig() {

    }
}
global class MatchingService implements copado.CopadoService {
    global MatchingService() {

    }
    global copado.Automations.FindMatchingRulesResult execute(copado.Automations.FindMatchingRulesRequest request) {
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
global class UpdateEnvironmentRequest {
    global Id environmentId;
    global copado.Automations.MatchingRuleConfig matchingRuleConfig;
    global UpdateEnvironmentRequest() {

    }
}
global class UpdateEnvironmentService implements copado.CopadoService {
    global UpdateEnvironmentService() {

    }
    global void execute(copado.Automations.UpdateEnvironmentRequest request) {

    }
}
}
