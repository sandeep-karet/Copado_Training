/**
* This class is used to generate test data for unit tests.
* Created : 05/20/2019
* @author Connor Gallaher
*/
@isTest
global class TestFactory {
    //Creates and returns a Program with the specified program name
    public static Product2 createProgram(String programName) {
        Product2 program = new Product2(Name=programName, Family=programName, IsActive=true, ProductCode = programName);
        return program;
    }
    public static Product2 createProgramWithFamily(String programName, String programFamily) {
        Product2 program = new Product2(Name=programName, Family=programFamily, IsActive=true, ProductCode = programName);
        return program;
    }
    //Creates and returns a Whole Person Program with the specified program name
    public static Product2 createWPProgram(String programName, String programFamily) {
        Product2 program = new Product2(Name=programName, Family=programFamily, IsActive=true, ProductCode = programName, Whole_Person_Solution__c = true);
        return program;
    }

    //Creates and returns a Pricebook
    public static Pricebook2 createPricebook() {
        Pricebook2 livongoPricebook = new Pricebook2(Name='Livongo', IsActive=true);
        return livongoPricebook;
    }

    //Creates and returns a PricebookEntry in the Pricebook with the specified Pricebook Id and specified Program Id
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id programId) {
        PricebookEntry pbe = new PricebookEntry(Pricebook2ID = pricebookId, Product2Id = programId, UnitPrice=10, IsActive=true);
        return pbe;
    }

    //Creates and returns an Account with the Client Account Record Type
    public static Account__c createClientAccount() {
        Account__c testAccount = new Account__c();
        testAccount.RecordTypeId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        testAccount.Name = 'Test Client Account';
        testAccount.Type__c = 'Self Funded Employer';
        testAccount.Covered_Lives__c = 10000; 
        return testAccount;
    }
    
    //Creates and returns an Account with the Downmarket Client Record Type
    public static Account__c createDownmarketClientAccount() {
        Account__c testAccount = new Account__c();
        testAccount.RecordTypeId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Downmarket_Client').getRecordTypeId();
        testAccount.Name = 'Test Downmarket Client Account';
        testAccount.Type__c = 'Self Funded Employer';
        testAccount.Covered_Lives__c = 10000;
        return testAccount;
    }

    //Creates and returns an Account with the Competitor Account Record Type
    public static Account__c createCompetitorAccount() {
        Account__c testAccount = new Account__c();
        testAccount.RecordTypeId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Competitor_Account').getRecordTypeId();
        testAccount.Name = 'Test Competitor Account';
        testAccount.Type__c = 'Payer/ASO';
        testAccount.Covered_Lives__c = 10000;
        return testAccount;
    }

    //Creates and returns an Account with the Partner Account Record Type
    public static Account__c createPartnerAccount() {
        Account__c testAccount = new Account__c();
        testAccount.RecordTypeId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
        testAccount.Name = 'Test Partner Account';
        testAccount.Type__c = 'Payer/ASO';
        testAccount.Covered_Lives__c = 10000;
        return testAccount;
    }

    //Creates and returns a new Opportunity
    public static Opportunity__c createOpportunity() {
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Opportunity';
        opp.StageName__c = 'Prospect';
        opp.Type__c = 'Renewal';
        opp.CloseDate__c = Date.today().addDays(1);
        return opp;
    }
    
    //Creates and returns a new Opportunity based on the type provided
    public static Opportunity__c createTypeBasedOpportunity(String type) {
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Opportunity ' + type;
        opp.StageName__c = 'Prospect';
        opp.Type__c = type;
        opp.CloseDate__c = Date.today().addDays(1);
        opp.LeadSource__c = 'Other';
        return opp;
    }
    
    //Creates and returns a new Pricing Structure
    public static Pricing_Structure__c createPricingStructure(Id pricebookId, Id programId) {
        Pricing_Structure__c ps = new Pricing_Structure__c();
        ps.Name = 'Standard';
        ps.Price_Book__c = pricebookId;
        ps.Program__c = programId;
        ps.IsActive__c = true;
        ps.List_Price__c = 65;
        return ps;
    }
    
    //Creates and returns a new OpportunityLineItem
    public static OpportunityLineItem__c createOpportunityLineItem(Id opptyId, Id pbeId) {
        OpportunityLineItem__c oli = new OpportunityLineItem__c();
        oli.Opportunity__c = opptyId;
        //oli.PricebookEntryId = pbeId;
        oli.Quantity__c = 12;
        oli.Product_Participants__c = 100;
        oli.UnitPrice__c = 65;
        return oli;
    }

    //Creates and returns a Contract (Client Overview)
    public static Contract__c createClientOverview() {
        Contract__c clientOverview = new Contract__c();
        clientOverview.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId();
        clientOverview.Status__c = 'Draft';
        return clientOverview;
    }

    //Creates and returns a Contract (Program Overview)
    public static Contract__c createProgramOverview() {
        Contract__c programOverview = new Contract__c();
        programOverview.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId();
        programOverview.Status__c = 'Draft';
        programOverview.Auto_Renewal__c = true;
        programOverview.PPPM__c = 100;
        programOverview.Participants__c = 1000;
        programOverview.Program_End_Date__c = Date.today();
        programOverview.Complete_Per_Legal__c = false;
        return programOverview;
    }
    
    //Creates and returns a TaskRayProject
    /*public static TASKRAY__Project__c createTaskRayProject() {
        TASKRAY__Project__c project = new TASKRAY__Project__c();
       	project.TaskRayStatus__c = 'Not Started';
        project.Project_Template_Category__c = 'Project Template';
        project.Project_Type__c = 'Contract Path Change';
        //project.Project_Sub_Type__c = 'Enterprise';
        return project;
    }*/

    //Creates and returns a ClientHandoffSummary
    public static Client_Handoff_Summary__c createClientHandoffSummary() {
        Client_Handoff_Summary__c chs = new Client_Handoff_Summary__c();
        return chs;
    }

    //Creates and returns a Contact
    public static Contact__c createSalesContact() {
        Contact__c con = new Contact__c();
        con.FirstName__c = 'Spider Man';
        con.LastName__c = 'Marvel';
        con.RecordTypeId = Schema.SObjectType.Contact__c.getRecordTypeInfosByDeveloperName().get('Sales_Contact').getRecordTypeId();
        con.Work_Phone__c = '1234567890';
        con.Email__c = 'contest@test.com';
        return con;
    }
    
    //Creates and returns a Relationship based on the type
    public static Relationship__c createRelationship(String type) {
        Relationship__c  rel = new Relationship__c();
        rel.RelationshipType__c = type;
        return rel;
    }
    
    //Creates and returns a Client Member Code
    public static ClientMemberCode__c createClientMemberCode(){
        ClientMemberCode__c memberCode= new ClientMemberCode__c();
        memberCode.RecordTypeId=Schema.SObjectType.ClientMemberCode__c.getRecordTypeInfosByDeveloperName().get('ClientMemberCode').getRecordTypeId();
        memberCode.UsedforRegistration__c=true;
        memberCode.ClientMemberCode__c='CMCXYZ9000';     
        return memberCode;
    }
    
    
}