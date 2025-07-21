@IsTest
private class MemberGroupRoleController_Test {
  @IsTest
  static void testBehavior() {
    Account umrAcct = TestDataFactory.createUMR();
    Account a = new Account(Name = 'Aetna', Source__c = 'HUB');
    insert a;
    Account b = new Account(Name = 'Aetna 1', Source__c = 'HUB');
    insert b;

    Mbr_Group__c g = new Mbr_Group__c(
      Name__c = 'test1',
      Client_Account__c = a.Id,
      Active_Date__c = Date.today()
    );
    insert g;

    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = b.Id,
      Mbr_Group__c = g.Id
    );
    insert r;

    Test.startTest();
    // Test group page
    ApexPages.StandardController sc = new ApexPages.StandardController(
      new Mbr_Group__c()
    );
    MemberGroupRoleController mc = new MemberGroupRoleController(sc);
    mc.setActiveDate();
    mc.addRole(); // force error adding a role

    mc.selGroup.Name__c = 'test2';
    mc.selGroup.Client_Account__c = a.Id;
    mc.selGroup.Active_Date__c = Date.today();

    // should be an error, since no new group info set
    mc.save();

    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Role_Type__c = null;
    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.addRole(); // force error adding a role

    mc.save();
    mc.cancel();

    mc.selRoleId = mc.newRoleWrapper.role.Id;
    mc.deleteRole();

    Test.setCurrentPageReference(Page.MemberGroup);
    ApexPages.currentPage().getParameters().put('gid', g.Id);
    sc = new ApexPages.StandardController(g);

    mc = new MemberGroupRoleController(sc);
    mc.newRoleWrapper.role.Source_Account__c = null;
    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = null;
    mc.addRole(); // force error adding a role
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Eligibility Provider';
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'ASO/TPA';
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Contractee';
    ApexPages.currentPage().getParameters().put('retURL', '/' + g.Id);
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Eligibility Provider';
    mc.addRole(); // force error adding a role
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = g.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'NotaRole';
    mc.addRole(); // force error adding a role
    mc.save();

    mc.selRoleIndex = 2;
    mc.deleteRole();

    mc.selGroup.Logo_Tag_ID__c = 'biu';
    mc.selGroup.Logo1_ID__c = 'biu';
    mc.selGroup.Logo2_ID__c = 'biu';
    mc.selGroup.Logo3_ID__c = 'biu';
    mc.selGroup.AltLogo1_ID__c = 'biu';
    mc.selGroup.AltLogo2_ID__c = 'biu';
    mc.validateLogos();
    // force a nasty error
    try {
      mc.selGroup = g;
      mc.newRoleWrapper.role.Source_Account__c = g.Id;
      mc.newRoleWrapper.role.Role_Type__c = 'Broker';

      mc.addRole();
      mc.save();
    } catch (Exception e) {
      System.assert(!String.isBlank(e.getMessage()));
    }

    // Test redirect
    sc = new ApexPages.StandardController(r);
    MemberGroupRedirectExtension mgr = new MemberGroupRedirectExtension(sc);
    PageReference pageRef = Page.MemberGroupRedirect;
    pageRef.getParameters().put('id', r.Id);
    System.debug('RID:' + r.Id);
    Test.setCurrentPage(pageRef);
    mgr.redirect();
    delete r;
    mgr.redirect();

    // delete by Id
    Mbr_Group_Role__c roleToDelete = [SELECT Id FROM Mbr_Group_Role__c LIMIT 1];
    mc.selRoleId = roleToDelete.Id;
    mc.deleteRole();

    // Now make a new PSF
    mc.newPSF();

    // Test Cloning
    Test.setCurrentPageReference(Page.MemberGroup);
    ApexPages.currentPage().getParameters().put('id', g.Id);
    ApexPages.currentPage().getParameters().put('clone', '1');
    ApexPages.currentPage().getParameters().put('retURL', '/' + g.Id);

    sc = new ApexPages.StandardController(g);
    mc = new MemberGroupRoleController(sc);
    mc.selGroup.Name__c = 'newClone';
    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Benefit Sponsor';
    mc.addRole();
    mc.save();
    Test.stopTest();
  }

  @IsTest
  static void testBehavior2() {
    Account umrAcct = TestDataFactory.createUMR();
    Account a = new Account(Name = 'Aetna', Source__c = 'HUB');
    insert a;
    Account b = new Account(Name = 'Aetna 1', Source__c = 'HUB');
    insert b;

    Mbr_Group__c g = new Mbr_Group__c(
      Name__c = 'test1',
      Client_Account__c = a.Id,
      Active_Date__c = Date.today()
    );
    insert g;

    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = b.Id,
      Mbr_Group__c = g.Id
    );
    insert r;

    logo_setting__c ls = logo_setting__c.getOrgDefaults();
    ls.isDocument__c = true;
    insert ls;

    Test.startTest();
    // Test group page
    ApexPages.StandardController sc = new ApexPages.StandardController(
      new Mbr_Group__c()
    );
    MemberGroupRoleController mc = new MemberGroupRoleController(sc);
    mc.setActiveDate();
    mc.addRole(); // force error adding a role

    mc.selGroup.Name__c = 'test2';
    mc.selGroup.Client_Account__c = a.Id;
    mc.selGroup.Active_Date__c = Date.today();

    // should be an error, since no new group info set
    mc.save();

    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Role_Type__c = null;
    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.addRole(); // force error adding a role

    mc.save();
    mc.cancel();

    mc.selRoleId = mc.newRoleWrapper.role.Id;
    mc.deleteRole();

    Test.setCurrentPageReference(Page.MemberGroup);
    ApexPages.currentPage().getParameters().put('gid', g.Id);
    sc = new ApexPages.StandardController(g);

    mc = new MemberGroupRoleController(sc);
    mc.newRoleWrapper.role.Source_Account__c = null;
    mc.newRoleWrapper.role.Role_Type__c = 'Broker';
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = null;
    mc.addRole(); // force error adding a role
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Eligibility Provider';
    mc.addRole(); // force error adding a role

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'ASO/TPA';
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Contractee';
    ApexPages.currentPage().getParameters().put('retURL', '/' + g.Id);
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Eligibility Provider';
    mc.addRole(); // force error adding a role
    mc.save();

    mc.newRoleWrapper.role.Source_Account__c = g.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'NotaRole';
    mc.addRole(); // force error adding a role
    mc.save();

    mc.selRoleIndex = 2;
    mc.deleteRole();

    mc.selGroup.Logo_Tag_ID__c = 'biu';
    mc.selGroup.Logo1_ID__c = 'biu';
    mc.selGroup.Logo2_ID__c = 'biu';
    mc.selGroup.Logo3_ID__c = 'biu';
    mc.selGroup.AltLogo1_ID__c = 'biu';
    mc.selGroup.AltLogo2_ID__c = 'biu';
    mc.validateLogos();
    // force a nasty error
    try {
      mc.selGroup = g;
      mc.newRoleWrapper.role.Source_Account__c = g.Id;
      mc.newRoleWrapper.role.Role_Type__c = 'Broker';

      mc.addRole();
      mc.save();
    } catch (Exception e) {
      System.assert(!String.isBlank(e.getMessage()));
    }

    // Test redirect
    sc = new ApexPages.StandardController(r);
    MemberGroupRedirectExtension mgr = new MemberGroupRedirectExtension(sc);
    PageReference pageRef = Page.MemberGroupRedirect;
    pageRef.getParameters().put('id', r.Id);
    System.debug('RID:' + r.Id);
    Test.setCurrentPage(pageRef);
    mgr.redirect();
    delete r;
    mgr.redirect();

    // delete by Id
    Mbr_Group_Role__c roleToDelete = [SELECT Id FROM Mbr_Group_Role__c LIMIT 1];
    mc.selRoleId = roleToDelete.Id;
    mc.deleteRole();

    // Now make a new PSF
    mc.newPSF();

    // Test Cloning
    Test.setCurrentPageReference(Page.MemberGroup);
    ApexPages.currentPage().getParameters().put('id', g.Id);
    ApexPages.currentPage().getParameters().put('clone', '1');
    ApexPages.currentPage().getParameters().put('retURL', '/' + g.Id);

    sc = new ApexPages.StandardController(g);
    mc = new MemberGroupRoleController(sc);
    mc.selGroup.Name__c = 'newClone';
    mc.newRoleWrapper.role.Source_Account__c = b.Id;
    mc.newRoleWrapper.role.Role_Type__c = 'Benefit Sponsor';
    mc.addRole();
    mc.save();
    Test.stopTest();
  }
}