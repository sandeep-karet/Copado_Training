/**
* Company : PwC.
* Description : Trigger on Opportunity
* 
* ****************************************************************************************
* History : 
* @date 17/03/2022
* @author Lakshitha Salian
*/
trigger L2O_OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();
    
}