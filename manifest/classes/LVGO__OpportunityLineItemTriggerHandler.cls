/**
* This is the TriggerHandler Class for the OpportunityLineItem Trigger.
* Created : 10/09/2020
* @author : Virinchi Bairisetty
*/
public class OpportunityLineItemTriggerHandler {
    public static void handleRevenueFieldsCalculation(List<OpportunityLineItem__c> lstOP) {       
        OppLineRevCalcHelper.calculateArrFieldValues(lstOP);
    } 
    public static void updateRevSynergyFlag(List<OpportunityLineItem__c> oppLineItems, Boolean isUpdate){
        OpportunityLineItemService.updateRevSynergyOnPrograms(oppLineItems, isUpdate);
    }
}