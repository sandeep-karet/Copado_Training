/**
* Company : PwC.
* Description : Trigger on Asset
* 
* ****************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
trigger L2O_AssetTrigger on Asset (before insert, before update, after update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run(); 

}