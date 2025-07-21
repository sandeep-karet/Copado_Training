/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/

trigger dlrs_RFPTrigger on RFP__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    dlrs.RollupService.triggerHandler(RFP__c.SObjectType);
}