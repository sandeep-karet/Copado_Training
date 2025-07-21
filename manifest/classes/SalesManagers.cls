@RestResource(urlMapping='/salesmgrs/*')
global class SalesManagers {
  @HttpGet
  global static List<User> doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    String accountId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );

    List<String> lstUsernames = System.Label.TeladocHealth_SF_Support_Users.replaceAll(
        '\\s+',
        ''
      )
      .split(',');
    List<User> result = [
      SELECT Id, Name, lastname, firstname, username, email
      FROM User
      WHERE IsActive = TRUE AND username IN :lstUsernames
      ORDER BY LastName ASC
    ];
    return result;
  }
}