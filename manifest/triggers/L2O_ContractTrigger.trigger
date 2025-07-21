/**
* Company : PwC.
* Description : Trigger on Contract
* 
* ****************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
trigger L2O_ContractTrigger on Contract (before insert, before update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();    
}