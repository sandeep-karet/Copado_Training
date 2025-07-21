/**
* Company : PwC.
* Description : Trigger on Apttus__APTS_Agreement__c
* 
* ****************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
trigger L2O_AgreementTrigger on Apttus__APTS_Agreement__c (before insert, before update) {
    
    //Run Metadata Trigger Handler Class
    new SDF_TGF_MetadataTriggerHandler().run();    
}