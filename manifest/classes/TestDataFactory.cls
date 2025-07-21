@isTest
public class TestDataFactory {
  public static Account createUMR() {
    Account umrAcct = new Account();
    umrAcct.Name = 'UMR';
    umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
    umrAcct.Source__c = 'HUB';
    umrAcct.CurrencyIsoCode = 'USD';
    umrAcct.Business_Region__c = 'USA';
    umrAcct.Account_Type__c = 'Health Plan';
    umrAcct.GUID__c = '1BB95CCB-765E-17A8-6778-6846FB556025';
    insert umrAcct;

    return umrAcct;
  }

  public static Account createTempAcct() {
    Account tmpAcct = new Account();
    tmpAcct.Name = 'Test Acct 1';
    tmpAcct.Account_Legal_Name__c = 'Test Acct 1';
    tmpAcct.Source__c = 'HUB';
    tmpAcct.CurrencyIsoCode = 'USD';
    tmpAcct.Business_Region__c = 'USA';
    insert tmpAcct;

    return tmpAcct;
  }

  public static Account createAccountUMR() {
    Account accObj = new Account();
    accObj.Name = 'TestAmendAccount';
    accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    accObj.Friendly_Account_Name__c = 'TestAmendAccount';
    accObj.Source__c = 'HUB';
    accObj.CurrencyIsoCode = 'USD';
    accObj.Business_Region__c = 'USA';
    accObj.Account_Type__c = 'Health Plan';
    accObj.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    insert accObj;

    return accObj;
  }
  public static Account createAccountUMRNoInsert() {
    Account accObj = new Account();
    accObj.Name = 'TestAmendAccount';
    accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    accObj.Friendly_Account_Name__c = 'TestAmendAccount';
    accObj.Source__c = 'HUB';
    accObj.CurrencyIsoCode = 'USD';
    accObj.Business_Region__c = 'USA';
    accObj.Account_Type__c = 'Broker';
    accObj.Rev_Synergy__c = 'Legacy Combined TD/LV Client';

    return accObj;
  }
  public static Account createParentAccount() {
    Account accObj = new Account();
    accObj.Name = 'New Benefits, LTD';
    accObj.GUID__c = '5326F18B-33D6-4F53-A532-ECC7C29E474C';
    accObj.revenue_effective_date__c = Date.today();
    insert accObj;

    return accObj;
  }

  public static Account createAccount(String name) {
    Account accObj = new Account();
    accObj.Name = name;
    accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    accObj.Friendly_Account_Name__c = 'TestAmendAccount';
    accObj.Source__c = 'HUB';
    accObj.CurrencyIsoCode = 'USD';
    accObj.Business_Region__c = 'USA';
    accObj.Account_Type__c = 'Health Plan';
    accObj.BillingStreet = 'test road test state';
    accObj.GUID__c = '3F0AF7F3-384F-540B-9C7A-8543C25E0D37';
    accObj.BillingStreet = '1 Infinite Test';
    accObj.BillingCity = 'Cupertino';
    accObj.BillingState = 'Alabama';
    accObj.BillingPostalCode = '90210';
    accObj.BillingCountry = 'United States';
    accObj.Phone = '1-800-838-8282';
    accObj.Account_Type__c = 'Broker';
    accObj.Source__c = 'HUB';
    insert accObj;
    return accObj;
  }

  public static Acct_Rel__c createAcctRel(
    String svc_accountId,
    String bsp_accountId
  ) {
    Acct_Rel__c objAR = new Acct_Rel__c();
    objAR.svc_acct__c = svc_accountId;
    objAR.benefit_sponsor__c = bsp_accountId;
    objAR.relationship_type__c = 'Broker';
    objAR.Broker_Percentage__c = 0.15;
    objAR.Chronic_Care_Broker_Flat_Rate__c = 0.10;
    objAR.Chronic_Care_Broker_Percentage__c = 0.10;
    objAR.start_date__c = Date.today();
    insert objAR;
    return objAR;
  }

  public static Contact createContact(Id acctId) {
    Contact conObj = new Contact();
    conObj.LastName = 'test name';
    conObj.AccountId = acctId;
    insert conObj;
    return conObj;
  }

  public static Contact createContactDynamicVals(
    String FNAme,
    String LName,
    String Email,
    Id acctId
  ) {
    Contact conObj = new Contact();
    conObj.FirstName = FNAme;
    conObj.LastName = LName;
    conObj.Email = Email;
    conObj.AccountId = acctId;
    return conObj;
  }

  public static Account createRandomAccount() {
    String acctGuid = GlobalIdUtils.generateGuid();
    Account acctObj = new Account(
      name = 'Acct-' + acctGuid,
      GUID__c = acctGuid
    );
    acctObj.revenue_effective_date__c = Date.today();
    insert acctObj;
    return acctObj;
  }
  public static SBQQ__Quote__c createQuote() {
    SBQQ__Quote__c quoteObj = new SBQQ__Quote__c();
    insert quoteObj;

    return quoteObj;
  }

  public static Opportunity createCWOpportunity(
    SBQQ__Quote__c quoteObj,
    Id acctId
  ) {
    Opportunity oppObj = new Opportunity();
    oppObj.AccountId = acctId;
    oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    oppObj.CloseDate = date.today().addMonths(2);
    oppObj.Type = 'New Business';
    oppObj.Business_Region__c = 'USA';
    oppObj.SBQQ__Contracted__c = true;
    oppObj.Name = 'New Benefits - Broker Portal';
    oppObj.StageName = 'Prospect';
    oppObj.Fee_Type__c = 'PEPM';
    oppObj.Initial_of_Lives__c = 1000;
    oppObj.LeadSource = 'Sales';
    insert oppObj;

    quoteObj.SBQQ__Opportunity2__c = oppObj.Id;
    update quoteObj;

    oppObj.Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
    oppObj.Contracted_Date__c = Date.Today();
    oppObj.SBQQ__PrimaryQuote__c = quoteObj.Id;
    update oppObj;

    return oppObj;
  }

  public static List<Product2> CreateProduct() {
    List<Product2> pdList = new List<Product2>();
    List<String> pdCode = new List<String>{
      'GM',
      'DERM',
      'TC',
      'GMCF',
      'DERMFEE',
      'TCPROGFEE',
      'BH',
      'BHPOT',
      'BHP1T',
      'BHNPT',
      'NUT',
      'OI',
      'TDBC',
      'SH',
      'EMO',
      'BD-USEMP-BUNDLE',
      'MH',
      'BHPOOT',
      'PRIMCARECF',
      'PRIMCAREACF',
      'NEWPATCF',
      'PRIMCAREFCF',
      'PRIM360CARE','MYSTR3'
    };
    for (String pc : pdCode) {
      product2 pdObj = new product2();
      pdObj.Name = 'Product: ' + pc;
      pdObj.ProductCode = pc;
      pdList.add(pdObj);
    }
    insert pdList;

    return pdList;
  }

  public static Product2 CreateProductWithDynamicVals(
    String Family,
    String Code
  ) {
    product2 pdObj = new product2();
    pdObj.Name = Family;
    pdObj.Family = Family;
    pdObj.ProductCode = Code;
    pdObj.IsActive = true;
    return pdObj;
  }
  public static Product2 CreateProductWithDynamicVals(
    String proName,
    String FamilyName,
    String Code
  ) {
    product2 pdObj = new product2();
    pdObj.Name = proName;
    pdObj.Family = FamilyName;
    pdObj.ProductCode = Code;
    pdObj.IsActive = true;
    return pdObj;
  }

  public static List<SBQQ__QuoteLine__c> createQuoteLine(Id quoteId) {
    List<String> pdCode = new List<String>{
      'GM',
      'DERM',
      'TC',
      'GMCF',
      'DERMFEE',
      'TCPROGFEE',
      'BH',
      'BHPOT',
      'BHP1T',
      'BHNPT',
      'NUT',
      'OI',
      'TDBC',
      'SH',
      'EMO',
      'BD-USEMP-BUNDLE',
      'MH',
      'BHPOOT',
      'PRIMCARECF',
      'PRIMCAREACF',
      'NEWPATCF',
      'PRIMCAREFCF',
      'PRIM360CARE',
          'MYSTR3'
    };
    List<Product2> productList = [
      SELECT Name, ProductCode, Id
      FROM Product2
      WHERE ProductCode IN :pdCode
    ];
    List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
    for (Product2 pd : productList) {
      SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c();
      quoteLineObj.SBQQ__Quote__c = quoteId;
      quoteLineObj.SBQQ__Product__c = pd.Id;
      quoteLineObj.SBQQ__ListPrice__c = 10;
      quotelineList.add(quoteLineObj);
    }
    insert quotelineList;

    return quotelineList;
  }

  public static Contract createContract(Id acctId) {
    Contract contObj = new Contract();
    if (acctId != null)
      contObj.AccountId = acctId;
    contObj.CurrencyIsoCode = 'USD';
    contObj.Status = 'Draft';
    contObj.StartDate = Date.today();
    contObj.ContractTerm = 25;
    insert contOBj;

    return contObj;
  }

  public static Contract createContract(Id acctId, Id oppId, Id quoteId) {
    Contract contObj = new Contract();
    if (acctId != null)
      contObj.AccountId = acctId;
    contObj.SBQQ__Opportunity__c = oppId;
    contObj.SBQQ__Quote__c = quoteId;
    insert contOBj;

    return contObj;
  }

  public static Contract createContractNoInsert(
    Id acctId,
    Id oppId,
    Id quoteId
  ) {
    Contract contObj = new Contract();
    if (acctId != null)
      contObj.AccountId = acctId;
    contObj.SBQQ__Opportunity__c = oppId;
    contObj.SBQQ__Quote__c = quoteId;

    return contObj;
  }

  public static List<SBQQ__Subscription__c> createSub(Id acctId, Id contId) {
    List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
    List<SBQQ__QuoteLine__c> quotelineList = [
      SELECT Id, SBQQ__Product__c, SBQQ__ProductCode__c
      FROM SBQQ__QuoteLine__c
    ];
    for (SBQQ__QuoteLine__c qlList : quotelineList) {
      if (
        qlList.SBQQ__ProductCode__c == 'GM' ||
        qlList.SBQQ__ProductCode__c == 'DERM' ||
        qlList.SBQQ__ProductCode__c == 'TC' ||
        qlList.SBQQ__ProductCode__c == 'BH' ||
        qlList.SBQQ__ProductCode__c == 'GMCF'
      ) {
        SBQQ__Subscription__c subObj = new SBQQ__Subscription__c();
        subObj.SBQQ__Quantity__c = 1000;
        subObj.SBQQ__QuoteLine__c = qlList.Id;
        subObj.SBQQ__Account__c = acctId;
        subObj.SBQQ__Contract__c = contId;
        subObj.fee_type__c = 'PEPM';
        subObj.SBQQ__SubscriptionStartDate__c = system.today() - 1;
        subObj.SBQQ__Product__c = qlList.SBQQ__Product__c;
        subObj.Current_Membership_Fee__c = 10;
        subList.add(subObj);
      }
    }
    insert subList;

    return subList;
  }

  public static Asset createSingleAsset(String accId, String ProdId) {
    Asset tempAss = new Asset(
      Name = 'test Asset',
      AccountId = accId,
      Consult_Fees__c = 200,
      Product2Id = ProdId
    );
    insert tempAss;
    return tempAss;
  }

  public static Asset createAsset(
    String Name,
    decimal Fee,
    Id acctId,
    Id contId,
    Id productId,
    Id subId
  ) {
    Asset assetTest = new Asset();
    assetTest.Name = Name;
    assetTest.Product2Id = productId;
    assetTest.AccountId = acctId;
    assetTest.ContactId = contId;
    assetTest.Consult_Fees__c = Fee;
    assetTest.SBQQ__RequiredBySubscription__c = subId;

    insert assetTest;

    return assetTest;
  }

  public static Asset createAssetNoInsert(
    String Name,
    decimal Fee,
    Id acctId,
    Id contId,
    Id productId,
    Id subId
  ) {
    Asset assetTest = new Asset();
    assetTest.Name = Name;
    assetTest.Product2Id = productId;
    assetTest.AccountId = acctId;
    if (contId != null) {
      assetTest.ContactId = contId;
    }
    assetTest.Consult_Fees__c = Fee;
    assetTest.SBQQ__RequiredBySubscription__c = subId;
    return assetTest;
  }

  public static Mbr_Group__c createSingleMbrGroup(Id acctId) {
    Mbr_Group__c tmpGrp = new Mbr_Group__c();
    tmpGrp.Name__c = 'Test Group';
    tmpGrp.Client_Account__c = acctId;
    tmpGrp.Shipping_Class__c = 'S';
    insert tmpGrp;

    return tmpGrp;
  }

  public static List<Mbr_Group__c> createMbrGroup(Id acctId) {
    List<Mbr_Group__c> mgList = new List<Mbr_Group__c>();
    for (Integer i = 0; i < 10; i++) {
      Mbr_Group__c mg = new Mbr_Group__c();
      mg.Name__c = 'Test Group ' + i;
      mg.Client_Account__c = acctId;
      mg.Termination_Date__c = system.today() + 3;
      mgList.add(mg);
    }
    insert mgList;

    return mgList;
  }

  public static List<Mbr_Group__c> createMbrGroupList(Id acctId) {
    List<Mbr_Group__c> mgList = new List<Mbr_Group__c>();
    for (Integer i = 0; i < 10; i++) {
      Mbr_Group__c mg = new Mbr_Group__c();
      mg.Name__c = 'Test Group ' + i;
      mg.Client_Account__c = acctId;
      mg.Status__c = 'ACTIVE';
      mg.Active_Date__c = Date.today();
      mgList.add(mg);
    }
    insert mgList;

    return mgList;
  }

  public static List<Contact> createMultipleContacts(
    Id acctId,
    boolean siteuser
  ) {
    List<Contact> conList = new List<Contact>();
    for (Integer i = 0; i < 10; i++) {
      Contact objCon = new Contact();
      objCon.FirstName = 'John' + i;
      objCon.LastName = 'Smith';
      objCon.Email = 'Test' + i + '.User@teladoc.com';
      objCon.Marketing_Site_User__c = siteuser;
      objCon.AccountId = acctId;
      objCon.Contact_Status__c = 'ACTIVE';
      conList.add(objCon);
    }

    insert conList;

    return conList;
  }

  public static List<Lead> createLeads(Integer numLeads) {
    List<Lead> leads = new List<Lead>();

    for (Integer i = 0; i < numLeads; i++) {
      Lead lead = new Lead(
        LastName = 'Test LastName ' + i,
        Company = 'Test Company ' + i
      );
      leads.add(lead);
    }
    insert leads;
    return leads;
  }
  public static Account createAccount() {
    Account accObj = new Account();
    accObj.Name = 'TestAmendAccount';
    accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    accObj.Friendly_Account_Name__c = 'TestAmendAccount';
    accObj.Source__c = 'HUB';
    accObj.CurrencyIsoCode = 'USD';
    accObj.Business_Region__c = 'USA';
    accObj.Account_Type__c = 'Health Plan';
    return accObj;
  }
  public static Opportunity createOpportunity(Id AccId) {
    Opportunity oppObj = new Opportunity();
    oppObj.Name = 'Test Factory Opp';
    oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    oppObj.AccountId = AccId;
    oppObj.Type = 'New Business';
    oppObj.Business_Region__c = 'USA';
    oppObj.CurrencyIsoCode = 'USD';
    oppObj.StageName = 'Prospect';
    oppObj.Probability = 10;
    oppObj.Initial_of_Lives__c = 500;
    oppObj.Fee_Type__c = 'PEPM';
    oppObj.CloseDate = Date.Today();
    oppObj.LeadSource = 'Marketing';
    oppObj.Decision_Date__c = Date.Today();
    return oppObj;
  }
  public static Opportunity createOpportunityWithPriceBook(
    Id AccId,
    Id pricebookId,
    Id UserId
  ) {
    Opportunity oppObj = new Opportunity();
    oppObj.Name = 'Test Factory Opp';
    oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    if (AccId != null)
      oppObj.AccountId = AccId;
    oppObj.Type = 'New Business';
    oppObj.Business_Region__c = 'USA';
    oppObj.CurrencyIsoCode = 'USD';
    oppObj.StageName = 'Prospect';
    oppObj.Probability = 10;
    oppObj.Initial_of_Lives__c = 500;
    oppObj.Fee_Type__c = 'PEPM';
    oppObj.CloseDate = Date.Today();
    oppObj.LeadSource = 'Marketing';
    oppObj.Decision_Date__c = Date.Today();
    if (pricebookId != null)
      oppObj.Pricebook2Id = pricebookId;
    if (UserId != null)
      oppObj.OwnerId = UserId;
    oppObj.Benefit_Consultant_Involved_in_Deal__c = 'NO';
    return oppObj;
  }
  public static List<Product2> createProducts(List<String> familyNames) {
    List<Product2> listProd = new List<Product2>();
    for (String sFamily : familyNames) {
      Product2 prod = new Product2(
        Name = sFamily + ' Name',
        Family = sFamily,
        ProductCode = sFamily.Left(3),
        IsActive = true,
        SBQQ__SubscriptionPricing__c = 'Fixed'
      );
      listProd.add(prod);
    }
    return listProd;
  }
  public static List<PricebookEntry> createPriceBookEntries(
    List<Product2> listProd2,
    Id idPriceBook
  ) {
    List<PricebookEntry> listPBE = new List<PricebookEntry>();
    for (Product2 recProd2 : listProd2) {
      PricebookEntry pbEntry = new PricebookEntry(
        Pricebook2Id = idPriceBook,
        Product2Id = recProd2.Id,
        UnitPrice = 1.40,
        IsActive = true
      );
      listPBE.add(pbEntry);
    }
    return listPBE;
  }
  public static SBQQ__Quote__c createQuote(Id idOpp) {
    SBQQ__Quote__c quoObj = new SBQQ__Quote__c();
    quoObj.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
      .get('Teladoc')
      .getRecordTypeId();
    quoObj.SBQQ__Opportunity2__c = idOpp;
    quoObj.SBQQ__Primary__c = true;
    quoObj.Sales_Channels__c = 'US Employer';
    quoObj.CPQ_Pricebook__c = 'Direct';
    quoObj.Include_in_Octiv_Proposal__c = false;
    return quoObj;
  }
  public static SBQQ__QuoteLine__c createQuoteLine(Id idQuote, Id idProd) {
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = idQuote;
    quoline1.SBQQ__Product__c = idProd;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    return quoline1;
  }
  public static OpportunityLineItem createOLI(
    Id idOpp,
    Id idPBE,
    Id idQuoteLine
  ) {
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = idOpp;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.PricebookEntryId = idPBE;
    oppli.SBQQ__QuoteLine__c = idQuoteLine;
    return oppli;
  }

  public static Product2 createSingleProduct() {
    Product2 prod = new Product2(
      Name = 'Nutrition',
      Family = 'Nutrition',
      ProductCode = 'NUT',
      IsActive = true,
      disable_flow__c = true
    );
    insert prod;
    return prod;
  }

  public static Product2 createSingleProduct(
    String prodName,
    String prodFamily,
    String prodCode
  ) {
    Product2 prod = new Product2(
      Name = prodName,
      Family = prodFamily,
      ProductCode = prodCode,
      IsActive = true,
      SBQQ__SubscriptionPricing__c = 'Fixed'
    );
    return prod;
  }
  public static User createUser(Id profileId) {
    User u = new User(
      FirstName = 'Jim',
      LastName = 'Dollar',
      Username = 'jdo@agillion.com',
      Alias = 'jimbo',
      TimeZoneSidKey = 'Asia/Tokyo',
      EmailEncodingKey = 'Shift_JIS',
      ProfileId = profileId,
      LanguageLocaleKey = 'pt_BR',
      LocaleSidKey = 'en_GB',
      Email = 'jdo@agillion.com'
    );
    return u;
  }

  public static Quotas__c createQuotas(Id userId) {
    Quotas__c quotas = new Quotas__c();
    quotas.Quotas_Owner__c = userId;
    quotas.ARR_Quotas_Amount__c = 1000;
    quotas.IYR_Quotas_Amount__c = 1000;
    quotas.Starting_Date__c = Date.Today() - 120;
    quotas.Ending_Date__c = Date.Today() + 120;
    return quotas;
  }
  public static Acct_Rel__c createAccRel(Id AccountId) {
    Acct_Rel__c acctRel1 = new Acct_Rel__c();
    acctRel1.Benefit_Sponsor__c = AccountId;
    acctRel1.Svc_Acct__c = AccountId;
    acctRel1.Relationship_Type__c = 'Contractee';
    acctRel1.Contract_Type__c = 'Direct';
    acctRel1.Start_Date__c = Date.Today();
    return acctRel1;
  }

  public static Acct_Rel__c createAccRel(
    Id AccountId,
    String relationshipTy,
    String contractTy,
    String lineofbusiness
  ) {
    Acct_Rel__c acctRel1 = new Acct_Rel__c();
    acctRel1.Svc_Acct__c = AccountId;
    acctRel1.Relationship_Type__c = relationshipTy;
    acctRel1.Contract_Type__c = contractTy;
    acctRel1.Line_of_Business__c = lineofbusiness;
    acctRel1.Start_Date__c = Date.today() - 30;
    return acctRel1;
  }
  public static Plan_Specific_Fees__c createPlanSpecificFees(
    Id assetId,
    Id memGrpId,
    Id subId
  ) {
    Plan_Specific_Fees__c psf = new Plan_Specific_Fees__c();
    psf.Product_Under_Contract__c = assetId;
    psf.Member_Group__c = memGrpId;
    psf.Subscription__c = subId;
    psf.Product_Start_Date__c = system.today();
    psf.Consult_Fee_Mbr_Pd__c = 49;
    return psf;
  }

  public static Plan_Specific_Fees__c createSinglePlanSpecificFees(
    Id mgId,
    Id subId
  ) {
    Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
      Member_Group__c = mgId,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = subId,
      Product_Start_Date__c = Date.Today()
    );
    insert gpRec;
    return gpRec;
  }

  public static Briefing__c createBriefing(Id OppId) {
    Briefing__c ecbr = new Briefing__c();
    ecbr.opportunity__c = OppId;
    ecbr.location__c = 'Virtual';
    ecbr.Preferred_Date__c = DateTime.newInstance(2021, 6, 6, 3, 3, 3);
    ecbr.Request_Time_Zone__c = 'Eastern';
    return ecbr;
  }

  public static Broker_Opp_Rel__c createBrokerOppRel() {
    Broker_Opp_Rel__c objBOR = new Broker_Opp_Rel__c();
    return objBOR;
  }

  public static Mbr_Group_Role__c createGroupRole(
    String mgroupId,
    String rolety,
    String accountId,
    String contactId
  ) {
    Mbr_Group_Role__c mgr = new Mbr_Group_Role__c();
    mgr.Mbr_Group__c = mgroupId;
    mgr.Role_Type__c = rolety;
    if (contactId != null) {
      mgr.Source_Contact__c = contactId;
    }
    mgr.Source_Account__c = accountId;
    return mgr;
  }

  /* public static Apttus__APTS_Agreement__c createApttusAPTSAgreement(Id accId, Id oppId)
    {
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Account__c = accId;
        agreement.Name = 'Test Agreement';
        agreement.OwnerId = userinfo.getUserId();
        agreement.Apttus__Contract_Start_Date__c = system.today();
        agreement.Apttus__Contract_End_Date__c = System.Today() + 5;
        agreement.Apttus__Related_Opportunity__c = oppId;
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        return agreement;
    }*/

  public static Case createCase(Account new_acct) {
    Case newCase = new Case();
    newCase.status = 'Not Started';
    newCase.Subject =
      'New Account Setup (' +
      new_acct.Name +
      ') - ' +
      date.today().format();
    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Admin Config')
      .getRecordTypeId();
    newCase.AccountId = new_acct.Id;
    newCase.status = 'Not Started';
    newCase.Description =
      'New account setup requested for (' +
      new_acct.Name +
      ' ) - Link to account setup form pdf: ' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.FileDownload?file=' +
      new_acct.id;
    return newCase;
  }

  public static Location__c createLocation(String accId) {
    Location__c objLoc = new Location__c();
    objLoc.Location_HQ__c = accId;
    insert objLoc;
    return objLoc;
  }

  public static Mbr_Group_Role__c createMbrGrpRole() {
    Mbr_Group_Role__c mgr = new Mbr_Group_Role__c();
    mgr.Role_Type__c = 'Payer';
    return mgr;
  }

  public static Mkt_Site_User__c createMktSiteUser(
    String conId,
    String mbrGrpId
  ) {
    Mkt_Site_User__c msu = new Mkt_Site_User__c();
    msu.Contact__c = conId;
    msu.Mbr_Group__c = mbrGrpId;
    insert msu;
    return msu;
  }

  public static Plan_Specific_Fees__c PlanSpecificFees() {
    Plan_Specific_Fees__c psf = new Plan_Specific_Fees__c();
    return psf;
  }
  public static SBQQ__Subscription__c createSBQQSubscription(String AccId) {
    SBQQ__Subscription__c objS = new SBQQ__Subscription__c();
    objS.SBQQ__Account__c = AccId;
    objS.Status__c = 'Active';
    objS.SBQQ__Quantity__c = 500;
    objS.Consult_Fees__c = 0.90;
    return objS;
  }

  public static SBQQ__Subscription__c createSBQQSubscription(
    String AccId,
    string ContractId
  ) {
    SBQQ__Subscription__c objS = new SBQQ__Subscription__c();
    objS.SBQQ__Account__c = AccId;
    objS.SBQQ__Quantity__c = 25;
    objS.SBQQ__Contract__c = ContractId;
    return objS;
  }

  public static SBQQ__Subscription__c createSBQQSubscripWithProd(
    String AccId,
    string prodId
  ) {
    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = AccId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prodId,
      Termination_Date__c = Date.newInstance(2036, 12, 9)
    );
    insert sub;
    return sub;
  }
  public static SBQQ__Subscription__c createSBQQSubscripWithProdNoInsert(
    String AccId,
    string prodId
  ) {
    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = AccId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prodId
    );

    return sub;
  }

  public static ContentVersion createContentVersion(String versionData) {
    ContentVersion objCV = new ContentVersion();
    objCV.Title = 'Test';
    objCV.PathOnClient = 'Test.jpg';
    objCV.VersionData = Blob.valueOf(versionData);
    objCV.IsMajorVersion = true;
    return objCV;
  }
}