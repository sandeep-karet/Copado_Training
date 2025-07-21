@isTest
private class OpportunityPastDateAlerts_Test {
  @TestSetup
  static void setup() {
    //create an account record
    Account accObj = TestDataFactory.createAccount();
    insert accObj;

    //create an opportunity record
    Opportunity oppObj = TestDataFactory.createOpportunity(accObj.Id);
    oppObj.CloseDate = Date.Today().addDays(-3);
    oppObj.Decision_Date__c = Date.Today().addDays(-3);
    insert oppObj;
  }

  static testMethod void test() {
    Test.startTest();
    OpportunityPastDateAlerts objPDA = new OpportunityPastDateAlerts();
    Database.BatchableContext bc;
    SchedulableContext sc;
    objPDA.start(bc);
    objPDA.execute(
      bc,
      [
        SELECT Id, ManagerId, Manager.Email
        FROM User
        WHERE id = :userInfo.getUserId()
      ]
    );
    objPDA.finish(bc);

    Test.stopTest();
  }
  @isTest
  public static void test1() {
    User u = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
      .Id,
      LastName = 'last',
      Email = 'puser000@amamama.com',
      Username = 'puser000@amamama.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert u;
    Opportunity testOpportunity = new Opportunity(
      CloseDate = Date.today().adddays(5),
      Name = 'Test Opportunity Triggers',
      Sub_Channel__c = 'Employer - West Client Sales',
      stagename = 'Prospect', //'Contracting',
      ownerid = u.id,
      Benefit_Consultant_Involved_in_Deal__c = 'No',
      Initial_of_Lives__c = 10,
      pricebook2Id = test.getStandardPricebookId()
      //SBQQ__PrimaryQuote__c = 'test'
    );
    insert testOpportunity;
    //testOpportunity.Contract_Path__c = System.Label.TD_Teladoc_Account;
    account acc = new account(name = 'test');
    insert acc;

    Product2 p = new product2(name = 'x');
    insert p;

    Product2 p2 = new product2(name = 'y');
    insert p2;

    //define the standart price for the product
    //insert new PricebookEntry(pricebook2id = test.getStandardPricebookId(), product2id = p.id,unitprice=1.0, isActive=true);

    Pricebook2 pb = new pricebook2(name = 'test');
    insert pb;

    PricebookEntry pbe = new PricebookEntry(
      pricebook2id = test.getStandardPricebookId(),
      product2id = p.id,
      unitprice = 1.0,
      isActive = true
    );
    insert pbe;

    OpportunityLineItem testOLI = new OpportunityLineItem(
      OpportunityId = testOpportunity.Id,
      Quantity = 20,
      TotalPrice = 20,
      PricebookEntryId = pbe.id
      // Any other data you need
    );
    insert testOLI;
    testOpportunity.stagename = 'Review/Negotiation';
    update testOpportunity;
    //Must have products in Review/Negotiation, Contracting, and Closed Won stages.
    Test.startTest();
    //SchedulableMonthlyEmail s=new SchedulableMonthlyEmail();
    //s.execute(null) ;
    OpportunityPastDateAlerts objPDA = new OpportunityPastDateAlerts();
    Database.BatchableContext bc;
    SchedulableContext sc;
    objPDA.start(bc);
    objPDA.execute(
      bc,
      [SELECT Id, ManagerId, Manager.Email FROM User WHERE id = :u.id]
    );
    objPDA.finish(bc);

    Test.stopTest();
  }
}