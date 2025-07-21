@isTest
private class Case_Trg_Test {
  @testSetup
  static void SetupTest() {
    UserRole role = [
      SELECT Id
      FROM UserRole
      WHERE Name = 'System Administrator'
    ];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u1 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'test12345@testtest.com',
      EmailEncodingKey = 'UTF-8',
      UserRoleId = role.Id,
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'test1234@testzxcas.org'
    );
    insert u1;
 
    UserRole role2 = [SELECT Id FROM UserRole WHERE Name = 'Contracts'];
    Profile profile2 = [
      SELECT Id, name
      FROM Profile
      WHERE Name = 'Sales Manager' // Changed for SCDEV-4626
    ];
    system.debug(profile2.name);
    User u2 = new User(
      Alias = 'lowRole',
      Country = 'United Kingdom',
      Email = 'test@testtest.com',
      EmailEncodingKey = 'UTF-8',
      UserRoleId = role2.Id,
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profile2.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'test5@testzxcas.org'
    );
    insert u2;
 
  }

  @isTest
  private static void caseOwner() {
    List<User> users = [
      SELECT Id
      FROM User
      WHERE Alias = 'lowRole' OR Alias = 'standt1'
    ];
    Account new_acct = new Account(
      name = 'Test Account',
      Friendly_Account_Name__c = 'Test Account',
      Business_Region__c = 'USA'
    );
    insert new_acct;
    Case newCase = new Case();
    newCase.Subject =
      'New Account Setup (' +
      new_acct.Name +
      ') - ' +
      date.today().format();
    newCase.AccountId = new_acct.Id;
    newCase.status = 'Not Started';
    newCase.ownerId = users[0].Id;
    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Admin Config')
      .getRecordTypeId();
    newCase.Description =
      'New account setup requested for (' +
      new_acct.Name +
      ' ) - Link to account setup form pdf: ' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.FileDownload?file=' +
      new_acct.id;
    insert newCase;
    newCase.ownerId = users[1].Id;
    update newCase;
    Case c = [SELECT Previous_Owner__c FROM Case];
    system.assertEquals(users[0].Id, c.Previous_Owner__c);
  }
}