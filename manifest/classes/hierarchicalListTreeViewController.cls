/**************************************************************************************************
* author        : Elambaruthi Thanasinghu
* date          : 31/01/2024
* Name          : hierarchicalListTreeViewController
* @description  : This class contains the code to retrieve the given sObject line items respect to the sObject id.
* History       :
**************************************************************************************************/

public with sharing class hierarchicalListTreeViewController {
    public hierarchicalListTreeViewController() {
    }

    @auraEnabled(cacheable=true)
    public Static wrapHVIEW getHierarchicalData(string sourceId, string listViewName){
        List<sObject> sobjList = new List<sObject>();
        wrapHVIEW dataWrapper;
        try{

            Hierarchical_List_View_Configuration__mdt hlvConfig = [SELECT Object_Name__c, Record_Id_Field__c, Self_Parent_Field__c, Self_Relationship_Name__c, Sourcing_Field_Name__c, List_View_Fields__c FROM Hierarchical_List_View_Configuration__mdt WHERE DeveloperName =:listViewName];

            String listfields = hlvConfig.List_View_Fields__c;
            String baseObj = hlvConfig.Object_Name__c;
            String childObj = hlvConfig.Self_Relationship_Name__c; 
            String condField = hlvConfig.Sourcing_Field_Name__c;
            String parentField  = hlvConfig.Self_Parent_Field__c;
            String recordIdField  = hlvConfig.Record_Id_Field__c;
            String query = '';
            if(recordIdField == 'Id'){
                query = String.format('SELECT Id, {0}, {1}, (SELECT Id FROM {2}) FROM {3} WHERE {4}=:sourceId', new List<String>{
                    listfields, parentField, childObj, baseObj, condField
                });
            }else{
                query = String.format('SELECT Id, {0}, {1} FROM {2} WHERE {3}=:sourceId', new List<String>{
                    listfields, parentField, baseObj, condField
                });
            }

            sobjList = Database.query(query);

            
            SObjectType objDescribe = Schema.getGlobalDescribe().get(hlvConfig.Object_Name__c);
            Map<String,Schema.SObjectField> mfields = objDescribe.getDescribe().fields.getMap(); 
            String namespacePrefix = objDescribe.getDescribe().getName().remove(objDescribe.getDescribe().getLocalName());
            String selectedFields = 'Id,'+hlvConfig.List_View_Fields__c;
            List<String> lstSelectedFields = selectedFields.replace(' ','').split(','); 

            Set<String> setParentIds = new Set<String>();
            if(recordIdField != 'Id'){
                for(sObject obj: sobjList){
                    setParentIds.add((String)obj.get(parentField));
                }
            }


            List<wrapRecordValue> lstRecordMeta = new List<wrapRecordValue>();
            for(sObject obj: sobjList){
                wrapRecordValue recordMeta = new wrapRecordValue();   
                recordMeta.recordId = (String)obj.get(recordIdField);                
                recordMeta.isParent=false;
                recordMeta.parentId = '';
                if(obj.get(parentField) != null){
                    recordMeta.parentId = (String)obj.get(parentField);
                }
                if(recordIdField == 'Id'){
                    for(sObject child :obj.getSObjects(childObj)){
                        recordMeta.isParent=true;                
                        break;
                    }
                }else if(setParentIds.contains((String)obj.get(recordIdField))){
                    recordMeta.isParent=true;
                }
                
                List<wrapFieldValue> lstFMeta = new List<wrapFieldValue>();
                for(String fieldName:lstSelectedFields){
                    wrapFieldValue fMeta = new wrapFieldValue();              
                    
                    SObjectField fl = mfields.get(fieldName);   
                    if(fl != null){                        
                        Schema.DescribeFieldResult fldResult = mfields.get(fieldName).getDescribe();
                        fMeta.dType = fldResult.getType().toString();
                        fMeta.dLabel = fldResult.getLabel();
                        fMeta.dName = fieldName;
                        fMeta.dValue= '';
                        if(obj.get(fieldName)!=null){
                            fMeta.dValue= obj.get(fieldName).toString();
                        }
                    }else{
                        List<String> refFieldList = fieldName.split('\\.');
                        String relObject = refFieldList[0].replace('__r','__c');
                           
                        if(mfields.get(relObject).getDescribe().getType() == Schema.DisplayType.REFERENCE)
                        {
                            Schema.SObjectType relSchema = mfields.get(relObject).getDescribe().getReferenceTo().get(0);
                            Map<String,Schema.SObjectField> relFieldMap = relSchema.getDescribe().fields.getMap();

                            Schema.DescribeFieldResult relfldResult = relFieldMap.get(refFieldList[1]).getDescribe();
                            fMeta.dType = relfldResult.getType().toString();
                            fMeta.dLabel = relfldResult.getLabel();
                            fMeta.dName = fieldName;
                            fMeta.dValue= (String) obj.getSobject(refFieldList[0]).get(refFieldList[1]);
                            
                        }

                    }
                    lstFMeta.add(fMeta);
                }
                recordMeta.lstFieldValues = lstFMeta;

                lstRecordMeta.add(recordMeta);
                
            }
            
            dataWrapper = new wrapHVIEW(hlvConfig.Object_Name__c, hlvConfig.Self_Parent_Field__c, hlvConfig.Self_Relationship_Name__c, lstRecordMeta);




        }catch(Exception ex){
            system.debug('Exception : '+ex);
        }

        return dataWrapper;
        
    }

    public class wrapHVIEW{
        @AuraEnabled public String ObjectName{get; set;}
        @AuraEnabled public String SelfParentFieldName{get; set;}
        @AuraEnabled public String SelfRelationshipName{get; set;}
        @AuraEnabled public List<wrapRecordValue> lstHViewData{get; set;}
        public wrapHVIEW(String objName, String ParentField, String RelName, List<wrapRecordValue> viewData){ 
            this.ObjectName = objName;              
            this.SelfParentFieldName = ParentField;
            this.SelfRelationshipName = RelName;
            this.lstHViewData=viewData;
        }
    }

    public class wrapRecordValue{
        @AuraEnabled public List<wrapFieldValue> lstFieldValues{get; set;}
        @AuraEnabled public Boolean isParent{get; set;}
        @AuraEnabled public String parentId{get; set;}
        @AuraEnabled public String recordId{get; set;}
        public wrapRecordValue(){
        }
    }

    public class wrapFieldValue{
        @AuraEnabled public String dType{get; set;}
        @AuraEnabled public String dLabel{get; set;}
        @AuraEnabled public String dName{get; set;}
        @AuraEnabled public String dValue{get; set;}
        public wrapFieldValue(){
        }
    }


}