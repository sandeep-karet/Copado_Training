@IsTest
private class AccountManagers_Test {
  @IsTest
  static void AccountManagers_Test() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/accountmgrs'; //Request URL
    req.httpMethod = 'GET'; //HTTP Request Type
    RestContext.request = req;
    RestContext.response = res;
    List<User> result = AccountManagers.doGet();
    List<User> cmList = [
      SELECT Id, Name, lastname, firstname, username, email
      FROM User
      WHERE
        IsActive = TRUE
        AND Profile.Name IN ('Client Manager', 'Client Operations')
    ];
    Test.stopTest();
    system.assertEquals(cmList.size(), result.size());
  }
}