@IsTest
private class MB_OppParser_Test {
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
      Name = 'UMRAc',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Friendly_Account_Name__c = 'TestAmendAccount',
      Guid__c = 'FD5E35E0-5175-D1CB-06B8-B48C018EA7C9',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Account_Type__c = 'Health Plan'
    );

    insert umrAcct;

    Acct_Rel__c accRel = new Acct_Rel__c(
      svc_acct__c = umrAcct.Id,
      benefit_sponsor__c = umrAcct.Id,
      relationship_type__c = 'Contractee',
      contract_type__c = 'Direct',
      start_date__c = Date.today()
    );
    insert accRel;

    Contact conObj = new Contact();
    conObj.LastName = 'test name';
    conObj.AccountId = umrAcct.Id;
    conObj.Email = 'testetst@testtesting.com';
    insert conObj;

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
    //Product2 prod4 = new Product2(Name = 'Hypertension Management', ProductCode = 'HYPT', IsActive = TRUE, Family = 'Livongo - Hypertension');
    prodList.add(prod1);
    prodList.add(prod2);
    prodList.add(prod3);
    //prodList.add(prod4);
    insert prodList;

    Opportunity oppObj2 = new Opportunity(
      Name = 'Opp With Lines',
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('Employer – Teladoc and HY Products')
        .getRecordTypeId(),
      CIM__c = null,
      ContractOps_Owner__c = null,
      Opp_Guid__c = '416805C1-85B3-D317-121B-B939FA02A645',
      isLVN__c = true,
      AccountId = umrAcct.Id,
      Type = 'New Business',
      Business_Region__c = 'USA',
      CurrencyIsoCode = 'USD',
      StageName = 'Prospect',
      Probability = 10,
      Initial_of_Lives__c = 500,
      Primary_Carrier__c = accRel.Id,
      Fee_Type__c = 'PEPM',
      Benefit_Consultant_Involved_in_Deal__c = 'No',
      CloseDate = Date.Today(),
      Contracted_Date__c = Date.Today(),
      Pricebook2Id = pricebookId,
      LeadSource = 'Marketing',
      Decision_Date__c = Date.Today()
    );

    insert oppObj2;
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
    insert quoObj2;
    List<SBQQ__QuoteLine__c> qteLineList = new List<SBQQ__QuoteLine__c>();
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c(
      SBQQ__Quote__c = quoObj2.Id,
      SBQQ__Product__c = prod1.Id,
      SBQQ__Quantity__c = 500,
      Consult_Type__c = 'Standard',
      SBQQ__PricingMethod__c = 'List',
      CurrencyIsoCode = 'USD',
      SBQQ__Number__c = 1
    );
    qteLineList.add(quoline1);
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(
      SBQQ__Quote__c = quoObj2.Id,
      SBQQ__Product__c = prod2.Id,
      SBQQ__Quantity__c = 500,
      Consult_Type__c = 'Standard',
      SBQQ__PricingMethod__c = 'List',
      CurrencyIsoCode = 'USD',
      SBQQ__Number__c = 1
    );
    qteLineList.add(quoline2);
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c(
      SBQQ__Quote__c = quoObj2.Id,
      SBQQ__Product__c = prod3.Id,
      SBQQ__Quantity__c = 500,
      Consult_Type__c = 'Standard',
      SBQQ__PricingMethod__c = 'List',
      CurrencyIsoCode = 'USD',
      SBQQ__Number__c = 1
    );
    qteLineList.add(quoline3);

    insert qteLineList;
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

    List<PricebookEntry> lvpbList = new List<PricebookEntry>();
    PricebookEntry pbEntry11 = new PricebookEntry(
      Pricebook2Id = livongoPricebook.Id,
      Product2Id = prod1.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    PricebookEntry pbEntry12 = new PricebookEntry(
      Pricebook2Id = livongoPricebook.Id,
      Product2Id = prod2.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    PricebookEntry pbEntry13 = new PricebookEntry(
      Pricebook2Id = livongoPricebook.Id,
      Product2Id = prod3.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    lvpbList.add(pbEntry11);
    lvpbList.add(pbEntry12);
    lvpbList.add(pbEntry13);
    insert lvpbList;

    List<OpportunityLineItem> oppLiList = new List<OpportunityLineItem>();
    OpportunityLineItem oppli = new OpportunityLIneItem(
      OpportunityId = oppObj2.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod1.Id,
      pricebookEntryId = pbEntry1.Id,
      SBQQ__QuoteLine__c = quoline1.Id
    );
    OpportunityLineItem oppli2 = new OpportunityLIneItem(
      OpportunityId = oppObj2.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod2.Id,
      pricebookEntryId = pbEntry2.Id,
      SBQQ__QuoteLine__c = quoline2.Id
    );
    //OpportunityLineItem oppli3 = new OpportunityLIneItem(OpportunityId = oppObj2.Id, Quantity = 1, TotalPrice = 100, product2Id = prod3.Id, pricebookEntryId = pbEntry3.Id, SBQQ__QuoteLine__c = quoline3.Id);
    oppLiList.add(oppli);
    oppLiList.add(oppli2);
    //oppLiList.add(oppli3);
    insert oppLiList;

    /*         
        LVGO__OpportunityLineItem__c oppLineItem = new LVGO__OpportunityLineItem__c();        
        oppLineItem.LVGO__Opportunity__c = lvopp.Id;
        oppLineItem.LVGO__Quantity__c = 1;
        oppLineItem.LVGO__UnitPrice__c = 100;
        oppLineItem.LVGO__Product2__c = prod3.Id;
        oppLineItem.LVGO__Product_Participants__c = 10;
        oppLineItem.LVGO__OpportunityProductName__c = prod3.Name;
        oppLineItem.Name = prod3.Name;
        insert oppLineItem;
        */

    delete objDS;
  }

  @isTest
  static void ParserTest() {
    MB_UpdateQueueable.doChainJob = false;
    MB_InsertQueueable.doChainJob = false;
    test.startTest();
    Opportunity oppWithProd = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Opp With Lines'
    ];
    oppWithProd.StageName = 'Contracting';
    update oppWithProd;

    OpportunityLineItem oli = [
      SELECT Id, Quantity
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppWithProd.Id
      LIMIT 1
    ];
    oli.Quantity = 2;
    update oli;

    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    OpportunityLineItem oppli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
    delete oppli;
    test.stopTest();
    //List<Q_Item__c> qlist = [SELECT Id FROM Q_Item__c];
    //system.assertEquals(2, qlist.size());
  }

  @isTest
  static void qItemCreationTest() {
    List<System.JSONGenerator> genlist = new List<System.JSONGenerator>();
    for (Opportunity opp : [
      SELECT Id, Opp_Guid__c, Name
      FROM Opportunity
      WHERE Name = 'Opp With Lines'
      LIMIT 1
    ]) {
      genlist.add(MB_OppJSONGenerator.generateJSONContent(opp.Opp_Guid__c));
    }

    test.startTest();

    MB_QXfr.CreateAsyncQItem('LVN', 'TDH', 'Opportunity_Parser', genlist);

    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{\'Contact\' : { \'AccountId\' : \'0015G00001mhqtlQAA\', \'Id\' : \'0037j00000shsvsAAA\', \'Name\' : \'New Test Contact\', \'Email\' : \'newtest@test.in\' }}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EB4","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"parserName","Type__c":"Outgoing"}';
    JSONParser parserTest = System.JSON.createParser(body);
    QItem_Opp_Parser.consumeObject(parserTest);

    test.stopTest();
  }

  @isTest
  static void qItemParserTest() {
    test.startTest();

    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    List<Q_Item__c> lstQItem = new List<Q_Item__c>();
    Q_Item__c qitem = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-01",  "Account" : {    "Id" : "0017h000014pNg8AAE",    "Name" : "Nestle Holdings, Inc.",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : "17036824600",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "734AB69A-4DDF-FC5F-D8C1-66D27BCCA315",    "BillingStreet" : "1812 N Moore St",    "BillingCity" : "Arlington",    "BillingState" : "Virginia",    "BillingPostalCode" : "22209-1815",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017h000014pNg8AAE",    "Id" : "0067h00000HmpcGAAR",    "Name" : "CON0000681-166229 - Nestle Holdings, Inc.",    "StageName" : "Closed Won",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-05-22",    "Next_Steps__c" : null,    "Opp_Guid__c" : "F0891A99-54C4-DEC2-B3CE-C1C9803C14AA",    "Initial_of_Lives__c" : "3500",    "Decision_Date__c" : "2023-05-22",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7h00000BFb2sAAD",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "CCCPB",    "Name" : "CON0000681-166229 - Nestle Holdings, Inc. Chronic Care Complete",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : "12",    "TotalPrice" : "0.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : "YES",    "DisableBHCoaching" : "NO"  } ]}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EA1',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    lstQItem.add(qitem);
    insert lstQItem;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{  \'CreatedbyId\' : \'0055G000005GjjYQAS\',  \'Createddate\' : \'2023-06-01\',  \'Account\' : {    \'Id\' : \'0017h000014pNg8AAE\',    \'Name\' : \'Nestle Holdings, Inc.\',    \'Type\' : \'Customer\',    \'Account_Type__c\' : \'Employer\',    \'Website\' : null,    \'Phone\' : \'17036824600\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Guid__c\' : \'734AB69A-4DDF-FC5F-D8C1-66D27BCCA315\',    \'BillingStreet\' : \'1812 N Moore St\',    \'BillingCity\' : \'Arlington\',    \'BillingState\' : \'Virginia\',    \'BillingPostalCode\' : \'22209-1815\',    \'BillingCountry\' : \'United States\',    \'Total_US_Employees_Benefits_Enrolled__c\' : null,    \'Members__c\' : null,    \'Sales_Ranking__c\' : null,    \'CIM__c\' : null,    \'Rev_Synergy__c\' : \'Net New Client (All Solutions)\',    \'Livongo_Account_Record_Type__c\' : null,    \'Account_Health_Score__c\' : null,    \'LOB\' : null  },  \'Opportunity\' : {    \'AccountId\' : \'0017h000014pNg8AAE\',    \'Id\' : \'0067h00000HmpcGAAR\',    \'Name\' : \'CON0000681-166229 - Nestle Holdings, Inc.\',    \'StageName\' : \'Closed Won\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Contracted_Date__c\' : null,    \'CloseDate\' : \'2023-05-22\',    \'Next_Steps__c\' : null,    \'Opp_Guid__c\' : \'F0891A99-54C4-DEC2-B3CE-C1C9803C14AA\',    \'Initial_of_Lives__c\' : \'3500\',    \'Decision_Date__c\' : \'2023-05-22\',    \'Pricebook2Id\' : \'01sf40000073UUUAA2\',    \'Ann_Rec_Rev__c\' : \'0.00\',    \'Primary_Carrier_LOB__c\' : null,    \'Monthly_Recurring_Revenue__c\' : \'0.00\',    \'LeadSource\' : \'Sales\',    \'Probability\' : \'100\',    \'Reason_for_Loss__c\' : null,    \'Type\' : \'New Business\',    \'Sub_Channel__c\' : \'Undefined\',    \'ForecastCategoryName\' : \'Closed\',    \'Primary_Carrier_Account__c\' : null,    \'Benefit_Consultant_Involved_in_Deal__c\' : null,    \'CIM__c\' : null,    \'Forecast_Manager_Call__c\' : null,    \'Request_CIM__c\' : \'false\',    \'Primary_Carrier__c\' : null,    \'Num_of_Broker_Rel__c\' : \'0\',    \'Sub_Type__c\' : null,    \'Box_Contract_URL__c\' : null,    \'Parent_Opportunity__c\' : null,    \'CIM_Assignment_Completed__c\' : \'false\',    \'Msg_Bus_Manual_Trigger__c\' : \'false\',    \'ContractOps_Notes__c\' : null,    \'ContractOps_Owner__c\' : null,    \'ContractOps_Stage__c\' : null,    \'ContractOps_Status__c\' : null,    \'CPQ_Pricebook__c\' : null,    \'Contract_Path__c\' : null  },  \'OpportunityLineItem\' : [ {    \'Id\' : \'00k7h00000BFb2sAAD\',    \'SalesPrice\' : \'0.00\',    \'ParentsProductCode\' : null,    \'ProductCode\' : \'CCCPB\',    \'Name\' : \'CON0000681-166229 - Nestle Holdings, Inc. Chronic Care Complete\',    \'Anchor\' : \'false\',    \'ParticipantQuantity\' : null,    \'SubscriptionTerm\' : \'12\',    \'TotalPrice\' : \'0.00\',    \'NetArr\' : null,    \'AdminFee\' : null,    \'AtRiskFee\' : null,    \'UpFrontFee\' : null,    \'DisableTeletherapy\' : \'YES\',    \'DisableBHCoaching\' : \'NO\'  } ]}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EA1","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"Opportunity_Parser","Type__c":"Incoming"}';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    system.assertEquals(true, result.contains('Success'));

    JSONParser parserTest = System.JSON.createParser(body);
    QItemEmailParser.consumeObject(parserTest);

    test.stopTest();
  }

  @isTest
  static void qItemParser2Test() {
    test.startTest();
    //String LVIslandRecordTypeid = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName().get('LV Org').getRecordTypeId();

    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    List<Q_Item__c> lstQItem = new List<Q_Item__c>();

    Q_Item__c qitem1 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-01",  "Account" : {    "Id" : "0017h000014pNg8AAF",    "Name" : "New Nestle Holdings, Inc.",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : "17036824600",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "734AB69A-4DDF-FC5F-D8C1-66D27BCCA316",    "BillingStreet" : "1812 N Moore St",    "BillingCity" : "Arlington",    "BillingState" : "Virginia",    "BillingPostalCode" : "22209-1815",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017h000014pNg8AAF",    "Id" : "0067h00000HmpcGAAS",    "Name" : "CON0000681-166229 -New Nestle Holdings, Inc.",    "StageName" : "Closed Won",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-05-22",    "Next_Steps__c" : null,    "Opp_Guid__c" : "F0891A99-54C4-DEC2-B3CE-C1C9803C14AB",    "Initial_of_Lives__c" : "3500",    "Decision_Date__c" : "2023-05-22",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7h00000BFb2sAAD",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "CCCPB",    "Name" : "CON0000681-166229 - New Nestle Holdings, Inc. Chronic Care Complete",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : "12",    "TotalPrice" : "0.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : "YES",    "DisableBHCoaching" : "NO"  } ]}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EA2',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    lstQItem.add(qitem1);
    insert lstQItem;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{  \'CreatedbyId\' : \'0055G000005GjjYQAS\',  \'Createddate\' : \'2023-06-01\',  \'Account\' : {    \'Id\' : \'0017h000014pNg8AAF\',    \'Name\' : \'New Nestle Holdings, Inc.\',    \'Type\' : \'Customer\',    \'Account_Type__c\' : \'Employer\',    \'Website\' : null,    \'Phone\' : \'17036824600\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Guid__c\' : \'734AB69A-4DDF-FC5F-D8C1-66D27BCCA316\',    \'BillingStreet\' : \'1812 N Moore St\',    \'BillingCity\' : \'Arlington\',    \'BillingState\' : \'Virginia\',    \'BillingPostalCode\' : \'22209-1815\',    \'BillingCountry\' : \'United States\',    \'Total_US_Employees_Benefits_Enrolled__c\' : null,    \'Members__c\' : null,    \'Sales_Ranking__c\' : null,    \'CIM__c\' : null,    \'Rev_Synergy__c\' : \'Net New Client (All Solutions)\',    \'Livongo_Account_Record_Type__c\' : null,    \'Account_Health_Score__c\' : null,    \'LOB\' : null  },  \'Opportunity\' : {    \'AccountId\' : \'0017h000014pNg8AAF\',    \'Id\' : \'0067h00000HmpcGAAS\',    \'Name\' : \'CON0000681-166229 -New Nestle Holdings, Inc.\',    \'StageName\' : \'Closed Won\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Contracted_Date__c\' : null,    \'CloseDate\' : \'2023-05-22\',    \'Next_Steps__c\' : null,    \'Opp_Guid__c\' : \'F0891A99-54C4-DEC2-B3CE-C1C9803C14AB\',    \'Initial_of_Lives__c\' : \'3500\',    \'Decision_Date__c\' : \'2023-05-22\',    \'Pricebook2Id\' : \'01sf40000073UUUAA2\',    \'Ann_Rec_Rev__c\' : \'0.00\',    \'Primary_Carrier_LOB__c\' : null,    \'Monthly_Recurring_Revenue__c\' : \'0.00\',    \'LeadSource\' : \'Sales\',    \'Probability\' : \'100\',    \'Reason_for_Loss__c\' : null,    \'Type\' : \'New Business\',    \'Sub_Channel__c\' : \'Undefined\',    \'ForecastCategoryName\' : \'Closed\',    \'Primary_Carrier_Account__c\' : null,    \'Benefit_Consultant_Involved_in_Deal__c\' : null,    \'CIM__c\' : null,    \'Forecast_Manager_Call__c\' : null,    \'Request_CIM__c\' : \'false\',    \'Primary_Carrier__c\' : null,    \'Num_of_Broker_Rel__c\' : \'0\',    \'Sub_Type__c\' : null,    \'Box_Contract_URL__c\' : null,    \'Parent_Opportunity__c\' : null,    \'CIM_Assignment_Completed__c\' : \'false\',    \'Msg_Bus_Manual_Trigger__c\' : \'false\',    \'ContractOps_Notes__c\' : null,    \'ContractOps_Owner__c\' : null,    \'ContractOps_Stage__c\' : null,    \'ContractOps_Status__c\' : null,    \'CPQ_Pricebook__c\' : null,    \'Contract_Path__c\' : null  },  \'OpportunityLineItem\' : [ {    \'Id\' : \'00k7h00000BFb2sAAE\',    \'SalesPrice\' : \'0.00\',    \'ParentsProductCode\' : null,    \'ProductCode\' : \'CCCPB\',    \'Name\' : \'CON0000681-166229 -New Nestle Holdings, Inc. Chronic Care Complete\',    \'Anchor\' : \'false\',    \'ParticipantQuantity\' : null,    \'SubscriptionTerm\' : \'12\',    \'TotalPrice\' : \'0.00\',    \'NetArr\' : null,    \'AdminFee\' : null,    \'AtRiskFee\' : null,    \'UpFrontFee\' : null,    \'DisableTeletherapy\' : \'YES\',    \'DisableBHCoaching\' : \'NO\'  } ]}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EA2","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"Opportunity_Parser","Type__c":"Incoming"}';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    system.assertEquals(true, result.contains('Success'));
    test.stopTest();
  }

  @isTest
  static void qItemWarningEmailTest() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;
    List<Q_Item__c> lstQItem = new List<Q_Item__c>();

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "DIAB",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      Result__c = '{"qItemError" : "None",  "isCreated" : "True"}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D89',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    insert qitem01;

    Q_Item__c qitem02 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "005f4000003H8aHAAS",  "Createddate" : "2023-06-13T00:00:00.000+05:30",  "Account" : {    "Id" : "0017h000015DNC2AAO",    "Name" : "Powell Garage",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : null,    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "D8B84EF6-1DB0-9B6B-76AD-B789BC9F75DE",    "BillingStreet" : "1327 De La Vina St",    "BillingCity" : "Santa Barbara",    "BillingState" : "California",    "BillingPostalCode" : "93101-3164",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017h000015DNC2AAO",    "Id" : "0067h00000HnLsgAAF",    "Name" : "zzzTest Opportunity PG",    "StageName" : "Closed Won",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-07-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "C93E2B9A-6524-FD47-050F-2F2D64C6D154",    "Initial_of_Lives__c" : "50",    "Decision_Date__c" : "2023-06-13T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7h00000BFmilAAD",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "HYPT",    "Name" : "zzzTest Opportunity PG Hypertension Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : "12",    "TotalPrice" : "12000.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : "YES",    "DisableBHCoaching" : "NO"  } ]}',
      Result__c = '{"qItemError" : "None",  "isCreated" : "True"}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EA4',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem02;
    Q_Item__c qitem03 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "005f4000003H8aHAAS",  "Createddate" : "2023-06-13T00:00:00.000+05:30",  "Account" : {    "Id" : "0017h000015DNC2AAO",    "Name" : "Powell Garage",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : null,    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "D8B84EF6-1DB0-9B6B-76AD-B789BC9F75DE",    "BillingStreet" : "1327 De La Vina St",    "BillingCity" : "Santa Barbara",    "BillingState" : "California",    "BillingPostalCode" : "93101-3164",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017h000015DNC2AAO",    "Id" : "0067h00000HnLsgAAF",    "Name" : "zzzTest Opportunity PG",    "StageName" : "Closed Won",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-07-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "C93E2B9A-6524-FD47-050F-2F2D64C6D154",    "Initial_of_Lives__c" : "50",    "Decision_Date__c" : "2023-06-13T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7h00000BFmilAAD",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "HYPT",    "Name" : "zzzTest Opportunity PG Hypertension Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : "12",    "TotalPrice" : "12000.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : "YES",    "DisableBHCoaching" : "NO"  } ]}',
      Result__c = '{"qItemError" : "None",  "isCreated" : "True"}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EA5',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem03;
    Q_Item__c qitem1 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson",    "Type" : "Prospect",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003Hu5wAAC",    "Guid__c" : "C3446DBE-825B-9C13-A5F2-173C2A8523BB",    "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003Hu5wAAC",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "0055G000005GrIEQA0",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      Result__c = '{"qItemError" : "None",  "isCreated" : "True"}',
      ItemKey__c = '758F26C0-7CB3-3C4A-AF0A-D5904E29A0DC',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    insert qitem1;

    test.stopTest();
  }

  @isTest
  static void qItemMBExceptionTest() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;
    List<Q_Item__c> lstQItem = new List<Q_Item__c>();

    Q_Item__c qitem1 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson Johnson Kendall & Johnson Johnson Kendall & Johnson Johnson Kendall & Johnson",    "Type" : "Prospect",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "C3446DBE-825B-9C13-A5F2-173C2A8523BB",    "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "0055G000005GrIEQA0",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      ItemKey__c = '758F26C0-7CB3-3C4A-AF0A-D5904E29A0DC',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    Q_Item__c qitem2 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson",    "Type" : "Prospect",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "C3446DBE-825B-9C13-A5F2-173C2A8523BB",    "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "0055G000005GrIEQA0",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      ItemKey__c = 'BDDE64CE-855E-2CC8-F62D-665E6D24F2D2',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    Q_Item__c qitem3 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson",    "Type" : "Prospect",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "C3446DBE-825B-9C13-A5F2-173C2A8523BB",    "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "0055G000005GrIEQA0",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      ItemKey__c = '51E78905-4D71-1EB7-D9C4-2D91699EB38D',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    // lstQItem.add(qitem1);
    lstQItem.add(qitem2);
    lstQItem.add(qitem3);
    insert lstQItem;
    test.stopTest();
  }

  @isTest
  static void qItemMBParserErrorTest() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;
    List<Q_Item__c> lstQItem = new List<Q_Item__c>();

    Q_Item__c qitem = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson K", "Type" : "Prospect", "Guid__c":"test",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003H8aHAAS",       "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : "15",    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003H8aHAAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : "005TEST",    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "-1",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : "005TEST",    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC", "Client_Manager__c":"005TESTE"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "005f4000003H8aHAAS",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      ItemKey__c = '758F26C0-7CB3-3C4A-AF0A-D5904E29A0DC',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    insert qitem;
    test.stopTest();
  }

  @isTest
  static void OppDeletionTest() {
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Opportunity opp = [
      SELECT Id, isLVN__c
      FROM Opportunity
      WHERE Name = 'Opp With Lines'
    ];
    opp.isLVN__c = true;
    update opp;
    SBQQ__Quote__c q = [
      SELECT id
      FROM SBQQ__Quote__c
      WHERE SBQQ__Opportunity2__c = :opp.id
    ];
    q.SBQQ__Primary__c = false;
    update q;
    delete q;
    system.debug('opp :::' + opp);
    delete opp;
    test.stopTest();
  }

  @IsTest
  static void MsgQItemBusIncomingSrc_Test() {
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockIncomingQ_Test());
    String body = '{"attributes": {"type": "Q_Item__c"},"Payload__c": "{}","ItemKey__c": "DE3C1C1E-5197-18DB-9539-270433A22EB4","Status__c": "Pending","Src__c": "ITH","Dst__c": "LVN","Parser_Name__c": "parserName","Type__c":"Outgoing"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    system.assertEquals(true, result.contains('True'));
    test.stopTest();
  }

  @isTest
  static void qiLineItemParseProductTest() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : "MYSTR3",    "ProductCode" : "MYSTR3",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D90',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem01;
    test.stopTest();
  }


  @isTest
  static void qItemQxfrProcessTest() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;

    List<System.JSONGenerator> genlist = new List<System.JSONGenerator>();
    for (Opportunity opp : [
      SELECT Id, Opp_Guid__c, Name
      FROM Opportunity
      WHERE Name = 'Opp With Lines'
      LIMIT 1
    ]) {
      genlist.add(MB_OppJSONGenerator.generateJSONContent(opp.Opp_Guid__c));
    }

    LVGO__Opportunity__c lvopp = [
      SELECT Id, name
      FROM LVGO__Opportunity__c
      LIMIT 1
    ];
    Product2 prod = [
      SELECT Id, Name
      FROM Product2
      WHERE Name = 'General Medical'
    ];
    LVGO__OpportunityLineItem__c oppLineItem = new LVGO__OpportunityLineItem__c();
    oppLineItem.LVGO__Opportunity__c = lvopp.Id;
    oppLineItem.LVGO__Quantity__c = 1;
    oppLineItem.LVGO__UnitPrice__c = 100;
    oppLineItem.LVGO__Product2__c = prod.Id;
    oppLineItem.LVGO__Product_Participants__c = 10;
    oppLineItem.LVGO__OpportunityProductName__c = prod.Name;
    oppLineItem.Name = prod.Name;
    insert oppLineItem;

    MB_QXfr.CreateAsyncQItem('LVN', 'TDH', 'Opportunity_Parser', genlist);

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : "MYSTR3",    "ProductCode" : "MYSTR3",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D90',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem01;
    test.stopTest();
  }
 @isTest
static void qiLineItemParseProductTest1() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : "MYSTRPLUS",    "ProductCode" : "MYSTRPLUS",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D90',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem01;
    test.stopTest();
  }
  @isTest
static void qiLineItemParseProductTest2() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : "MSDIGIT",    "ProductCode" : "MSDIGIT",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D90',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem01;
    test.stopTest();
  }
 @isTest
static void qiLineItemParseProductTest3() {
    test.startTest();
    MB_InsertQueueable.doChainJob = false;

    Q_Item__c qitem01 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-06-14T00:00:00.000+05:30",  "Account" : {    "Id" : "0017j00000uxQVaAAM",    "Name" : "Test Kalyani",    "Type" : "Customer",    "Account_Type__c" : null,    "Website" : null,    "Phone" : "876543234",    "OwnerId" : "0055G000005GjjYQAS",    "Guid__c" : "142BB26A-BF50-AF34-3F43-FDDF1AF8CA4B",    "BillingStreet" : "U13",    "BillingCity" : "New York",    "BillingState" : "New York",    "BillingPostalCode" : "2343",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uxQVaAAM",    "Id" : "0067j00000AmFHPAA3",    "Name" : "Test Kalyani 2",    "StageName" : "Closed Won",    "OwnerId" : "0055G000005GjjYQAS",    "Contracted_Date__c" : null,    "CloseDate" : "2023-06-14T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "1C6E4436-8F0A-30C3-D1B2-74D3E7A1F6A3",    "Initial_of_Lives__c" : "1000",    "Decision_Date__c" : null,    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Marketing",    "Probability" : "100",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Closed",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : null,    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : null  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006X9GAAA0",    "SalesPrice" : "0.00",    "ParentsProductCode" : "TKB","GrandParentsProductCode":"TKB",   "ProductCode" : "MSDIGIT",    "Name" : "Test Kalyani 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "7500.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '7BCF0140-9093-7D25-50B7-FDC200CE4D90',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVNILD',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    insert qitem01;
    test.stopTest();
  }
}