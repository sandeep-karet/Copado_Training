@isTest
private class Credentials_Test {
  @isTest
  static void Confirm_All_Fields_Populate() {
    Credentials myCreds = new Credentials('username', 'password', 'domainname');
    System.assertEquals(myCreds.username, 'username');
    System.assertEquals(myCreds.password, 'password');
    System.assertEquals(myCreds.domain, 'domainname');
  }
}