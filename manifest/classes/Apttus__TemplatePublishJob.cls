/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class TemplatePublishJob implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Map<Id,Id> callLookup;
    global Apttus.SessionInfo sessionInfo;
    global String sessionKey;
    global List<Id> templateIds;
    global TemplatePublishJob(List<Id> templateIds, Apttus.SessionInfo sessionInfo) {

    }
    global TemplatePublishJob(List<Id> templateIds, String sessionKey) {

    }
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext bc) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
}
