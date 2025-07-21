@RestResource(urlMapping='/accountmgrs/*')
global class AccountManagers {
  @HttpGet
  global static List<User> doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    // Grab Account Manager Roles
    // select id, developername from userrole where developername like '%_Management_%'
    //Map<Id, UserRole> acctMgrRoles = new Map<Id, UserRole>([select id, developername from userrole where developername like '%_Management_%']);
    Map<Id, Profile> scopedProfiles = new Map<Id, Profile>(
      [
        SELECT id, name
        FROM profile
        WHERE name IN ('Client Manager', 'Client Operations')
      ]
    );

    String accountId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    List<User> result = [
      SELECT Id, Name, lastname, firstname, username, email
      FROM User
      WHERE IsActive = TRUE AND profileId IN :scopedProfiles.keyset()
      ORDER BY LastName ASC
    ];
    return result;
  }
}