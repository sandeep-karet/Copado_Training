/**
* Company : PwC.
* Description : Trigger on OrderItem
* 
* ****************************************************************************************
* History : 
* @date 03/06/2022
* @author Neha Sharma
*/
trigger L2O_OrderItemTrigger on OrderItem (before insert, before update,after update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();    
}