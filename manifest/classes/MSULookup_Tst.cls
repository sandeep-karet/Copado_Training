@IsTest
public with sharing class MSULookup_Tst {
  public static testMethod void testMSULookup() {
    Account umrAcct = TestDataFactory.createUMR();
    Account aRef = new Account(Export_Id__c = 'TestAcct1234');
    Account a2Ref = new Account(Export_Id__c = 'TestAcct9876');
    Account a = new Account(
      Name = 'BioHorizons Implant Systems, Inc',
      Export_Id__c = 'TestAcct1234',
      Source__c = 'HUB'
    );
    Account a2 = new Account(
      Name = 'Sobobo Implant Systems, Inc',
      Export_Id__c = 'TestAcct9876',
      Source__c = 'HUB'
    );
    Contact tmpCon = new Contact(
      FirstName = 'Mrs',
      LastName = 'User',
      Marketing_Site_Username__c = 'eufbe',
      Email = 'Test.User@teladoc.com',
      Marketing_Site_User__c = true,
      Account = a2Ref,
      Contact_Status__c = 'Active'
    );
    Contact tmpCon2 = new Contact(
      FirstName = 'Mr',
      LastName = 'User2',
      Email = 'Test.User2@teladoc.com',
      Marketing_Site_User__c = true,
      Account = aRef,
      Contact_Status__c = 'Inactive - Deceased'
    );
    Contact tmpCon3 = new Contact(
      FirstName = 'Mr',
      LastName = 'Delme',
      Email = 'Test.User2@teladoc.com',
      Marketing_Site_User__c = true,
      Account = aRef,
      Contact_Status__c = 'Active'
    );
    Contact tmpCon4 = new Contact(
      FirstName = 'Mrs',
      LastName = 'Notanmsu',
      Marketing_Site_Username__c = 'eufbfeefe',
      Email = 'Test.User@teladoc.com',
      Marketing_Site_User__c = false,
      Account = a2Ref,
      Contact_Status__c = 'Active'
    );
    Mbr_Group__c tmpGroup = new Mbr_Group__c(
      Name__c = 'Test Group',
      Client_Account__r = aRef,
      Status__c = 'ACTIVE'
    );
    Mbr_Group__c tmpGroup2 = new Mbr_Group__c(
      Name__c = 'Te2st Group',
      Client_Account__r = a2Ref,
      Status__c = 'ACTIVE'
    );
    Database.insert(
      new List<SObject>{
        a,
        a2,
        tmpCon,
        tmpCon2,
        tmpGroup,
        tmpGroup2,
        tmpCon3,
        tmpCon4
      }
    );

    Mbr_Group_Role__c mgr = new Mbr_Group_Role__c();
    mgr.Mbr_Group__c = tmpGroup.Id;
    mgr.Role_Type__c = 'Payer';
    mgr.Source_Contact__c = tmpCon.Id;
    mgr.Source_Account__c = a2.Id;
    insert mgr;

    delete tmpCon3;
    List<Mkt_Site_User__c> dupeBatch = new List<Mkt_Site_User__c>();
    Mkt_Site_User__c msug = new Mkt_Site_User__c();
    msug.Contact__c = tmpCon2.Id;
    msug.Mbr_Group__c = tmpGroup2.Id;

    try {
      insert msug;
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
    // try to flag dupe error for existing and batch

    msug = new Mkt_Site_User__c();
    msug.Contact__c = tmpCon2.Id;
    msug.Mbr_Group__c = tmpGroup2.Id;
    dupeBatch.add(msug);

    msug = new Mkt_Site_User__c();
    msug.Contact__c = tmpCon.Id;
    msug.Mbr_Group__c = tmpGroup2.Id;
    dupeBatch.add(msug);

    msug = new Mkt_Site_User__c();
    msug.Contact__c = tmpCon.Id;
    msug.Mbr_Group__c = tmpGroup2.Id;
    dupeBatch.add(msug);

    try {
      insert dupeBatch;
    } catch (Exception e) {
      System.debug(e.getMessage());
    }

    Test.startTest();

    PageReference pageRef = Page.MSULookup;
    Test.setCurrentPage(pageRef);

    pageRef.getParameters().put('gid', tmpGroup.Id);
    MSULookupController mc = new MSULookupController();
    mc.searchContactName = 'mrs';
    mc.filterContacts();
    mc.searchContactName = 'mr';
    mc.filterContacts();
    mc.searchContactName = '';
    mc.filterContacts();

    PageReference pageRef2 = Page.MSULookup;
    pageRef2.getParameters().put('cid', tmpCon.Id);
    Test.setCurrentPage(pageRef2);

    System.debug('CON ID-->' + tmpCon.Id);

    mc = new MSULookupController();
    mc.searchGroupName = '';
    mc.filterGroups();
    mc.searchGroupName = 'fail';
    mc.filterGroups();
    mc.searchGroupName = 'Test';
    mc.filterGroups();

    PageReference pageRef3 = Page.MSULookup;
    pageRef3.getParameters().put('cid', tmpCon2.Id);
    Test.setCurrentPage(pageRef3);

    // Test Deleted ID
    PageReference pageRef4 = Page.MSULookup;
    pageRef4.getParameters().put('cid', tmpCon3.Id);
    Test.setCurrentPage(pageRef4);
    MSULookupController mc2 = new MSULookupController();
    System.debug('sel contact:' + mc2.selContactId + ' -> ' + mc2.selContact);

    PageReference pageRef5 = Page.MSULookup;
    Test.setCurrentPage(pageRef5);
    pageRef5.getParameters().put('gid', null);
    pageRef5.getParameters().put('cid', null);
    MSULookupController mc4 = new MSULookupController();
    System.assert(mc4.selContact == null);

    PageReference pageRef6 = Page.MSULookup;
    pageRef6.getParameters().put('cid', tmpCon4.Id);
    Test.setCurrentPage(pageRef6);
    MSULookupController mc3 = new MSULookupController();
    System.debug('sel contact:' + mc3.selContactId + ' -> ' + mc3.selContact);
    Test.stopTest();
  }
}