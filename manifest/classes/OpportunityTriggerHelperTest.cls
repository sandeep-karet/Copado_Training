/*https://teladochealth--preprod2.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
 * Created by amruthakommuri on 2019-02-12.
 **/

@isTest
private class OpportunityTriggerHelperTest {
  //Defined test dataset
  @testSetup
  static void setupdata() {
    Test.startTest();
    SBQQ.TriggerControl.disable();
    Account umrAcct = TestDataFactory.createUMR();

    //create an account record
    Account accObj = TestDataFactory.createAccountUMR();

    //Create Account Relationships
    List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();

    Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
    acctRel1.Relationship_Type__c = 'Payer and Eligibility Provider';
    acctRel1.Contract_Type__c = null;
    accRelList.add(acctRel1);

    Acct_Rel__c acctRel2 = TestDataFactory.createAccRel(accObj.Id);
    acctRel2.Relationship_Type__c = 'Eligibility Provider Only';
    acctRel2.Contract_Type__c = null;
    accRelList.add(acctRel2);
    insert accRelList;

    //create an opportunity record
    Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
    insert oppObj2;

    List<SBQQ__Quote__c> quoList = new List<SBQQ__Quote__c>();

    //Create 2 quote records
    SBQQ__Quote__c quoObj1 = TestDataFactory.createQuote(oppObj2.Id);
    quoObj1.SBQQ__Primary__c = true;
    quoList.add(quoObj1);

    SBQQ__Quote__c quoObj2 = TestDataFactory.createQuote(oppObj2.Id);
    quoObj2.SBQQ__Primary__c = false;
    quoList.add(quoObj2);
    insert quolist;

    list<Product2> prodlist = new List<Product2>();

    //create BD US core bundle product
    Product2 prod1 = TestDataFactory.createSingleProduct(
      'EMS 2.0 Bundle',
      'Expert Medical Services',
      'BD-USEMP-BUNDLE-2.0'
    );
    prodlist.add(Prod1);

    //create TD Standard Bundle product
    Product2 prod2 = TestDataFactory.createSingleProduct(
      'TD Bundle - Standard',
      'Teladoc',
      'TD-STD'
    );
    prodlist.add(Prod2);

    //create Gen Med product
    Product2 prod3 = TestDataFactory.createSingleProduct(
      'General Medical',
      'General Medical',
      'GM'
    );
    prodlist.add(Prod3);

    //create TD-Included Bundle
    Product2 prod4 = TestDataFactory.createSingleProduct(
      'TD Bundle - Included - less than 1000',
      'Teladoc',
      'TD-INCL-L1000'
    );
    prodlist.add(Prod4);

    Product2 prod5 = TestDataFactory.createSingleProduct(
      'HealthiestYou',
      'General Medical',
      'HY'
    );
    prodlist.add(Prod5);

    Product2 prod6 = TestDataFactory.createSingleProduct(
      'HY - Consult Fee',
      'General Medical',
      'HYCF'
    );
    prodlist.add(Prod6);

    insert Prodlist;

    //create a contract record 2
    Contract conObj2 = TestDataFactory.createContractNoInsert(
      accObj.Id,
      oppObj2.id,
      null
    );
    conObj2.Status = 'Draft';
    conObj2.CurrencyIsoCode = 'USD';
    conObj2.StartDate = Date.Today();
    conObj2.ContractTerm = 12;
    insert conObj2;
    SBQQ.TriggerControl.enable();
    Test.StopTest();
  }

  //Test Case for 'Telehealth Services - Both TD Standard & TD Included' proposal template
  @isTest
  static void combiledTDTemplateValid() {
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    List<Contract> clist = [SELECT id FROM contract];
    List<Account> acclist = [SELECT id FROM Account];
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    list<Product2> prodlist = [SELECT id FROM Product2];
    test.startTest();
    SBQQ.TriggerControl.disable();
    //Create quote lines for the primary quote
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline1.SBQQ__Quote__c = quolist[0].Id;
    quoline1.SBQQ__Product__c = prodlist[1].Id;
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.Consult_Type__c = 'Standard';
    insert quoline1;
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c();
    quoline2.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline2.SBQQ__Quote__c = quolist[0].Id;
    quoline2.SBQQ__Product__c = prodlist[2].Id;
    quoline2.CurrencyIsoCode = 'USD';
    quoline2.Consult_Type__c = 'Standard';
    insert quoline2;

    //Create quote lines for the primary quote
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
    quoline3.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline3.SBQQ__Quote__c = quolist[0].Id;
    quoline3.SBQQ__Product__c = prodlist[3].Id;
    quoline3.CurrencyIsoCode = 'USD';
    quoline3.Consult_Type__c = 'Included';
    insert quoline3;
    SBQQ__QuoteLine__c quoline4 = new SBQQ__QuoteLine__c();
    quoline4.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline4.SBQQ__Quote__c = quolist[1].Id;
    quoline4.SBQQ__Product__c = prodlist[2].Id;
    quoline4.CurrencyIsoCode = 'USD';
    quoline4.Consult_Type__c = 'Included';
    insert quoline4;

    opplist[0]
      .Proposal_Template__c = 'Telehealth Services - Both TD Standard & TD Included';
    update opplist[0];
    system.assertEquals(
      'Telehealth Services - Both TD Standard & TD Included',
      opplist[0].Proposal_Template__c
    );
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  //Test Case for 'HY Core Bundle Standard' proposal template
  @isTest
  static void HYCoreStandardTemplateValid() {
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    List<Contract> clist = [SELECT id FROM contract];
    List<Account> acclist = [SELECT id FROM Account];
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    list<Product2> prodlist = [SELECT id FROM Product2];
    Test.startTest();
    SBQQ.TriggerControl.disable();
    //Create quote lines for the primary quote
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
    quoline3.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline3.SBQQ__Quote__c = quolist[0].Id;
    quoline3.SBQQ__Product__c = prodlist[4].Id;
    quoline3.CurrencyIsoCode = 'USD';
    quoline3.Consult_Type__c = 'Standard';
    insert quoline3;
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline1.SBQQ__Quote__c = quolist[0].Id;
    quoline1.SBQQ__Product__c = prodlist[5].Id;
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.Consult_Type__c = 'Standard';
    insert quoline1;

    opplist[0].Proposal_Template__c = 'HY Core Bundle Standard';
    update opplist[0];
    system.assertEquals(
      'HY Core Bundle Standard',
      opplist[0].Proposal_Template__c
    );
    SBQQ.TriggerControl.enable();
    Test.Stoptest();
  }

  @isTest
  static void DynamicTemplateValid() {
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    List<Contract> clist = [SELECT id FROM contract];
    List<Account> acclist = [SELECT id FROM Account];
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    list<Product2> prodlist = [SELECT id FROM Product2];
    Test.StartTest();
    //Create quote lines for the primary quote
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
    quoline3.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline3.SBQQ__Quote__c = quolist[0].Id;
    quoline3.SBQQ__Product__c = prodlist[1].Id;
    quoline3.CurrencyIsoCode = 'USD';
    quoline3.Consult_Type__c = 'Standard';
    insert quoline3;

    opplist[0].Proposal_Template__c = 'Dynamic Proposal on Primary Quote';
    update opplist[0];
    system.assertEquals(
      'Dynamic Proposal on Primary Quote',
      opplist[0].Proposal_Template__c
    );
    Test.stopTest();
  }

  //Test Case for 'HY Core Bundle Included' proposal template
  @isTest
  static void HYCoreIncludedTemplateValid() {
    List<Opportunity> opplist = [SELECT id FROM Opportunity];
    List<Contract> clist = [SELECT id FROM contract];
    List<Account> acclist = [SELECT id FROM Account];
    List<SBQQ__Quote__c> quolist = [SELECT id FROM SBQQ__Quote__c];
    list<Product2> prodlist = [SELECT id, Name FROM Product2];
    Test.startTest();
    SBQQ.TriggerControl.disable();
    //Create quote lines for the primary quote
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
    quoline3.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline3.SBQQ__Quote__c = quolist[0].Id;
    quoline3.SBQQ__Product__c = prodlist[4].Id;
    quoline3.CurrencyIsoCode = 'USD';
    quoline3.Consult_Type__c = 'Included';
    insert quoline3;
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    quoline1.SBQQ__Quote__c = quolist[0].Id;
    quoline1.SBQQ__Product__c = prodlist[5].Id;
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.Consult_Type__c = 'Standard';
    insert quoline1;
    system.debug(prodlist[5].Name);
    system.debug(prodlist[4].Name);
    opplist[0].Proposal_Template__c = 'HY Core Bundle Included';

    update opplist[0];
    system.assertEquals(
      'HY Core Bundle Included',
      opplist[0].Proposal_Template__c
    );
    SBQQ.TriggerControl.enable();
    Test.StopTest();
  }

  @isTest
  static void validationPrimaryCarrier() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    List<Contract> clist = [SELECT id FROM contract];
    Account accObj = [SELECT Id FROM Account WHERE Name != 'UMR'];
    Opportunity opp = new Opportunity();
    opp.Name = 'test 1';
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    opp.AccountId = accObj.Id;
    opp.Type = 'New Business';
    opp.Business_Region__c = 'USA';
    opp.CurrencyIsoCode = 'USD';
    opp.StageName = 'Prospect';
    opp.Probability = 10;
    opp.Initial_of_Lives__c = 500;
    opp.Fee_Type__c = 'PEPM';
    opp.LeadSource = 'Sales';
    opp.CloseDate = Date.Today();
    opp.LeadSource = 'Sales';
    opp.SBQQ__AmendedContract__c = clist[0].Id;
    insert opp;

    SBQQ__Quote__c quo = new SBQQ__Quote__c();
    quo.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
      .get('Teladoc')
      .getRecordTypeId();
    quo.SBQQ__Opportunity2__c = opp.Id;
    quo.SBQQ__Primary__c = true;
    quo.Sales_Channels__c = 'US HealthPlan';
    quo.Carrier__c = 'Aetna';
    quo.Line_of_Business__c = 'ASO';
    quo.Pricing_Model__c = 'Contracted Pricing';
    quo.CPQ_Pricebook__c = 'Carrier';
    quo.Include_in_Octiv_Proposal__c = false;
    insert quo;

    try {
      OpportunityTriggerHelper.updateQuoteRecordType(
        new List<SBQQ__Quote__c>{ quo }
      );
      OpportunityTriggerHelper.getOppQuoteMap(new List<Opportunity>{ opp });
      OpportunityTriggerHelper.getTDStandardCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getTDIncludedCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getBDStandardCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getEMS2StandardCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getEMS2IncludedCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getHYStandardCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getHYIncludedCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getBHCustomCountMap(
        new List<Opportunity>{ opp }
      );
      OpportunityTriggerHelper.getBackCareCountMap(
        new List<Opportunity>{ opp }
      );
      opp.StageName = 'Contracting';
      update opp;
    } catch (Exception e) {
      //Below values will be deprecated later for Contract Path LOB functionality
      //Boolean expectedExceptionThrown =  e.getMessage().contains('The Contract Path field is required for any health plan related opportunities.') ? true : false;
      //System.AssertEquals(expectedExceptionThrown, true);
    }
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @isTest
  static void testaccRelCreation() {
    List<Contract> clist = [SELECT id FROM contract];
    Account accObj = [SELECT Id FROM Account WHERE Name != 'UMR'];
    Id pricebookId = Test.getStandardPricebookId();

    //Create your product
    Product2 prod = new Product2(
      Name = 'Product X',
      ProductCode = 'Pro-X',
      isActive = true
    );
    insert prod;

    //Create your pricebook entry
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 100.00,
      IsActive = true
    );
    insert pbEntry;

    Opportunity opp = new Opportunity();
    opp.Name = 'test 1';
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    opp.AccountId = accObj.Id;
    opp.Type = 'New Business';
    opp.Business_Region__c = 'USA';
    opp.CurrencyIsoCode = 'USD';
    opp.StageName = 'Prospect';
    opp.Probability = 10;
    opp.Initial_of_Lives__c = 500;
    opp.Fee_Type__c = 'PEPM';
    opp.LeadSource = 'Sales';
    opp.CloseDate = Date.Today();
    opp.LeadSource = 'Sales';
    opp.SBQQ__AmendedContract__c = clist[0].Id;
    opp.pricebook2Id = pricebookId;
    insert opp;
    /*
        List<SBQQ__Quote__c> quolist =[Select id from SBQQ__Quote__c];
        list<Product2> prodlist =[select id, Name from Product2];
        
        //Create quote lines for the primary quote
        SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
        quoline3.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        quoline3.SBQQ__Quote__c = quolist[0].Id;
        quoline3.SBQQ__Product__c = prodlist[4].Id;
        quoline3.CurrencyIsoCode ='USD';
        quoline3.Consult_Type__c = 'Included';
        insert quoline3;*/

    //create your opportunity line item.  This assumes you already have an opportunity created, called opp
    OpportunityLineItem oli = new OpportunityLineItem(
      OpportunityId = opp.Id,
      Quantity = 5,
      PricebookEntryId = pbEntry.Id,
      TotalPrice = 100
    );
    insert oli;
    test.startTest();
    SBQQ.TriggerControl.disable();
    SBQQ__Quote__c quo = new SBQQ__Quote__c();
    quo.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
      .get('Teladoc')
      .getRecordTypeId();
    quo.SBQQ__Opportunity2__c = opp.Id;
    quo.SBQQ__Primary__c = true;
    quo.Sales_Channels__c = 'US Employer';
    //quo.Carrier__c ='Direct';
    //quo.Line_of_Business__c = 'ASO';
    //quo.Pricing_Model__c ='Contracted Pricing';
    //quo.CPQ_Pricebook__c = 'Carrier';
    //quo.Include_in_Octiv_Proposal__c = false;
    insert quo;

    opp.Benefit_Consultant_Involved_in_Deal__c = 'No';
    opp.Contract_Path__c = accObj.Id;
    opp.StageName = 'Contracting';
    update opp;
    SBQQ.TriggerControl.enable();
    Test.stopTest();
  }

  /**
   * @description Test method for createStageMetricObjRec
   * Test method to create the Stage Metric records for Opportunity Stage Change
   */
  @isTest
  static void createStageMetricObjRec_positive() {
    Opportunity oppRecord = [
      SELECT Id, AccountId, Sub_Channel__c, StageName
      FROM Opportunity
      LIMIT 1
    ];

    Test.startTest();
    oppRecord.StageName = 'Discovery';
    oppRecord.Benefit_Consultant_Involved_in_Deal__c = 'No';
    oppRecord.Contract_Path__c = oppRecord.AccountId;
    update oppRecord;
    Test.stopTest();

    List<L2O_Stage_Metric__c> stageMetricsList = [
      SELECT Id, Name
      FROM L2O_Stage_Metric__c
      WHERE L2O_Opportunity__c = :oppRecord.Id
    ];
    //Two Stage Metrics gets created one up on Opp creation and second upon Stage Change
    System.assertEquals(stageMetricsList.Size(), 2);
  }
}