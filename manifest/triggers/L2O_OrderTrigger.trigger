/**
* Company : PwC.
* Description : Trigger on Order
* 
* ****************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
trigger L2O_OrderTrigger on Order (before insert, before update, after update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();
}