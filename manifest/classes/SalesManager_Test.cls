@IsTest
private class SalesManager_Test {
  @IsTest
  static void SalesManager_Test() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/salesmgrs'; //Request URL
    req.httpMethod = 'GET'; //HTTP Request Type
    RestContext.request = req;
    RestContext.response = res;
    List<User> result = SalesManagers.doGet();
    List<String> lstUsernames = System.Label.TeladocHealth_SF_Support_Users.replaceAll(
        '\\s+',
        ''
      )
      .split(',');
    List<User> resultList = [
      SELECT Id, Name, lastname, firstname, username, email
      FROM User
      WHERE IsActive = TRUE AND username IN :lstUsernames
      ORDER BY LastName ASC
    ];
    Test.stopTest();
    system.assertEquals(resultList.size(), result.size());
  }
}