@IsTest
private class AccountPermissions_Test {
  @TestSetup
  static void setup() {
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

    UserRole role2 = [SELECT Id FROM UserRole WHERE Name = 'Contracts'];
    Profile profile2 = [
      SELECT Id, name
      FROM Profile
      WHERE Name = 'Sales Manager'//Changed for SCDEV-4626
    ];
    system.debug(profile2.name);

    User u2 = TestDataFactory.createUser(profile2.Id);
    u2.Alias = 'lowRole';
    u2.UserRoleId = role2.Id;
    u2.UserName = 'test5@testzxcas.org';
    u2.LastName = 'Testing';
    insert u2;
  }

  @IsTest
  static void deleteAccountFail() {
    User u1 = [
      SELECT Id, profile.name, userrole.name
      FROM User
      WHERE Alias = 'standt1'
    ];
    User u2 = [
      SELECT Id, profile.name, userrole.name
      FROM User
      WHERE Alias = 'lowRole'
    ];
    Account accObj = TestDataFactory.createAccount('TestAccount');
    accObj.OwnerId = u1.Id;
    update accObj;
    account acct = [SELECT owner.profile.name FROM Account];
    System.debug(acct.owner.profile.name);
    system.debug(u1.profile.name + '___' + u1.userrole.name);
    system.debug(u2.profile.name + '___' + u2.userrole.name);
    System.runAs(u2) {
      Boolean error;
      try {
        delete accObj;
        error = false;
      } catch (exception e) {
        error = true;
      }
      system.assertEquals(true, error);
    }
  }
}