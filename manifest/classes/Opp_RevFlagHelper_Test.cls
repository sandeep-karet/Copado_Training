@IsTest
private class Opp_RevFlagHelper_Test {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createUMR();
    Id pricebookId = Test.getStandardPricebookId();

    Opportunity opp = TestDataFactory.createOpportunityWithPriceBook(
      acct.Id,
      pricebookId,
      UserInfo.getUserId()
    );
    insert opp;

    List<Product2> pd = new List<Product2>();
    pd.add(TestDataFactory.CreateProductWithDynamicVals('new MH', 'MYSTR3'));
    pd.add(TestDataFactory.CreateProductWithDynamicVals('Dermatology', 'DERM'));
    pd.add(TestDataFactory.CreateProductWithDynamicVals('Livongo', 'LVN'));
    insert pd;

    SBQQ__Quote__c quoObj = TestDataFactory.createQuote(opp.Id);
    insert quoObj;
  }

  @IsTest
  static void LV_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
      qte.Id,
      prodLvn.Id
    );
    insert quoline1;
    PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prodLvn },
      pricebookId
    )[0];
    insert pbEntry;
    OpportunityLineItem oppli = TestDataFactory.createOLI(
      opp.Id,
      pbEntry.Id,
      quoline1.Id
    );
    insert oppli;
    test.startTest();
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Cross-sell LV Products into TD',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }

  @IsTest
  static void TD_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodTdh = [SELECT Id FROM Product2 WHERE Family = 'Dermatology'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodTdh.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    insert quoline1;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodTdh.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.Product2Id = prodTdh.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli;
    test.startTest();
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Cross-sell TD Products into LV',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }

  @IsTest
  static void TdLvn_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
    Product2 prodTdh = [SELECT Id FROM Product2 WHERE Family = 'Dermatology'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodTdh.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    insert quoline1;
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c();
    quoline2.SBQQ__Quote__c = qte.Id;
    quoline2.SBQQ__Product__c = prodLvn.Id;
    quoline2.SBQQ__Quantity__c = 500;
    quoline2.Consult_Type__c = 'Standard';
    quoline2.SBQQ__PricingMethod__c = 'List';
    quoline2.CurrencyIsoCode = 'USD';
    quoline2.SBQQ__Number__c = 1;
    insert quoline2;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodTdh.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    PricebookEntry pbEntry1 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodLvn.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry1;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.Product2Id = prodTdh.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli;
    OpportunityLineItem oppli1 = new OpportunityLIneItem();
    oppli1.OpportunityId = opp.Id;
    oppli1.Quantity = 1;
    oppli1.TotalPrice = 100;
    oppli1.Product2Id = prodLvn.Id;
    oppli1.PricebookEntryId = pbEntry1.Id;
    oppli1.SBQQ__QuoteLine__c = quoline2.Id;
    insert oppli1;
    test.startTest();
    system.assertEquals(
      'No Synergy',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Cross-sell TD Products into LV',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Cross-sell LV Products into TD',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'Net New Client All Solutions',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }
  @IsTest
  static void NewMH_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodNew = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodNew.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    insert quoline1;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodNew.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.Product2Id = prodNew.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli;
    test.startTest();
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }

  @IsTest
  static void LvNewMh_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
    Product2 prodNew = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodNew.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    insert quoline1;
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c();
    quoline2.SBQQ__Quote__c = qte.Id;
    quoline2.SBQQ__Product__c = prodLvn.Id;
    quoline2.SBQQ__Quantity__c = 500;
    quoline2.Consult_Type__c = 'Standard';
    quoline2.SBQQ__PricingMethod__c = 'List';
    quoline2.CurrencyIsoCode = 'USD';
    quoline2.SBQQ__Number__c = 1;
    insert quoline2;
    PricebookEntry pbEntry1 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodLvn.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry1;
    PricebookEntry pbEntry2 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodNew.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry2;
    OpportunityLineItem oppli1 = new OpportunityLIneItem();
    oppli1.OpportunityId = opp.Id;
    oppli1.Quantity = 1;
    oppli1.TotalPrice = 100;
    oppli1.Product2Id = prodNew.Id;
    oppli1.PricebookEntryId = pbEntry2.Id;
    oppli1.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli1;
    OpportunityLineItem oppli2 = new OpportunityLIneItem();
    oppli2.OpportunityId = opp.Id;
    oppli2.Quantity = 1;
    oppli2.TotalPrice = 100;
    oppli2.Product2Id = prodLvn.Id;
    oppli2.PricebookEntryId = pbEntry1.Id;
    oppli2.SBQQ__QuoteLine__c = quoline2.Id;
    insert oppli2;
    test.startTest();
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }

  @IsTest
  static void TdNewMh_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodTdh = [SELECT Id FROM Product2 WHERE Family = 'Dermatology'];
    Product2 prodNew = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodNew.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    insert quoline1;
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c();
    quoline2.SBQQ__Quote__c = qte.Id;
    quoline2.SBQQ__Product__c = prodTdh.Id;
    quoline2.SBQQ__Quantity__c = 500;
    quoline2.Consult_Type__c = 'Standard';
    quoline2.SBQQ__PricingMethod__c = 'List';
    quoline2.CurrencyIsoCode = 'USD';
    quoline2.SBQQ__Number__c = 1;
    insert quoline2;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodTdh.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    PricebookEntry pbEntry2 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodNew.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry2;

    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.Product2Id = prodTdh.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.SBQQ__QuoteLine__c = quoline2.Id;
    insert oppli;
    OpportunityLineItem oppli1 = new OpportunityLIneItem();
    oppli1.OpportunityId = opp.Id;
    oppli1.Quantity = 1;
    oppli1.TotalPrice = 100;
    oppli1.Product2Id = prodNew.Id;
    oppli1.PricebookEntryId = pbEntry2.Id;
    oppli1.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli1;
    test.startTest();
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }

  @IsTest
  static void LvTdNewMh_Test() {
    Id pricebookId = Test.getStandardPricebookId();
    Account acct = [SELECT Id FROM Account];
    acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
    update acct;
    Opportunity opp = [SELECT Id FROM Opportunity];
    Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
    Product2 prodTdh = [SELECT Id FROM Product2 WHERE Family = 'Dermatology'];
    Product2 prodNew = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3'];
    SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];

    List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
    SBQQ__QuoteLine__c quoline1 = new SBQQ__QuoteLine__c();
    quoline1.SBQQ__Quote__c = qte.Id;
    quoline1.SBQQ__Product__c = prodNew.Id;
    quoline1.SBQQ__Quantity__c = 500;
    quoline1.Consult_Type__c = 'Standard';
    quoline1.SBQQ__PricingMethod__c = 'List';
    quoline1.CurrencyIsoCode = 'USD';
    quoline1.SBQQ__Number__c = 1;
    qlList.add(quoline1);
    SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c();
    quoline2.SBQQ__Quote__c = qte.Id;
    quoline2.SBQQ__Product__c = prodTdh.Id;
    quoline2.SBQQ__Quantity__c = 500;
    quoline2.Consult_Type__c = 'Standard';
    quoline2.SBQQ__PricingMethod__c = 'List';
    quoline2.CurrencyIsoCode = 'USD';
    quoline2.SBQQ__Number__c = 1;
    qlList.add(quoline2);
    SBQQ__QuoteLine__c quoline3 = new SBQQ__QuoteLine__c();
    quoline3.SBQQ__Quote__c = qte.Id;
    quoline3.SBQQ__Product__c = prodLvn.Id;
    quoline3.SBQQ__Quantity__c = 500;
    quoline3.Consult_Type__c = 'Standard';
    quoline3.SBQQ__PricingMethod__c = 'List';
    quoline3.CurrencyIsoCode = 'USD';
    quoline3.SBQQ__Number__c = 1;
    qlList.add(quoline3);
    insert qlList;
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodTdh.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry;
    PricebookEntry pbEntry1 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodLvn.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry1;
    PricebookEntry pbEntry2 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = prodNew.Id,
      UnitPrice = 1.40,
      IsActive = true
    );
    insert pbEntry2;
    test.startTest();
    OpportunityLineItem oppli = new OpportunityLIneItem();
    oppli.OpportunityId = opp.Id;
    oppli.Quantity = 1;
    oppli.TotalPrice = 100;
    oppli.Product2Id = prodTdh.Id;
    oppli.PricebookEntryId = pbEntry.Id;
    oppli.SBQQ__QuoteLine__c = quoline2.Id;
    insert oppli;
    OpportunityLineItem oppli1 = new OpportunityLIneItem();
    oppli1.OpportunityId = opp.Id;
    oppli1.Quantity = 1;
    oppli1.TotalPrice = 100;
    oppli1.Product2Id = prodNew.Id;
    oppli1.PricebookEntryId = pbEntry2.Id;
    oppli1.SBQQ__QuoteLine__c = quoline1.Id;
    insert oppli1;
    OpportunityLineItem oppli2 = new OpportunityLIneItem();
    oppli2.OpportunityId = opp.Id;
    oppli2.Quantity = 1;
    oppli2.TotalPrice = 100;
    oppli2.Product2Id = prodLvn.Id;
    oppli2.PricebookEntryId = pbEntry1.Id;
    oppli2.SBQQ__QuoteLine__c = quoline3.Id;
    insert oppli2;
    system.assertEquals(
      'Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy LV Client';
    update acct;
    system.assertEquals(
      'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Legacy TD Client';
    update acct;
    system.assertEquals(
      'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
    update acct;
    system.assertEquals(
      'Net New Client All Solutions',
      [SELECT Opp_Rev_Synergy_Flag__c FROM Opportunity].Opp_Rev_Synergy_Flag__c
    );
    test.stopTest();
  }
}