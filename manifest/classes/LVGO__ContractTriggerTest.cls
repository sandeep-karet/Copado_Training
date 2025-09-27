@isTest
public class ContractTriggerTest {

    public static final Id PROGRAM_OVERVIEW_RT = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId();
    public static final Id OPPORTUNITY_PARTNERSHIP_RT = Schema.SObjectType.Relationship__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Partnership').getRecordTypeId();
    public static final Id PRIMARY_PRODUCT_RT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Primary_Product').getRecordTypeId(); 
    public static final Integer DEFAULT_FALLBACK_VALUE = Integer.valueOf(System.Label.Default_Renewal_Opp_Fallback_Value);
    public static final String DM_SOLUTION = System.Label.DM_Solution;
    public static final String CV_SOLUTION = System.Label.CV_Solution;
    public static final String DP_SOLUTION = System.Label.DP_Solution;
    
    @TestSetup
    static void setupData() {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        
        Account__c clientAccount = TestFactory.createClientAccount();
        Account__c partnerAccount = TestFactory.createPartnerAccount();
        
        Contract__c clientOverview = TestFactory.createClientOverview();
        Contract__c programOverview = TestFactory.createProgramOverview();
        Contract__c programOverview2 = TestFactory.createProgramOverview();
        Contract__c programOverview3 = TestFactory.createProgramOverview();

        Pricebook2 livongoPricebook = TestFactory.createPricebook();
        insert livongoPricebook;

        List<Product2> programs = new List<Product2>();
        Product2 program = TestFactory.createProgram('Diabetes');
        program.Whole_Person_Solution__c = false; 
        program.recordtypeid=PRIMARY_PRODUCT_RT; 

        Product2 program2 = TestFactory.createProgram('Hypertension'); 
program2.Whole_Person_Solution__c = false; 
program2.recordtypeid=PRIMARY_PRODUCT_RT; 
        Product2 program3 = TestFactory.createProgram('Prediabetes'); 
program3.Whole_Person_Solution__c = false; 
program3.recordtypeid=PRIMARY_PRODUCT_RT; 
        Product2 program4 = TestFactory.createProgram('myStrength'); 
program4.Whole_Person_Solution__c = false; 
program4.recordtypeid=PRIMARY_PRODUCT_RT; 
        Product2 program5 = TestFactory.createProgram('mystrength Complete'); 
program5.Whole_Person_Solution__c = false; 
program5.recordtypeid=PRIMARY_PRODUCT_RT; 
        Product2 program6 = TestFactory.createProgram('Teladoc'); 
program6.Whole_Person_Solution__c = false; 
program6.recordtypeid=PRIMARY_PRODUCT_RT; 
        programs.add(program);
        programs.add(program2);
        programs.add(program3);
        programs.add(program4);
        programs.add(program5);
        programs.add(program6);
        insert programs;

        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry standardPBE1 = TestFactory.createPricebookEntry(standardPBId, program.Id);
        PricebookEntry standardPBE2 = TestFactory.createPricebookEntry(standardPBId, program2.Id);
        PricebookEntry standardPBE3 = TestFactory.createPricebookEntry(standardPBId, program3.Id);
        PricebookEntry standardPBE4 = TestFactory.createPricebookEntry(standardPBId, program4.Id);
        PricebookEntry standardPBE5 = TestFactory.createPricebookEntry(standardPBId, program5.Id);
        PricebookEntry standardPBE6 = TestFactory.createPricebookEntry(standardPBId, program6.Id);
        PricebookEntry pbe1 = TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id);
        PricebookEntry pbe2 = TestFactory.createPricebookEntry(livongoPricebook.Id, program2.Id);
        PricebookEntry pbe3 = TestFactory.createPricebookEntry(livongoPricebook.Id, program3.Id);
        PricebookEntry pbe4 = TestFactory.createPricebookEntry(livongoPricebook.Id, program4.Id);
        PricebookEntry pbe5 = TestFactory.createPricebookEntry(livongoPricebook.Id, program5.Id);
        PricebookEntry pbe6 = TestFactory.createPricebookEntry(livongoPricebook.Id, program6.Id);

        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(standardPBE1);
        entries.add(standardPBE2);
        entries.add(standardPBE3);
        entries.add(standardPBE4);
        entries.add(standardPBE5);
        entries.add(standardPBE6);
        entries.add(pbe1);
        entries.add(pbe2);
        entries.add(pbe3);
        entries.add(pbe4);
        entries.add(pbe5);
        entries.add(pbe6);
        insert entries;
        
        List<Pricing_Structure__c> pricingStructureList = new List<Pricing_Structure__c>();
        for (Product2 p :programs) {
            pricingStructureList.add(TestFactory.createPricingStructure(livongoPricebook.Id, p.Id));
        }
        insert pricingStructureList;
        
        Pricing_Structure__c ps = TestFactory.createPricingStructure(livongoPricebook.Id, programs[0].Id);
        ps.Name='Livongo';
        insert ps;
        
        List<Account__c> accounts = new List<Account__c>();
        accounts.add(clientAccount);
        accounts.add(partnerAccount);
        insert accounts;

        clientOverview.Account__c = clientAccount.Id;
        clientOverview.Contract_Path__c = partnerAccount.Id;
        clientOverview.CSM__c = System.UserInfo.getUserId();
        clientOverview.Name = 'Test Client Overview';

        List<Contract__c> cList = new List<Contract__c>();
        cList.add(clientOverview);
        insert cList;

        Opportunity__c opp = TestFactory.createOpportunity();
        opp.Account__c = clientAccount.Id;
        opp.Contract__c = clientOverview.Id;
        insert opp;

        programOverview.Client_Overview__c = clientOverview.Id;
        programOverview.Account__c = clientAccount.Id;
        programOverview.Program_Name__c = 'Diabetes';
        programOverview.Pricebook2__c = livongoPricebook.Id; 

        programOverview2.Client_Overview__c = clientOverview.Id;
        programOverview2.Account__c = clientAccount.Id;
        programOverview2.Program_Name__c = 'Hypertension';

        programOverview3.Client_Overview__c = clientOverview.Id;
        programOverview3.Account__c = clientAccount.Id;
        programOverview3.Program_Name__c = 'Prediabetes';

        cList.add(programOverview);
        cList.add(programOverview2);
        cList.add(programOverview3);
        upsert cList;
    }

    private static Pricebook2 getPricebook() {
        return [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Livongo'];
    }

    private static List<Contract__c> getProgramOverviews() {
        return [SELECT Id, Program_End_Date__c, Complete_Per_Legal__c, Client_Overview__c, RecordTypeId, Account__c, Program_Name__c, 
                Actual_Launch_Date__c, Last_Date_of_Data_Refresh__c, Outreach_Stratification__c FROM Contract__c WHERE RecordTypeId = :PROGRAM_OVERVIEW_RT];
    }

    private static List<Contract__c> getClientOverview() {
        return [SELECT Id, CSM__c, CIM__c, Contract_Path__c, Account__c FROM Contract__c];
    }

    private static Contract__c getClientOverviewFromProgramOverview(Id clientOverviewId) {
        return [SELECT Id, CSM__c, CIM__c, Contract_Path__c, Account__c, Account__r.Name, Account__r.OwnerId FROM Contract__c WHERE Id = :clientOverviewId];
    }

    private static List<Opportunity__c> getOpportunities() {
        return [SELECT Id, Name, Account__c, Type__c, StageName__c, Owner__c, Contract_Path__c, Contract__c, CloseDate__c FROM Opportunity__c];
    }

    private static List<Opportunity__c> getOpportunitiesWithIds(Set<Id> idSet) {
            return [SELECT Id, Name, Account__c, Type__c, StageName__c, Owner__c, Contract_Path__c, Contract__c, CloseDate__c FROM Opportunity__c WHERE Id IN :idset];
    }

    private static List<OpportunityLineItem__c> getOpportunityPrograms() {
        return [SELECT Id, Opportunity__c, Program_Family__c, UnitPrice__c, Product2__c, Product_Participants__c FROM OpportunityLineItem__c];
    }
    
    private static List<PricebookEntry> getlivongoPBEntriesList() {
        return [SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Livongo'];
    }
    
    private static List<Pricing_Structure__c> getLivongoPBPricingStructures() {
        return [SELECT Id, Program__c, Program__r.Id, Program__r.Name FROM Pricing_Structure__c WHERE Price_Book__r.Name = 'Livongo'];
    }
    
    @isTest
    static void updatePOsCampaignFields() {
        Contract__c co = [SELECT Id,Campaign_Lifecycle_Participation__c, Custom_Campaign__c, Phone_Campaign__c,Enrollment_on_Autopilot__c,
                           Campaign_Type__c FROM Contract__c WHERE Name = 'Test Client Overview'];
        co.Campaign_Lifecycle_Participation__c = 'TLC';
        co.Custom_Campaign__c = 'Medicaid';
        co.Phone_Campaign__c = 'With Phone';
        co.Campaign_Type__c = 'Custom';
        co.Enrollment_on_Autopilot__c = true;
        Test.startTest();
        update co;
        List<Contract__c> poList = [SELECT Id,Campaign_Lifecycle_Participation__c, Custom_Campaign__c, Phone_Campaign__c,Enrollment_on_Autopilot__c,
                           Campaign_Type__c FROM Contract__c WHERE Client_Overview__c =: co.Id];
        System.assertEquals(co.Campaign_Lifecycle_Participation__c, poList[0].Campaign_Lifecycle_Participation__c);
        System.assertEquals(co.Custom_Campaign__c, poList[0].Custom_Campaign__c);
        System.assertEquals(co.Phone_Campaign__c, poList[0].Phone_Campaign__c);
        System.assertEquals(co.Campaign_Type__c, poList[0].Campaign_Type__c);
        System.assertEquals(co.Enrollment_on_Autopilot__c, poList[0].Enrollment_on_Autopilot__c);
        Test.stopTest();
    }
    
    @isTest
    static void updatePOonCreate(){
        Contract__c clientOverview = [SELECT Id,Account__c, Campaign_Lifecycle_Participation__c, Custom_Campaign__c, Phone_Campaign__c,Enrollment_on_Autopilot__c,
                           Campaign_Type__c FROM Contract__c WHERE Name = 'Test Client Overview'];
        Contract__c programOverview = new Contract__c();
        programOverview.Client_Overview__c = clientOverview.Id;
        programOverview.Account__c = clientOverview.Account__c;
        programOverview.Program_Name__c = 'Diabetes';
        Test.startTest();
        insert programOverview;
        Contract__c po = [SELECT Campaign_Lifecycle_Participation__c, Custom_Campaign__c, Phone_Campaign__c,Enrollment_on_Autopilot__c,
                           Campaign_Type__c FROM Contract__c WHERE ID =: programOverview.Id];
        System.assertEquals(clientOverview.Campaign_Lifecycle_Participation__c, programOverview.Campaign_Lifecycle_Participation__c);
        System.assertEquals(clientOverview.Custom_Campaign__c, programOverview.Custom_Campaign__c);
        System.assertEquals(clientOverview.Phone_Campaign__c, programOverview.Phone_Campaign__c);
        System.assertEquals(clientOverview.Campaign_Type__c, programOverview.Campaign_Type__c);
        System.assertEquals(clientOverview.Enrollment_on_Autopilot__c, programOverview.Enrollment_on_Autopilot__c);
        
        Test.stopTest();
    }
    @isTest
    static void getProgramAbbreviationsTest() {
        Program_Abbreviation__mdt[] programMdts = [SELECT Program_Name__c, Abbreviation__c FROM Program_Abbreviation__mdt];
        Map<String, String> programsToAbbreviations = new Map<String, String>();
        for (Program_Abbreviation__mdt programMdt : programMdts) {
            programsToAbbreviations.put(programMdt.Program_Name__c, programMdt.Abbreviation__c);
        }
        
        Test.startTest();
        
        Map<String, String> abbreviations = ContractService.abbreviations;
        
        Test.stopTest();
        
        System.assertNotEquals(null, abbreviations);
        System.assertEquals(true, abbreviations.containsKey('Diabetes'));
        System.assertEquals('DM', abbreviations.get('Diabetes'));
        System.assertEquals(true, abbreviations.containsKey('Hypertension'));
        System.assertEquals('HTN', abbreviations.get('Hypertension'));
        System.assertEquals(true, abbreviations.containsKey('Behavioral Health'));
        System.assertEquals('BH', abbreviations.get('Behavioral Health'));
        System.assertEquals(true, abbreviations.containsKey('Prediabetes'));
        System.assertEquals('DPP', abbreviations.get('Prediabetes'));
        System.assertEquals(true, abbreviations.containsKey('Weight Management'));
        System.assertEquals('WM', abbreviations.get('Weight Management'));
    }

    @isTest
    static void contractUpdateNoCompletePerLegalChangeTest() {
        List<Contract__c> pos = getProgramOverviews();
        for (Contract__c po : pos) {
              po.PPPM__c = 999;
        }

        Test.startTest();

        update pos;

        Test.stopTest();

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        List<Opportunity__c> opportunities = getOpportunities();

        System.assertEquals(0, oppPrograms.size());
        //1, because opp created already in test setup
        System.assertEquals(1, opportunities.size());
    }

    @isTest
    static void contractUpdateCompletedPerLegalChangeButNoOpportunityAssociatedWithClientOverviewTest() {
        List<Opportunity__c> opportunities = getOpportunities();
       
        List<Relationship__c> opportunityPartnershipRelationships = [SELECT Id, RecordTypeId, Opportunity_Partnership__c FROM Relationship__c WHERE RecordTypeId = :OPPORTUNITY_PARTNERSHIP_RT AND Opportunity_Partnership__c = :opportunities[0].Id];
        //must delete opportunity partnership relationships before can delete opp.
        delete opportunityPartnershipRelationships;
        //once relationships deleted, delete opp.
        delete opportunities;

        List<Contract__c> pos = getProgramOverviews();
        for (Contract__c po : pos) {
            po.Program_End_Date__c = Date.today().addDays(10);
            po.Complete_Per_Legal__c = true;
        }

        Test.startTest();

        update pos;

        Test.stopTest();

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        List<Opportunity__c> opps = getOpportunities();

        //None should get created because there is no Opp associated with the CO
        System.assertEquals(0, oppPrograms.size());
        //Initially inserted Opp deleted at beginning of this test method
        System.assertEquals(0, opps.size());

    }

    /* @isTest
    static void contractUpdateSameProgramEndDateOnProgramOverviewsTest() {

        List<Contract__c> pos = getProgramOverviews();
        for (Contract__c po : pos) {
            po.Program_End_Date__c = Date.today().addDays(5);
            po.Complete_Per_Legal__c = true;
        }

        Test.startTest();

        update pos;

        Test.stopTest();

        List<Contract__c> programOverviews = getProgramOverviews();
    
        for (Contract__c po : programOverviews) {
            System.assertEquals(Date.today().addDays(5), po.Program_End_Date__c);
        }

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        Set<Id> oppIds = new Set<Id>();
        System.assertEquals(3, oppPrograms.size());
        for (OpportunityLineItem__c oppProgram : oppPrograms) {
            oppIds.add(oppProgram.Opportunity__c);
        }

        List<Opportunity__c> opps = getOpportunitiesWithIds(oppIds);
        System.assertEquals(1, opps.size());
        System.assertEquals(Date.today().addDays(5), opps[0].CloseDate__c);
        System.assertEquals('Renewal', opps[0].Type__c);
        System.assertEquals('Review/Negotiation', opps[0].StageName__c);
        System.assertEquals(System.UserInfo.getUserId(), opps[0].Owner__c);
        System.assertEquals(programOverviews[0].Client_Overview__c, opps[0].Contract__c);
   
        for (OpportunityLineItem__c oppProgram : oppPrograms) {
            System.assertEquals(opps[0].Id, oppProgram.Opportunity__c);
        }
    } */

    /* @isTest
    static void contractUpdateDifferentProgramEndDateOnProgramOverviewsTest() {
        List<Contract__c> pos = getProgramOverviews();
        pos[0].Program_End_Date__c = Date.today().addDays(5);
        pos[0].Auto_Renewal__c = false;
        pos[0].Complete_Per_Legal__c = true;
        pos[1].Program_End_Date__c = Date.today().addDays(4);
        pos[1].Complete_Per_Legal__c = true;
        pos[2].Program_End_Date__c = Date.today().addDays(3);
        pos[2].Complete_Per_Legal__c = true;

        Test.startTest();

        update pos;

        Test.stopTest();
        
        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        Set<Id> oppIds = new Set<Id>();
        System.assertEquals(3, oppPrograms.size());
        for (OpportunityLineItem__c oppProgram : oppPrograms) {
            oppIds.add(oppProgram.Opportunity__c);
        }

        List<Opportunity__c> opps = getOpportunitiesWithIds(oppIds);
        System.assertEquals(3, opps.size());
    } */

    /* @isTest
    static void contractUpdateExistingOpportunityMatchTest() {
        Opportunity__c o = TestFactory.createOpportunity();
        o.Name = String.valueOf(System.today().year()) + ' Renewal - ' + TestFactory.createClientAccount().Name + ' - DM - Auto-renewal';
        o.CloseDate__c= Date.today().addDays(5);

        Contract__c po = [SELECT Id, Program_End_Date__c, Client_Overview__c, RecordTypeId, Account__c FROM Contract__c WHERE RecordTypeId = :PROGRAM_OVERVIEW_RT AND Program_Name__c = 'Hypertension' LIMIT 1];
        po.Program_End_Date__c = Date.today().addDays(5);
        po.Complete_Per_Legal__c = true;

        Contract__c clientOverview = getClientOverviewFromProgramOverview(po.Client_Overview__c);

        Pricebook2 pb = getPricebook();

        o.Account__c = clientOverview.Account__c;
        o.Contract_Path__c = clientOverview.Contract_Path__c;
        o.Pricebook2__c = pb.Id;
        o.Owner__c = clientOverview.CSM__c;
        o.Contract__c = clientOverview.Id;
        insert o;

        Test.startTest();

        update po;

        Test.stopTest();
        
        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        System.assertEquals(1, oppPrograms.size());
        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(oppPrograms[0].Opportunity__c);

        List<Opportunity__c> opps = getOpportunitiesWithIds(oppIds);
        System.assertEquals(1, opps.size());
        System.assertEquals(Date.today().addDays(5), opps[0].CloseDate__c);
        System.assertEquals('Renewal', opps[0].Type__c);
        System.assertEquals('Prospect', opps[0].StageName__c);
        System.assertEquals(System.UserInfo.getUserId(), opps[0].Owner__c);
        System.assertEquals(po.Client_Overview__c, opps[0].Contract__c);
        System.assertEquals(true, opps[0].Name.contains('HTN'));
        System.assertEquals(true, opps[0].Name.contains('DM'));

        System.assertEquals(opps[0].Id, oppPrograms[0].Opportunity__c);
        System.assertEquals('Hypertension', oppPrograms[0].Program_Family__c);

    } */

    /* @isTest
    static void contractUpdateExistingOpportunityMatchLongOpportunityNameTest() {
        Opportunity__c o = TestFactory.createOpportunity();
        o.Name = String.valueOf(System.today().year()) + ' Renewal - ' + TestFactory.createClientAccount().Name + ' - Really Unrealistically Long Program Name - Auto-renewal';
        o.Name = o.Name.substring(0,80);
        o.CloseDate__c = Date.today().addDays(5);

        Contract__c po = [SELECT Id, Program_End_Date__c, Client_Overview__c, RecordTypeId, Account__c FROM Contract__c WHERE RecordTypeId = :PROGRAM_OVERVIEW_RT AND Program_Name__c = 'Hypertension' LIMIT 1];
        po.Program_End_Date__c = Date.today().addDays(5);
        po.Complete_Per_Legal__c = true;

        Contract__c clientOverview = getClientOverviewFromProgramOverview(po.Client_Overview__c);

        Pricebook2 pb = getPricebook();

        o.Account__c = clientOverview.Account__c;
        o.Contract_Path__c = clientOverview.Contract_Path__c;
        o.Pricebook2__c = pb.Id;
        o.Owner__c = clientOverview.CSM__c;
        o.Contract__c = clientOverview.Id;
        insert o;

        Test.startTest();

        update po;

        Test.stopTest();

        
        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        System.assertEquals(1, oppPrograms.size());
        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(oppPrograms[0].Opportunity__c);

        List<Opportunity__c> opps = getOpportunitiesWithIds(oppIds);
        System.assertEquals(1, opps.size());
    }*/

    /*    @isTest
    static void contractUpdateCheckThatDuplicateProgramsAreNotIncludedInOppNameTest() {
        List<Contract__c> pos = getProgramOverviews();
        for (Contract__c po : pos) {
            po.Complete_Per_Legal__c = true;
        }
        //create new Program Overview
        Contract__c programOverview = TestFactory.createProgramOverview();
        Contract__c clientOverview = getClientOverviewFromProgramOverview(pos[0].Client_Overview__c);
        programOverview.Client_Overview__c = clientOverview.Id;
        programOverview.Account__c = clientOverview.Account__c;
        //Make the program one that already exists (duplicate) in the set of POs
        //this will map to DPP in the abbreviations map
        programOverview.Program_Name__c = 'Prediabetes';
        insert programOverview;

        programOverview.Complete_Per_Legal__c = true;
        pos.add(programOverview);
        system.debug('pos:::'+pos);
        
        Test.startTest();

        update pos;

        Test.stopTest();

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();

        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem__c oppProgram : oppPrograms) {
            oppIds.add(oppProgram.Opportunity__c);
        }

        List<Opportunity__c> opps = getOpportunitiesWithIds(oppIds);
        System.assertEquals(1, opps.size());

        String oppName = opps[0].Name;
        String[] oppNameTokens = oppName.split(' ');
        Map<String, Integer> tokenToCount = new Map<String, Integer>();
        for (String oppNameToken : oppNameTokens) {
            //exclude '-' (dash) character
            if (!oppNameToken.equals('-')) {
                if (tokenToCount.containsKey(oppNameToken)) {
                    Integer count = tokenToCount.get(oppNameToken);
                    count++;
                }
                else {
                    tokenToCount.put(oppNameToken, 1);
                }
            }
        }
        //Make sure only one DPP is in the name; duplicated programs shouldn't be included in Opp name
        System.assertEquals(1, tokenToCount.get('DPP'));
    } */

    /* @isTest
    static void contractUpdatePPPMFromPOIsNullTest() {
        List<Contract__c> pos = getProgramOverviews();
        pos[0].Program_End_Date__c = Date.today().addDays(5);
        pos[0].Complete_Per_Legal__c = true;
        pos[0].PPPM__c = null;
        pos[1].Program_End_Date__c = Date.today().addDays(4);
        pos[1].Complete_Per_Legal__c = true;
        pos[2].Program_End_Date__c = Date.today().addDays(3);
        pos[2].Complete_Per_Legal__c = true;

        Test.startTest();

        update pos;

        Test.stopTest();

        List<Opportunity__c> opps = getOpportunities();
        
        //4, because there's the initial opp inserted in testsetup
        System.assertEquals(4, opps.size());

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        System.assertEquals(3, oppPrograms.size());
        System.assertEquals(DEFAULT_FALLBACK_VALUE, oppPrograms[0].UnitPrice__c);
    } */

    /* @isTest
    static void contractUpdateParticipantsFromPOIsNullTest() {
        List<Contract__c> pos = getProgramOverviews();
        pos[0].Program_End_Date__c = Date.today().addDays(5);
        pos[0].Complete_Per_Legal__c = true;
        pos[0].Participants__c = null;
        pos[1].Program_End_Date__c = Date.today().addDays(4);
        pos[1].Complete_Per_Legal__c = true;
        pos[2].Program_End_Date__c = Date.today().addDays(3);
        pos[2].Complete_Per_Legal__c = true;

        Test.startTest();

        update pos;

        Test.stopTest();

        List<Opportunity__c> opps = getOpportunities();
        
        //4, because there's the initial opp inserted in testsetup
        System.assertEquals(4, opps.size());

        List<OpportunityLineItem__c> oppPrograms = getOpportunityPrograms();
        System.assertEquals(3, oppPrograms.size());
        System.assertEquals(DEFAULT_FALLBACK_VALUE, oppPrograms[0].Product_Participants__c);
    }*/
    
    @isTest
    static void contractUpdateCSMIsNullTest() {
        List<Contract__c> pos = getProgramOverviews();
        
        for(Contract__c po: pos) {
            po.Program_End_Date__c = Date.today().addDays(5);
            po.Complete_Per_Legal__c = true;
        }
        
        Contract__c clientOverview = getClientOverviewFromProgramOverview(pos[0].Client_Overview__c);
        clientOverview.CSM__c = null;
        update clientOverview;

        Test.startTest();

        update pos;

        Test.stopTest();
        
    }
    
    @isTest
    static void contractUpdateDownMarketCSMIsNullTest() {
        List<Contract__c> pos = getProgramOverviews();
        
        for(Contract__c po: pos) {
            po.Program_End_Date__c = Date.today().addDays(5);
            po.Complete_Per_Legal__c = true;
        }
        
        Contract__c clientOverview = getClientOverviewFromProgramOverview(pos[0].Client_Overview__c);
        clientOverview.CSM__c = null;
        clientOverview.Population_Type__c = 'ASO downmarket';
        update clientOverview;

        Test.startTest();

        update pos;

        Test.stopTest();

    }
    
    @isTest
    static void handleContractDelete() {
        DmlException expectedException;
        List<Contract__c> clientOverview = getClientOverview();
        
        Test.startTest();
        
        try {
            delete clientOverview;
        }
        catch(DmlException d) {
            expectedException = d;
        }
        
        Test.stopTest();
        System.assertNotEquals(Null, expectedException, 'Your attempt to delete this client overview could not be completed because it has associated program overview(s)');
    }
    
    @isTest
    static void createRelatedCOPOTest() {
        List<Id> oppIdList = new List<Id>();
        List<Opportunity__c> oppList = getOpportunities();
        List<PricebookEntry> entryList = getlivongoPBEntriesList();
        List<PricebookEntry> strandardPBEEntryList = new List<PricebookEntry>();
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        List<Product2> wpPrograms = new List<Product2>();
        List<Pricing_Structure__c> pricingStructures = getLivongoPBPricingStructures();
        Map<Id, Pricing_Structure__c> programsToPricingStructureMap = new Map<Id, Pricing_Structure__c>();
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        String oppIdString;
        List<String> oppSource = new List<String>();
        List<List<String>> oppSourceList = new List<List<String>>();
        
        if (!pricingStructures.isEmpty()) {
            for (Pricing_Structure__c ps: pricingStructures) {
                if (ps.Program__r.Name.contains('Hypertension')) {
                    ps.Name = 'Standard HTN w/Cellular';
                }
                programsToPricingStructureMap.put(ps.Program__r.Id, ps);
            }
            update pricingStructures;
        }
        
        Product2 wpProgram1 = TestFactory.createWPProgram(DM_SOLUTION, 'Diabetes');
        Product2 wpProgram2 = TestFactory.createWPProgram(CV_SOLUTION, 'Hypertension');
        Product2 wpProgram3 = TestFactory.createWPProgram(DP_SOLUTION, 'Prediabetes');
        Product2 standalone = TestFactory.createProgram('Behavioral Health');
        
        wpPrograms.add(wpProgram1);
        wpPrograms.add(wpProgram2);
        wpPrograms.add(wpProgram3);
        wpPrograms.add(standalone);
        
        insert wpPrograms;
        
        for (Product2 program: wpPrograms) {
            PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, program.Id);
            PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id);
            strandardPBEEntryList.add(standardPbe);
            entryList.add(pbe);
        }
        
        insert strandardPBEEntryList;
        upsert entryList;        
        
        for (Opportunity__c opp: oppList) {
            oppIdList.add(opp.Id);
            for(PricebookEntry pbe: entryList) {
                OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Price_Book_ID__c = pbe.Pricebook2Id;
                oli.Program_ID__c = pbe.Product2Id;
                oli.Product2__c = pbe.Product2Id; 
                //oli.Pricing_Structure__c = programsToPricingStructureMap.get(pbe.Product2Id) != null ? programsToPricingStructureMap.get(pbe.Product2Id).Id : null;
                oliList.add(oli);
            }
        }
        insert oliList;
        System.debug(oppIdList[0]);
        oppSource.add(oppIdList[0]);
        oppSourceList.add(oppSource);
        Test.startTest();
        ContractService.createdRelatedCoPo(oppSourceList);
        Test.stopTest();
    }
    
    @isTest
    static void wholePersonTransitionTest() {
        List<Id> oppIdList = new List<Id>();
        List<Opportunity__c> oppList = getOpportunities();
        List<PricebookEntry> entryList = getlivongoPBEntriesList();
        List<PricebookEntry> strandardPBEEntryList = new List<PricebookEntry>();
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        List<Product2> wpPrograms = new List<Product2>();
        List<Pricing_Structure__c> pricingStructures = getLivongoPBPricingStructures();
        Map<Id, Pricing_Structure__c> programsToPricingStructureMap = new Map<Id, Pricing_Structure__c>();
        Pricebook2 livongoPricebook = getPricebook();
        Id standardPBId = Test.getStandardPricebookId();
        String oppIdString;
        List<String> oppSource = new List<String>();
        List<List<String>> oppSourceList = new List<List<String>>();
        
        if (!pricingStructures.isEmpty()) {
            for (Pricing_Structure__c ps: pricingStructures) {
                if (ps.Program__r.Name.contains('Hypertension')) {
                    ps.Name = 'Standard HTN w/Cellular';
                }
                programsToPricingStructureMap.put(ps.Program__r.Id, ps);
            }
            update pricingStructures;
        }
        
        Product2 wpProgram1 = TestFactory.createWPProgram(DM_SOLUTION, 'Diabetes');
        Product2 wpProgram2 = TestFactory.createWPProgram(CV_SOLUTION, 'Hypertension');
        Product2 wpProgram3 = TestFactory.createWPProgram(DP_SOLUTION, 'Prediabetes');
        Product2 standalone = TestFactory.createProgram('Behavioral Health');
        
        wpPrograms.add(wpProgram1);
        wpPrograms.add(wpProgram2);
        wpPrograms.add(wpProgram3);
        wpPrograms.add(standalone);
        
        insert wpPrograms;
        Test.startTest();
        
        for (Product2 program: wpPrograms) {
            PricebookEntry standardPbe = TestFactory.createPricebookEntry(standardPBId, program.Id);
            PricebookEntry pbe = TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id);
            strandardPBEEntryList.add(standardPbe);
            entryList.add(pbe);
        }
        
        insert strandardPBEEntryList;
        upsert entryList;
        
        List<Contract__c> pos = getProgramOverviews();
        for (Contract__c po : pos) {
            po.Complete_Per_Legal__c = true;
            po.Program_Type__c = 'Standalone';
            po.Status__c = 'Active';
        }
        
        update pos;
        Contract__c clientOverview = getClientOverviewFromProgramOverview(pos[0].Client_Overview__c);
        
        for (Opportunity__c opp: oppList) {
            oppIdList.add(opp.Id);
            for(PricebookEntry pbe: entryList) {
                OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Price_Book_ID__c = pbe.Pricebook2Id;
                oli.Program_ID__c = pbe.Product2Id;                
                oli.Product2__c = pbe.Product2Id; 
                //oli.Pricing_Structure__c = programsToPricingStructureMap.get(pbe.Product2Id) != null ? programsToPricingStructureMap.get(pbe.Product2Id).Id : null;
                oliList.add(oli);
            }
        }
        
        insert oliList;
        
        oppSource.add(oppIdList[0]);
        oppSource.add(clientOverview.Id);
        oppSource.add('Whole Person Program Overview Transition');
        oppSourceList.add(oppSource);
        
        ContractService.createdRelatedCoPo(oppSourceList);

        Test.stopTest();
    }
    
    @isTest
    static void updateHelathScoresTest() {
        List<Contract__c> programOverviews = getProgramOverviews();
        Set<Id> accIdSet = new Set<Id>();
        for (Contract__c program : programOverviews) {
            program.Actual_Launch_Date__c = Date.today();
            program.Outreach_Stratification__c = 'A';
            accIdSet.add(program.Account__c);
        }
        Test.startTest();
        update programOverviews;
        Test.stopTest();
        
        List<Health_Score__c> hsList = [SELECT Id, Actual_Result__c FROM Health_Score__c WHERE Account__c IN :accIdSet AND Health_Segment__c = 'Client Launch Date'];
        for (Health_Score__c hs : hsList) {
            System.assertEquals(String.valueOf(Date.today().format()), hs.Actual_Result__c);
        }
    }
}