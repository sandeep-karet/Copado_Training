@isTest
private class CaseDailyEmail_Test {
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
    /*SCDEV-4626   
    UserRole role2 = [SELECT Id FROM UserRole WHERE Name = 'Contracts'];
    Profile profile2 = [
      SELECT Id, name
      FROM Profile
      WHERE Name = 'Client Manager'
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
    insert u2; */
  }
  @isTest
  private static void testschedule() {
    List<User> users = [
      SELECT Id
      FROM User
      WHERE Alias = 'lowRole' OR Alias = 'standt1'
    ];
    // Create account
    Account new_acct = new Account(
      name = 'Test Account',
      Friendly_Account_Name__c = 'Test Account',
      Business_Region__c = 'USA'
    );
    insert new_acct;

    // Create case
    Case newCase = new Case();
    newCase.Subject =
      'New Account Setup (' +
      new_acct.Name +
      ') - ' +
      date.today().format();
    newCase.AccountId = new_acct.Id;
    newCase.status = 'Not Started';
    //newCase.ownerId = users[0].Id;
    newCase.Previous_Owner__c = users[0].Id;
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
    Case newCase2 = new Case();
    newCase2.Subject =
      'New Account Setup (' +
      new_acct.Name +
      ') - ' +
      date.today().format();
    newCase2.AccountId = new_acct.Id;
    newCase2.status = 'Not Started';
    newCase2.ownerId = users[0].id;
    newCase2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Admin Config')
      .getRecordTypeId();
    newCase2.Description =
      'New account setup requested for (' +
      new_acct.Name +
      ' ) - Link to account setup form pdf: ' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.FileDownload?file=' +
      new_acct.id;
    insert newCase2;
    Test.StartTest();
    CaseDailyEmail sh1 = new CaseDailyEmail();
    String sch = '0 0 23 * * ?';
    system.schedule('Test  Check', sch, sh1);
    Test.stopTest();
  }
}