global class AdminEmail implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
    List<String> profileList = new List<String>{
      'System Administrator',
      'System Administrator - Teladoc'
    };
    List<User> targetUsers = [
      SELECT id, username, email
      FROM user
      WHERE
        profile.name IN :profileList
        AND isactive = TRUE
        AND email LIKE '%.invalid'
    ];
    Set<Id> userIds = new Set<ID>();

    for (User tmpUsr : targetUsers) {
      integer email_length = tmpUsr.email.length() - 8;
      tmpUsr.email = tmpUsr.email.left(email_length);

      userIds.add(tmpUsr.Id);
    }
    Database.update(targetUsers, false);
    if (userIds != null)
      updatePermissionSetForUsers(userIds);
  }

  // option 1 remove SSO only permission-set assignment for users
  public static void updatePermissionSetForUsers(Set<Id> userIds) {
    ID ssoPermissionSetID = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'SSO_Only'
      LIMIT 1
    ]
    .Id;
    List<PermissionSetAssignment> permissionSetAssignmentIds = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE AssigneeId IN :userIds AND PermissionSetId = :ssoPermissionSetID
    ];

    if (
      permissionSetAssignmentIds != null &&
      permissionSetAssignmentIds.size() > 0
    ) {
      delete permissionSetAssignmentIds;
    }
    // send password reset email using batchjob
    System.scheduleBatch(
      new RevertUserEmailsBatchable(userIds),
      'User Password Reset Job',
      15
    );
  }
}