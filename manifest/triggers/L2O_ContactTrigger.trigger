/**
* Company : PwC.
* Description : Trigger on Contact
* 
* ****************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/
trigger L2O_ContactTrigger on Contact (before insert, before update, after insert, after update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();    
}