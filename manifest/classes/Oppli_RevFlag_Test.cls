@IsTest
private class Oppli_RevFlag_Test {
  /*@TestSetup
    static void setup() {
        SBQQ.TriggerControl.disable();
        Account acct = TestDataFactory.createUMR();
        Id pricebookId = Test.getStandardPricebookId();

        Opportunity opp = TestDataFactory.createOpportunityWithPriceBook(acct.Id, pricebookId, UserInfo.getUserId());
        insert opp;
        
        List<Product2> pd = new List<Product2>();
        Product2 prod1 = TestDataFactory.CreateProductWithDynamicVals('MYSTR3', 'MYSTR3');
        prod1.SBQQ__SubscriptionPricing__c = 'Fixed';
        pd.add(prod1);
        Product2 prod2 = TestDataFactory.CreateProductWithDynamicVals('Dermatology', 'DERM');
        prod2.SBQQ__SubscriptionPricing__c = 'Fixed';
        pd.add(prod2);
        Product2 prod3 = TestDataFactory.CreateProductWithDynamicVals('Livongo', 'LVN');
        prod3.SBQQ__SubscriptionPricing__c = 'Fixed';
        pd.add(prod3);
        Product2 prod4 = TestDataFactory.CreateProductWithDynamicVals('NOProvider', 'TEST');
        prod4.SBQQ__SubscriptionPricing__c = 'Fixed';
        pd.add(prod4);    
        insert pd; 
        
        SBQQ__Quote__c quoObj = TestDataFactory.createQuote(opp.Id);
        insert quoObj;
        SBQQ.TriggerControl.enable();
    }

    @IsTest
    static void LV_Product() {
        Test.startTest();
        SBQQ.TriggerControl.disable();
        Id pricebookId = Test.getStandardPricebookId();
        Account acct = [SELECt Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 prodLvn = [SELECT Id FROM Product2 WHERE Family = 'Livongo'];
        SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(qte.Id, prodLvn.Id);
        Insert quoline1;
        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ prodLvn }, pricebookId)[0];
        insert pbEntry;
        OpportunityLineItem oppli = TestDataFactory.createOLI(opp.Id, pbEntry.Id, quoline1.Id);
        insert oppli;
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy LV Client';
        update acct;    
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy TD Client';
        update acct; 
        system.assertEquals('Cross-sell LV Products into TD', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy HHS Client';
        update acct; 
        system.assertEquals('Cross-sell LV to HHS', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy Combined HHS/LV Client';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        Test.stopTest();
        SBQQ.TriggerControl.enable();
    }
 
    
    @IsTest
    static void TD_Product() {
        test.startTest();
        SBQQ.TriggerControl.disable();
        Id pricebookId = Test.getStandardPricebookId();
        Account acct = [SELECt Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 prodTdh = [SELECT Id FROM Product2 WHERE Family = 'Dermatology'];
        SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(qte.Id, prodTdh.Id);
        Insert quoline1;
        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ prodTdh }, pricebookId)[0];
        insert pbEntry;
        OpportunityLineItem oppli = TestDataFactory.createOLI(opp.Id, pbEntry.Id, quoline1.Id);
        insert oppli;
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy LV Client';
        update acct;    
        system.assertEquals('Cross-sell TD Products into LV', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy TD Client';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy HHS Client';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy Combined HHS/LV Client';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        SBQQ.TriggerControl.enable();
        test.stopTest();      
    }  
    
    @IsTest
    static void myStr_Prod() {
        test.startTest();
        SBQQ.TriggerControl.disable();
        Id pricebookId = Test.getStandardPricebookId();
        Account acct = [SELECt Id FROM Account];
        acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
        update acct;
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 myStr = [SELECT Id FROM Product2 WHERE ProductCode = 'MYSTR3'];
        SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(qte.Id, myStr.Id);
        Insert quoline1;
        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ myStr }, pricebookId)[0];
        insert pbEntry;
        OpportunityLineItem oppli = TestDataFactory.createOLI(opp.Id, pbEntry.Id, quoline1.Id);
        insert oppli;
        system.assertEquals('Combined TD/LV Solution (MH)', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy LV Client';
        update acct;    
        system.assertEquals('Combined TD/LV Solution (MH)', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy TD Client';
        update acct; 
        system.assertEquals('Combined TD/LV Solution (MH)', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
        update acct; 
        system.assertEquals('Combined TD/LV Solution (MH)', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        SBQQ.TriggerControl.enable();
        test.stopTest();           
    }  
    
    @IsTest
    static void Fee_Prod() {
        test.startTest();
        SBQQ.TriggerControl.disable();
        Id pricebookId = Test.getStandardPricebookId();
        Account acct = [SELECt Id FROM Account];
        acct.Rev_Synergy__c = 'Legacy Combined TD/LV Client';
        update acct;
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 myStr = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST'];
        SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(qte.Id, myStr.Id);
        Insert quoline1;
        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ myStr }, pricebookId)[0];
        insert pbEntry;
        OpportunityLineItem oppli = TestDataFactory.createOLI(opp.Id, pbEntry.Id, quoline1.Id);
        insert oppli;
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy LV Client';
        update acct;    
        system.assertEquals('Cross-sell TD Products into LV', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Legacy TD Client';
        update acct;  
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        acct.Rev_Synergy__c = 'Net New Client (All Solutions)';
        update acct; 
        system.assertEquals('No Synergy', [SELECT Revenue_Synergy_Flag__c FROM OpportunityLineItem].Revenue_Synergy_Flag__c);
        SBQQ.TriggerControl.enable();
        test.stopTest();           
    }  */
}