/**
* This class contains the primary business logic for the Contract__c object.
* Created : 05/13/2019
* @author Connor Gallaher - Slalom
*/
global class ContractService {
    public static final Integer DEFAULT_NUM_MONTHS = Integer.valueOf(System.Label.Default_Renewal_Opp_Num_Months);
    public static final String DEFAULT_RENEWAL_OPP_TYPE = System.Label.Default_Renewal_Opp_Type;
    public static final String DEFAULT_RENEWAL_OPP_STAGE = System.Label.Default_Renewal_Opp_Stage;
    public static final String DEFAULT_RENEWAL_OPP_STAGE_VOC = System.Label.Default_Renewal_Opp_Stage_VOC;
    public static final String DEFAULT_PRICEBOOK_NAME = System.Label.Default_Renewal_Opp_Pricebook_Name;
    public static final Integer DEFAULT_FALLBACK_VAL = Integer.valueOf(System.Label.Default_Renewal_Opp_Fallback_Value);
    public static final String TONYCOLISTRAUSERID = System.Label.TonyColistraUserId;
    public static final String GARYALPERTUSERID = System.Label.GaryAlpertUserId;
    public static final String JESSICAGAHANGUUSERID = System.Label.JessicaGahunguUserId;
    public static final String POPULATIONTYPEASODOWNMARKET = System.Label.PopulationTypeASODownMarket;
    public static final String DEFAULT_PROGRAM_IMPLEMENTATION_STATUS = System.Label.Default_Program_Implementation_Status;
    public static final String NEW_DEVICE_TYPE_HTAND = System.Label.New_Device_Type_HTAND;
    public static final String NEW_DEVICE_TYPE_HT900 = System.Label.New_Device_Type_HT900;
    public static final String DEFAULT_BH_V1_PROGRAM_NAME = System.Label.Default_BH_1_0_Program_Name;
    public static final String DEFAULT_MYSTRENGTH_PROGRAM_PLATFORM_VERSION = System.Label.myStrength_Program_Platform_Version;
    public static final Id CLIENT_OVERVIEW_RT =  Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId(); 
    public static final Id PROGRAM_OVERVIEW_RT = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId(); 
    public static final String POPULATIONTYPENONHSSDOWNMARKET = System.Label.PopulationTypeNonHSSDownmarket;
    public static final String DIABETES_W_CKD_AWARE_VARIANT = System.Label.Diabetes_w_CKD_Aware_Variant;
    public static final String HYPERTENSION_W_CKD_AWARE_VARIANT = System.Label.Hypertension_w_CKD_Aware_Variant;
    public static final String MYSTRENGTH = System.Label.myStrength;
    public static final String MYSTRENGTH_COMPLETE = System.Label.myStrength_Complete;
    
    public static Map<String, String> abbreviations { get; set; }
    public static Map<Id, Id> activeUserIdMap { get; set; }
    public static Map<String, List<Whole_Person_Solution_Mapping__mdt>> wpMappings {get; set;}
    public static Map<String, Decimal> programToPercentMap = new Map<String, Decimal>();    
    
    static {
        Map<String, Decimal> pprMap = new Map<String, Decimal>();
        ProgramParticipantsRenewals__mdt[] pprMDT = [SELECT ProgramName__c, Percentage__c FROM ProgramParticipantsRenewals__mdt];
        for (ProgramParticipantsRenewals__mdt ppr: pprMDT) {
            pprMap.put(ppr.ProgramName__c, ppr.Percentage__c);
        }
        programToPercentMap = pprMap;        
    }
    
    static {
        //Get Custom Metadata Type storing Program Names => their Abbreviation
        Program_Abbreviation__mdt[] programMdts = [SELECT Program_Name__c, Abbreviation__c FROM Program_Abbreviation__mdt];
        Map<String, String> programsToAbbreviations = new Map<String, String>();
        for (Program_Abbreviation__mdt programMdt : programMdts) {
            programsToAbbreviations.put(programMdt.Program_Name__c, programMdt.Abbreviation__c);
        }
        abbreviations = programsToAbbreviations;
        
        Map<Id, Id> usersIdMap = new Map<Id, Id>();
        List<User> userList = [SELECT Id, Name FROM User WHERE (Id = :TONYCOLISTRAUSERID OR Id = :GARYALPERTUSERID OR Id = :JESSICAGAHANGUUSERID) AND IsActive = TRUE];
        for (User u: userList) {
            usersIdMap.put(u.Id, u.Id);
        }
        activeUserIdMap = usersIdMap;
        
        Whole_Person_Solution_Mapping__mdt[] wpMappingsMDT = [SELECT Solution__c, Program__c, Program_Type__c, Program_Platform_Version__c FROM Whole_Person_Solution_Mapping__mdt];
        Map<String, List<Whole_Person_Solution_Mapping__mdt>> wpMappingMap = new Map<String, List<Whole_Person_Solution_Mapping__mdt>>();
        for (Whole_Person_Solution_Mapping__mdt wpMdt : wpMappingsMDT) {
            string key = wpMdt.Solution__c;
            if (wpMappingMap.keySet().contains(key)) {
                wpMappingMap.get(key).add(wpMdt);
            }
            else {
                wpMappingMap.put(key, new List<Whole_Person_Solution_Mapping__mdt>{wpMdt});
            }
        }  
        wpMappings = wpMappingMap;
    }
    
    /*
* Main method called from the ContractTriggerHandler class.  Handles initial queries for key objects and data
* that will be needed throughout this class.  Handles delegation of creation of objects through calls to
* other methods and overall primary handling of business logic.
*/
    public static void autoCreateRenewalOpportunities(List<Contract__c> contracts) {
        //Iterate through POs and add unique Client Overviews to a set
        Set<Id> clientOverviewIds = new Set<Id>();
        for (Contract__c c : contracts) {
            clientOverviewIds.add(c.Client_Overview__c);
        }
        
        //Find opportunities related to those Client Overviews
        List<Contract__c> contractsToRenew = new List<Contract__c>();
        Boolean Disable_TeleTherapy = false;
        List<Opportunity__c> opportunities = [SELECT Id, Contract__c FROM Opportunity__c WHERE Contract__c IN :clientOverviewIds];
        List<Contract__c> bhProgramOverviews = [SELECT Id, Program_Type__c,Client_Overview__c, Program_Name__c, Disable_Teletherapy__c FROM Contract__c WHERE Program_Name__c = 'Behavioral Health' AND Client_Overview__c IN :clientoverviewIds];
        for (Opportunity__c o : opportunities) {
            for (Contract__c c : contracts) {
                if (c.Client_Overview__c == o.Contract__c && c.Program_Type__c != 'WP Non-Anchor') {
                    //List will contain only contracts for which P.E.D. has changed
                    //and for which there is an existing Opportunity__c related to the Client Overview
                    contractsToRenew.add(c);
                }
            }
            if (bhProgramOverviews.size() > 0) {
                for (Contract__c po : bhProgramOverviews) {
                    if(po.Client_Overview__c == o.Contract__c) {  
                        Disable_TeleTherapy = po.Disable_Teletherapy__c;
                    }
                }
            }
        }
        
        Map<Id, ContractRenewalHelper> helperMap = new Map<Id, ContractRenewalHelper>();
        ContractRenewalHelper helper;
        
        //Construct ContractRenewalHelper objects
        for (Contract__c c : contractsToRenew) {
            helper = new ContractRenewalHelper(c);
            helperMap.put(c.Id, helper);
        }
        //Get Default Pricebook
        Pricebook2 livongoPricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = :DEFAULT_PRICEBOOK_NAME LIMIT 1];
        
        //Get (unique) names of Programs from Contracts
        Set<String> uniqueProgramNames = new Set<String>();
        for (ContractRenewalHelper h : helperMap.values()) {
            uniqueProgramNames.add(h.programOverview.Program_Name__c);
        }
        
        Id primaryProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Primary_Product').getRecordTypeId();
        //To store program family names
        Map<Id, Product2> programMap = new Map<Id, Product2>([SELECT Id, Name, Family, RecordTypeId, IsActive, Whole_Person_Solution__c FROM Product2 WHERE Family IN :uniqueProgramNames AND IsActive = TRUE]);
        for (ContractRenewalHelper h : helperMap.values()) {
            Boolean wpProgramOverview = h.programOverview.Program_Type__c == 'WP Anchor'; 
            for (Product2 program : programMap.values()) {
                Boolean ckdAwareProduct = (program.Name == DIABETES_W_CKD_AWARE_VARIANT || program.Name == HYPERTENSION_W_CKD_AWARE_VARIANT) ? true : false;
                //Only use primary record type Product2 objects
                if (h.programOverview.Program_Name__c == program.Family && program.RecordTypeId == primaryProductRecordTypeId && wpProgramOverview && wpProgramOverview == program.Whole_Person_Solution__c
                    && !ckdAwareProduct && !h.programOverview.CKD_Aware_Variant__c) {
                        h.program = program;
                        h.disableTeletherapy = Disable_TeleTherapy;
                        break;
                    }
                else if (h.programOverview.Program_Name__c == program.Family && program.RecordTypeId == primaryProductRecordTypeId && program.Whole_Person_Solution__c == false && !ckdAwareProduct && !h.programOverview.CKD_Aware_Variant__c) {
                        h.program = program;
                		}
                else if (h.programOverview.Program_Name__c == program.Family && program.RecordTypeId == primaryProductRecordTypeId && program.Whole_Person_Solution__c == false 
                         && h.programOverview.CKD_Aware_Variant__c && ckdAwareProduct) {   
                         h.program = program;
                    	}
            }
        }
        
        //Map each Program Id to its corresponding PricebookEntry Id
        Map<Id, Id> programIdsToPriceBookEntryIds = new Map<Id, Id>();
        for (PriceBookEntry entry : [SELECT Id, Product2Id, Pricebook2Id, IsActive FROM PriceBookEntry WHERE IsActive = TRUE AND Pricebook2Id =: livongoPricebook.Id AND Product2Id IN :programMap.keySet()]) {
            programIdsToPriceBookEntryIds.put(entry.Product2Id, entry.Id);
        }
        //Get unique Client Overview Ids
        Set<Id> coIds = new Set<Id>();
        for (Contract__c c : contractsToRenew) {
            coIds.add(c.Client_Overview__c);
        }
        
        Set<Id> accountIds = new Set<Id>();
        //Map Client Overview Id to the corresponding Client Overview (Contract) object
        Map<Id, Contract__c> clientOverviewMap = new Map<Id, Contract__c>([SELECT Id, CSM__c, CIM__c, Contract_Path__c, Account__c, Account__r.Name, Account__r.OwnerId, Account__r.of_Enrolled_RPwDs_to_date__c, Account__r.of_Enrolled_RPwHs_to_Date__c,
                                                                     Population_Type__c, Contract_Path__r.Name FROM Contract__c WHERE Id IN :coIds]);  
        for (ContractRenewalHelper h : helperMap.values()) {
            h.clientOverview = clientOverviewMap.get(h.programOverview.Client_Overview__c);
            //Store unique Account Ids
            accountIds.add(h.clientOverview.Account__c);
        }
        
        findAndUpdateExistingOpportunities(helperMap.values(), accountIds);
        
        List<Opportunity__c> newOpps = createAndInsertNewOpportunities(helperMap.values(), livongoPricebook.Id);
        
        //Iterate through each PO, update PO to Opportunity__c map with proper mappings
        for (ContractRenewalHelper h : helperMap.values()) {
            if (h.opp != null) {
                //Opportunity__c already set, continue to next iteration
                continue;
            }
            else {
                for (Opportunity__c o : newOpps) {
                    if (h.clientOverview.Contract_Path__c == o.Contract_Path__c && h.clientOverview.Account__c == o.Account__c && h.programOverview.Program_End_Date__c == o.CloseDate__c) {
                        //Opportunity__c found, so set lookup to that Opportunity__c and stop looping.
                        h.opp = o;
                        break;
                    }
                }
            }
        }
        findAndUpdateExistingOpportunityPrograms(helperMap.values());
        
        createAndInsertOpportunityPrograms(helperMap.values(), programIdsToPriceBookEntryIds);
    }
    
    /*
* Finds existing Opportunity/Opportunities based on each Program Overview's End Date, as well as the corresponding Client Overview's Contract__c Path and Account.
* If an Opportunity__c is found, set Opportunity__c to the found Opportunity, and update the name by appending the Family from the current PO to the Opp name.
* Finally, update the Opportunity/Opportunities.
*/
    public static void findAndUpdateExistingOpportunities(List<ContractRenewalHelper> helpers, Set<Id> accountIds) {
        //Map each Program Overview to the Opportunity__c it will be associated with
        Set<Id> updatedSetOpps = new Set<Id>();
        Map<Id, Opportunity__c> updatedMapOpps = new Map<Id, Opportunity__c>();
        List<Opportunity__c> updatedOpps = new List<Opportunity__c>();
        for (Opportunity__c o : [SELECT Id, Name, Contract_Path__c, Account__c, CloseDate__c, Pricebook2__c FROM Opportunity__c WHERE Account__c IN :accountIds]) {
            for (ContractRenewalHelper h : helpers) {
                if (h.clientOverview.Contract_Path__c == o.Contract_Path__c && h.clientOverview.Account__c == o.Account__c && h.programOverview.Program_End_Date__c == o.CloseDate__c) {
                    h.opp = o;
                    String updatedOppName = updateOppNameWithNewProgram(o.Name, h.program.Family, h.program.Whole_Person_Solution__c);
                    o.Name = updatedOppName;
                    //Add to Map and Set for update
                    updatedMapOpps.put(o.Id, o);
                    updatedSetOpps.add(o.Id);
                }
            }
        }
        if (updatedSetOpps.size() > 0) {
            for (Id oppId: updatedSetOpps){
                updatedOpps.add(updatedMapOpps.get(oppId));
            }
        }
        //Update Opportunity(ies) with new name(s)
        if (!updatedOpps.isEmpty()) {
            try {
                update updatedOpps;
            }
            catch (DmlException ex) {
                System.debug('An exception occurred: ' + ex.getMessage());
            }
        }
    }
    
    /*
* Stub out new Opportunity/Opportunities with defined criteria from the POs/COs and insert these new Opportunity/Opportunities.
* @return list of these newly created Opportunity__c objects.
*/
    public static List<Opportunity__c> createAndInsertNewOpportunities(List<ContractRenewalHelper> helpers, Id pbId) {
        //Stub out remaining Opportunities for POs without an associated Opportunity
        Opportunity__c oppStub;
        Set<Opportunity__c> oppStubs = new Set<Opportunity__c>();
        for (ContractRenewalHelper h : helpers) {
            Boolean skipStub = false;
            if (h.opp == null) {
                for (Opportunity__c o : oppStubs) {
                    //Check if Opportunity__c stub already exists with the criteria matching the current PO/CO
                    if (h.clientOverview.Account__c == o.Account__c && h.programOverview.Program_End_Date__c == o.CloseDate__c && h.clientOverview.Contract_Path__c == o.Contract_Path__c) {
                        //Update the Opportunity__c name to include the new program family name
                        String updatedOppName = updateOppNameWithNewProgram(o.Name, h.program.Family, h.program.Whole_Person_Solution__c);
                        o.Name = updatedOppName;
                        //Will want to skip stubbing an Opportunity__c for this iteration, so stop looking through Opportunities
                        skipStub = true;
                        break;
                    }
                }
                //Stub out a new Opportunity, if needed
                if (!skipStub) {
                    oppStub = new Opportunity__c();
                    oppStub.Account__c = h.clientOverview.Account__c;
                    oppStub.Pricebook2__c = pbId;
                    oppStub.Type__c = DEFAULT_RENEWAL_OPP_TYPE;
                    if (h.programOverview.Auto_Renewal__c) {
                        oppStub.StageName__c = DEFAULT_RENEWAL_OPP_STAGE_VOC;
                        oppStub.Bypass_Product_Requirement__c = TRUE; // allows bypass of Opp Validiation Rule  Prevent_update_from_proposal2
                    }
                    else {
                        oppStub.StageName__c = DEFAULT_RENEWAL_OPP_STAGE;   
                    }
                    oppStub.CloseDate__c = h.programOverview.Program_End_Date__c;
                    if (h.clientOverview.CSM__c != null) {
                        oppStub.Owner__c = h.clientOverview.CSM__c;
                    }
                    else if (h.clientOverview.CSM__c == null && (h.clientOverview.Population_Type__c == POPULATIONTYPEASODOWNMARKET ||
                                                                 h.clientOverview.Population_Type__c == POPULATIONTYPENONHSSDOWNMARKET) &&
                             activeUserIdMap.get(TONYCOLISTRAUSERID) != null) {
                                 oppStub.Owner__c = activeUserIdMap.get(TONYCOLISTRAUSERID);
                             }
                    else if (h.clientOverview.CSM__c == null && (h.clientOverview.Population_Type__c == POPULATIONTYPEASODOWNMARKET ||
                                                                 h.clientOverview.Population_Type__c == POPULATIONTYPENONHSSDOWNMARKET ) &&
                             activeUserIdMap.get(GARYALPERTUSERID) != null) {
                                 oppStub.Owner__c = activeUserIdMap.get(GARYALPERTUSERID);
                             }
                    else if (h.clientOverview.CSM__c == null && h.clientOverview.Population_Type__c != POPULATIONTYPEASODOWNMARKET &&
                             activeUserIdMap.get(GARYALPERTUSERID) != null) {
                                 oppStub.Owner__c = activeUserIdMap.get(GARYALPERTUSERID);
                             }
                    else if (activeUserIdMap.get(JESSICAGAHANGUUSERID) != null) {
                        oppStub.Owner__c = JESSICAGAHANGUUSERID;
                    }
                    else {
                        oppStub.Owner__c = h.clientOverview.Account__r.OwnerId;
                    }
                    String oppName = String.valueOf(h.programOverview.Program_End_Date__c.year()) + ' Renewal - ';
                    if (h.clientOverview.Account__r.Name.length() > 40) {
                        oppName += h.clientOverview.Account__r.Name.substring(0, 40);
                    }
                    else {
                        oppName += h.clientOverview.Account__r.Name;
                    }
                    oppName += ' - ';
                    if (h.clientOverview.Contract_Path__c != null && h.clientOverview.Contract_Path__r.Name.length() > 40) {
                        oppName += h.clientOverview.Contract_Path__r.Name.substring(0, 40);
                        oppName += ' - ';
                    }
                    else if(h.clientOverview.Contract_Path__c != null) {
                        oppName += h.clientOverview.Contract_Path__r.Name;
                        oppName += ' - ';
                    }
                    if (h.program.Whole_Person_Solution__c && !oppName.contains('WP')) {
                        oppName += 'WP - ';
                    }
                    oppName += abbreviations.get(String.valueOf(h.program.Family));
                    if (h.programOverview.Auto_Renewal__c) {
                        oppName += ' - Auto-renewal';
                    }
                    //Opportunity__c Name field is restricted to 120 characters
                    if (oppName.length() > 120) {
                        oppStub.Name = oppName.substring(0, 120);
                    }
                    else {
                        oppStub.Name = oppName;
                    }
                    oppStub.Contract_Path__c = h.clientOverview.Contract_Path__c;
                    oppStub.Contract__c = h.clientOverview.Id;
                    oppStubs.add(oppStub);
                }
            }
        }
        
        List<Opportunity__c> newOpps = new List<Opportunity__c>(oppStubs);
        //Insert new Opportunity__c objects to get IDs
        if (!newOpps.isEmpty()) {
            try {
                insert newOpps;
            }
            catch (DmlException ex) {
                System.debug('An exception occurred: ' + ex.getMessage());
            }
        }
        return newOpps;
    }
    
    /*
* Finds existing Opportunity__c Programs for the Opportunities associated with each
* Program Overview.  Program Overviews are potentially updated multiple times
* in SpringCM, and we do not want to create a new Opportunity__c Program each time
* SpringCM is updated.  This method ensures no duplicate Opportunity__c Programs
* are created by finding any existing Opportunity__c Programs under a Program Overview's
* associated Opportunity__c based on the Program Id (Product2Id)
*/
    public static void findAndUpdateExistingOpportunityPrograms(List<ContractRenewalHelper> helpers) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, List<OpportunityLineItem__c>> opportunityToOppPrograms = new Map<Id, List<OpportunityLineItem__c>>();
        for (ContractRenewalHelper h : helpers) {
            oppIds.add(h.opp.Id);
            opportunityToOppPrograms.put(h.opp.Id, new List<OpportunityLineItem__c>());
        }
        List<OpportunityLineItem__c> existingOppPrograms = [SELECT Id, Product2__c, Opportunity__c FROM OpportunityLineItem__c WHERE Opportunity__c IN :oppIds];
        
        for (OpportunityLineItem__c existingOppProgram : existingOppPrograms) {
            opportunityToOppPrograms.get(existingOppProgram.Opportunity__c).add(existingOppProgram);
        }
        for (ContractRenewalHelper h : helpers) {
            for (OpportunityLineItem__c op : opportunityToOppPrograms.get(h.opp.Id)) {
                if (h.program.Id == op.Product2__c) {
                    h.oppProgram = op;
                    break;
                }
            }
        }
    }
    
    /*
* Create an Opportunity__c Program (OpportunityLineItem) for each Program Overview with defined criteria and insert these new Opportunity__c Program(s).
*/
    public static void createAndInsertOpportunityPrograms(List<ContractRenewalHelper> helpers, Map<Id, Id> programIdsToPriceBookEntryIds) {
        //Create a new Opp Program for each PO
        //Map each Program Overview to its corresponding Opportunity__c Program
        List<OpportunityLineItem__c> oppPrograms = new List<OpportunityLineItem__c>();
        for (ContractRenewalHelper h : helpers) {
            //Opp Program would only be set already if there was one found in
            //the method findAndUpdateExistingOpportunityPrograms.  If one is set already,
            //skip that iteration.
            if (h.oppProgram != null) {
                continue;
            }
            //Otherwise, continue with creating a new Opp Program
            OpportunityLineItem__c oppProgram = new OpportunityLineItem__c();
            //if (h.programOverview.Participants__c != null) {
            //oppProgram.Product_Participants__c = h.programOverview.Participants__c;
            //JENGA 1505 - no longer using Program Overview's Participants
            //instead using 25% of Account's of_Enrolled_RPwDs_to_date__c if Diabetes, or 10% of of_Enrolled_RPwHs_to_Date__c if HTN
            if (h.clientOverview.Account__r.of_Enrolled_RPwDs_to_date__c != null && h.programOverview.Program_Name__c == 'Diabetes') {
                oppProgram.Product_Participants__c = (h.clientOverview.Account__r.of_Enrolled_RPwDs_to_date__c * programToPercentMap.get('Diabetes'));
            }
            else if (h.clientOverview.Account__r.of_Enrolled_RPwHs_to_Date__c != null && h.programOverview.Program_Name__c == 'Hypertension') {
                oppProgram.Product_Participants__c = (h.clientOverview.Account__r.of_Enrolled_RPwHs_to_Date__c * programToPercentMap.get('Hypertension'));
            }
            else {
                oppProgram.Product_Participants__c = DEFAULT_FALLBACK_VAL;
            }
            if(oppProgram.Product_Participants__c != null){
                oppProgram.Product_Participants__c = oppProgram.Product_Participants__c.round(); 
            }
            //oppProgram.PricebookEntryId = programIdsToPriceBookEntryIds.get(h.program.Id);
            if (h.programOverview.PPPM__c != null) {
                oppProgram.UnitPrice__c = h.programOverview.PPPM__c;
            }
            else {
                oppProgram.UnitPrice__c = DEFAULT_FALLBACK_VAL;
            }
            oppProgram.Quantity__c = DEFAULT_NUM_MONTHS;
            oppProgram.Disable_Teletherapy__c = h.disableTeletherapy;
            h.oppProgram = oppProgram;
            h.oppProgram.Opportunity__c = h.opp.Id;
            oppPrograms.add(h.oppProgram);
        }
        
        //Finally, insert all Opportunity__c Programs
        if (!oppPrograms.isEmpty()) {
            try {
                insert oppPrograms;
            }
            catch (DmlException ex) {
                System.debug('An exception occurred: ' + ex.getMessage());
            }
        }
    }
    
    /*
* Update the Opportunity__c name with the new program family name
* @return the updated String for the Opportunity__c name
*/
    public static String updateOppNameWithNewProgram(String oppName, String programFamily, Boolean wholePersonSolution) {
        Boolean keepAutoRenewalInName = false;
        if (oppName.contains('Auto-renewal')) {
            oppName = oppName.substring(0, oppName.lastIndexOf(' - '));
            keepAutoRenewalInName = true;
        }
        else {
            oppName = oppName.substring(0, oppName.length());
        }
        oppName += ' ';
        if (wholePersonSolution && !oppName.contains('WP')) {
            String remainingStr = oppName.substring(oppName.lastIndexOf(' - '));
            oppName = oppName.substring(0, oppName.lastIndexOf(' - '));
            oppName += '- WP ' + remainingStr;
        }
        String programAbbreviation = abbreviations.get(programFamily);
        //Ensure Opp name won't contain the same program
        //(e.g. YYYY Renewal - Account - DM DM ; This should NOT happen)
        if (!oppName.contains(programAbbreviation)) {
            oppName += programAbbreviation;
        }
        if (keepAutoRenewalInName) {
            oppName += ' - Auto-renewal';
        }
        //Opportunity__c Name field is restricted to 120 characters
        if (oppName.length() > 120) {
            oppName = oppName.substring(0, 120);
        }
        return oppName;
    }
    
    //Creating related Client Overview and Program Overview
    //Invocable Methods called from Opportunity__c Process Builder and Create Client Overview Bundle button on Opportunity
    @InvocableMethod(label='Create Related Client Overview and Program Overviews')
    global static void createdRelatedCoPo(List<List<String>> oppSource) {     
        List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
        Map<Id, Contract__c> oppToClientOverviewsMap = new Map<Id, Contract__c>();
        Map<String, Contract__c> programOverviewsToCreateMap = new Map<String, Contract__c>();
        Map<Id, Id> oppContractMap = new Map<Id, Id>();
        List<ProgramWrap> programWrapList = new List<ProgramWrap>();
        List<Contract__c> poList = new List<Contract__c>();
        ProgramWrap programWrap;
        Id oppId;
        Id coId;
        String sourceType;
        Map<String, Contract__c> existingProgramsMap = new Map<String, Contract__c>();
        Contract__c existingPO;
        
        //Getting OppId from oppSource
        if (oppSource.size() > 0) {
            oppId = oppSource.get(0).get(0);
        }
        //Getting Client Overview Id and Source Type from source parameter
        if (oppSource.size() > 0 && oppSource.get(0).size() > 1) {
            coId = oppSource.get(0).get(1);
            sourceType = oppSource.get(0).get(2);
        }
        
        //Get Opportunity__c Info
        List<Opportunity__c> oppList = [SELECT Id, Account__c, Contract_Path__c,Type__c,Has_Broker__c,Account__r.Name,Revenue_Bucket__c, Contract_Path__r.Name, CIM__c, BillingPartner__c,
                                     Contract__c, Launch_Date__c, (SELECT Id, Program_Family__c, Pricing_Structure__c, Pricing_Structure__r.Name, PO_WholePerson__c, 
                                                                  Product2__r.Whole_Person_Solution__c, Disable_BH_Coaching__c, Disable_Teletherapy__c, OpportunityProductName__c  FROM LGVO_OpportunityProducts__r) 
                                     FROM Opportunity__c WHERE Id = :oppId];
        Opportunity__c opp = oppList[0];
        
        //Get Programs realted to CO if coId not equal to null and add them to Map
        //These Existing Programs are used to set defaults for new WP Transition Program Overviews
        if (coId != null) {
            List<Contract__c> existingCO = [SELECT Id,Revenue_Bucket__c FROM Contract__c WHERE Id = :coId LIMIT 1];
            Contract__c CO = existingCO[0];
            
            poList = [SELECT Id, Account__c, Client_Overview__c, Program_Name__c, OE_Month_End__c, Actual_Launch_Date__c, Member_Recruitment_Began__c, 
                      Initial_Targeted_Marketing__c, Recruitable_Pop_Current__c, Product_Enrollment_Cap__c, CSM__c,
                      CIM__c, cbi_header__c, cbi_step1__c, cbi_step2__c, cbi_step3__c, cbi_disclaimer__c, Program_Began_as_Pilot__c,
                      Disclaimer__c, Eligibility_Sentence__c, Spanish_Eligibility_Sentence__c, Automated_Enrollment_Injection__c,
                      Relaunch_Start_Date__c, Pop_Refresh_Start_Date__c, Name, Is_there_Lapse_Criteria__c, Lapsed_Criteria_Source__c,
                      Escalation_Details__c, Eligibility_Escalation_Path__c, Eligibility_Verification_Method__c  
                      FROM Contract__c WHERE RecordTypeId = :PROGRAM_OVERVIEW_RT AND Client_Overview__c = :coId AND Status__c = 'Active' AND Program_Type__c = 'Standalone'];
            
            if (!poList.isEmpty()) {
                for (Contract__c po: poList) {
                    
                    existingProgramsMap.put(po.Program_Name__c, po);
                }
            }
            if(opp.Revenue_Bucket__c != null) {
                CO.Revenue_Bucket__c = opp.Revenue_Bucket__c;
            }
            oppToClientOverviewsMap.put(oppId, CO);
        }
        
        //If there is no existing CO, Create a new CO
        if (coId == null) {
            Contract__c clientOverview = new Contract__c();
            clientOverview.Account__c = opp.Account__c;
            clientOverview.BillingPartner__c = opp.BillingPartner__c ;
            clientOverview.CIM__c = opp.CIM__c;
            clientOverview.Contract_Path__c = opp.Contract_Path__c; 
            clientOverview.Revenue_Bucket__c = opp.Revenue_Bucket__c;
            if (opp.Contract_Path__c != null && opp.Account__c != null) {
                clientOverview.Name = (opp.Account__r.Name + ' - ' + opp.Contract_Path__r.Name).Left(80).trim();
            }
            else if (opp.Account__c != null) {
                clientOverview.Name = opp.Account__r.Name;
            }
            if (opp.Type__c == 'New Business') {
                clientOverview.Has_Broker__c = opp.Has_Broker__c;
            }
            clientOverview.RecordTypeId = CLIENT_OVERVIEW_RT;
            oppToClientOverviewsMap.put(opp.Id, clientOverview);
            
            //Inserting the COs
            if (oppToClientOverviewsMap.size() > 0) {
                try {
                    insert oppToClientOverviewsMap.values();
                }
                catch (DmlException ex) {
                    System.debug('An exception occurred: ' + ex.getMessage());
                }
            }
        }
        Boolean Disable_BH_Coaching = false;
        Boolean Disable_Teletherapy = false;
        //Looping over the Opportunity__c lineitems to create the related POs based on the Opportunity__c line items
        //Get the whole person mapping if any and add them to the program wrap list.
        for (OpportunityLineItem__c oppLineItem: opp.LGVO_OpportunityProducts__r) {
            if (oppLineItem.Product2__r.Whole_Person_Solution__c) {
                List<Whole_Person_Solution_Mapping__mdt> wpPrograms = wpMappings.get(oppLineItem.OpportunityProductName__c);
                if (wpPrograms != null && wpPrograms.size() > 0) {
                    for (Whole_Person_Solution_Mapping__mdt wpProgram: wpPrograms) {
                        programWrap = new ProgramWrap(wpProgram);
                        programWrapList.add(programWrap);
                    }
                }
            }
            else {
                programWrap = new ProgramWrap(oppLineItem);
                programWrapList.add(programWrap);
            }
            if(oppLineItem.Disable_BH_Coaching__c) {
                Disable_BH_Coaching = true;
            }
            if(oppLineItem.Disable_Teletherapy__c) {
                Disable_Teletherapy = true;
            }
            system.debug('Disable Teletherapy::: ' + oppLineItem.Disable_Teletherapy__c);
        }
        
        //Creating Program Overviews for all the programs that came from both Standalone and Whole Person Solution OLIs
        if (programWrapList.size() > 0) {
            for (ProgramWrap program: programWrapList) {
                String programName = program.ProgramName;
                //If the program is already existing in the Map, It doesn't add duplicate programs rather it updates the Program Type based on the below logic
                if (programOverviewsToCreateMap.keySet().contains(programName)) {        
                    switch on programOverviewsToCreateMap.get(programName).Program_Type__c {
                        when 'WP Anchor' {
                            programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Anchor';
                        }
                        when 'WP Non-Anchor' {
                            if (program.programType == 'WP Anchor') {
                                programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Anchor';
                            }
                            else if (program.programType == 'Standalone') {
                                programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Non-Anchor + Standalone';
                            }
                        }
                        when 'Standalone' {
                            if (program.programType == 'WP Anchor') {
                                programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Anchor';
                            }
                            else if (program.programType == 'WP Non-Anchor') {
                                programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Non-Anchor + Standalone';
                            }
                        }
                        when 'WP Non-Anchor + Standalone' {
                            if (program.programType == 'WP Anchor') {
                                programOverviewsToCreateMap.get(programName).Program_Type__c = 'WP Anchor';
                            }
                        }
                    }
                }
                //If the program is not existing it adds a new program to Map
                else {
                    Contract__c programOverview = new Contract__c();
                    programOverview.Account__c = opp.Account__c;
                    programOverview.Client_Overview__c = oppToClientOverviewsMap.get(opp.Id).Id;
                    programOverview.RecordTypeId = PROGRAM_OVERVIEW_RT;
                    programOverview.Program_Name__c = program.programName;
                    
                    
                    
                    if (opp.Contract_Path__c != null && opp.Account__c != null) {
                        programOverview.Name = (opp.Account__r.Name + ' - ' + program.programName + ' - ' + opp.Contract_Path__r.Name).left(80).trim();
                    }
                    else if (opp.Account__c != null) {
                        programOverview.Name = (opp.Account__r.Name + ' - ' + program.programName).left(80).trim();
                    }
                    programOverview.Program_Type__c = program.programType;
                    if (program.programName == 'Hypertension' && program.pricingStructure != null && program.pricingStructure.Contains('Cellular')) {
                        programOverview.New_Device_Type__c = NEW_DEVICE_TYPE_HT900;
                    }
                    if (program.programName == 'Hypertension' && program.pricingStructure != null && program.pricingStructure.Contains('Cellular')) {
                        programOverview.New_Device_Type__c = NEW_DEVICE_TYPE_HT900;
                    }
                    /* Bluetooth Pricing Structure for Hypertension has been removed
                    else if (program.programName == 'Hypertension' && program.pricingStructure != null && program.pricingStructure.Contains('Bluetooth')) {
                    programOverview.New_Device_Type__c = NEW_DEVICE_TYPE_HTAND;
                    } */
                    else if (program.programName == 'Hypertension' && programOverview.Program_Type__c != 'Standalone') {
                        programOverview.New_Device_Type__c = NEW_DEVICE_TYPE_HT900;
                    }
                    if (program.oliName != null && program.oliName == DEFAULT_BH_V1_PROGRAM_NAME) {
                        programOverview.Program_Platform_Version__c = DEFAULT_MYSTRENGTH_PROGRAM_PLATFORM_VERSION;
                    }
                    else if (program.programPlatformVersion != null) {
                        programOverview.Program_Platform_Version__c = program.programPlatformVersion;
                    }
                    else if (program.oliName != null && program.oliName == MYSTRENGTH) {
                        programOverview.Program_Platform_Version__c = MYSTRENGTH;
                        programOverview.Disable_BH_Coaching__c = true;
                        programOverview.Disable_Teletherapy__c = true;
                    }
                    else if (program.oliName != null && program.oliName == MYSTRENGTH_COMPLETE) {
                        programOverview.Program_Platform_Version__c = MYSTRENGTH_COMPLETE;
                    }
                    if ((program.oliName != null && program.oliName == DIABETES_W_CKD_AWARE_VARIANT) ||
                        (program.oliName != null && program.oliName == HYPERTENSION_W_CKD_AWARE_VARIANT) || 
                        (program.soultionName != null && program.soultionName == 'CKD Solution' && (program.programName == 'Diabetes' || program.programName == 'Hypertension'))) {
                            programOverview.CKD_Aware_Variant__c = true;
                        }
                    programOverview.Program_Implementation_status__c = DEFAULT_PROGRAM_IMPLEMENTATION_STATUS;
                    
                    programOverview.Disable_BH_Coaching__c = Disable_BH_Coaching && programOverview.Program_Name__c == 'Behavioral Health' && 
                        (programOverview.Program_Platform_Version__c == null || programOverview.Program_Platform_Version__c == 'Livongo') ? true : false;
                    programOverview.Disable_Teletherapy__c = Disable_Teletherapy && programOverview.Program_Name__c == 'Behavioral Health' &&
                        (programOverview.Program_Platform_Version__c == null || programOverview.Program_Platform_Version__c == 'myStrength Complete') ? true : false;
                    
                    programOverviewsToCreateMap.put(programOverview.Program_Name__c, programOverview);
                }
            }
            //If the sourceType is Whole Person Program Overview Transition it sets the deafult values for programs from existing standalone programs
            if (sourceType == 'Whole Person Program Overview Transition' && programOverviewsToCreateMap.size() > 0) {
                for (Contract__c p : programOverviewsToCreateMap.Values()) {
                    if (p.Program_Type__c != 'WP Non-Anchor') {
                        existingPO = existingProgramsMap.get(p.Program_Name__c);
                        if (existingPO != null) {
                            p.Whole_Person_Transition_Date__c = opp.Launch_Date__c;
                            p.OE_Month_End__c = existingPO.OE_Month_End__c;
                            p.Actual_Launch_Date__c = existingPO.Actual_Launch_Date__c;
                            p.Member_Recruitment_Began__c = existingPO.Member_Recruitment_Began__c;
                            p.Recruitable_Pop_Current__c = existingPO.Recruitable_Pop_Current__c;
                            p.Product_Enrollment_Cap__c = existingPO.Product_Enrollment_Cap__c;
                            p.CSM__c = existingPO.CSM__c;
                            p.CIM__c = existingPO.CIM__c;
                            p.cbi_header__c = existingPO.cbi_header__c;
                            p.cbi_step1__c = existingPO.cbi_step1__c;
                            p.cbi_step2__c = existingPO.cbi_step2__c;
                            p.cbi_step3__c = existingPO.cbi_step3__c;
                            p.cbi_disclaimer__c = existingPO.cbi_disclaimer__c;
                            p.Program_Began_as_Pilot__c = existingPO.Program_Began_as_Pilot__c;
                            p.Disclaimer__c = existingPO.Disclaimer__c;
                            p.Eligibility_Sentence__c = existingPO.Eligibility_Sentence__c;
                            p.Spanish_Eligibility_Sentence__c = existingPO.Spanish_Eligibility_Sentence__c;
                            p.Automated_Enrollment_Injection__c = existingPO.Automated_Enrollment_Injection__c;
                            p.Relaunch_Start_Date__c = existingPO.Relaunch_Start_Date__c;
                            p.Pop_Refresh_Start_Date__c = existingPO.Pop_Refresh_Start_Date__c;
                            p.Name = existingPO.Name;
                            p.Is_there_Lapse_Criteria__c = existingPO.Is_there_Lapse_Criteria__c;
                            p.Lapsed_Criteria_Source__c = existingPO.Lapsed_Criteria_Source__c;
                            p.Escalation_Details__c = existingPO.Escalation_Details__c;
                            p.Eligibility_Escalation_Path__c = existingPO.Eligibility_Escalation_Path__c;
                            p.Eligibility_Verification_Method__c = existingPO.Eligibility_Verification_Method__c;
                        }
                    }
                }
            }
            
        }
        //Inserting the POs
        if (programOverviewsToCreateMap.size() > 0) {
            try {
                insert programOverviewsToCreateMap.values();
            }
            catch (DmlException ex) {
                System.debug('An exception occurred: ' + ex.getMessage());
            }
        }
        
        //Updating the opp so the newly created CO is associated with the Opportunity.
        opp.Contract__c = oppToClientOverviewsMap.get(opp.Id).Id;
        update opp;
    }
    
    public static void copyCoDetailsToPOs(Map<Id, Contract__c> oldCoMap, List<Contract__c> clientOverviewsList) {
        List<Contract__c> poList = new List<Contract__c>();
        List<Contract__c> poListToBeUpdatedFinal = new List<Contract__c>();
        
        Map<Id,Contract__c> coMap = new Map<Id,Contract__c>([SELECT Id, Name, RecordType.Name, Campaign_Lifecycle_Participation__c, Campaign_Type__c,Custom_Campaign__c,Phone_Campaign__c,Enrollment_on_Autopilot__c  
                  FROM Contract__c WHERE ID IN : clientOverviewsList]);
        
        if(coMap.keySet().size() > 0) {
            
            poList = [SELECT Id, Name, RecordType.Name,client_Overview__c, Campaign_Lifecycle_Participation__c, Campaign_Type__c,Custom_Campaign__c,Phone_Campaign__c,Enrollment_on_Autopilot__c  
                  FROM Contract__c WHERE client_Overview__c IN : coMap.keySet()];
            for(Contract__c po : poList) {
                Boolean addToList = false;
                if(String.IsBlank(po.Campaign_Lifecycle_Participation__c) && po.Campaign_Lifecycle_Participation__c != coMap.get(po.Client_Overview__c).Campaign_Lifecycle_Participation__c
                   && coMap.get(po.Client_Overview__c).Campaign_Lifecycle_Participation__c != oldCoMap.get(po.Client_Overview__c).Campaign_Lifecycle_Participation__c) {
                    po.Campaign_Lifecycle_Participation__c = coMap.get(po.Client_Overview__c).Campaign_Lifecycle_Participation__c;
                    addToList = true;
                }
                if(String.IsBlank(po.Campaign_Type__c) && po.Campaign_Type__c != coMap.get(po.Client_Overview__c).Campaign_Type__c 
                   && coMap.get(po.Client_Overview__c).Campaign_Type__c != oldCoMap.get(po.Client_Overview__c).Campaign_Type__c) {
                    po.Campaign_Type__c = coMap.get(po.Client_Overview__c).Campaign_Type__c;
                    addToList = true;
                }
                if(String.IsBlank(po.Custom_Campaign__c) && po.Custom_Campaign__c != coMap.get(po.Client_Overview__c).Custom_Campaign__c 
                   && coMap.get(po.Client_Overview__c).Custom_Campaign__c != oldCoMap.get(po.Client_Overview__c).Custom_Campaign__c) {
                    po.Custom_Campaign__c = coMap.get(po.Client_Overview__c).Custom_Campaign__c;
                    addToList = true;
                }
                if(String.IsBlank(po.Phone_Campaign__c) && po.Phone_Campaign__c != coMap.get(po.Client_Overview__c).Phone_Campaign__c 
                   && coMap.get(po.Client_Overview__c).Phone_Campaign__c != oldCoMap.get(po.Client_Overview__c).Phone_Campaign__c) {
                    po.Phone_Campaign__c = coMap.get(po.Client_Overview__c).Phone_Campaign__c;
                    addToList = true;
                }
                if(po.Enrollment_on_Autopilot__c == false && po.Enrollment_on_Autopilot__c != coMap.get(po.Client_Overview__c).Enrollment_on_Autopilot__c 
                   && coMap.get(po.Client_Overview__c).Enrollment_on_Autopilot__c != oldCoMap.get(po.Client_Overview__c).Enrollment_on_Autopilot__c) {
                    po.Enrollment_on_Autopilot__c = coMap.get(po.Client_Overview__c).Enrollment_on_Autopilot__c;
                    addToList = true;
                }
                if(addToList) {
                    poListToBeUpdatedFinal.add(po);
                }
            }
        }
        if(poListToBeUpdatedFinal.size() > 0) {
            update poListToBeUpdatedFinal;
        }
    }
    
    public static void getDetailsFromCoToPo(List<Contract__c> newContracts) { 
        Set<String> coIds = new Set<String>();
        for(Contract__c po : newContracts) {
           coIds.add(po.Client_Overview__c);
        }
        
        if(!coIds.isEmpty()) {
            Map<Id,Contract__c> coMap = new Map<Id,Contract__c>([SELECT Id, Name, RecordType.Name, Campaign_Lifecycle_Participation__c, Campaign_Type__c,Custom_Campaign__c,Phone_Campaign__c,Enrollment_on_Autopilot__c
                                                           FROM Contract__c WHERE ID IN : coIds]);
            for(Contract__c po : newContracts) { 
                po.Campaign_Lifecycle_Participation__c = String.IsBlank(po.Campaign_Lifecycle_Participation__c)? coMap.get(po.Client_Overview__c).Campaign_Lifecycle_Participation__c : po.Campaign_Lifecycle_Participation__c;
                po.Campaign_Type__c = String.IsBlank(po.Campaign_Type__c) ? coMap.get(po.Client_Overview__c).Campaign_Type__c : po.Campaign_Type__c;
                po.Custom_Campaign__c = String.IsBlank(po.Custom_Campaign__c) ? coMap.get(po.Client_Overview__c).Custom_Campaign__c : po.Custom_Campaign__c;
                po.Phone_Campaign__c = String.IsBlank(po.Phone_Campaign__c) ? coMap.get(po.Client_Overview__c).Phone_Campaign__c : po.Phone_Campaign__c;
                po.Enrollment_on_Autopilot__c = po.Enrollment_on_Autopilot__c == false ? coMap.get(po.Client_Overview__c).Enrollment_on_Autopilot__c :  po.Enrollment_on_Autopilot__c; 
            }
        }
    }
    //Chatter in the TechOps group for field tracking
    //Create chatter notifications based on the type of operation type
    public static void chatterTechOps(Map<Id, Contract__c> oldContracts, List<Contract__c> newContracts, List<Schema.FieldSetMember> contractTrackedFields, String operationType) {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        CollaborationGroup chatterGroup;
        List<CollaborationGroup> chatterGroupList = [SELECT Id, Name from CollaborationGroup WHERE Name = 'TechOps' LIMIT 1];
        if (chatterGroupList.size() > 0) {
            chatterGroup = chatterGroupList[0];
            if (operationType == 'Insert' || operationType == 'Update') {
                for (Contract__c newContract : newContracts) {
                    String recordTypeName = Schema.SObjectType.Contract__c.getRecordTypeInfosById().get(newContract.RecordtypeId).getName();
                    if (operationType == 'Update') {
                        Contract__c oldContract = oldContracts.get(newContract.Id);
                        for (Schema.FieldSetMember fsm : contractTrackedFields) {
                            String fieldName  = fsm.getFieldPath();
                            String fieldLabel = fsm.getLabel();
                            
                            if (newContract.get(fieldName) == oldContract.get(fieldName))
                                continue;
                            
                            if (newContract.get(fieldName) != oldContract.get(fieldName)) {
                                String inputText = '\n' + fieldLabel + ' has been updated on ' + recordTypeName + ' ' +
                                    newContract.get('ContractNumber__c')+'\n' + 
                                    'Old Value: ' + oldContract.get(fieldName) + '\n' + 
                                    'New Value: ' + newContract.get(fieldName) + '\n';
                                ConnectApi.FeedItemInput feedItemInput = createFeed(inputText, chatterGroup.Id, newContract.Id);
                                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                                batchInputs.add(batchInput);
                            }
                        }
                    }
                    else if (operationType == 'Insert' && recordTypeName == 'Program Overview') {
                        String inputText = '\nNew ' + recordTypeName +' '+newContract.get('ContractNumber__c')+' has been created';
                        ConnectApi.FeedItemInput feedItemInput = createFeed(inputText, chatterGroup.Id, newContract.Id);
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                        batchInputs.add(batchInput);   
                    } 
                }
            }
            if (operationType == 'Delete' && oldContracts != null) {
                List<Contract__c> oldContractList = oldContracts.Values();
                if (oldContracts.Values().size() > 0) {
                    for (Contract__c p : oldContracts.Values()) {
                        String recordTypeName = Schema.SObjectType.Contract__c.getRecordTypeInfosById().get(p.RecordtypeId).getName();
                        if (recordTypeName == 'Program Overview') {
                            String inputText = '\n'+ p.Program_Name__c+' Program Overview ' + p.ContractNumber__c + ' has been deleted';
                            ConnectApi.FeedItemInput feedItemInput = createFeed(inputText, chatterGroup.Id, p.Client_Overview_Id__c);
                            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                            batchInputs.add(batchInput);
                        }
                    }  
                }
            }
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
        }
    }
    //Create a feed item using Connect Api with the InputText, Mention and RecordId
    public static ConnectApi.FeedItemInput createFeed(String inputText, Id mentionId, Id recordId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        mentionSegmentInput.id = mentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = inputText;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId == null ? 'me' : recordId;
        return feedItemInput;
    }
    
    public static void updateHealthScores(List<Contract__c> newContracts) {
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, Map<String, List<Contract__c>>> accToConMap = new Map<Id, Map<String, List<Contract__c>>>();
        List<Health_Score__c> hsListToUpdate = new List<Health_Score__c>();
        String outreachStratificationDM;
        String outreachStratificationHTN;
        for (Contract__c con : newContracts) {
            accIdSet.add(con.Account__c);
        }
        if (accIdSet.size() > 0){
            List<Contract__c> conList = [SELECT Id, Account__c, Program_Name__c, Actual_Launch_Date__c, Last_Date_of_Data_Refresh__c, Outreach_Stratification__c 
                                      FROM Contract__c WHERE Account__c IN :accIdSet AND RecordType.Name = 'Program Overview' AND (Status__c != 'Terminated' OR Status__c != 'Expired')];
            
            if (conList != null) {
                for (Contract__c con : conList) {
                    if (accToConMap.containsKey(con.Account__c)) {
                        Map<String, List<Contract__c>> conMap = accToConMap.get(con.Account__c);
                        if (conMap.containsKey(con.Program_Name__c)) {
                            List<Contract__c> contractList = conMap.get(con.Program_Name__c);
                            contractList.add(con);
                        }
                        else {
                            conMap.put(con.Program_Name__c, new List<Contract__c> {con});
                        } 
                    }
                    else {
                        accToConMap.put(con.Account__c, new Map<String, List<Contract__c>> {con.Program_Name__c => new List<Contract__c> {con}});
                    }
                } 
            } 
            
            List<Health_Score__c> hsList = [SELECT Id, Account__c, Actual_Result__c, Program__c, Health_Segment__c FROM Health_Score__c 
                                            WHERE Account__c IN :accIdSet AND RecordType.Name = 'Program Health Score' 
                                            AND (Health_Segment__c = 'Client Launch Date' OR Health_Segment__c = 'Marketing Type (Outreach Stratification)')];
            
            if (hsList.size() > 0) {
                for (Health_Score__c hs : hsList) {
                    List<Contract__c> programs;
                    if (accToConMap.get(hs.Account__c) != null) {
                        programs = accToConMap.get(hs.Account__c).get(hs.Program__c);
                    }
                    if (programs != null) {
                        Contract__c closestCon = findClosestCon(programs, 'LaunchDate');
                        if (closestCon.Actual_Launch_Date__c != null && hs.Health_Segment__c == 'Client Launch Date') {
                            hs.Actual_Result__c = String.valueOf(closestCon.Actual_Launch_Date__c.format());
                        }
                        if (programs.size() > 1 && hs.Health_Segment__c == 'Marketing Type (Outreach Stratification)') {
                            String outreachStratification;
                            for (Contract__c po : programs) {
                                if (po.Outreach_Stratification__c == 'C' || outreachStratification == 'C') {      
                                    outreachStratification = 'C';
                                }
                                else if ((po.Outreach_Stratification__c == 'B' && outreachStratification != 'C') || outreachStratification == 'B') {
                                    outreachStratification = 'B';
                                }
                                else if ((po.Outreach_Stratification__c == 'A' && outreachStratification != 'B' && outreachStratification != 'C') || outreachStratification == 'A') {
                                    outreachStratification = 'A';
                                }
                                else {
                                    outreachStratification = po.Outreach_Stratification__c;
                                }
                            }
                            hs.Actual_Result__c = outreachStratification;   
                        }
                        else if (hs.Health_Segment__c == 'Marketing Type (Outreach Stratification)'){
                            hs.Actual_Result__c = programs[0].Outreach_Stratification__c;
                        }
                        hsListToUpdate.add(hs);
                    }
                } 
            }
        }
        try {
            if (hsListToUpdate.size() > 0) {
                update hsListToUpdate;
            } 
        }
        catch (DmlException ex) {
            System.debug('An exception occurred: ' + ex.getMessage());
        }
    }
    
    public static Contract__c findClosestCon(List<Contract__c> conList, String fieldName) {
        Contract__c closestCon = new Contract__c();
        Map<Date, Contract__c> conMap = new Map<Date, Contract__c>();
        Set<Date> dateSet = new Set<Date>();
        List<Date> dateList;
        
        if(conList.Size() > 0) {
            for(Contract__c con : conList) {
                if (fieldName == 'LaunchDate') {
                    conMap.put(con.Actual_Launch_Date__c, con);
                }
                else {
                    conMap.put(con.Actual_Launch_Date__c, con);
                }
            }
            dateSet = conMap.keySet();
            dateList = new List<Date>(dateSet);
            dateList.sort();
            closestCon = conMap.get(dateList[dateList.size() - 1]);
        }
        return closestCon;
    }
    
    public class ProgramWrap {
        public String soultionName {get; set;}
        public String programName {get; set;}
        public String programType {get; set;}
        public String pricingStructure {get; set;}
        public String oliName {get; set;}
        public String programPlatformVersion {get; set;}
        
        public ProgramWrap(OpportunityLineItem__c oli) {
            this.programName = oli.Program_Family__c;
            this.programType = 'Standalone';
            this.pricingStructure = oli.Pricing_Structure__r.Name;
            this.oliName = oli.OpportunityProductName__c;
        }
        
        public ProgramWrap(Whole_Person_Solution_Mapping__mdt wpProgram) {
            this.soultionName = wpProgram.Solution__c;
            this.programName = wpProgram.Program__c;
            this.programType = wpProgram.Program_Type__c;
            this.programPlatformVersion = wpProgram.Program_Platform_Version__c;
        }
    }
    
    /*
    * Inner class used to store key data that will be used/reused throughout the ContractService class.
    */
    public class ContractRenewalHelper {
        public Contract__c programOverview { get; set; }
        public Contract__c clientOverview { get; set; }
        public Product2 program { get; set; }
        public OpportunityLineItem__c oppProgram { get; set; }
        public Opportunity__c opp { get; set; }
        public Boolean disableTeleTherapy {get; set;}
        
        public ContractRenewalHelper(Contract__c programOverview) {
            this.programOverview = programOverview;
            this.disableTeleTherapy = false;
        }
    }
}
