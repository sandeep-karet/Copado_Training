/**
* Company : PwC.
* @description : L2O_PlatFormEvent_Ctrl will be executed from the L2O_AccountTriggerHelperService and L2O_OrderItemTriggerHelperService to Publish the Platform Events
* *****************************************************************************************************************************************
* History : 
* @date 06/07/2022
* @author Neha Sheikh
*/
 
public without sharing class L2O_PlatFormEvent_Ctrl extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = '';
    public static String methodName = ''; 
    // Unique GUID field variables
    public static String strGUID = 'L2O_GUID__c';
    // split string indicator variables
    public static String strSplit = '\\.';
    
    /**
* @name  publishPlatFormEvents
* @description Publish Platform Event 'L2O_Order_item_Broadcast__e' and 'L2O_Account_Broadcast__e'
* @param objectName for Objectname
@param platformEventName for Platform Event Name
@param objectIdList for List of respective object record IDs
@param mapQryIndicator for filtering fields need to Query
@param mapPltfmEntIndct for storing the Platform Event object Indicator
@return isEventPublishSuccess will return the True/False for publised Event
**/ 
    
    public List<String> publishPlatFormEvents(String objectName,String platformEventName,List<Id> objectIdList, Map<String,List<String>> mapQryIndicator,Map<String,String> mapPltfmEntIndct){
        List<L2OPlatformEventMappingRecords__mdt> lstMapPlatformEventSFObjects = new List<L2OPlatformEventMappingRecords__mdt>();
        List<sObject> lstObjrecords = new List<sObject>();
        List<sObject> lstPublishEvents = new List<sObject>();
        List<String> lstRectoUpdate = new List<String>();
        List<L2O_Platform_Event_Published__c> publishEventsList = new List<L2O_Platform_Event_Published__c>();
        
        try{
            lstMapPlatformEventSFObjects = getPtEvtMtdRecords(platformEventName,objectName,mapQryIndicator);
            methodName = 'publishPlatFormEvents';
            lstObjrecords = getSObjectRecords(lstMapPlatformEventSFObjects,objectIdList,objectName);
            methodName = 'publishPlatFormEvents';
            lstPublishEvents = setDataForPlatEvent(lstObjrecords,lstMapPlatformEventSFObjects,platformEventName,mapQryIndicator,mapPltfmEntIndct);
            methodName = 'publishPlatFormEvents';
            //Publish Events
            if(lstPublishEvents.size()>0){
                List<Database.SaveResult> results = EventBus.publish(lstPublishEvents);               
                Integer tempCount = 0;
                for (Database.SaveResult sr : results) {
                    L2O_Platform_Event_Published__c platformeventObject = new L2O_Platform_Event_Published__c();
                    Sobject obj = lstPublishEvents[tempCount];
                    platformeventObject.L2O_Object__c = objectName;
                    platformeventObject.L2O_Platform_event_Name__c = platformEventName;
                    platformeventObject.L2O_Object_Id__c = String.valueOf(obj.get(strGUID));
                    if (sr.isSuccess()) {
                        if(!lstRectoUpdate.contains(String.valueOf(obj.get(strGUID)))){
                            lstRectoUpdate.add(String.valueOf(obj.get(strGUID))); 
                        }
                        platformeventObject.L2O_Status__c = 'Success';
                    } else {                      
                        platformeventObject.L2O_Status__c = 'Errored';
                        platformeventObject.L2O_Error_Message__c = String.valueOf(sr.getErrors()[0]);
                        SDF_LGR_LoggerManager.DBufLogger.error(String.valueOf(sr),className,methodName);
                    }
                    publishEventsList.add(platformeventObject);
                    tempCount++;
                }
                if(publishEventsList.size() > 0){
                    insert publishEventsList;
                }
            }
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        return lstRectoUpdate; 
    }
    
    /**
* @name  getSObjectRecords
* @description to fetch the List of sObject records
* @param  lstMapPlatformEventSFObjects for CustomMetadata records
@param  objectIdList Stores sObject record Ids
@param  objectName Stores sObject Name 
@return List object Quried sObject records

**/
    
    public List<sObject> getSObjectRecords(List<L2OPlatformEventMappingRecords__mdt> lstMapPlatformEventSFObjects, 
                                           List<Id> objectIdList,String objectName){
                                               methodName = 'getSObjectRecords';
                                               List<sObject> lstObjrecords = new List<sObject>();
                                               String strMetaDataSourceFields = '';
                                               
                                               for(L2OPlatformEventMappingRecords__mdt mdt:  lstMapPlatformEventSFObjects){
                                                   if(mdt.L2O_SourceFieldAPIName__c != null && !strMetaDataSourceFields.split(',').contains(mdt.L2O_SourceFieldAPIName__c)){
                                                       strMetaDataSourceFields += mdt.L2O_SourceFieldAPIName__c+',';
                                                   }
                                               }  
                                               //Creation of Dyanamic Query
                                               if(!String.isEmpty(strMetaDataSourceFields)){
                                                   strMetaDataSourceFields=strMetaDataSourceFields.Substring(0,strMetaDataSourceFields.length()-1);  
                                                  lstObjrecords = Database.query('SELECT Id, ' + String.escapeSingleQuotes(strMetaDataSourceFields) + 
                                                       ' FROM ' + String.escapeSingleQuotes(objectName) + 
                                                       ' WHERE Id IN : objectIdList');
                                               }
                                               return lstObjrecords;
                                           }
    /**
* @name  setDataForPlatEvent
* @description Mapping the respective Platform Event fields with the sobject fields
* @param  lstObjrecords for Object record IDs
* @param  lstMapPlatformEventSFObjects for CustomMetadata records
* @param platformEventName for platform Event Name
* @param mapQryIndicator for filtering fields need to Query
* @param mapPltfmEntIndct for storing the Platform Event object Indicator
* @return  lstPublishEvents for platform event records 
**/
    
    public List<sObject> setDataForPlatEvent(List<sObject> lstObjrecords,List<L2OPlatformEventMappingRecords__mdt> lstMapPlatformEventSFObjects,
                                             String platformEventName,Map<String,List<String>> mapQryIndicator,Map<String,String> mapPltfmEntIndct){
                                                 methodName = 'setDataForPlatEvent';
                                                 List<sObject> lstPublishEvents = new List<sObject>();
                                                 
                                                 for(sObject obj : lstObjrecords){
                                                     List<String> strPltfmEntIndctList =new List<String>();
                                                     strPltfmEntIndctList.addAll(mapPltfmEntIndct.get(String.valueOf(obj.get(strGUID))).split(','));
                                                     Schema.SObjectType stdShareType = Schema.getGlobalDescribe().get(platformEventName);
                                                     SObject objNew = stdShareType.newSObject();
                                                     for(L2OPlatformEventMappingRecords__mdt mdt : lstMapPlatformEventSFObjects){
                                                         if(validateQryIndicator(obj,mdt.L2O_SourceFieldIndicator__c,mapQryIndicator)){
                                                             if(mdt.L2O_SourceFieldAPIName__c != null && mdt.L2O_TargetFieldAPIName__c != null){
                                                                 if(mdt.L2O_SourceFieldAPIName__c.split(strSplit).size() == 2 &&
                                                                    isMdtSourceFieldNull(mdt,obj)){
                                                                        objNew.put(mdt.L2O_TargetFieldAPIName__c,
                                                                                   obj.getSObject(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0])
                                                                                   .get(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[1]));
                                                                    }
                                                                 else if(mdt.L2O_SourceFieldAPIName__c.split(strSplit).size() == 1 &&
                                                                         isMdtSourceFieldNull(mdt,obj)){
                                                                             objNew.put(mdt.L2O_TargetFieldAPIName__c,
                                                                                        mdt.L2O_ConcatenatewithSourceField__c != null ? 
                                                                                        obj.get(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0])+mdt.L2O_ConcatenatewithSourceField__c : 
                                                                                        obj.get(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0]));
                                                                         }
                                                             }else if(mdt.L2O_PlatformEventIndicator__c != null){
                                                                 objNew.put(mdt.L2O_TargetFieldAPIName__c,setPltfrmEvntIndicator(mdt,strPltfmEntIndctList));
                                                                 methodName = 'setDataForPlatEvent';
                                                             }
                                                         }
                                                     }
                                                     lstPublishEvents.add(objNew);
                                                     strPltfmEntIndctList.clear(); // to clear all the element from the list
                                                     }
                                                 return lstPublishEvents;
                                             }
    /**
* @name  validateQryIndicator
* @description To check if the indicator is bind with correct obj record
* @param  obj sobject record
@param  mdtSourceIndicator Source field indicator from metadata
@param mapQryIndicator contains query indicator per record
@return Return if indicator is matched with record indicator
**/
    public Boolean validateQryIndicator(SObject obj,String mdtSourceIndicator, Map<String,List<String>> mapQryIndicator){
        Boolean isValid = false;
        for(String spltStr : mdtSourceIndicator.split(',')){
            if(mapQryIndicator.get(String.valueOf(obj.get(strGUID))).contains(spltStr)){
                isValid = true;
            }
        }
        return isValid;
    }
    
    /**
* @name  setPltfrmEvntIndicator
* @description To set the Platform Event Field Indicator
* @param  mdt for CustomMetadata records
@param  strPltfmEntIndctList List of String to store custom inidcation
@return Return the mapped Indicator 
**/
    
    public String setPltfrmEvntIndicator(L2OPlatformEventMappingRecords__mdt mdt, List<String> strPltfmEntIndctList){
        methodName = 'setPltfrmEvntIndicator';
        for(String str : strPltfmEntIndctList){
            if(str.split('-').contains(mdt.L2O_PlatformEventIndicator__c)) {
                return str.substringAfter('-');
            }
        }
        return '';
    }
    
    /**
* @name  getPtEvtMtdRecords
* @description To get and return the List of Custom MetaData(L2OPlatformEventMappingRecords__mdt) records
* @param  platformEventName for Platform Event Name
@param  objectName for Objectname
@param  mapQryIndicator Metadata Indicator
@return Return the List of L2OPlatformEventMappingRecords__mdt Custom Metdatda records
**/
    public List<L2OPlatformEventMappingRecords__mdt> getPtEvtMtdRecords(String platformEventName,String objectName,Map<String,List<String>> mapQryIndicator){
        methodName = 'getPtEvtMtdRecords';
        List<String> listIndictor = new List<String>();
        String strQryIndicator = '';
        for(List<String> lstStr : mapQryIndicator.Values()){
            listIndictor.addAll(lstStr);
        }
        for(String str : listIndictor){
            strQryIndicator +=str+',';
        }
        List<L2OPlatformEventMappingRecords__mdt> returnMDTList = new List<L2OPlatformEventMappingRecords__mdt>();
        for(L2OPlatformEventMappingRecords__mdt mdt : [SELECT L2O_PlatformEventName__c,L2O_SourceObject__c,
                                                       L2O_SourceFieldAPIName__c,L2O_TargetFieldAPIName__c,
                                                       L2O_ConcatenatewithSourceField__c,L2O_SourceFieldIndicator__c,
                                                       L2O_PlatformEventIndicator__c
                                                       FROM L2OPlatformEventMappingRecords__mdt
                                                       WHERE L2O_SourceObject__c = :objectName
                                                       AND L2O_PlatformEventName__c = :platformEventName]){
                                                           if(mdt.L2O_SourceFieldIndicator__c != null){
                                                               for(String tempStr : mdt.L2O_SourceFieldIndicator__c.split(',')){
                                                                   if(strQryIndicator != null && strQryIndicator.split(',').contains(tempStr) && 
                                                                      !returnMDTList.contains(mdt)){
                                                                          returnMDTList.add(mdt);
                                                                      }
                                                               }
                                                           }
                                                       }
        return returnMDTList;
    }
    
    /**
* @name  isMdtSourceFieldNull
* @description Returning whether the mapped sObject field value is null or not.
@param  mdt for CustomMetadata records
@param  obj for processed record
@return Return true if the field value is not null else return false
**/
    
    public Boolean isMdtSourceFieldNull(L2OPlatformEventMappingRecords__mdt mdt,Sobject obj){
        Boolean isSourceFldNull = false;
        
        if(mdt.L2O_SourceFieldAPIName__c.split(strSplit).size() == 2 &&
           (obj.getSObject(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0]) != null &&
            obj.getSObject(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0])
            .get(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[1]) != null)){
                isSourceFldNull = true;
            }
        else if(mdt.L2O_SourceFieldAPIName__c.split(strSplit).size() == 1 &&
                obj.get(mdt.L2O_SourceFieldAPIName__c.split(strSplit)[0]) != null){
                    isSourceFldNull = true;
                }
        return isSourceFldNull;
    }
}