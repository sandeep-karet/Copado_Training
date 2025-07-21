/**
 * TODO: Specific Id - Path parameter
 * Name Search - possibly a POST instead of a GET and match with other field names.
 * Versioning. (to allow for older and newer calls).
 */
@RestResource(urlMapping='/1.0/AccountSearch/*')
global with sharing class AccountService {
  @HttpPost
  global static List<AccountWrapper> searchAccounts() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String jsonBody = req.requestBody.toString().trim();
    Map<String, String> inputMap;
    try {
      inputMap = (Map<String, String>) JSON.deserialize(
        jsonBody,
        Map<String, String>.class
      );
    } catch (Exception e) {
      throw new AccountServiceException(
        'Exception parsing JSON; check body ' + e.getMessage()
      );
    }

    String accountName = inputMap.get('name'); // Get the name of the account to search for
    String external_id = inputMap.get('external_id'); // Get the External id of the account to search for

    try {
      if (!String.isBlank(accountName)) {
        return new AccountSelector().selectByName(accountName);
      } else
        return null;
    } catch (Exception ex) {
      throw new AccountServiceException(ex.getMessage());
      // Add logging logic
    }
  }

  @HttpGet
  global static List<AccountWrapper> getAccountById() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String accountId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );

    try {
      if (!String.isBlank(accountId)) {
        Set<Id> accIdSet = new Set<Id>();
        for (Id accId : accountId.split(','))
          accIdSet.add(accId);

        return new AccountSelector().selectById(accIdSet);
      } else
        return null;
    } catch (Exception ex) {
      throw new AccountServiceException(ex.getMessage());
      // Add logging logic
    }
  }

  global class AccountServiceException extends Exception {
  }
}