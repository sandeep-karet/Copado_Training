/**
* Company : PwC.
* @description : This class get the Platform Event configuration metadata 
* ************************************************************************************************************************************
* History : 
* @date 14/09/2022
* @author Neha Sheikh
*/ 
public without sharing class L2O_PlatformEvent_MetadataHandler {
     
    /**
* @name  getMetadataPlatformEvents
* @description get the details of L2O_Platform_Events_Configuration__mdt 
* @param  strPltfrmEvntName for platform event Name
* @return  isResult will retrun true if metadata found
**/
    public Boolean getMetadataPlatformEvents (String strPltfrmEvntName){
        Boolean isResult = false;
        
        List<L2O_Platform_Events_Configuration__mdt> pltfrmEvntMdtList = new List<L2O_Platform_Events_Configuration__mdt>();
        pltfrmEvntMdtList = [SELECT L2O_Platform_Event_Name__c, L2O_Active__c 
                                 FROM L2O_Platform_Events_Configuration__mdt 
                                 WHERE L2O_Platform_Event_Name__c =: strPltfrmEvntName
                                 AND L2O_Active__c = True];
       if(!pltfrmEvntMdtList.isEmpty()){
            isResult = true; 
            }
        return isResult;
    }
}