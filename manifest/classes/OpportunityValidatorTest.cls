/**
 * Created by amruthakommuri on 2019-06-17.
 */

@isTest
public with sharing class OpportunityValidatorTest {
  //Defined test dataset
  @testSetup
  static void setupdata() {
    //create an account record
    Account accObj = TestDataFactory.createAccountUMR();

    List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();

    Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
    insert acctRel1;

    Id pricebookId = Test.getStandardPricebookId();

    //Create Quota Record
    Quotas__c quota = new Quotas__c();
    quota.ARR_Quotas_Amount__c = 1000;
    quota.IYR_Quotas_Amount__c = 2000;
    quota.Quotas_Owner__c = UserInfo.getUserId();
    quota.role__c = 'System Administrator';
    quota.Ending_Date__c = date.today().addMonths(3);
    quota.Starting_Date__c = date.today();
    insert quota;

    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunity(accObj.Id);
    oppObj.Pricebook2Id = pricebookId;
    oppObj.Benefit_Consultant_Involved_in_Deal__c = 'NO';
    oppObj.LeadSource = 'Sales';
    oppObj.StageName = 'Prospect';
    oppObj.Quotas__c = quota.Id;
    oppObj.OwnerId = UserInfo.getUserId();
    insert oppObj;

    //create Gen Med product
    Product2 prod2 = TestDataFactory.createSingleProduct(
      'General Medical',
      'General Medical',
      'GM'
    );
    insert prod2;

    PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prod2 },
      pricebookId
    )[0];
    insert pbEntry;

    //Create a quote record
    SBQQ__Quote__c quoObj = TestDataFactory.createQuote(oppObj.Id);
    insert quoObj;

    SBQQ.TriggerControl.disable();
    //Create quotelines
    SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
      quoObj.Id,
      prod2.Id
    );
    insert quoline1;
  }

  @isTest
  public static void OpportunityContractingPassesValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
      Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opplist[0].id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;

    insert opl;
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u4 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'demo1@teladochealth.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testoppvalid4@teladochealth.com'
    );
    insert u4;
    System.runAs(u4) {
      opplist[0].Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
      opplist[0].StageName = 'Contracting';
      update opplist;
      opplist[0].CloseDate = Date.Today().AddDays(7);
      update opplist;

      System.AssertEquals(Date.Today().AddDays(7), opplist[0].CloseDate);
    }
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @isTest
  public static void OpportunityContractingFailsValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
     Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opplist[0].id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Operations'];
    User u3 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'demo1@teladochealth.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testoppvalid3@teladochealth.com'
    );
    insert u3;
    quolist[0].CPQ_Pricebook__c = 'Direct';
    update quolist;
    opplist[0].Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    opplist[0].StageName = 'Contracting';
    opplist[0].OwnerId = u3.Id;
    update opplist;
    System.runAs(u3) {
      try {
        opplist[0].CloseDate = Date.Today().AddDays(7);
        update opplist;
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains(
              'Only user with Contracting Permission or System Administrator modify opportunity after the CPQ Records are created.'
            )
          ? true
          : false;
        System.AssertEquals(false, expectedExceptionThrown);
      }
    }
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @isTest
  public static void OpportunityClosedWonPassesValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id, CloseDate FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
      Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opplist[0].id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u1 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'demo1@teladochealth.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testoppvalid1@teladochealth.com'
    );
    insert u1;
    System.runAs(u1) {
      quolist[0].CPQ_Pricebook__c = 'Direct';
      update quolist;
     opplist[0].Contract_Path__c = accObj.Id;//System.Label.TD_Teladoc_Account;
      opplist[0].StageName = 'Closed Won';
      opplist[0].Contracted_Date__c = Date.Today().AddDays(3);
      opplist[0]
        .Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
      update opplist;
      // new validation rule prevent revenue date change
      //opplist[0].CloseDate = Date.Today().AddDays (7);
      //update opplist;

      System.assertEquals(Date.Today(), opplist[0].CloseDate);
      SBQQ.TriggerControl.enable();
      test.stopTest();
    }
  }

  @isTest
  public static void OpportunityClosedWonFailsValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id, CloseDate FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
      Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opplist[0].id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Operations'];
    User u2 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'demo1@teladochealth.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testoppvalid2@teladochealth.com'
    );
    insert u2;
    quolist[0].CPQ_Pricebook__c = 'Direct';
    update quolist;
    opplist[0].Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    opplist[0].StageName = 'Closed Won';
    opplist[0].Contracted_Date__c = Date.Today().AddDays(3);
    opplist[0].OwnerId = u2.Id;
    opplist[0]
      .Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';

    update opplist;
    System.runAs(u2) {
      try {
        opplist[0].CloseDate = Date.Today().AddDays(7);
        update opplist;
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains(
              'Only System Administrators can edit a Closed Won Opportunity.'
            )
          ? true
          : false;
        System.AssertEquals(true, expectedExceptionThrown);
      }
    }
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  //Test case for Contractee Relationship validation for Contracting/Closed Won Stage Change
  @isTest
  static void opportunityStageValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
      Account accObj = TestDataFactory.createAccountUMR();
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opplist[0].id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    //        List<Account> acclist =[select id from Account ];
    //        List<Acct_Rel__c> acctRellist =[select id from Acct_Rel__c];

    //        Acct_Rel__c acctRel3 = new Acct_Rel__c();
    //        acctRel3.Benefit_Sponsor__c = acclist[0].Id;
    //        acctRel3.Svc_Acct__c = acclist[0].Id;
    //        acctRel3.Relationship_Type__c = 'Contractee';
    //        acctRel3.Start_Date__c = Date.Today();
    //
    //        insert acctRel3;
    opplist[0]
      .Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
    opplist[0].Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    opplist[0].StageName = 'Closed Won';
    opplist[0].Contracted_Date__c = Date.Today();
    update opplist;

    system.assertEquals('Closed Won', opplist[0].StageName);
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  //Test case for Contractee Relationship validation for Contracting/Closed Won Stage Change
  @isTest
  static void opportunityStageErrorValidation() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    List<Account> acclist = [SELECT id FROM Account];
     Account accObj = TestDataFactory.createAccountUMR();
    List<Acct_Rel__c> acctRellist = [SELECT id FROM Acct_Rel__c];

    try {
      opplist[0].Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
      opplist[0].StageName = 'Contracting';
      update opplist;
    } catch (Exception e) {
      //Below values will be deprecated later for Contract Path LOB functionality
      //Boolean expectedExceptionThrown =  e.getMessage().contains('No Contractee relationship exists on account')?true : false;
      //System.AssertEquals(expectedExceptionThrown, true);
    }
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  //Test case for Contractee Relationship validation for Contracting/Closed Won Stage Change
  @isTest
  static void OppRFPCreateTest() {
    test.startTest();
    SBQQ.TriggerControl.disable();
      Account accObj = TestDataFactory.createAccountUMR();
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    opp.Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    opp.StageName = 'Proposal';
    update opp;
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opp.id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    RFP__c rfp = new RFP__c(
      Opportunity__c = opp.id,
      Opportunity_plan__c = 'No',
      Relationship_map__c = 'No',
      Due_Date__c = Date.Today().addDays(30),
      Release_Date__c = Date.Today().addDays(15)
    );
    Database.insert(rfp);
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  //Test case for enabling RFP finalist Checkbox on Opportunity
  @isTest
  static void OppRFPFinalistTest() {
    test.startTest();
    SBQQ.TriggerControl.disable();
       Account accObj = TestDataFactory.createAccountUMR();
    Opportunity opp = [
      SELECT Id, stageName, RFP_Finalist__c, RFP_Count__c
      FROM Opportunity
      LIMIT 1
    ];
    opp.Contract_Path__c = accObj.Id;//System.Label.TD_Teladoc_Account;
    opp.StageName = 'Proposal';
    update opp;
    PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
    OpportunityLineItem opl = new OpportunityLineItem();
    opl.OpportunityId = opp.Id;
    opl.Quantity = 500;
    opl.PricebookEntryId = pbEntry.Id;
    opl.TotalPrice = 500 * pbEntry.UnitPrice;
    insert opl;
    RFP__c rfp = new RFP__c(
      Opportunity__c = opp.Id,
      Opportunity_plan__c = 'No',
      Relationship_map__c = 'No',
      Due_Date__c = Date.Today().addDays(30),
      Release_Date__c = Date.Today().addDays(15)
    );
    Database.insert(rfp);

    opp.Contracted_Date__c = Date.today();
    opp.Contract_Service_Agreement_Status__c = 'Executed';
    opp.StageName = 'Closed Won';
    update opp;

    Opportunity oppAfterUpdate = [
      SELECT Id, stageName, RFP_Finalist__c, RFP_Count__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];
    //Verify if the RFP Finalist checkbox on Opp is updated to True
    System.assertEquals(true, oppAfterUpdate.RFP_Finalist__c);
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @isTest
  static void validateQuoteTotalSumFields() {
    test.startTest();
    SBQQ.TriggerControl.disable();   
    //Getting Test user
    List<String> lstUsernames = System.Label.TeladocHealth_SF_Support_Users.replaceAll(
        '\\s+',
        ''
      )
      .split(',');
    List<User> result = [
      SELECT Id, Name, lastname, firstname, username, email
      FROM User
      WHERE IsActive = TRUE AND profile.name='System Administrator' //username IN :lstUsernames
      ORDER BY LastName ASC
      LIMIT 1
    ];

    Opportunity opp = [SELECT Id, Quotas__c FROM Opportunity LIMIT 1];
    //create Quota record
    Quotas__c quota = new Quotas__c();
    quota.ARR_Quotas_Amount__c = 1000;
    quota.IYR_Quotas_Amount__c = 2000;
    quota.Quotas_Owner__c = result[0].id;
    quota.Ending_Date__c = date.today().addMonths(3);
    quota.Starting_Date__c = date.today();
    insert quota;

    opp.Quotas__c = quota.Id;
    update opp;
    SBQQ.TriggerControl.enable();
    test.stopTest();
    List<Quotas__c> quotas_inserted = [
      SELECT Id, Current_Total_ARR__c, Current_Total_IYR__c
      FROM Quotas__c
      WHERE Quotas_Owner__c = :result[0].id
    ];
    //System.assertEquals(2000, quotas_inserted[0].Current_Total_ARR__c,'failed in arr');
    //System.assertEquals(4000, quotas_inserted[0].Current_Total_IYR__c,'failed in iyr');
  }

  //Test case for validateContractingOpp method
  @isTest
  static void validateContractingOpp_positive() {
    test.startTest();
    SBQQ.TriggerControl.disable();
      Account accObj = TestDataFactory.createAccountUMR();
    Opportunity opp = [
      SELECT Id, stageName, RFP_Finalist__c, RFP_Count__c
      FROM Opportunity
      LIMIT 1
    ];
    opp.Contract_Path__c =accObj.Id; //System.Label.TD_Teladoc_Account;
    opp.StageName = 'Proposal';
    opp.SBQQ__Contracted__c = true;

    update opp;

    opp.Contracted_Date__c = Date.today();
    opp.StageName = 'Contracting';
    update opp;
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }
}