@isTest
private class OppDataMigrationTest {
  @TestSetup
  static void setup() {
    SBQQ.TriggerControl.disable();
    Account acct = TestDataFactory.createUMR();
    Id pricebookId = Test.getStandardPricebookId();

    Opportunity opp = TestDataFactory.createOpportunity(acct.Id);
    opp.Pricebook2Id = pricebookId;
    opp.LVN_Pricebook__c = 'Livongo';
    opp.LVN_Pricing_Structure__c = 'Standard';
    opp.LVN_Migration_Opp__c = true;
    opp.LVN_Pricebook_Type__c = 'Healthplan';
    insert opp;

    List<Product2> pd = new List<Product2>();
    pd.add(
      TestDataFactory.createSingleProduct(
        'Diabetes',
        'Livongo - Diabetes',
        'DIAB'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Livongo BH 2.0',
        'Livongo - Behavioral Health',
        'LVBH-2.0'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Hypertension',
        'Livongo - Hypertension',
        'HYPT'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Weight Management',
        'Livongo - Weight Management',
        'WEIGM'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Chronic Kidney Disease',
        'Livongo - Chronic Kidney Disease',
        'CKD'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Psychiatry Initial Visit Fee',
        'Behavioral Health',
        'BHP1T'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Psychiatry Ongoing Visit Fee',
        'Behavioral HealthH',
        'BHPOT'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Therapy Ongoing Visit Fee',
        'Behavioral HealthH',
        'BHNPT'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Therapy Ongoing Visit Fee',
        'Behavioral HealthH',
        'BHNPT'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'Diabetes Prevention',
        'Livongo - Prediabetes',
        'DIABP'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'CV Solution',
        'Livongo - Hypertension',
        'CVSOL'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'DM Solution',
        'Livongo - Diabetes',
        'DMSOL'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'CKD Solution',
        'Livongo - Chronic Kidney Disease',
        'CKDSOL'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'DP Solution',
        'Livongo - Prediabetes',
        'DPSOL'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct(
        'MyStrength Complete',
        'Livongo - Behavioral Health',
        'MYSTR3'
      )
    );
    pd.add(
      TestDataFactory.createSingleProduct('HF Solution', 'HF Solution', 'HFS')
    );

    insert pd;
    List<Product2> listProd1 = new List<Product2>();
    listProd1.add(pd[0]);
    List<PriceBookEntry> listPBE = TestDataFactory.createPriceBookEntries(
      listProd1,
      pricebookId
    );
    insert listPBE;

    OpportunityLineItem oppli = TestDataFactory.createOLI(
      opp.Id,
      listPBE[0].Id,
      null
    );
    insert oppli;
    SBQQ.TriggerControl.enable();
  }

  @IsTest
  static void dataMigrationTest1() {
    SBQQ.TriggerControl.disable();
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
  }

  @IsTest
  static void dataMigrationTest2() {
    Test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity opp = [SELECT Id FROM Opportunity];
    SBQQ__Quote__c quoObj1 = TestDataFactory.createQuote(opp.Id);
    insert quoObj1;
    opp.LVN_Pricing_Structure__c = 'Health Plan';
    opp.LVN_Contract_Path_Account_Type__c = 'PBM';
    opp.Benefit_Consultant_Involved_in_Deal__c = 'No';
    opp.Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
    //opp.Contract_Path__c = System.Label.TD_Teladoc_Account;
    opp.StageName = 'Closed Won';
    opp.Contracted_Date__c = Date.Today();
    update opp;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    Test.stopTest();
  }

  @IsTest
  static void dataMigrationTest4() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity opp = [SELECT Id FROM Opportunity];
    SBQQ__Quote__c quoObj1 = TestDataFactory.createQuote(opp.Id);
    insert quoObj1;
    opp.LVN_Pricing_Structure__c = 'Reseller';
    opp.LVN_Contract_Path_Account_Type__c = 'TPA';
    opp.Benefit_Consultant_Involved_in_Deal__c = 'No';
    opp.Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
    opp.StageName = 'Closed Won';
    opp.Contracted_Date__c = Date.Today();
    //opp.Contract_Path__c = System.Label.TD_Teladoc_Account;
    update opp;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest6() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity opp = [SELECT Id FROM Opportunity];
    SBQQ__Quote__c quoObj1 = new SBQQ__Quote__c();
    opp.LVN_Pricebook__c = 'ACAP';
    opp.LVN_Pricebook_Type__c = 'Broker';
    update opp;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest7() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity opp = [SELECT Id FROM Opportunity];
    opp.LVN_Pricebook__c = 'DECM';
    opp.LVN_Pricebook_Type__c = 'Reseller';
    update opp;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest8() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Opportunity opp = [SELECT Id FROM Opportunity];
    opp.LVN_Pricebook__c = 'Highmark BCBS';
    opp.LVN_Pricing_Structure__c = 'Standard';
    opp.LVN_Pricebook_Type__c = 'Healthplan';
    update opp;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest9() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'CV Solution'];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    oppli.DM_Create_MSC__c = true;
    oppli.DM_Disable_Teletherapy__c = 'NO';
    insert oppli;
    List<SBQQ__QuoteLine__c> qlList2 = [
      SELECT Id, SBQQ__Product__r.Name
      FROM SBQQ__QuoteLine__c
    ];
    system.debug(qlList2.size());
    Database.executeBatch(new LvnDataMigrationBch(null));
    test.stopTest();
    List<SBQQ__QuoteLine__c> qlList = [
      SELECT Id, SBQQ__Product__r.Name, SBQQ__RequiredBy__c
      FROM SBQQ__QuoteLine__c
    ];
    system.debug(qlList.size());
    for (SBQQ__QuoteLine__c ql : qlList) {
      system.debug(
        ql.Id +
          ' || ' +
          ql.SBQQ__Product__r.Name +
          ' || ' +
          ql.SBQQ__RequiredBy__c
      );
    }
    SBQQ.TriggerControl.enable();
  }

  @IsTest
  static void dataMigrationTest10() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'DM Solution'];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    insert oppli;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
  }

  @IsTest
  static void dataMigrationTest11() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'CKD Solution'];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    insert oppli;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest12() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'DP Solution'];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    insert oppli;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest13() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [
      SELECT Id
      FROM Product2
      WHERE Name = 'MyStrength Complete'
    ];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    insert oppli;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }

  @IsTest
  static void dataMigrationTest14() {
    test.startTest();
    SBQQ.TriggerControl.disable();
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'HF Solution'];
    Opportunity opp = [SELECT Id FROM Opportunity];
    OpportunitylineItem oppliold = [SELECT Id FROM OpportunitylineItem];
    delete oppliold;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prod.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 300;
    oppli.Product2Id = prod.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.DM_Admin_Fee__c = 30;
    oppli.DM_At_Risk_Fee__c = 20;
    oppli.DM_Up_Front_Fee__c = 10;
    oppli.DM_Participant_Quantity__c = 300;
    oppli.UnitPrice = 30;
    oppli.DM_Enrollment_Percentage__c = 5;
    oppli.DM_Participation_Percentage__c = 100;
    oppli.DM_Disable_Teletherapy__c = 'NO';
    insert oppli;
    Database.executeBatch(new LvnDataMigrationBch(null));
    SBQQ.TriggerControl.enable();
    test.stopTest();
  }
}