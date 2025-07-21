@isTest
private class CaseNotificationEmailTest {
  @testSetup
  static void SetupTest() {
    UserRole role = [
      SELECT Id
      FROM UserRole
      WHERE Name = 'System Administrator'
    ];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u1 = TestDataFactory.createUser(p.Id);
    u1.Alias = 'standt1';
    u1.UserRoleId = role.Id;
    insert u1;
    /* SCDEV-4626 - Change start
    UserRole role2 = [SELECT Id FROM UserRole WHERE Name = 'Contracts'];
    Profile profile2 = [
      SELECT Id, name
      FROM Profile
      WHERE Name = 'Sales Provider'
    ];
    system.debug(profile2.name);

    User u2 = TestDataFactory.createUser(profile2.Id);
    u2.Alias = 'lowRole';
    u2.UserRoleId = role2.Id;
    u2.UserName = 'test5@testzxcas.org';
    u2.LastName = 'Testing';
    insert u2;
    SCDEV-4626 - Change end*/
  }
  @isTest
  private static void testschedule() {
    List<User> users = [
      SELECT Id
      FROM User
      WHERE Alias = 'lowRole' OR Alias = 'standt1'
    ];
    // Create account
    Account new_acct = TestDataFactory.createAccount('Test Account');
    new_acct.Friendly_Account_Name__c = 'Test Account';
    new_acct.Business_Region__c = 'USA';
    update new_acct;

    // Create case
    Case newCase = TestDataFactory.createCase(new_acct);
    newCase.ownerId = users[0].Id;
    insert newCase;
    Case newCase2 = TestDataFactory.createCase(new_acct);
    newCase2.ownerId = users[0].Id;
    insert newCase2;
    Test.StartTest();
    CaseNotificationEmail sh1 = new CaseNotificationEmail();
    String sch = '0 0 23 * * ?';
    system.schedule('Test  Check', sch, sh1);
    Test.stopTest();
  }
}