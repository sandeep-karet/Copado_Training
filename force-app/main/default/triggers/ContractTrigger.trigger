/**
* A Trigger for the Contract object.
* Created : 05/13/2019
* @author Connor Gallaher - Slalom
*/

trigger ContractTrigger on Contract__c (after insert, before insert, after update, before delete, after delete) {
    LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
    if(switchFlg != null && switchFlg.Triggers__c){
    if (Trigger.isAfter && Trigger.isInsert) {
        ContractTriggerHandler.handleContractAfterInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        ContractTriggerHandler.handleContractBeforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContractTriggerHandler.handleContractUpdate(Trigger.oldMap, Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isDelete){
        ContractTriggerHandler.handleContractDelete(Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isDelete){
        ContractTriggerHandler.handleContractAfterDelete(Trigger.oldMap);
    }
    }
}