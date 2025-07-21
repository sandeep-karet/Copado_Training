public class FreezeUsers {
  public static void Freeze() {
    Map<Id, User> mappedUsers = new Map<Id, User>(
      [
        SELECT id
        FROM user
        WHERE
          profile.name NOT IN (
            'System Administrator',
            'SalesforceIQ Integration User',
            'Sales Insights Integration User',
            'Analytics Cloud Integration User'
          )
          AND isActive = TRUE
      ]
    );
    List<UserLogin> scopedLogins = [
      SELECT id, isFrozen
      FROM UserLogin
      WHERE userid IN :mappedUsers.keyset()
    ];
    System.debug(scopedLogins.size());
    for (UserLogin tmpUl : scopedLogins)
      tmpUl.isFrozen = true;

    update scopedLogins;
  }
  public static void Thaw() {
    List<UserLogin> scopedLogins = [
      SELECT id, isFrozen
      FROM UserLogin
      WHERE isFrozen = TRUE
    ];
    System.debug(scopedLogins.size());
    for (UserLogin tmpUl : scopedLogins)
      tmpUl.isFrozen = false;

    update scopedLogins;
  }
}