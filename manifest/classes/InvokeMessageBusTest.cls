@istest
public class InvokeMessageBusTest {
  @testSetup
  public static void setup() {
    list<Product2> prodlist = new List<Product2>();
    //create an Account
    Account accObj = TestDataFactory.createAccount();
    insert accObj;
    List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();

    Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
    acctRel1.Benefit_Sponsor__c = accObj.Id;
    insert acctRel1;

    LVGO__Account__c lvgoAccount = new LVGO__Account__c();
    lvgoAccount.Name = 'Livongo';
    lvgoAccount.LVGO__TD_Acct_Guid__c = 'FD5E35E0-5175-D1CB-06B8-B48C018EA7C9';
    insert lvgoAccount;

    LVGO__Opportunity__c lvopp = new LVGO__Opportunity__c();
    lvopp.Name = 'Test Opportunity ';
    lvopp.LVGO__StageName__c = 'Prospect';
    lvopp.LVGO__Type__c = 'Renewal';
    lvopp.LVGO__CloseDate__c = Date.today().addDays(1);
    lvopp.LVGO__LeadSource__c = 'Other';
    lvopp.LVGO__Account__c = lvgoAccount.Id;
    lvopp.LVGO__TD_Opp_Guid__c = '416805C1-85B3-D317-121B-B939FA02A645';
    insert lvopp;

    Pricebook2 livongoPricebook = new Pricebook2(
      Name = 'Livongo',
      IsActive = true
    );
    insert livongoPricebook;

    Id StandardPricebook = Test.getStandardPricebookId();
    Pricebook2 TeladocPriceBook = new Pricebook2(
      Name = 'Teladoc Price Book',
      IsActive = true
    );
    insert TeladocPriceBook;
    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunity(accObj.Id);
    oppObj.Pricebook2Id = TeladocPriceBook.Id;
    oppObj.Benefit_Consultant_Involved_in_Deal__c = 'NO';
    oppObj.LeadSource = 'Sales';
    oppObj.StageName = 'Discovery';
    insert oppObj;

    // create a chronic care Product
    Product2 prod1 = TestDataFactory.createSingleProduct(
      'Prediabetes Management',
      'Chronic Care - Prediabetes',
      'DIABP'
    );
    prodlist.add(Prod1);
    insert Prodlist;

    PricebookEntry[] spbEntry = TestDataFactory.createPriceBookEntries(
      Prodlist,
      StandardPricebook
    );
    insert spbEntry;
    PricebookEntry[] tpbEntry = TestDataFactory.createPriceBookEntries(
      Prodlist,
      TeladocPriceBook.Id
    );
    insert tpbEntry;
  }

  @isTest
  public static void testMBInvoke() {
    Message_Bus_Toggle__c MB = Message_Bus_Toggle__c.getOrgDefaults();
    MB.Enable_MB_LV_Island__c = true;
    MB.Enable_MB_LV_Org__c = false;
    MB.Enable_MB__c = true;
    MB.Error_Email_Enable__c = true;

    insert MB;
    Test.StartTest();
    List<Id> oppIds = new List<Id>();
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1 FOR UPDATE];
    opp.StageName = 'Closed Won';
    update Opp;
    oppIds.add(Opp.Id);
    InvokeMessageBus.OppInvokeMB(oppIds);
    Test.StopTest();
  }
  @isTest
  public static void testMBInvokeLVOrg() {
    Test.setMock(HttpCalloutMock.class, new MB_MockIncomingQ_Test());
    Message_Bus_Toggle__c MB = Message_Bus_Toggle__c.getOrgDefaults();
    MB.Enable_MB_LV_Island__c = false;
    MB.Enable_MB_LV_Org__c = true;
    MB.Enable_MB__c = true;
    MB.Error_Email_Enable__c = true;

    insert MB;
    Test.StartTest();
    List<Id> oppIds = new List<Id>();
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1 FOR UPDATE];
    opp.StageName = 'Closed Won';
    update Opp;
    oppIds.add(Opp.Id);
    InvokeMessageBus.OppInvokeMB(oppIds);
    Test.StopTest();
  }
}