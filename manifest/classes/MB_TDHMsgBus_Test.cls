@IsTest
private class MB_TDHMsgBus_Test {
  @TestSetup
  public static void setup() {
    Message_Bus_Toggle__c MB = Message_Bus_Toggle__c.getOrgDefaults();
    MB.Enable_MB__c = true;
    MB.Error_Email_Enable__c = true;
    MB.Enable_MB_LV_Island__c = true;
    insert MB;
    Dev_Settings__c objDS = new Dev_Settings__c(
      SetupOwnerId = UserInfo.getUserId(),
      Disable_Triggers__c = true
    );
    insert objDS;
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Account umrAcct = new Account(
      Name = 'UMR',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Friendly_Account_Name__c = 'TestAmendAccount',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Account_Type__c = 'Health Plan'
    );
    insert umrAcct;

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

    Id pricebookId = Test.getStandardPricebookId();
    List<Opportunity> lstOpps = new List<Opportunity>();
    Opportunity oppObj = new Opportunity(
      Name = 'No Line Item',
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('Employer – Teladoc and HY Products')
        .getRecordTypeId(),
      AccountId = umrAcct.Id,
      Type = 'New Business',
      Business_Region__c = 'USA',
      CurrencyIsoCode = 'USD',
      StageName = 'Prospect',
      Probability = 10,
      Initial_of_Lives__c = 500,
      Fee_Type__c = 'PEPM',
      CloseDate = Date.Today(),
      Contracted_Date__c = Date.Today(),
      Pricebook2Id = pricebookId,
      LeadSource = 'Marketing',
      Decision_Date__c = Date.Today()
    );
    lstOpps.add(oppObj);

    Opportunity oppObj2 = new Opportunity(
      Name = 'Got Line Item',
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('Employer – Teladoc and HY Products')
        .getRecordTypeId(),
      isLVN__c = true,
      AccountId = umrAcct.Id,
      Type = 'New Business',
      Business_Region__c = 'USA',
      CurrencyIsoCode = 'USD',
      StageName = 'Prospect',
      Probability = 10,
      Initial_of_Lives__c = 500,
      Fee_Type__c = 'PEPM',
      Benefit_Consultant_Involved_in_Deal__c = 'No',
      CloseDate = Date.Today(),
      Contracted_Date__c = Date.Today(),
      Pricebook2Id = pricebookId,
      LeadSource = 'Marketing',
      Decision_Date__c = Date.Today()
    );

    lstOpps.add(oppObj2);

    insert lstOpps;

    List<Product2> prodList = new List<Product2>();
    Product2 prod1 = new Product2(
      Name = 'Livongo DIAB',
      ProductCode = 'DIAB',
      IsActive = true,
      Family = 'Livongo'
    );
    Product2 prod2 = new Product2(
      Name = 'Livongo BH',
      ProductCode = 'BH',
      IsActive = true,
      Family = 'Livongo'
    );
    Product2 prod3 = new Product2(
      Name = 'General Medical',
      ProductCode = 'GM',
      IsActive = true,
      Family = 'General Medical'
    );
    prodList.add(prod1);
    prodList.add(prod2);
    prodList.add(prod3);
    insert prodList;

    List<SBQQ__Quote__c> lstQts = new List<SBQQ__Quote__c>();
    SBQQ__Quote__c quoObj1 = new SBQQ__Quote__c(
      RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
        .get('Teladoc')
        .getRecordTypeId(),
      SBQQ__Opportunity2__c = oppObj.Id,
      SBQQ__Primary__c = true,
      Sales_Channels__c = 'US Employer',
      CPQ_Pricebook__c = 'Direct',
      Include_in_Octiv_Proposal__c = false
    );
    lstQts.add(quoObj1);

    SBQQ__Quote__c quoObj2 = new SBQQ__Quote__c(
      RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
        .get('Teladoc')
        .getRecordTypeId(),
      SBQQ__Opportunity2__c = oppObj2.Id,
      SBQQ__Primary__c = true,
      Sales_Channels__c = 'US Employer',
      CPQ_Pricebook__c = 'Direct',
      Include_in_Octiv_Proposal__c = false
    );
    lstQts.add(quoObj2);

    insert lstQts;

    /*
        List<SBQQ__QuoteLine__c> qteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoObj2.Id ,SBQQ__Product__c = prod1.Id, SBQQ__Quantity__c = 500, Consult_Type__c = 'Standard', SBQQ__PricingMethod__c = 'List',
                                                             CurrencyIsoCode = 'USD', SBQQ__Number__c = 1);
        qteLineList.add(quoline1);
        SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoObj2.Id ,SBQQ__Product__c = prod2.Id, SBQQ__Quantity__c = 500, Consult_Type__c = 'Standard', SBQQ__PricingMethod__c = 'List',
                                                             CurrencyIsoCode = 'USD', SBQQ__Number__c = 1);
        qteLineList.add(quoline2);
         SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoObj2.Id ,SBQQ__Product__c = prod3.Id, SBQQ__Quantity__c = 500, Consult_Type__c = 'Standard', SBQQ__PricingMethod__c = 'List',
                                                             CurrencyIsoCode = 'USD', SBQQ__Number__c = 1);
        qteLineList.add(quoline3); 
        
        insert qteLineList;
        */
    List<PricebookEntry> pbList = new List<PricebookEntry>();
    PricebookEntry pbEntry1 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod1.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    PricebookEntry pbEntry2 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod2.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    PricebookEntry pbEntry3 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod3.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    pbList.add(pbEntry1);
    pbList.add(pbEntry2);
    pbList.add(pbEntry3);
    insert pbList;

    /*
        List<OpportunityLineItem> oppLiList = new List<OpportunityLineItem>();
        OpportunityLineItem oppli = new OpportunityLIneItem(OpportunityId = oppObj2.Id, Quantity = 1, TotalPrice = 100, product2Id = prod1.Id, pricebookEntryId = pbEntry1.Id, SBQQ__QuoteLine__c = quoline1.Id);
        OpportunityLineItem oppli2 = new OpportunityLIneItem(OpportunityId = oppObj2.Id, Quantity = 1, TotalPrice = 100, product2Id = prod2.Id, pricebookEntryId = pbEntry2.Id, SBQQ__QuoteLine__c = quoline2.Id);
        OpportunityLineItem oppli3 = new OpportunityLIneItem(OpportunityId = oppObj2.Id, Quantity = 1, TotalPrice = 100, product2Id = prod3.Id, pricebookEntryId = pbEntry3.Id, SBQQ__QuoteLine__c = quoline3.Id);
        oppLiList.add(oppli);
        oppLiList.add(oppli2);
        oppLiList.add(oppli3);
        insert oppLiList;
        */

    delete objDS;
  }

  @IsTest
  static void NewUpdate() {
    Test.startTest();
    Dev_Settings__c objDS = new Dev_Settings__c(
      SetupOwnerId = UserInfo.getUserId(),
      Disable_Triggers__c = true
    );
    insert objDS;
    Opportunity oppWithProd = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Got Line Item'
    ];
    oppWithProd.StageName = 'Contracting';
    update oppWithProd;
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Id pricebookId = Test.getStandardPricebookId();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'No Line Item'];
    SBQQ__Quote__c quoObj1 = [
      SELECT Id
      FROM SBQQ__Quote__c
      WHERE SBQQ__Opportunity2__r.Name = 'No Line Item'
    ];
    Product2 prod1 = [SELECT Id FROM Product2 LIMIT 1];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c(
      SBQQ__Quote__c = quoObj1.Id,
      SBQQ__Product__c = prod1.Id,
      SBQQ__Quantity__c = 500,
      Consult_Type__c = 'Standard',
      SBQQ__PricingMethod__c = 'List',
      CurrencyIsoCode = 'USD',
      SBQQ__Number__c = 1
    );
    insert quoline1;
    List<Q_Item__c> beforeDeleteQlist = [SELECT Id FROM Q_Item__c];
    PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
    OpportunityLineItem oppli = new OpportunityLIneItem(
      OpportunityId = opp.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod1.Id,
      pricebookEntryId = pbEntry.Id,
      SBQQ__QuoteLine__c = quoline1.Id
    );
    insert oppli;
    List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    system.assertEquals(beforeDeleteQlist.size(), qlist.size());
    Test.stopTest();
  }

  @IsTest
  static void MsgQItemNoneAsyncOutgoing_Test() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockIncomingQ_Test());
    String body = '{"attributes": {"type": "Q_Item__c"},"Payload__c": "{}","ItemKey__c": "DE3C1C1E-5197-18DB-9539-27043fA22EB4","Status__c": "Pending","Src__c": "TDH","Dst__c": "LVN","Parser_Name__c": "parserName","Type__c":"Outgoing"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    Test.stopTest();
  }

  @isTest
  static void DeleteOppLine() {
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    test.startTest();
    Dev_Settings__c objDS = new Dev_Settings__c(
      SetupOwnerId = UserInfo.getUserId(),
      Disable_Triggers__c = true
    );
    insert objDS;

    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'No Line Item'];
    opp.StageName = 'Contracting';
    update opp;

    Id pricebookId = Test.getStandardPricebookId();
    //Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'No Line Item'];
    SBQQ__Quote__c quoObj1 = [
      SELECT Id
      FROM SBQQ__Quote__c
      WHERE SBQQ__Opportunity2__r.Name = 'No Line Item'
    ];
    Product2 prod1 = [SELECT Id FROM Product2 LIMIT 1];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c(
      SBQQ__Quote__c = quoObj1.Id,
      SBQQ__Product__c = prod1.Id,
      SBQQ__Quantity__c = 500,
      Consult_Type__c = 'Standard',
      SBQQ__PricingMethod__c = 'List',
      CurrencyIsoCode = 'USD',
      SBQQ__Number__c = 1
    );
    insert quoline1;
    PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
    OpportunityLineItem opplinew = new OpportunityLIneItem(
      OpportunityId = opp.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod1.Id,
      pricebookEntryId = pbEntry.Id,
      SBQQ__QuoteLine__c = quoline1.Id
    );
    insert opplinew;

    OpportunityLineItem oppli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
    delete oppli;
    test.stopTest();
    //List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    //system.assertEquals(1, qlist.size());
  }

  @isTest
  static void OppTrg() {
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Got Line Item'];
    opp.StageName = 'Contracting';
    update opp;
    test.stopTest();
    //List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    //system.assertEquals(1, qlist.size());
  }

  @isTest
  static void OppTrgIsLvn() {
    test.startTest();
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Got Line Item'];
    opp.StageName = 'Contracting';
    opp.isLVN__c = true;
    update opp;
    test.stopTest();
    //List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    //system.assertEquals(1, qlist.size());
  }

  @isTest
  static void OppTrgIsLvn2() {
    List<Id> oppIds = new List<Id>();
    test.startTest();
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Got Line Item'];
    opp.StageName = 'Closed Won';
    opp.isLVN__c = true;
    update opp;
    oppIds.add(Opp.Id);
    //InvokeMessageBus.OppInvokeMB(oppIds);
    test.stopTest();
    //List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    //system.assertEquals(1, qlist.size());
  }

  @IsTest
  static void skippingStage() {
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Id pricebookId = Test.getStandardPricebookId();
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Got Line Item'];

    opp.Contract_Service_Agreement_Status__c = 'Executed';
    opp.Contracted_Date__c = Date.Today();
    opp.StageName = 'Closed Won';
    try {
      update opp;
    } catch (exception e) {
      String error = e.getMessage();
      system.debug(e.getMessage());
      system.assertEquals(true, error.contains('Cannot move an Opportunity'));
    }
    test.stopTest();
  }

  @isTest
  static void DeleteOppTrg() {
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'No Line Item'];
    SBQQ__Quote__c q = [
      SELECT id
      FROM SBQQ__Quote__c
      WHERE SBQQ__Opportunity2__c = :opp.id
    ];
    q.SBQQ__Primary__c = false;
    update q;
    delete q;
    opp.isLVN__c = true;
    update opp;
    system.debug('opp :::' + opp);
    delete opp;
    test.stopTest();
  }
}