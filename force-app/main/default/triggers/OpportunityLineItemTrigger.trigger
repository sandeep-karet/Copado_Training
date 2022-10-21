/**
* This is the Trigger for OpportunityLineItem object.
* Created : 10/09/2020
* @author : Virinchi Bairisetty
*/
trigger OpportunityLineItemTrigger on OpportunityLineItem__c (before insert, before update) {
    if (Trigger.isInsert) {
        //method for Arr fileds calucations
        OpportunityLineItemTriggerHandler.handleRevenueFieldsCalculation(Trigger.new);
        //method to update the Rev Synergy Flag on Programs
        OpportunityLineItemTriggerHandler.updateRevSynergyFlag(Trigger.New, false);
    }
    if (Trigger.isUpdate) {
        //method for Arr fileds calucations
        OpportunityLineItemTriggerHandler.handleRevenueFieldsCalculation(Trigger.new);
        /* This update is being handled on Account after update */
        //OpportunityLineItemTriggerHandler.updateRevSynergyFlag(Trigger.New);
    }
}