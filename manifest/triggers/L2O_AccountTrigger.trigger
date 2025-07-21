/**
* Company : PwC.
* Description : Trigger on Account
* 
* ****************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/
trigger L2O_AccountTrigger on Account (before insert,after insert,before update, after update) {
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();  
}