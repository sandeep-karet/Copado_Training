@RestResource(urlMapping='/orgsubsoption/*')
global class OrgSubscriptions {
  @HttpGet
  global static String doGet() {
    List<String> result = new List<String>();
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String parentGUID = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    List<SBQQ__Subscription__c> subList = [
      SELECT
        Id,
        Fee_Type__c,
        SBQQ__Product__r.ProductCode,
        Current_Membership_Fee__c,
        (SELECT Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r)
      FROM SBQQ__Subscription__c
      WHERE
        SBQQ__Account__r.Guid__c = :parentGUID
        AND (SBQQ__SubscriptionStartDate__c <= TODAY
        OR Termination_Date__c = NULL)
      ORDER BY SBQQ__SubscriptionStartDate__c DESC
    ];
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartArray();
    for (SBQQ__Subscription__c sub : subList) {
      gen.writeStartObject();
      gen.writeStringField('SubscriptionId', sub.Id);
      gen.writeStringField('ProductCode', sub.SBQQ__Product__r.ProductCode);
      gen.writeStringField('Fee_Type__c', sub.Fee_Type__c);
      gen.writeNumberField(
        'Current_Membership_Fee__c',
        sub.Current_Membership_Fee__c
      );
      gen.writeFieldName('Asset');
      gen.writeStartArray();
      for (Asset ast : sub.SBQQ__ChildAssets__r) {
        gen.writeStartObject();
        gen.writeStringField('AssetId', ast.Id);
        gen.writeStringField('ProductCode', ast.Product2.ProductCode);
        gen.writeNumberField('Consult_Fees__c', ast.Consult_Fees__c);
        gen.writeEndObject();
      }
      gen.writeEndArray();
      gen.writeEndObject();
    }
    gen.writeEndArray();

    return gen.getAsString();
  }
}