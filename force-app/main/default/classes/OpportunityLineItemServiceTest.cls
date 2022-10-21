@isTest
public with sharing class OpportunityLineItemServiceTest {
    
    public static final String DM_SOLUTION = System.Label.DM_Solution;
    public static final String CV_SOLUTION = System.Label.CV_Solution;
    public static final String DP_SOLUTION = System.Label.DP_Solution;
    public static Map<String, Decimal> programToParticipantPercentMap = new Map<String, Decimal>();
    
    @TestSetup
    static void testData(){
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;      
        
        Opportunity__c newBusinessOpp = TestFactory.createTypeBasedOpportunity('New Business');
        newBusinessOpp.Account__c = clientAccount.Id;
        newBusinessOpp.Opportunity_Covered_Lives__c=10000;     
        insert newBusinessOpp;
        
        Pricebook2 livongoPricebook = TestFactory.createPricebook();
        insert livongoPricebook;
        
        List<Product2> programsList = new List<Product2>();
        programsList.add(TestFactory.createProgram('Livongo for Diabetes'));
        programsList.add(TestFactory.createProgram('Livongo for Hypertension'));
        programsList.add(TestFactory.createProgram('Livongo Diabetes Prevention Program'));
        programsList.add(TestFactory.createProgram('Livongo for Weight Management'));
        programsList.add(TestFactory.createProgram('Livongo for Behavioral Health by myStrength 2.0'));
        programsList.add(TestFactory.createWPProgram(CV_SOLUTION, 'Hypertension'));
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
        
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        
        for(PricebookEntry pbe: livongoPBEntriesList) {
            oliList.add(TestFactory.createOpportunityLineItem(newBusinessOpp.Id, pbe.Id));
        }   
        insert oliList;
        
        //UserRole r = new UserRole(DeveloperName = 'Commercial', Name = 'Commercial');
        //insert r;        
    }
    
    private static Opportunity__c getOpportunity() {
        return [SELECT Id, Owner__c, Opportunity_Covered_Lives__c FROM Opportunity__c LIMIT 1];
    }
    
    private static UserRole getUserRole() {
        return [SELECT Id FROM UserRole WHERE DeveloperName = 'Commercial' LIMIT 1];
    }
    
    private static OpportunityLineItem__c getOppLineItem(Id OppId) {
        return [SELECT Id,Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE ID =: OppId LIMIT 1];
    }
    
    private static Pricebook2 getPricebook() {
        return [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Livongo'];
    }    
    
    private static List<OpportunityLineItem__c> getOLI() {
        return [SELECT Id, Program_ID__c, Product2__c,OpportunityProductName__c, Opportunity__r.Opportunity_Covered_Lives__c, Product_Participants__c,Estimated_At_Risk_PPPM__c,
                Pricing_Structure__c, Quantity__c, UnitPrice__c, Gross_Program_ARR__c, Gross_Program_ARR_Copy__c, Program_ARR__c, Program_ARR_Copy__c, Estimated_Partner_Admin_Fees__c,
                 Bypass_Sales_Price_Validation__c, Up_Front_Per_Member__c FROM OpportunityLineItem__c];
    }
     private static Pricing_Structure__c getPricingStructure() {
        return [SELECT Id,Price_Book__c,Program__c,List_Price__c,Name FROM Pricing_Structure__c WHERE Name =: 'Standard' limit 1];
    }
    
    static {
        Map<String, Decimal> ppMap = new Map<String, Decimal>();
        Program_Participant__mdt[] ppMDT = [SELECT Program_Name__c, ParticipantPercentage__c FROM Program_Participant__mdt];
        for (Program_Participant__mdt pp: ppMDT) {
            ppMap.put(pp.Program_Name__c, pp.ParticipantPercentage__c);
        }
        programToParticipantPercentMap = ppMap;        
    }
    
    @isTest
    static void calculateProgramParticipantsTest() {
        Opportunity__c opp=getOpportunity();               
        List<List<OpportunityLineItem__c>> OppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<OpportunityLineItem__c> oliList = getOLI();
        Test.startTest();
        Opportunity__c objopp= TestFactory.createOpportunity();
        Insert objopp;
        
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        Map<Id, Product2> mapToProduct = new Map<Id, Product2>();
        
        Product2 Program = TestFactory.createProgram('myStrength');
        insert Program;
        mapToProduct.put(Program.Id ,Program );
        
        PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, Program.Id);
        PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, Program.Id);
                      
        pbeList.add(standardPbe);
        pbeList.add(pbe);
        insert pbeList;
       
        Pricing_Structure__c ps = new Pricing_Structure__c();
        ps.Name = 'PPPM';
        ps.Price_Book__c = livongoPricebook.Id;
        ps.Program__c = Program.Id;
        ps.IsActive__c = true;
        ps.List_Price__c = 65;
        insert ps;
        
        OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(objopp.Id, pbe.Id);
        oli.Product2__c = Program.Id;
        oli.Currently_Enrolled_Members__c = 1;
        insert oli;
        
        
        Map<Id ,Pricing_Structure__c> MapToPricingStructure = new  Map<Id ,Pricing_Structure__c>();
        MapToPricingStructure.put(ps.Id ,ps);
        oli.Pricing_Structure__c = ps.Id;
        oliList[0].Pricing_Structure__c = ps.Id;
        //OppLineRevCalcHelper.calculateArrFieldValues(oliList);
        OppLineItemList.add(oliList); 
        
        Pricing_Structure__c ps1 = new Pricing_Structure__c();
        ps1.Name = 'PEPM';
        ps1.Price_Book__c = livongoPricebook.Id;
        ps1.Program__c = Program.Id;
        ps1.IsActive__c = true;
        ps1.List_Price__c = 65;
        insert ps1;
        
        OpportunityLineItem__c oli1 = TestFactory.createOpportunityLineItem(objopp.Id, pbe.Id);
        oli1.Product2__c = Program.Id;
        insert oli1;
       
        Map<Id ,Pricing_Structure__c> MapToPricingStructure1 = new  Map<Id ,Pricing_Structure__c>();
        oli1.Pricing_Structure__c = ps1.Id;
        MapToPricingStructure1.put(ps1.Id ,ps1);
        List<OpportunityLineItem__c> lstOLI = new List<OpportunityLineItem__c>();
        lstOLI.add(oli1);
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI);
        ps1.Name = 'PMPM';
        update ps1;
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI);
        
        finalOppLineItemList = OpportunityLineItemService.calculateProgramParticipants(OppLineItemList);
        Test.stopTest();
             
        for (OpportunityLineItem__c finalList: finalOppLineItemList[0]) {              
            if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == CV_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get(CV_SOLUTION) * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == 'Livongo for Diabetes'){
                system.assertEquals((programToParticipantPercentMap.get('Livongo for Diabetes') * opp.Opportunity_Covered_Lives__c), finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == 'Livongo for Hypertension'){
                system.assertEquals((programToParticipantPercentMap.get('Livongo for Hypertension') * opp.Opportunity_Covered_Lives__c), finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == 'Livongo for Weight Management'){
                system.assertEquals((programToParticipantPercentMap.get('Livongo for Weight Management') * opp.Opportunity_Covered_Lives__c), finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == 'Livongo Diabetes Prevention Program'){
                system.assertEquals((programToParticipantPercentMap.get('Livongo Diabetes Prevention Program') * opp.Opportunity_Covered_Lives__c), finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == 'Livongo for Behavioral Health by myStrength 2.0'){
                system.assertEquals(opp.Opportunity_Covered_Lives__c, finalList.Product_Participants__c);
            }    
        }     
    }
     @isTest
    static void calculateProgramParticipantsTests() {
        
        Opportunity__c opp=getOpportunity();               
        List<List<OpportunityLineItem__c>> OppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<OpportunityLineItem__c> oliList = getOLI();
        Test.startTest();
        Opportunity__c objopp= TestFactory.createOpportunity();
        Insert objopp;
        
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        Map<Id, Product2> mapToProduct = new Map<Id, Product2>();
        
        Product2 Program = TestFactory.createProgram('myStrength Complete');
        insert Program;
        mapToProduct.put(Program.Id ,Program );
        
        PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, Program.Id);
        PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, Program.Id);
                      
        pbeList.add(standardPbe);
        pbeList.add(pbe);
        insert pbeList;
       
        Pricing_Structure__c ps = new Pricing_Structure__c();
        ps.Name = 'PPPM';
        ps.Price_Book__c = livongoPricebook.Id;
        ps.Program__c = Program.Id;
        ps.IsActive__c = true;
        ps.List_Price__c = 65;
        insert ps;
        
        OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(objopp.Id, pbe.Id);
        oli.Product2__c = Program.Id;
        system.debug('******@@@'+oli);
        insert oli;
        
        
        Map<Id ,Pricing_Structure__c> MapToPricingStructure = new  Map<Id ,Pricing_Structure__c>();
        MapToPricingStructure.put(ps.Id ,ps);
        oli.Pricing_Structure__c = ps.Id;
        system.debug('mapToProduct'+mapToProduct);
        List<OpportunityLineItem__c> lstOLI = new List<OpportunityLineItem__c>();
        lstOLI.add(oli);
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI);
        ps.Name = 'PEPM';
        update ps;     
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI); 
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI); 
        ps.Name = 'PMPM';
        update ps;     
        OppLineRevCalcHelper.calculateArrFieldValues(lstOLI); 
        //List<OpportunityLineItem> lst = [SELECT Id, Product2Id From OpportunityLineItem Where Id IN: lstOLI];
        System.assertEquals(Program.Id, lstOLI[0].Product2__c); 
        Test.stopTest();
        
    }
    
    
    
    
    @isTest
    static void calculateProgramParticipantsTest1() {
        Opportunity__c opp = getOpportunity();
        List<List<OpportunityLineItem__c>> OppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<OpportunityLineItem__c> oliList = getOLI();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        
        Product2 wpProgram = TestFactory.createWPProgram(DM_SOLUTION, 'Diabetes');
        insert wpProgram;
        
        PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, wpProgram.Id);
        PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, wpProgram.Id);
        
        pbeList.add(standardPbe);
        pbeList.add(pbe);
        insert pbeList;
        
        OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(opp.Id, pbe.Id);
        oli.Price_Book_ID__c = pbe.Pricebook2Id;
        oli.Program_ID__c = pbe.Product2Id;
        insert oli;
        
        //oli.Pricing_Structure__c = 
        oliList.add(oli);
        
        OppLineItemList.add(OLIList);
        
        Test.startTest();
        finalOppLineItemList = OpportunityLineItemService.calculateProgramParticipants(OppLineItemList);
        Test.stopTest();
        
        for (OpportunityLineItem__c finalList: finalOppLineItemList[0]) {
            if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == CV_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get('CV + DM') * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == DM_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get(DM_SOLUTION) * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }
        }
    }
    
    @isTest
    static void calculateProgramParticipantsTest2() {
        Opportunity__c opp = getOpportunity();
        List<List<OpportunityLineItem__c>> OppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<OpportunityLineItem__c> oliList = getOLI();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        
        Product2 wpProgram = TestFactory.createWPProgram(DP_SOLUTION, 'Prediabetes');
        insert wpProgram;
        
        PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, wpProgram.Id);
        PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, wpProgram.Id);
        
        pbeList.add(standardPbe);
        pbeList.add(pbe);
        insert pbeList;
        
        OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(opp.Id, pbe.Id);
        oli.Price_Book_ID__c = pbe.Pricebook2Id;
        oli.Program_ID__c = pbe.Product2Id;
        insert oli;
        
        oliList.add(oli);
        
        OppLineItemList.add(oliList);
        
        Test.startTest();
        finalOppLineItemList = OpportunityLineItemService.calculateProgramParticipants(OppLineItemList);
        Test.stopTest();
        
        for (OpportunityLineItem__c finalList: finalOppLineItemList[0]) {
            if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == CV_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get('CV + DP') * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == DM_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get(DM_SOLUTION) * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }else if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == DP_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get(DP_SOLUTION) * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }
        }
    }
    
    @isTest
    static void calculateProgramParticipantsTest3() {
        Opportunity__c opp = getOpportunity();
        List<List<OpportunityLineItem__c>> OppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<List<OpportunityLineItem__c>> finalOppLineItemList = new List<List<OpportunityLineItem__c>>(); 
        List<OpportunityLineItem__c> oliList = getOLI();
        List<PricebookEntry> standardPbeList = new List<PricebookEntry>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        List<Product2> wpPrograms = new List<Product2>();
        
        wpPrograms.add(TestFactory.createWPProgram(DM_SOLUTION, 'Diabetes'));
        wpPrograms.add(TestFactory.createWPProgram(DP_SOLUTION, 'Prediabetes'));
        insert wpPrograms;
        
        for (Product2 program: wpPrograms) {
            standardPbeList.add(TestFactory.createPricebookEntry(standardPBId, program.Id));
            pbeList.add(TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id));
        }
        
        insert standardPbeList;
        insert pbeList;
        
        for (PricebookEntry pbe: pbeList) {
            OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(opp.Id, pbe.Id);
            oli.Price_Book_ID__c = pbe.Pricebook2Id;
            oli.Program_ID__c = pbe.Product2Id;
            oliList.add(oli);
        }
        
        upsert oliList;
        
        OppLineItemList.add(oliList);
        
        Test.startTest();
        finalOppLineItemList = OpportunityLineItemService.calculateProgramParticipants(OppLineItemList);
        Test.stopTest();
        
        for (OpportunityLineItem__c finalList: finalOppLineItemList[0]) {           
            if(finalList.OpportunityProductName__c!= null && finalList.OpportunityProductName__c == CV_SOLUTION){
                system.assertEquals((programToParticipantPercentMap.get('CV + DM + DP') * opp.Opportunity_Covered_Lives__c) , finalList.Product_Participants__c);
            }
        }        
    }
    
    @isTest
    static void opportunityLineItemTriggerHandlerTest() {
        List<OpportunityLineItem__c> oppLineItemList = getOLI();
        for (OpportunityLineItem__c oli: oppLineItemList) {
            oli.Quantity__c = 12;
            oli.UnitPrice__c = 50;
            oli.Bypass_Sales_Price_Validation__c = True;
        }
        update oppLineItemList;
    }
   
    @isTest
    static void OppPrgmRevSynNeWMH_LegcyCmbndTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynNeWMH_LegcyLvTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
   
    @isTest
    static void OppPrgmRevSynNeWMH_NetNewTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynNeWMH_LegacyTdTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynNeWMH_LegacyHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy HHS Client';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynNeWMH_CombinedHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name = 'myStrength' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__C, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined HHS/LV Client';
        update acc;
        System.AssertEquals('Combined TD/LV Solution (MH)',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynLv_LegcyCmbndTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynLv_LegacyLvTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynLv_NetNewTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynLv_LegacyTdTest() {
        OpportunityLineItem__c oppLine = [SELECT Id, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        update acc;
        System.AssertEquals('Cross-sell LV Products into TD',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void OppPrgmRevSynTD_LegcyCmbndTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined TD/LV Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynTD_LegacyLvTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy LV Client';
        update acc;
        System.AssertEquals('Cross-sell TD Products into LV',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynTD_NetNewTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Net New Client (All Solutions)';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynTD_LegacyTdTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy TD Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynLv_LegacyHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy HHS Client';
        update acc;
        System.AssertEquals('Cross-sell LV to HHS',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynTd_LegacyHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy HHS Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynLv_CombinedHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Product2__r.Name Like '%Livongo%' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined HHS/LV Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
    
    @isTest
    static void OppPrgmRevSynTd_CombinedHHSTest() {
        OpportunityLineItem__c oppLine = [SELECT Id,Name, Program_Family__c, Opportunity__c, Program_Rev_Synergy_Flag__c FROM OpportunityLineItem__c WHERE 
                                       Program_Family__c= 'Teladoc' LIMIT 1];
        Opportunity__c Opp = [SELECT Id, Account__c, Account__r.Acct_Rev_Synergy_Flag__c FROM Opportunity__c WHERE ID =: oppLine.Opportunity__c LIMIT 1];
        Account__c acc = [SELECT Id, Acct_Rev_Synergy_Flag__c FROM Account__c WHERE ID =: opp.Account__c LIMIT 1];
        Test.startTest();
        acc.Acct_Rev_Synergy_Flag__c = 'Legacy Combined HHS/LV Client';
        update acc;
        System.AssertEquals('No Synergy',getOppLineItem(oppLine.Id).Program_Rev_Synergy_Flag__c);
        Test.stopTest();
    }
}