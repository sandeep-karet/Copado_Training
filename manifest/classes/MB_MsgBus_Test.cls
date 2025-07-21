@IsTest
private class MB_MsgBus_Test {
  @TestSetup
  public static void setup() {
    Message_Bus_Toggle__c MB = Message_Bus_Toggle__c.getOrgDefaults();
    MB.Enable_MB__c = true;
    MB.Error_Email_Enable__c = true;
    insert MB;
    Dev_Settings__c csDS = new Dev_Settings__c(
      SetupOwnerId = UserInfo.getUserId(),
      Disable_Triggers__c = true
    );
    insert csDS;

    Account umrAcct = new Account(
      Name = 'New UMR',
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

    Id pricebookId = Test.getStandardPricebookId();
    String GUID = 'F1CE3C57-8290-0ECB-60D3-6F31CBE57162';
    Opportunity oppObj = new Opportunity(
      Name = 'Opp with No Lines',
      Opp_Guid__c = GUID,
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
    insert oppObj;

    Account umrAcct1 = new Account(
      Name = 'Allspring Global Investments TEST',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Friendly_Account_Name__c = 'Allspring Global Investments TEST',
      Guid__c = 'FD5E35E0-5175-D1CB-06B8-B48C018EA7C9',
      Source__c = 'LV',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Account_Type__c = 'Employer'
    );
    insert umrAcct1;

    String oppGuid = '416805C1-85B3-D317-121B-B939FA02A645';

    Opportunity oppObj1 = new Opportunity(
      Name = 'Allspring Global Inv - TEST - DM',
      Opp_Guid__c = oppGuid,
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('Health Plan - Teladoc and HY Products')
        .getRecordTypeId(),
      AccountId = umrAcct1.Id,
      Type = 'New Business',
      Business_Region__c = 'USA',
      CurrencyIsoCode = 'USD',
      StageName = 'Prospect',
      Probability = 10,
      Initial_of_Lives__c = 1900,
      Fee_Type__c = 'PEPM',
      CloseDate = Date.Today(),
      Contracted_Date__c = Date.Today(),
      Pricebook2Id = pricebookId,
      LeadSource = 'Sales',
      Decision_Date__c = Date.Today()
    );
    insert oppObj1;

    Acct_Rel__c accRel = new Acct_Rel__c(
      svc_acct__c = umrAcct1.id,
      benefit_sponsor__c = umrAcct1.Id,
      relationship_type__c = 'Contractee',
      contract_type__c = 'Direct',
      start_date__c = Date.today()
    );
    insert accRel;

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

    SBQQ__Quote__c quoObj2 = new SBQQ__Quote__c(
      RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
        .get('Teladoc')
        .getRecordTypeId(),
      SBQQ__Opportunity2__c = oppObj1.Id,
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
    List<OpportunityLineItem> oppLiList = new List<OpportunityLineItem>();
    OpportunityLineItem oppli = new OpportunityLIneItem(
      OpportunityId = oppObj1.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod1.Id,
      pricebookEntryId = pbEntry1.Id,
      SBQQ__QuoteLine__c = quoline1.Id
    );
    OpportunityLineItem oppli2 = new OpportunityLIneItem(
      OpportunityId = oppObj1.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod2.Id,
      pricebookEntryId = pbEntry2.Id,
      SBQQ__QuoteLine__c = quoline2.Id
    );
    OpportunityLineItem oppli3 = new OpportunityLIneItem(
      OpportunityId = oppObj1.Id,
      Quantity = 1,
      TotalPrice = 100,
      product2Id = prod3.Id,
      pricebookEntryId = pbEntry3.Id,
      SBQQ__QuoteLine__c = quoline3.Id
    );
    oppLiList.add(oppli);
    oppLiList.add(oppli2);
    oppLiList.add(oppli3);
    insert oppLiList;

    delete csDS;
  }

  @IsTest
  static void processTest() {
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    //String oppGUID = GlobalIdUtils.generateGuid();
    String GUID = 'F1CE3C57-8290-0ECB-60D3-6F31CBE57162';
    //JSONGenerator gen = JSON.createGenerator(true);
    //JSONGenerator gen = MB_OppJSONGenerator.generateJSONContent(GUID);
    JSONGenerator gen = MB_OppJSONGenerator.generateJSONContent(GUID);

    List<JSONGenerator> genList = new List<JSONGenerator>();
    genList.add(gen);
    //MB_QXfr.CreateAsyncQItem('LVN', 'TDH', 'itsatest', genList);
    test.stopTest();
  }

  @IsTest
  static void MsgQItemBusOutgoing_Test() {
    Test.setMock(HttpCalloutMock.class, new MB_MockIncomingQ_Test());
    String body = '{"attributes": {"type": "Q_Item__c"},"Payload__c": "{}","ItemKey__c": "DE3C1C1E-5197-18DB-9539-270433A22EB4","Status__c": "Pending","Src__c": "TDH","Dst__c": "LVN","Parser_Name__c": "parserName","Type__c":"Outgoing"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    system.assertEquals(true, result.contains('True'));
  }

  @isTest
  static void testException() {
    List<Q_Item__c> qList = new List<Q_Item__c>();
    Q_Item__c qitem = new Q_Item__c(
      Payload__c = '{}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB4',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'parserName',
      Type__c = 'Outgoing',
      RecordTypeId = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
        .get('LV Island')
        .getRecordTypeId()
    );
    Q_Item__c qitem2 = new Q_Item__c(
      Payload__c = '{}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB5',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'parserName',
      Type__c = 'Incoming',
      RecordTypeId = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
        .get('LV Island')
        .getRecordTypeId()
    );
    Q_Item__c qitem3 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-03-24 14:49:03",  "Account" : {    "Id" : "0017j00000uCn8sAAC",    "Name" : "Test",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : null,    "OwnerId" : "0055G000005GjjdQAC",    "Guid__c" : "D60F56DC-B35A-F6F0-A5CB-833AFAE81EF7",    "BillingStreet" : null,    "BillingCity" : null,    "BillingState" : null,    "BillingPostalCode" : null,    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uCn8sAAC",    "Id" : "0067j00000AkX9FAAV",    "Name" : "test 2",    "StageName" : "Contracting",    "OwnerId" : "0055G000005GjjdQAC",    "Contracted_Date__c" : "2023-04-05 00:00:00",    "CloseDate" : "2023-04-08 00:00:00",    "Next_Steps__c" : null,    "Opp_Guid__c" : "3E8F0086-0DB8-9E95-231B-0F1298CAE98C",    "Initial_of_Lives__c" : "100",    "Decision_Date__c" : "2023-04-08 00:00:00",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "90",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Commit",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "true",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : "Direct",    "Contract_Path__c" : "0017j00000uFFEeAAO"  },  "OpportunityLineItem" : [ {    "Id" : "00k7j000006UKgZAAW",    "SalesPrice" : "0.00",    "ParentsProductCode" : null,    "ProductCode" : "DIAB",    "Name" : "test 2 Diabetes Management",    "Anchor" : "false",    "ParticipantQuantity" : null,    "SubscriptionTerm" : null,    "TotalPrice" : "75000.00",    "NetArr" : null,    "AdminFee" : null,    "AtRiskFee" : null,    "UpFrontFee" : null,    "DisableTeletherapy" : null,    "DisableBHCoaching" : null  } ]}',
      ItemKey__c = '3407861F-E791-EC0B-D03D-E5890F2BCBFD',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing',
      RecordTypeId = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
        .get('LV Island')
        .getRecordTypeId()
    );
    qList.add(qitem);
    qList.add(qitem2);
    qList.add(qitem3);

    Q_Item__c qitem1 = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GrKmQAK",  "Createddate" : "2023-03-31T00:00:00.000+05:30",  "Account" : {    "Id" : "001f400000dFzrLAAS",    "Name" : "Johnson Kendall & Johnson Johnson Kendall & Johnson Johnson Kendall & Johnson Johnson Kendall & Johnson Johnson Kendall & Johnson",    "Type" : "Prospect",    "Account_Type__c" : "Broker",    "Website" : "jkj.com",    "Phone" : "2155796443",    "OwnerId" : "005f4000003Hu5wAAC",    "Guid__c" : "C3446DBE-825B-9C13-A5F2-173C2A8523BB",    "BillingStreet" : "54 Devyn Drive",    "BillingCity" : "Chester Springs",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19425",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "001f400000dFzrLAAS",    "Id" : "0065G00000rQ0m4QAC",    "Name" : "JOHNSON, KENDALL, & JOHNSON - DM + HTN - New Business - IBC",    "StageName" : "Discovery",    "OwnerId" : "005f4000003Hu5wAAC",    "Contracted_Date__c" : null,    "CloseDate" : "2023-01-01T00:00:00.000+05:30",    "Next_Steps__c" : null,    "Opp_Guid__c" : "D93F9234-0556-9A0D-0F53-659455A8397F",    "Initial_of_Lives__c" : "180",    "Decision_Date__c" : "2023-02-01T00:00:00.000+05:30",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "0",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Employer - Downmarket",    "ForecastCategoryName" : "Pipeline",    "Primary_Carrier_Account__c" : null,    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "false",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : "Chronic Care",    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "false",    "ContractOps_Notes__c" : "2/1 - IBC provided an excel form without a CCS. A. DeVoe requested sales-ops close/won opportunity due to lack of official paperwork.",    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : null,    "Contract_Path__c" : "001f400000dG3sjAAC"  },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG3sjAAC",    "Name" : "Independence Blue Cross (IBC)",    "Type" : "Customer",    "Account_Type__c" : "Health Plan",    "Website" : "www.ibx.com",    "Phone" : "(215) 241-2400",    "OwnerId" : "0055G000005GrIEQA0",    "Guid__c" : "BC36E172-321F-1532-C7A9-AA0DEF61266F",    "BillingStreet" : "1901 Market Street",    "BillingCity" : "Philadelphia",    "BillingState" : "Pennsylvania",    "BillingPostalCode" : "19103",    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Legacy Combined TD/LV Client",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : "Green"  },  "OpportunityLineItem" : [ ]} ]}',
      ItemKey__c = 'BDDE64CE-855E-2CC8-F62D-665E6D24F2D2',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    qList.add(qitem1);
    Boolean exp = false;
    try {
      insert qList;
    } catch (exception e) {
      exp = true;
    }
    system.assertEquals(true, exp);
  }
  /*
    @isTest
    static void msgLVOrgOutgoing_Test(){
        Q_Item__c qitem = new Q_Item__c(Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-03-24",  "Account" : {    "Id" : "0017j00000uCn8sAAC",    "Name" : "Test",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : null,    "OwnerId" : "0055G000005GjjdQAC",    "Guid__c" : "D60F56DC-B35A-F6F0-A5CB-833AFAE81EF7",    "BillingStreet" : null,    "BillingCity" : null,    "BillingState" : null,    "BillingPostalCode" : null,    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uCn8sAAC",    "Id" : "0067j00000AkX9FAAV",    "Name" : "test 2",    "StageName" : "Contracting",    "OwnerId" : "0055G000005GjjdQAC",    "Contracted_Date__c" : "2023-04-03",    "CloseDate" : "2023-04-08",    "Next_Steps__c" : null,    "Opp_Guid__c" : "3E8F0086-0DB8-9E95-231B-0F1298CAE98C",    "Initial_of_Lives__c" : "100",    "Decision_Date__c" : "2023-04-08",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "90",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Commit",    "Primary_Carrier_Account__c" :"0017j00000uCn8sAAC",    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "true",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : "Direct",    "Contract_Path__c" : "0017j00000uFFEeAAO"  }}', ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB4', Status__c = 'Pending', Src__c = 'TDH', Dst__c = 'LVN',
                                        Parser_Name__c = 'Opportunity_Parser', Type__c = 'Outgoing',RecordTypeId = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName().get('LV Org').getRecordTypeId());
        //insert qitem;
        
    }
    */
  @IsTest
  static void MsgQItemBusIncoming_Test() {
    LVGO__Account__c lvgoAccount = new LVGO__Account__c();
    lvgoAccount.Name = 'Livongo Test';
    lvgoAccount.LVGO__TD_Acct_Guid__c = 'D60F56DC-B35A-F6F0-A5CB-833AFAE81EF7';
    insert lvgoAccount;

    LVGO__Account_Long_ID__mdt asw = new LVGO__Account_Long_ID__mdt();
    asw.DeveloperName = 'Caremark';
    asw.LVGO__Account_Long_ID__c = lvgoAccount.Id;

    Q_Item__c qitem = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G000005GjjYQAS",  "Createddate" : "2023-03-24",  "Account" : {    "Id" : "0017j00000uCn8sAAC",    "Name" : "Test",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : null,    "Phone" : null,    "OwnerId" : "0055G000005GjjdQAC",    "Guid__c" : "D60F56DC-B35A-F6F0-A5CB-833AFAE81EF7",    "BillingStreet" : null,    "BillingCity" : null,    "BillingState" : null,    "BillingPostalCode" : null,    "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : null,    "Members__c" : null,    "Sales_Ranking__c" : null,    "CIM__c" : null,    "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : null,    "Account_Health_Score__c" : null,    "LOB" : null  },  "Opportunity" : {    "AccountId" : "0017j00000uCn8sAAC",    "Id" : "0067j00000AkX9FAAV",    "Name" : "test 2",    "StageName" : "Contracting",    "OwnerId" : "0055G000005GjjdQAC",    "Contracted_Date__c" : "2023-04-05",    "CloseDate" : "2023-04-08",    "Next_Steps__c" : null,    "Opp_Guid__c" : "3E8F0086-0DB8-9E95-231B-0F1298CAE98C",    "Initial_of_Lives__c" : "100",    "Decision_Date__c" : "2023-04-08",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "0.00",    "Primary_Carrier_LOB__c" : null,    "Monthly_Recurring_Revenue__c" : "0.00",    "LeadSource" : "Sales",    "Probability" : "90",    "Reason_for_Loss__c" : null,    "Type" : "New Business",    "Sub_Channel__c" : "Undefined",    "ForecastCategoryName" : "Commit",    "Primary_Carrier_Account__c" :"0017j00000uCn8sAAC",    "Benefit_Consultant_Involved_in_Deal__c" : "No",    "CIM__c" : null,    "Forecast_Manager_Call__c" : null,    "Request_CIM__c" : "true",    "Primary_Carrier__c" : null,    "Num_of_Broker_Rel__c" : "0",    "Sub_Type__c" : null,    "Box_Contract_URL__c" : null,    "Parent_Opportunity__c" : null,    "CIM_Assignment_Completed__c" : "false",    "Msg_Bus_Manual_Trigger__c" : "true",    "ContractOps_Notes__c" : null,    "ContractOps_Owner__c" : null,    "ContractOps_Stage__c" : null,    "ContractOps_Status__c" : null,    "CPQ_Pricebook__c" : "Direct",    "Contract_Path__c" : "0017j00000uFFEeAAO"  }}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB4',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );
    insert qitem;

    LVGO__Contract__c clientOverview = new LVGO__Contract__c();
    clientOverview.RecordTypeId = Schema.SObjectType.LVGO__Contract__c.getRecordTypeInfosByDeveloperName()
      .get('Client_Overview')
      .getRecordTypeId();
    clientOverview.LVGO__Status__c = 'Draft';
    clientOverview.LVGO__Account__c = lvgoAccount.Id;
    clientOverview.LVGO__CSM__c = System.UserInfo.getUserId();
    clientOverview.Name = 'Test Client Overview';
    insert clientOverview;

    LVGO__Opportunity__c lvopp = new LVGO__Opportunity__c();
    lvopp.Name = 'Test Opportunity ';
    lvopp.LVGO__StageName__c = 'Prospect';
    lvopp.LVGO__Type__c = 'Renewal';
    lvopp.LVGO__CloseDate__c = Date.today().addDays(1);
    lvopp.LVGO__LeadSource__c = 'Other';
    lvopp.LVGO__TD_Opp_Guid__c = '3E8F0086-0DB8-9E95-231B-0F1298CAE98C';
    lvopp.LVGO__Account__c = lvgoAccount.Id;
    lvopp.LVGO__Contract__c = clientOverview.Id;
    insert lvopp;

    test.startTest();
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/msgqitembus/';
    req.httpMethod = 'POST';
    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{  \'CreatedbyId\' : \'0055G000005GjjYQAS\',  \'Createddate\' : \'2023-03-24\',  \'Account\' : {    \'Id\' : \'0017j00000uCn8sAAC\',    \'Name\' : \'Test\',    \'Type\' : \'Customer\',    \'Account_Type__c\' : \'Employer\',    \'Website\' : null,    \'Phone\' : null,    \'OwnerId\' : \'0055G000005GjjdQAC\',    \'Guid__c\' : \'D60F56DC-B35A-F6F0-A5CB-833AFAE81EF7\',    \'BillingStreet\' : null,    \'BillingCity\' : null,    \'BillingState\' : null,    \'BillingPostalCode\' : null,    \'BillingCountry\' : \'United States\',    \'Total_US_Employees_Benefits_Enrolled__c\' : null,    \'Members__c\' : null,    \'Sales_Ranking__c\' : null,    \'CIM__c\' : null,    \'Rev_Synergy__c\' : \'Net New Client (All Solutions)\',    \'Livongo_Account_Record_Type__c\' : null,    \'Account_Health_Score__c\' : null,    \'LOB\' : null  },  \'Opportunity\' : {    \'AccountId\' : \'0017j00000uCn8sAAC\',    \'Id\' : \'0067j00000AkX9FAAV\',    \'Name\' : \'test 2\',    \'StageName\' : \'Contracting\',    \'OwnerId\' : \'0055G000005GjjdQAC\',    \'Contracted_Date__c\' : \'2023-04-05\',    \'CloseDate\' : \'2023-04-08\',    \'Next_Steps__c\' : null,    \'Opp_Guid__c\' : \'3E8F0086-0DB8-9E95-231B-0F1298CAE98C\',    \'Initial_of_Lives__c\' : \'100\',    \'Decision_Date__c\' : \'2023-04-08\',    \'Pricebook2Id\' : \'01sf40000073UUUAA2\',    \'Ann_Rec_Rev__c\' : \'0.00\',    \'Primary_Carrier_LOB__c\' : null,    \'Monthly_Recurring_Revenue__c\' : \'0.00\',    \'LeadSource\' : \'Sales\',    \'Probability\' : \'90\',    \'Reason_for_Loss__c\' : null,    \'Type\' : \'New Business\',    \'Sub_Channel__c\' : \'Undefined\',    \'ForecastCategoryName\' : \'Commit\',    \'Primary_Carrier_Account__c\' : \'0017j00000uCn8sAAC\',    \'Benefit_Consultant_Involved_in_Deal__c\' : \'No\',    \'CIM__c\' : null,    \'Forecast_Manager_Call__c\' : null,    \'Request_CIM__c\' : \'true\',    \'Primary_Carrier__c\' : null,    \'Num_of_Broker_Rel__c\' : \'0\',    \'Sub_Type__c\' : null,    \'Box_Contract_URL__c\' : null,    \'Parent_Opportunity__c\' : null,    \'CIM_Assignment_Completed__c\' : \'false\',    \'Msg_Bus_Manual_Trigger__c\' : \'true\',    \'ContractOps_Notes__c\' : null,    \'ContractOps_Owner__c\' : null,    \'ContractOps_Stage__c\' : null,    \'ContractOps_Status__c\' : null,    \'CPQ_Pricebook__c\' : \'Direct\',    \'Contract_Path__c\' : \'0017j00000uFFEeAAO\'  }}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EB4","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"Opportunity_Parser","Type__c":"Incoming"}';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    String result = MsgQItemBus.processQ();
    system.assertEquals(true, result.contains('Success'));
    test.stopTest();
  }

  @IsTest
  static void baseParserTest() {
    test.startTest();
    QItem_BaseParser parser = new QItem_BaseParser();
    system.assertEquals(false, (parser.yieldBoolean('test', 'N')));
    system.assertEquals(true, (parser.yieldBoolean('test', 'Y')));
    system.assertEquals(true, (parser.yieldBoolean('test', 'true')));
    parser.yieldBoolean('test', null);
    JSONParser parserText = null;
    parser.Parse(parserText);
    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EB4","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"parserName","Type__c":"Outgoing"}';
    JSONParser parserTest = System.JSON.createParser(body);
    parser.consumeObject(parserTest);
    parser.FetchTypedValue('Q_Item__c', 'Name', 'test');
    parser.FetchTypedValue(
      'Q_Item__c',
      'Createddate',
      '2021-03-01T00:00:00.000Z'
    );
    parser.parseIsoDate(null, 'key');
    test.stopTest();
  }

  @IsTest
  static void contactParseTest() {
    Test.setMock(HttpCalloutMock.class, new MB_MockMsgBus_Test());
    Q_Item__c qitem = new Q_Item__c(
      Payload__c = '{  "CreatedbyId" : "0055G0000074LxQQAU",  "Createddate" : "2021-10-11",  "Account" : {    "Id" : "0015G00001mhqtlQAA",    "Name" : "Allspring Global Investments",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "OwnerId" : "0055G000005GrH2QAK",    "Account_Manager__c" : "0055G000005GrIYQA0",    "Guid__c" : "FD5E35E0-5175-D1CB-06B8-B48C018EA7C9",   "BillingCountry" : "United States",    "Total_US_Employees_Benefits_Enrolled__c" : "1125",  "Rev_Synergy__c" : "Net New Client (All Solutions)",    "Livongo_Account_Record_Type__c" : "Client Account",    "Account_Health_Score__c" : "Green",    "LOB" : "N/A"  },  "Opportunity" : {    "AccountId" : "0015G00001mhqtlQAA",    "Id" : "0065G00000dUBceQAG",    "Name" : "Allspring Global Investments - DM",    "StageName" : "Contracting",    "OwnerId" : "0055G000005GrH2QAK",  "CloseDate" : "2021-11-01",    "Next_Steps__c" : "10/7 - Need CIM ASAP.",    "Opp_Guid__c" : "416805C1-85B3-D317-121B-B939FA02A645",    "Initial_of_Lives__c" : "1900",    "Decision_Date__c" : "2021-10-15",    "Pricebook2Id" : "01sf40000073UUUAA2",    "Ann_Rec_Rev__c" : "22914.00",    "Primary_Carrier_LOB__c" : "N/A",    "Monthly_Recurring_Revenue__c" : "1909.50",    "Client_Manager__c" : "0055G000005GrIYQA0",    "LeadSource" : "Sales",    "Probability" : "90",  "Type" : "New Business",    "Sub_Channel__c" : "DTE - West Client Sales",    "ForecastCategoryName" : "Commit",    "Primary_Carrier_Account__c" : "Express Scripts",    "Benefit_Consultant_Involved_in_Deal__c" : "No",  "Forecast_Manager_Call__c" : "Not in Forecast",    "Request_CIM__c" : "true",    "Primary_Carrier__c" : "a1E5G00000BWlFjUAL",    "Num_of_Broker_Rel__c" : "0" },  "PrimaryCarrierAccount" : {    "Id" : "001f400000dG2cmAAC",    "Name" : "Express Scripts",    "Type" : "Customer",    "Account_Type__c" : "Employer",    "Website" : "www.express-scripts.com",    "Phone" : "(314) 443-3362",    "OwnerId" : "0055G000005GrIJQA0", "Guid__c" : "98C8CFE6-B05E-4D7E-E8DE-B7F225B29A77",    "BillingStreet" : "1 Express Way",    "BillingCity" : "St. Louis",    "BillingState" : "Missouri",    "BillingPostalCode" : "85072",    "BillingCountry" : "United States",  "Members__c" : "10000000",    "Sales_Ranking__c" : "Tier A - Best candidate", "Rev_Synergy__c" : "Legacy Combined TD/LV Client",  "Account_Health_Score__c" : "Black"  },  "OpportunityLineItem" : [{   "OpportunityId" : "0065G00000dUBceQAG", "Id" : "00k5G00001pwHKbQAM",    "SalesPrice" : "67.00",  "ProductCode" : "DIAB",    "Name" : "Allspring Global Investments - DM Diabetes",    "Anchor" : "false",    "ParticipantQuantity" : "114",    "SubscriptionTerm" : "12",    "TotalPrice" : "22914.00",    "NetArr" : "18331.20",    "AdminFee" : "13",    "AtRiskFee" : "0",  "DisableTeletherapy" : "YES",    "DisableBHCoaching" : "NO"  }], "SBQQ__Quote__c" : {"SBQQ__Opportunity2__c" : "0065G00000dUBceQAG", "SBQQ__Primary__c" : "TRUE", "Sales_Channels__c" : "US Employer", "CPQ_Pricebook__c" : "Direct", "Include_in_Octiv_Proposal__c" : "false"}}',
      ItemKey__c = 'DE3C1C1E-5197-18DB-9539-270433A22EB9',
      Status__c = 'Pending',
      Src__c = 'TDH',
      Dst__c = 'LVN',
      Parser_Name__c = 'Opportunity_Parser',
      Type__c = 'Outgoing'
    );

    test.startTest();

    insert qitem;

    test.stopTest();
  }
}