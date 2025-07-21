@isTest
private class Contact_Grp_Rollup_BchTest {
  @TestSetup
  static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    Account acct = TestDataFactory.createParentAccount();
    Account acct2 = new Account();
    acct2.Name = 'New Benefits, LTD';
    acct2.GUID__c = '5326F18B-33D6-4F53-A532-ECC7C29Ed74C';
    acct2.revenue_effective_date__c = Date.today();
    acct2.BillingStreet = 'test road test state';
    insert acct2;
    Contact con = TestDataFactory.createContact(acct.Id);
    con.marketing_site_user__c = true;
    con.email = 'test@test.com';
    update con;
    Mbr_Group__c mg = new Mbr_Group__c();
    mg.Name__c = 'Test Group';
    mg.Client_Account__c = acct2.Id;
    mg.Termination_Date__c = system.today() + 3;
    mg.Status__c = 'Active';
    insert mg;
    Mbr_Group__c mg2 = new Mbr_Group__c();
    mg2.Name__c = 'Test Group1';
    mg2.Client_Account__c = acct2.Id;
    mg2.Termination_Date__c = system.today() + 3;
    mg2.Status__c = 'Active';
    insert mg2;
    List<Mbr_Group__c> mbrGrp = TestDataFactory.createMbrGroup(acct.Id);
    Mbr_Group_Role__c mbrGrpRole = new Mbr_Group_Role__c(
      Mbr_Group__c = mg.Id,
      Source_Account__c = acct.Id,
      Role_Type__c = 'Payer'
    );
    insert mbrGrpRole;
    Mkt_Site_User__c mktSiteUser = new Mkt_Site_User__c();
    mktSiteUser.Contact__c = con.Id;
    mktSiteUser.Mbr_Group__c = mg2.Id;
    insert mktSiteUser;
  }

  static testMethod void defaultTest() {
    test.startTest();
    Contact_Grp_Rollup_Bch testing = new Contact_Grp_Rollup_Bch(null);
    DataBase.executeBatch(testing);
    test.stopTest();
    system.assertEquals(
      12,
      [SELECT Group_Count__c FROM Contact].Group_Count__c
    );
  }

  static testMethod void sameCountDefaultTest() {
    Contact con = [SELECT Id FROM Contact];
    con.Group_Count__c = 12;
    update con;
    test.startTest();
    Contact_Grp_Rollup_Bch testing = new Contact_Grp_Rollup_Bch(null);
    DataBase.executeBatch(testing);
    test.stopTest();
    system.assertEquals(
      12,
      [SELECT Group_Count__c FROM Contact].Group_Count__c
    );
  }

  static testMethod void customTest() {
    List<Mbr_Group__c> mglist = [SELECT id FROM Mbr_Group__c];
    test.startTest();
    Contact_Grp_Rollup_Bch testing = new Contact_Grp_Rollup_Bch(
      'SELECT Id, Group_Count__c, AccountId FROM Contact WHERE marketing_site_user__c = TRUE'
    );
    DataBase.executeBatch(testing);
    test.stopTest();
    system.assertEquals(
      12,
      [SELECT Group_Count__c FROM Contact].Group_Count__c
    );
  }
}