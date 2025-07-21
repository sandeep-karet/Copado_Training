@isTest
private class Contact_Grp_Zero_BchTest {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createParentAccount();
    Contact con = TestDataFactory.createContact(acct.Id);
    con.marketing_site_user__c = false;
    con.Group_Count__c = 8;
    update con;
  }

  static testMethod void defaultTest() {
    Contact con = [SELECT Id, Group_Count__c FROM Contact];
    test.startTest();
    Contact_Grp_Zero_Bch testing = new Contact_Grp_Zero_Bch(null);
    DataBase.executeBatch(testing);
    test.stopTest();
    system.assertEquals(0, [SELECT Group_Count__c FROM Contact].Group_Count__c);
  }

  static testMethod void customTest() {
    Contact con = [SELECT Id, Group_Count__c FROM Contact];
    test.startTest();
    //Contact_Grp_Zero_Bch testing = new Contact_Grp_Zero_Bch('SELECT Id FROM Contact');
    DataBase.executeBatch(new Contact_Grp_Zero_Bch('SELECT Id FROM Contact'));
    test.stopTest();
    system.assertEquals(0, [SELECT Group_Count__c FROM Contact].Group_Count__c);
  }
}