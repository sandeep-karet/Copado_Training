/**
* Company : PwC.
* Description : Trigger on SBQQ__Subscription__c
* 
* ****************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
trigger L2O_SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update, after insert, after update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run(); 

}