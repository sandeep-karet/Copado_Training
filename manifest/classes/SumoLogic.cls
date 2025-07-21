public class SumoLogic {
    public static Integer PostLog(string sfdcId, string sfdcContext, string urlText, Integer errorCode){
        SumoLogicRequest pdr = new SumoLogicRequest(sfdcId, sfdcContext, urlText, errorCode);
        List<Map<String, Object>> links = new List<Map<String, Object>>();
        
        system.debug(JSON.serialize(pdr));
        HttpRequest auth_req = new HttpRequest();
        auth_req.setMethod('POST');
        if(UserInfo.getOrganizationId() == '00DVB000005Ld6jEAO')
            auth_req.setHeader('X-Sumo-Category','application_prod_salesforce');
        else
            auth_req.setHeader('X-Sumo-Category','application_dev_salesforce');
        
        auth_req.setHeader('X-Sumo-Fields','environment='+ UserInfo.getOrganizationId());
        auth_req.setEndpoint('https://endpoint1.collection.us2.sumologic.com/receiver/v1/http/ZaVnC4dhaV1fd57lBCHniTAYNgW8CBi70htYWXango7gTHjPRxHQBERTIIcPH0Sw1LFz6oQLpvnQj89E66y5FOqzdz7fFZPhxOXGSgoRGD3T8GlRgJrXmA==');
        auth_req.setBody(JSON.serialize(pdr.request));
        Http auth_callout = new Http();
        HttpResponse auth_response = auth_callout.send(auth_req);
        system.debug(auth_response.getBody());    
        return auth_response.getStatusCode();
    }
    
}