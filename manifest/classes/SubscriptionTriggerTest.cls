@IsTest
private class SubscriptionTriggerTest {
  @TestSetup
  static void setup() {
    //create an account record
    Account umrAcct = TestDataFactory.createUMR();
    Account accObj = TestDataFactory.createAccountUMR();

    Mbr_Group__c mbrGrp = TestDataFactory.createMbrGroup(accObj.Id)[0];

    //create an opportunity record
    Opportunity opp = TestDataFactory.createOpportunity(accObj.Id);
    opp.LeadSource = 'Sales';
    insert opp;

    SBQQ__Quote__c sbqqQte = TestDataFactory.createQuote(opp.Id);
    insert sbqqQte;

    //create Gen Med - Consult Fee product
    Product2 prod = TestDataFactory.createSingleProduct(
      'GM - Consult Fee',
      'General Medical',
      'GMCF'
    );
    insert Prod;

    SBQQ__QuoteLine__c quoline = TestDataFactory.createQuoteLine(
      sbqqQte.Id,
      prod.Id
    );
    insert quoline;

    //create a contract
    Contract cont = TestDataFactory.createContractNoInsert(
      accObj.Id,
      opp.id,
      null
    );
    cont.Status = 'Draft';
    cont.CurrencyIsoCode = 'USD';
    cont.StartDate = Date.Today();
    cont.ContractTerm = 12;
    insert cont;

    //Gen Med
    SBQQ__Subscription__c sub = TestDataFactory.createSub(
      accObj.Id,
      cont.id
    )[0];

    //Create Assets

    Asset asset1 = TestDataFactory.createAssetNoInsert(
      'GM - Consult Fee',
      49,
      accObj.Id,
      null,
      prod.Id,
      sub.Id
    );
    asset1.Quantity = 500;
    asset1.CurrencyIsoCode = 'USD';
    asset1.SBQQ__QuoteLine__c = quoline.Id;
    insert asset1;

    Plan_Specific_Fees__c psf = new Plan_Specific_Fees__c();
    psf.Member_Group__c = mbrGrp.Id;
    psf.Subscription__c = sub.Id;
    psf.Product_Start_Date__c = system.today();
    psf.Consult_Fee_Mbr_Pd__c = 49;
    insert psf;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u1 = TestDataFactory.createUser(p.Id);
    u1.Alias = 'standt1';
    insert u1;
  }

  // delete sub with contract, asset and psf
  @IsTest
  static void deleteSub1() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      String error;
      SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c];
      try {
        delete sub;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(
        true,
        error.contains('1 PSF 1 Asset associated to this subscription.')
      );
    }
    test.stopTest();
  }

  @IsTest
  static void deleteContract() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
        SetupOwnerId = UserInfo.getUserId(),
        User_Permission__c = true
      );
      insert objDS;
      Contract cont = [SELECT Id FROM Contract];
      String error;
      try {
        delete cont;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(
        true,
        error.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
      );
    }
    test.stopTest();
  }

  // delete contract with sub contain psf and asset
  @IsTest
  static void deleteContract2() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
        SetupOwnerId = UserInfo.getUserId(),
        User_Permission__c = true
      );
      insert objDS;
      Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
      delete psf;
      Contract cont = [SELECT Id FROM Contract];
      String error;
      try {
        delete cont;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(
        true,
        error.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
      );
    }
    test.stopTest();
  }

  // delete sub with contract and assets
  @IsTest
  static void deleteSub2() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
        SetupOwnerId = UserInfo.getUserId(),
        User_Permission__c = true
      );
      insert objDS;
      Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
      delete psf;
      String error;
      SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c];
      try {
        delete sub;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(
        true,
        error.contains('1 Asset associated to this subscription.')
      );
    }
    test.stopTest();
  }

  //delete sub with contract psf
  @IsTest
  static void deleteSub3() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
        SetupOwnerId = UserInfo.getUserId(),
        User_Permission__c = true
      );
      insert objDS;
      SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c];
      Mbr_Group__c mbrGrp = [SELECT Id FROM Mbr_Group__c LIMIT 1];
      Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
      delete psf;
      Asset asset = [SELECT Id FROM Asset];
      delete asset;
      Plan_Specific_Fees__c psf2 = new Plan_Specific_Fees__c();
      psf2.Member_Group__c = mbrGrp.Id;
      psf2.Subscription__c = sub.Id;
      psf2.Product_Start_Date__c = system.today();
      insert psf2;
      String error;
      try {
        delete sub;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(
        true,
        error.contains('1 PSF associated to this subscription.')
      );
    }
    test.stopTest();
  }

  //delete asset without psf
  @IsTest
  static void deleteAsset2() {
    test.startTest();
    User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
    list<Group> group1 = [SELECT id, name FROM Group WHERE Name = 'All Users'];
    GroupMember gm = new GroupMember();
    gm.GroupId = group1[0].id;
    gm.UserOrGroupId = u1.id;
    insert gm;
    System.runAs(u1) {
      PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
        SetupOwnerId = UserInfo.getUserId(),
        User_Permission__c = true
      );
      insert objDS;
      Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
      delete psf;
      Asset asset = [SELECT Id FROM Asset];
      String error;
      try {
        delete asset;
        error = null;
      } catch (exception e) {
        error = string.valueOf(e);
      }
      system.assertEquals(null, error);
    }
    test.stopTest();
  }
}