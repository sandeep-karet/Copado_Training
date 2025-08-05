/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Promotions implements copado.CopadoDomain {
    global static copado.Promotions.CalculationService CalculationService {
        get;
        set;
    }
    global static copado.Promotions.MetadataService MetadataService {
        get;
        set;
    }
    global static copado.Promotions.UserStoryCommitService UserStoryCommitService {
        get;
        set;
    }
    global Promotions() {

    }
global class CalculationService implements copado.CopadoService {
    global CalculationService() {

    }
    global copado.Promotions.CalculationServiceResult calculateBackwardPromotions(copado.Promotions.CalculationServiceRequest request) {
        return null;
    }
    global copado.Promotions.CalculationServiceResult calculateForwardPromotions(copado.Promotions.CalculationServiceRequest request) {
        return null;
    }
    global copado.Promotions.CalculationServiceResult calculateOutOfSyncBackwardPromotions(copado.Promotions.CalculationServiceRequest request) {
        return null;
    }
}
global class CalculationServiceRequest implements copado.CopadoServiceRequest {
    global Id destinationEnvironmentId;
    global Id environmentId;
    global Boolean filterExcludeFromCbm;
    global Boolean filterReadyToPromote;
    global Id pipelineId;
    global CalculationServiceRequest() {

    }
}
global class CalculationServiceResult implements copado.CopadoServiceResult {
    global Set<Id> userStoryIds;
    global CalculationServiceResult() {

    }
}
global class MetadataService implements copado.CopadoService {
    global MetadataService() {

    }
    global copado.Promotions.MetadataServiceResult retrieve(copado.Promotions.MetadataServiceRequest request) {
        return null;
    }
}
global class MetadataServiceRequest implements copado.CopadoServiceRequest {
    global Set<Id> userStoryIds;
    global MetadataServiceRequest() {

    }
}
global class MetadataServiceResult implements copado.CopadoServiceResult {
    global List<copado__User_Story_Metadata__c> userStoryMetadatas;
    global MetadataServiceResult() {

    }
}
global class UserStoryCommitService implements copado.CopadoService {
    global UserStoryCommitService() {

    }
    global copado.Promotions.UserStoryCommitServiceResult retrieve(copado.Promotions.UserStoryCommitServiceRequest request) {
        return null;
    }
}
global class UserStoryCommitServiceRequest implements copado.CopadoServiceRequest {
    global Set<Id> userStoryIds;
    global UserStoryCommitServiceRequest() {

    }
}
global class UserStoryCommitServiceResult implements copado.CopadoServiceResult {
    global List<copado__User_Story_Commit__c> userStoryCommits;
    global UserStoryCommitServiceResult() {

    }
}
}
