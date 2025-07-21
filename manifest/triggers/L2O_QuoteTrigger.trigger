/**
* Company : PwC.
* Description : Trigger on CPQ Quote
* 
* ****************************************************************************************
* History : 
* @date 25/02/2022
* @author Lakshitha Salian
*/

trigger L2O_QuoteTrigger on SBQQ__Quote__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();
    
}