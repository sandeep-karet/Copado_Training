/*************************************************************************     
* @description This class is used for passing lead information and callng rest resource in ith
* @param NA
* @Author InfoSys Developer
**************************************************************************/
public without sharing class TDH_Lead_Controller {
    /**
* @description This is an Aura Enabled method called by TDH_LeadtransferController
* @param recordId is Lead record id from controller
* @return ld which are lead records
**/
    @AuraEnabled 
    public static Lead getLead(String recordId) {
        Lead ld = [SELECT Id, Status,L2O_Microsoft_Involved__c,LeadSource,L2O_Lead_Source_Detail__c,L2O_Lead_Source_Detail_Other__c, Allow_Transfer__c, Transferred_To__c, FirstName, OwnerId, LastName, Title, Company, Description, Email, Street, City, State, Postalcode, Country, Phone FROM Lead WHERE Id =: recordId];
        return ld;
    }
    /**
* @description This is an Aura Enabled method called by TDH_LeadtransferController which send record to ith
* @param ld is Lead record id from controller
* @return deserializedRes which is ResWrapper object
**/
    @AuraEnabled
    public static ResWrapper sendRecord(Lead ld) {
        String jsonString = JSON.serialize(ld); 
        EtlItem newItem = new EtlItem();
        newItem.parserName = 'Lead';
        newItem.requestVersion = '1.0';
        newItem.payload = jsonString;
        String jsonstr = JSON.serialize(newItem);
        HttpRequest req1 = new HttpRequest();
        if (ld.Transferred_To__c == 'ITH') {
            req1.setEndpoint('callout:ITH_Org_New/services/apexrest/gcrm2ithbus/');
        } 
        req1.setMethod('POST');
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setBody(jsonstr);
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        while (res1.getStatusCode() == 302) {
            req1.setEndpoint(res1.getHeader('Location'));
            res1 = new Http().send(req1);
            
        }
        
        BusItem__c busItem = new BusItem__c();
        busItem.Payload__c = jsonString;
        busItem.Processed__c = false;
        busItem.Source__c = 'TDH';
        if (ld.Transferred_To__c == 'ITH') {
            busItem.Send_to__c = 'ITH';
        } 
        if((GlobalIdUtils.isGuid(busItem.GUID__c)==false)||String.isBlank(busItem.GUID__c))
        {
        busItem.GUID__c = GlobalIdUtils.generateGuid();
        }
        
        busItem.SourceOwnerId__c = ld.OwnerId;
        busItem.SourceUrl__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ld.Id;
        
        if (res1.getStatusCode() != 200) {
            busItem.Status__c = 'Callout_Status: ' + res1.getStatusCode();
            ResWrapper resWrapper = new ResWrapper('false', 'ERROR CODE: ' + String.valueOf(res1.getStatusCode()));
            insert busItem;         
            return resWrapper;
        } else {
            busItem.Status__c = 'RESPONSE_BODY ' + res1.getbody(); 
            busItem.Processed__c = true;
            insert busItem;         
            String res = res1.getbody().unescapeEcmaScript();
            res  = res.substring(1, res.length() - 1);
            ResWrapper deserializedRes = (ResWrapper)JSON.deserialize(res, ResWrapper.class); 
            return deserializedRes;
        }        	
    }
    /**
* @description ResWrapper is being used by TDH_Lead_Controller which sets value of isInsert and result
* @param NA
* @Author InfoSys Developer
**/   
    public class ResWrapper {
/**
* @description isInsert used to set value for isInsert variable
*/
        @auraEnabled
        public String isInsert {get; set;}
/**
* @description result used to store result 
*/
        @auraEnabled
        public String result {get; set;}
        /**
* @description ResWrapper used as a constructor
* @param isInsert used to set the isInsert value and result used to send the result data
* @param result used to send the result data
*/
        public ResWrapper(String isInsert, String result){
            this.isInsert = isInsert;
            this.result = result;
        }
    }
}