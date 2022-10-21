@isTest
public class OpportunityTriggerTest {
    public static final String NEW_BUSINESS = 'New Business';
    public static final String RENEWAL = 'Renewal';
    public static final String EXPANSION = 'Expansion';
    public static final String CROSSSELL = 'Cross-sell (New product)';
    public static final String CONTRACTPATHCHANGE = 'Contract Path Change';
    @TestSetup
    static void setupData() {
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
        
        Account__c partnerAccount = TestFactory.createPartnerAccount();
        insert partnerAccount;
        
        Contract__c clientOverview = TestFactory.createClientOverview();
        clientOverview.Account__c = clientAccount.Id;
        clientOverview.Contract_Path__c = partnerAccount.Id;
        clientOverview.CSM__c = System.UserInfo.getUserId();
        insert clientOverview;
        
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        oppList.add(TestFactory.createTypeBasedOpportunity(NEW_BUSINESS));
        oppList.add(TestFactory.createTypeBasedOpportunity(RENEWAL));
        oppList.add(TestFactory.createTypeBasedOpportunity(EXPANSION));
        oppList.add(TestFactory.createTypeBasedOpportunity(CROSSSELL));
        oppList.add(TestFactory.createTypeBasedOpportunity(CONTRACTPATHCHANGE));
        
        for(Opportunity__c opp: oppList) {
            opp.Account__c = clientAccount.Id;
            opp.Contract_Path__c = partnerAccount.Id;
            if(opp.Type__c == CONTRACTPATHCHANGE) {
                opp.Original_Contract__c = clientOverview.Id;
            }
        }
        
        if(oppList.size() > 0) {
            insert oppList;
        }
        
        List<Opportunity__c> oppRevFlagList = new List<Opportunity__c>();
        oppRevFlagList.add(TestFactory.createTypeBasedOpportunity(NEW_BUSINESS));
        //oppRevFlagList.add(TestFactory.createTypeBasedOpportunity(RENEWAL));
        
        for(Opportunity__c opp: oppRevFlagList){
            opp.Account__c = clientAccount.Id;
            opp.Contract_Path__c = partnerAccount.Id;
            opp.Name = 'Test Opp Rev Synergy' + opp.Type__c;
        }
        
        if(oppRevFlagList.size() > 0){
            insert oppRevFlagList;
        } 
        
        Pricebook2 livongoPricebook = TestFactory.createPricebook();
        insert livongoPricebook;
        
        List<Product2> programsList = new List<Product2>();
        programsList.add(TestFactory.createProgram('Livongo for Diabetes'));
        programsList.add(TestFactory.createProgram('Livongo for Hypertension'));
        programsList.add(TestFactory.createProgram('Livongo Diabetes Prevention Program'));
        programsList.add(TestFactory.createProgram('Teladoc'));
        programsList.add(TestFactory.createProgram('myStrength'));
        programsList.add(TestFactory.createProgram('myStrength Complete'));
        
        insert programsList;
        
        Id standardPBId = Test.getStandardPricebookId();
        
        List<PricebookEntry> entriesList = new List<PricebookEntry>();
        List<PricebookEntry> livongoPBEntriesList = new List<PricebookEntry>();
        List<Pricing_Structure__c> pricingStructureList = new List<Pricing_Structure__c>();
        
        for(Product2 program: programsList) {
            entriesList.add(TestFactory.createPricebookEntry(standardPBId, program.Id));
            livongoPBEntriesList.add(TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id));
            pricingStructureList.add(TestFactory.createPricingStructure(livongoPricebook.Id, program.Id));
        }
        
        insert entriesList;
        insert livongoPBEntriesList;
        insert pricingStructureList;
        
        Map<Id,Id> standardPricingStructureMap = new Map<Id,Id>();
        for(Pricing_Structure__c ps: pricingStructureList) {
            standardPricingStructureMap.put(ps.Program__c, ps.Id);
        }
        
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        
        for (Opportunity__c oppty: oppList) {
            for(PricebookEntry pbe: livongoPBEntriesList) {
                oliList.add(TestFactory.createOpportunityLineItem(oppty.Id, pbe.Id));
            }
        }
        
        insert oliList;
        
        for(OpportunityLineItem__c oli: oliList) {
            oli.Product_Participants__c = 100;
            oli.UnitPrice__c = 62.00;
            oli.OpportunityProductName__c = 'Livongo for Diabetes';
        }
        
        update oliList;
    }
    
    private static Account__c getAccountById(Id accId) {
        return [SELECT Id, Name, Client_ARR__c FROM Account__c WHERE Id = :accId LIMIT 1];
    }
    
    private static Set<Id> getAccountIdSet() {
        Map<Id, Account__c> accIdMap = new Map<Id, Account__c>([SELECT Id FROM Account__c LIMIT 200]);
        Set<Id> accIdSet = new Set<Id>(accIdMap.keySet());
        return accIdSet;
    }
    
    private static Opportunity__c getOpportunityByType(String Type) {
        return [SELECT Id, Name, Account__c, Type__c, Gross_ARR__c, Adjusted_Annual_Renewal_Value_Enrolled__c,
                Livongo_for_Diabetes_PPPM__c, Livongo_for_Diabetes_PwDs__c, Account__r.Client_Arr__c, CloseDate__c, 
                (SELECT Id, Product_Participants__c, UnitPrice__c, Pricing_Structure__r.Name, Quantity__c, Program_Family__c, 
                 Gross_Program_ARR__c, Gross_Program_ARR_Copy__c FROM LGVO_OpportunityProducts__r)
                FROM Opportunity__c WHERE Type__c = :Type LIMIT 1];
    }
    
    private static PricebookEntry getPBE() {
        return [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'Livongo for Diabetes' AND Pricebook2.Name = 'Livongo' LIMIT 1];
    }
    
    private static List<PricebookEntry> getLivongoPBEs() {
        return [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' and Product2.Name Like 'Livongo%'];
    }
    
    private static List<OpportunityLineItem__c> getOLI() {
        return [SELECT Id, Name, Product_Participants__c,OpportunityProductName__c, UnitPrice__c, Pricing_Structure__r.Name, Quantity__c, Program_Family__c, Gross_Program_ARR__c, 
                Gross_Program_ARR_Copy__c FROM OpportunityLineItem__c]; 
    }
    
    private static Opportunity__c getOpportunity(){
        return [SELECT Id, Name, Type__c, Account__c, Opp_Rev_Synergy_Flag__c FROM Opportunity__c WHERE Name Like 'Test Opp Rev Synergy%' and Type__c = 'New Business'];
    }
    
    private static Account__c getAccount(Opportunity__c OppRev){
        return [SELECT Id, Name, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE Id =: oppRev.Account__c];
    }
    
    private static List<OpportunityLineItem__c> getOppLineItems(Id OppRevId, List<PriceBookEntry> pbes){
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        for(PricebookEntry pbe: pbes) {
                oliList.add(TestFactory.createOpportunityLineItem(oppRevId, pbe.Id));
            }  
        insert oliList;
        return oliList;
    }
    @isTest
    static void singleNBOpportunityTest() {
        Test.startTest();
        Opportunity__c opp = getOpportunityByType(NEW_BUSINESS);
        opp.StageName__c = 'Closed Won';
        
        update opp;
        
        Account__c acc = getAccountById(opp.Account__c);
        OpportunityTriggerHandler.handleRevFieldsCalculationFromOpp(new Set<Id>{ opp.Id });
        Test.stopTest();
        System.assertEquals(opp.Gross_ARR__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void singleRenewalOpportunityTest() {
        Test.startTest();
        Opportunity__c opp = getOpportunityByType(RENEWAL);
        opp.StageName__c = 'Closed Won';
        
        update opp;
        
        Account__c acc = getAccountById(opp.Account__c);
        Test.stopTest();
        System.assertEquals(opp.Adjusted_Annual_Renewal_Value_Enrolled__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void newBusinessAndRenewalOpportunityTest() {
        Test.startTest();
        Opportunity__c nbOpp = getOpportunityByType(NEW_BUSINESS);
        nbOpp.StageName__c = 'Closed Won';
        Opportunity__c renewalOpp = getOpportunityByType(RENEWAL);
        renewalOpp.StageName__c = 'Closed Won';
        
       
        update nbOpp;
        update renewalOpp; 
        
        
        Account__c acc = getAccountById(renewalOpp.Account__c);
        Test.stopTest();
        System.assertEquals(renewalOpp.Adjusted_Annual_Renewal_Value_Enrolled__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void renewalAndContractPathChangeOpportunityTest() {
        Test.startTest();
        Opportunity__c renewalOpp = getOpportunityByType(RENEWAL);
        renewalOpp.StageName__c = 'Closed Won';

        Opportunity__c contractPathChangeOpp = getOpportunityByType(CONTRACTPATHCHANGE);
        contractPathChangeOpp.StageName__c = 'Closed Won';
        contractPathChangeOpp.CloseDate__c = Date.today().addDays(-1);
          
        update renewalOpp; 
        update contractPathChangeOpp;
        
        Account__c acc = getAccountById(renewalOpp.Account__c);
        Test.stopTest();
        System.assertEquals(renewalOpp.Adjusted_Annual_Renewal_Value_Enrolled__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void renewalAndContractPathChangeOpportunityTest2() {
        Test.startTest();
        Opportunity__c renewalOpp = getOpportunityByType(RENEWAL);
        renewalOpp.StageName__c = 'Closed Won';
        renewalOpp.CloseDate__c = Date.today().addDays(-1);

        Opportunity__c contractPathChangeOpp = getOpportunityByType(CONTRACTPATHCHANGE);
        contractPathChangeOpp.StageName__c = 'Closed Won';
        
        update renewalOpp; 
        update contractPathChangeOpp;
        
        Account__c acc = getAccountById(contractPathChangeOpp.Account__c);
        Test.stopTest();
        System.assertEquals(contractPathChangeOpp.Gross_ARR__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void renewalAndExpansionOpportunityTest() {
        Test.startTest();
        Opportunity__c renewalOpp = getOpportunityByType(RENEWAL);
        renewalOpp.StageName__c = 'Closed Won';
        renewalOpp.CloseDate__c = Date.today().addDays(-1);

        Opportunity__c expansionOpp = getOpportunityByType(EXPANSION);
        expansionOpp.StageName__c = 'Closed Won';
         
        update renewalOpp; 
        update expansionOpp;
        
        Account__c acc = getAccountById(expansionOpp.Account__c);
        Test.stopTest();
        System.assertEquals(expansionOpp.Gross_ARR__c + renewalOpp.Adjusted_Annual_Renewal_Value_Enrolled__c, acc.Client_Arr__c);
    }
    
    @isTest
    static void renewalAndExpansionOpportunityTest2() {
        Test.startTest();
        Opportunity__c renewalOpp = getOpportunityByType(RENEWAL);
        renewalOpp.StageName__c = 'Closed Won';

        Opportunity__c expansionOpp = getOpportunityByType(EXPANSION);
        expansionOpp.StageName__c = 'Closed Won';
        expansionOpp.CloseDate__c = Date.today().addDays(-1);
        
        PricebookEntry pbe = getPBE();
        OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(expansionOpp.Id, pbe.Id);
        
        insert oli;
   
        update renewalOpp; 
        update expansionOpp;
        Boolean isProdutsMatched = OpportunityService.findIfOppProductsMatch(renewalOpp, expansionOpp);
        
        
        Account__c acc = getAccountById(expansionOpp.Account__c);
        Test.stopTest();
        System.assertEquals(isProdutsMatched, false);
    }
    
    @isTest
    static void newBusinessAndContractPathChangeOpportunityTest() {
        Test.startTest();
        Opportunity__c nbOpp = getOpportunityByType(NEW_BUSINESS);
        nbOpp.StageName__c = 'Closed Won';
        nbOpp.CloseDate__c = Date.today().addDays(-1);
        
        Opportunity__c contractPathChangeOpp = getOpportunityByType(CONTRACTPATHCHANGE);
        contractPathChangeOpp.StageName__c = 'Closed Won';
        
        update nbOpp;
        update contractPathChangeOpp; 
        
        Account__c acc = getAccountById(contractPathChangeOpp.Account__c);
        Test.stopTest();
        System.assertEquals(contractPathChangeOpp.Gross_ARR__c , acc.Client_Arr__c);
    }
    
    @isTest
    static void newBusinessAndExpansionOpportunityTest() {
        Test.startTest();
        Opportunity__c nbOpp = getOpportunityByType(NEW_BUSINESS);
        nbOpp.StageName__c = 'Closed Won';
        
        Opportunity__c expansionOpp = getOpportunityByType(EXPANSION);
        expansionOpp.StageName__c = 'Closed Won';
        
        
        update nbOpp;
        update expansionOpp; 
        
        
        Account__c acc = getAccountById(expansionOpp.Account__c);
        Test.stopTest();
        System.assertEquals(nbOpp.Gross_ARR__c + expansionOpp.Gross_ARR__c, acc.Client_Arr__c);
    }
    
    @isTest
    static void clientARRUpdateFromAccountTest(){
        Test.startTest();
        Set<Id> accIdSet = getAccountIdSet();
        
        Opportunity__c nbOpp = getOpportunityByType(NEW_BUSINESS);
        nbOpp.StageName__c = 'Closed Won';
        
        Opportunity__c expansionOpp = getOpportunityByType(EXPANSION);
        expansionOpp.StageName__c = 'Closed Won';

        
        update nbOpp;
        update expansionOpp; 
        OpportunityService.handleClientARRUpdateFromAccount(accIdSet);
        
        
        Account__c acc = getAccountById(expansionOpp.Account__c);
        Test.stopTest();
        System.assertEquals(nbOpp.Gross_ARR__c + expansionOpp.Gross_ARR__c, acc.Client_Arr__c);
    }
    
    @isTest
    static void healthScoresTest() {
        Test.startTest();
        Opportunity__c opp = getOpportunityByType(RENEWAL);
        opp.CloseDate__c = Date.today().addMonths(24);
        
        
        update opp;
        
        
        List<Health_Score__c> hsList = [SELECT Id, Account__c, Actual_Result__c FROM Health_Score__c 
                                            WHERE Account__c = :opp.Account__c AND RecordType.Name = 'Account Health Score' 
                                            AND Health_Segment__c = 'Renewal Timing'];
        Health_Score__c hsScore = hsList[0];
        Test.stopTest();
        
        System.assertEquals('>1 year', hsScore.Actual_Result__c);
    }
    
     @isTest
    static void oppRevSynLV_LegcyCmbndTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        List<PricebookEntry> pbes = getLivongoPBEs();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client'; 
        Test.startTest();
        update acc;
       
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynLV_LegcyLvTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        List<PricebookEntry> pbes = getLivongoPBEs();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client'; 
        
        Test.startTest();
        update acc;
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
     @isTest
    static void oppRevSynLV_NetNewTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        List<PricebookEntry> pbes = getLivongoPBEs();
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)'; 
        Test.startTest();
        update acc;
        
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynLV_LegacyTdTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        List<PricebookEntry> pbes = getLivongoPBEs();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client'; 
        Test.startTest();
        update acc;
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell LV Products into TD',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynFTD_LegcyCmbndTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Family = 'Teladoc' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();        
    }
    
    @isTest
    static void oppRevSynFTD_LegacyLVTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Family = 'Teladoc' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell TD Products into LV',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynFTD_NetNewTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Family = 'Teladoc' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynFTD_LegacyTDTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Family = 'Teladoc' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
   @isTest
    static void oppRevSynNewMH_LegcyCmbndTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Name = 'myStrength' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynNewMH_LegacyLvTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Name = 'myStrength' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynNewMH_NetNewTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Name = 'myStrength' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevSynNewMH_LegacyTdTest() {
        
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        Test.startTest();
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Name = 'myStrength' Limit 1];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTDNewMH_LegcyCmbndTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTDNewMH_LegcyLvTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTDNewMH_NetNewTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Net New Client (All Solutions)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTDNewMH_LegacyTdTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    
    @isTest
    static void oppRevFlagLvTD_LegcyCmbndTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND Product2.Name != 'myStrength' 
                                     AND Product2.Name != 'myStrength Complete'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('No Synergy',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    } 
    
    @isTest
    static void oppRevFlagLvTD_LegacyLvTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND Product2.Name != 'myStrength' 
                                     AND Product2.Name != 'myStrength Complete'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell TD Products into LV',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTD_NetNewTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND Product2.Name != 'myStrength' 
                                     AND Product2.Name != 'myStrength Complete'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Net New Client (All Solutions)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvTD_LegacyTdTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND Product2.Name != 'myStrength' 
                                     AND Product2.Name != 'myStrength Complete'];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell LV Products into TD',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagTdNewMH_LegcyCmbndTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Family = 'Teladoc' OR Product2.Name = 'myStrength')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    } 
    
    @isTest
    static void oppRevFlagTdNewMH_LegacyLvTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Family = 'Teladoc' OR Product2.Name = 'myStrength')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagTdNewMH_NetNewTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Family = 'Teladoc' OR Product2.Name = 'myStrength')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Cross-sell TD Products into LV + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagTdNewMH_LegacyTdTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        
        update acc;
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Family = 'Teladoc' OR Product2.Name = 'myStrength')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvNewMH_LegcyCmbndTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        
        update acc;        
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Name ='myStrength' OR Product2.Family != 'Teladoc')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvNewMH_LegacyLvTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        
        update acc;        
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Name ='myStrength' OR Product2.Family != 'Teladoc')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        
        System.AssertEquals('Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvNewMH_NetNewTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        
        update acc;        
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Name ='myStrength' OR Product2.Family != 'Teladoc')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        
        System.AssertEquals('Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void oppRevFlagLvNewMH_LegacyTdTest() {
        Test.startTest();
        Opportunity__c oppRev = getOpportunity();
        Account__c acc = getAccount(oppRev);
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        
        update acc;        
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo' AND (Product2.Name ='myStrength' OR Product2.Family != 'Teladoc')];
        List<OpportunityLineItem__c> oliList = getOppLineItems(oppRev.Id,pbes);
        
        System.AssertEquals('Cross-sell LV Products into TD + Combined TD/LV Solution (MH)',getOpportunity().Opp_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
}