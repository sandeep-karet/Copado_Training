@isTest(SeeAllData=false)
class AdminEmailTest {
  @testSetup
  static void setup() {
    Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator'];
    Profile p2 = [
      SELECT id
      FROM Profile
      WHERE name = 'System Administrator - Teladoc'
    ];
    User user1;
    User user2;

    user1 = newUser(p.id, 'Alpha', 'User 1', 'user_1testemail@example.com');
    user2 = newUser(p2.id, 'Beta', 'User 2', 'user_2@testemail.com.invalid');
    insert new List<User>{ user1, user2 };
  }

  @isTest
  static void MakeValidTest() {
    Test.startTest();
    User u = [
      SELECT ID, name, username, email
      FROM User
      WHERE email = 'user_2@testemail.com.invalid'
      LIMIT 1
    ];
    System.runAs(u) {
      Test.testSandboxPostCopyScript(
        new AdminEmail(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationName()
      );
    }

    Test.stopTest();
  }

  private static User newUser(
    ID profileId,
    String firstName,
    String lastName,
    String email
  ) {
    Integer rand = Math.round(Math.random() * 1000);
    return new User(
      isActive = true,
      profileId = profileId,
      alias = firstName.substring(0, 1) + lastName.substring(1, 5),
      firstName = firstName,
      lastName = lastName,
      email = email,
      username = rand + email,
      emailEncodingKey = 'UTF-8',
      languageLocaleKey = 'en_US',
      localeSidKey = 'en_US',
      timeZoneSidKey = 'America/Chicago'
    );
  }
}