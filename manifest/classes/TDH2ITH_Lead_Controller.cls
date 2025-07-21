public without sharing class TDH2ITH_Lead_Controller {
  @AuraEnabled
  public static Lead getLead(String recordId) {
    Lead ld = [
      SELECT
        Id,
        Status,
        allow_ith_transfer__c,
        Microsoft_Involved__c,
        FirstName,
        OwnerId,
        LastName,
        Title,
        Company,
        Description,
        Email,
        Street,
        City,
        State,
        Postalcode,
        Country,
        Phone
      FROM Lead
      WHERE Id = :recordId
    ];
    return ld;
  }

  @AuraEnabled
  public static resWrapper sendRecord(Lead ld) {
    String jsonString = JSON.serialize(ld);
    EtlItem newItem = new EtlItem();
    newItem.parserName = 'Lead';
    newItem.requestVersion = '1.0';
    newItem.payload = jsonString;
    String jsonstr = JSON.serialize(newItem);
    system.debug(jsonstr);
    HttpRequest req1 = new HttpRequest();
    req1.setEndpoint('callout:ITH_Org/services/apexrest/tdh2ithbus/');
    req1.setMethod('POST');
    req1.setHeader('Content-Type', 'application/json');
    req1.setHeader('accept', 'application/json');
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
    busItem.Send_to__c = 'ITH';
    busItem.GUID__c = GlobalIdUtils.generateGuid();
    busItem.SourceOwnerId__c = ld.OwnerId;
    busItem.SourceUrl__c =
      URL.getOrgDomainUrl().toExternalForm() +
      '/' +
      ld.Id;

    if (res1.getStatusCode() != 200) {
      busItem.Status__c = 'Callout_Status: ' + res1.getStatusCode();
      resWrapper resWrapper = new resWrapper(
        'false',
        'ERROR CODE: ' + String.valueOf(res1.getStatusCode())
      );
      insert busItem;
      return resWrapper;
    } else {
      busItem.Status__c = 'RESPONSE_BODY ' + res1.getbody();
      busItem.Processed__c = true;
      insert busItem;
      String res = res1.getbody().unescapeEcmaScript();
      res = res.substring(1, res.length() - 1);
      resWrapper deserializedRes = (resWrapper) JSON.deserialize(
        res,
        resWrapper.class
      );
      if (deserializedRes.isInsert == 'true') {
        ld.Transferred_To__c = 'ITH';
        update ld;
      }
      return deserializedRes;
    }
  }

  public class resWrapper {
    @auraEnabled
    public String isInsert { get; set; }
    @auraEnabled
    public String result { get; set; }
    public resWrapper(String isInsert, String result) {
      this.isInsert = isInsert;
      this.result = result;
    }
  }
}