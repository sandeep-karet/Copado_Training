/**
* A Trigger for the Health_Score__c object.
* Created : 12/02/2020
* @author Virinchi Bairisetty - Livongo
*/
trigger HealthScoreTrigger on Health_Score__c (before insert, before update) { 
    if (Trigger.isBefore && Trigger.isInsert){
        HealthScoreTriggerHandler.handleHealthScoreBeforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate){
        HealthScoreTriggerHandler.handleHealthScoreBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}