@RestResource(UrlMapping='/Nasf/*')
global with sharing class NASFInfoService {
  //EEM:  Entry to JSON endpoint for NASF form.
  //      Must provide account id for it to work.
  //      Test with this in explorer /services/apexrest/Nasf/[AccountId]
  @HttpGet
  global static Mg2_NASFHelper.Mg2_NASFInfo getNASFInfoByAccountId() {
    RestRequest request = RestContext.request;
    // grab the caseId from the end of the URL
    String accountId = request.requestURI.substring(
      request.requestURI.lastIndexOf('/') + 1
    );
    return Mg2_NASFHelper.getNasfInfoByAccountId(accountId, null);
  }
}