@IsTest
private class CreateContractControllerTest {
    @TestSetup
    static void setup(){

        Contact con = new Contact();

        Account parentAcctTest = TestDataFactory.createParentAccount();
		con = TestDataFactory.createContact(parentAcctTest.Id);
        parentAcctTest.Primary_Billing_Contact__c = con.Id;
        parentAcctTest.Account_Type__c = 'Hospital and Health System';
        update parentAcctTest;

        Id pricebookId = Test.getStandardPricebookId();

        Opportunity opp = TestDataFactory.createOpportunity(parentAcctTest.Id);
        opp.Pricebook2Id = pricebookId;
		opp.Benefit_Consultant_Involved_in_Deal__c = 'NO';
        opp.LeadSource = 'Sales';
        insert opp;

        OpportunityContactRole oppRole = new OpportunityContactRole();
        oppRole.OpportunityId = opp.Id;
        oppRole.ContactId = con.Id;
        insert oppRole;
       
        product2 pdObj = TestDataFactory.createSingleProduct('General Medical', 'General Medical', 'GM');
        insert pdObj;

        SBQQ__Quote__c quoteObj = TestDataFactory.createQuote(opp.Id);
        insert quoteObj;

        SBQQ__QuoteLine__c quoline2 = TestDataFactory.createQuoteLine(quoteObj.Id, pdObj.Id);
        insert quoline2;


        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ pdObj }, pricebookId)[0];
        insert pbEntry;

        OpportunityLineItem opl = TestDataFactory.createOLI(opp.id, pbEntry.Id, null);
        opl.Quantity = 500; 
        opl.TotalPrice = 500 * pbEntry.UnitPrice;
        insert opl;
        
    }
    @IsTest
    static void errorMissingLivesTest() {
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.Initial_of_Lives__c = null;
        update opp;
        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Number of Lives field missing, can not create a Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorMissingBillingContact(){
        test.startTest();
        Account acct = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];

        acct.Primary_Billing_Contact__c = null;
        update acct;
        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Primary Billing Contact missing, can not create a Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorMissingContactRole(){
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        OpportunityContactRole contactRole = [select id from OpportunityContactRole where OpportunityId =: opp.id];

        delete contactRole;
        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Contact Role is missing, can not create a Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorMissingPrimaryQuote(){
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        SBQQ__Quote__c quote = [select id,SBQQ__primary__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: opp.Id];
        quote.SBQQ__primary__c = false;
        update quote;

        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('No Primary Quote for the Opportunity, Can not create a Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorNotApprovedQuote(){
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        SBQQ__Quote__c quote = [select id,SBQQ__primary__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: opp.Id];
        quote.SBQQ__Status__c = 'pending';
        quote.Approval_Custom_Consult_Fees__c = true;
        update quote;

        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Primary Quote is not Approved, Can not create a Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorOppStage(){
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];

        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('The Opportunity must be in Contracting to create an Octiv Contract', result);
        test.stopTest();
    }

    @IsTest
    static void errorNoContracteeRel(){
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Operations'];
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='test12345@testtest.com',EmailEncodingKey='UTF-8',
                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testzxcas.org');
        insert u1;
        Opportunity opp = [SELECT Id FROM Opportunity];
        System.runAs(u1){
            String result = CreateContractController.errorCheck(opp.Id);
            //Below values will be deprecated later for Contract Path LOB functionality
            //system.assertEquals('No Contractee relationship exists on account', result);
        }
        test.stopTest();
    }

    @IsTest
    static void successContract(){
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];        
        //opp.Contract_Path__c =  System.Label.TD_Teladoc_Account;
        opp.StageName = 'Contracting';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Employer – Teladoc and HY Products').getRecordTypeId();
        update opp;

        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals(null, result);
        test.stopTest();
    }

    /*
    @IsTest
    static void errorCheckTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Operations'];
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='test12345@testtest.com',EmailEncodingKey='UTF-8', 
                           LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testzxcas.org');
        insert u1;

        product2 prod = [SELECT Id FROM product2];
        Account acct = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        SBQQ__Quote__c quote = [select Id from SBQQ__Quote__c];

        String result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Number of Lives field missing, can not create a Contract', result);
        opp.Initial_of_Lives__c = 100;
        update opp;
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Primary Billing Contact missing, can not create a Contract', result);
        Contact con = new Contact();
        con.LastName = 'test name';
        con.AccountId = acct.Id;
        insert con; 
        acct.Primary_Billing_Contact__c = con.Id;
        update acct;
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Contact Role is missing, can not create a Contract', result);
        OpportunityContactRole oppRole = new OpportunityContactRole();
        oppRole.OpportunityId = opp.Id;
        oppRole.ContactId = con.Id;
        insert oppRole;
        test.startTest();
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('No Primary Quote for the Opportunity, Can not create a Contract', result);
        test.stopTest();
        test.startTest();
        quote.SBQQ__Primary__c = true;
        update quote;
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('Primary Quote is not Approved, Can not create a Contract', result);
        test.stopTest();
        quote.SBQQ__Status__c = 'Approved';
        quote.Approval_Custom_Consult_Fees__c = false;
        update quote;
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals('The Opportunity must be in Contracting to create an Octiv Contract',result);
        opp.StageName = 'Contracting';
        update opp;
        
        test.startTest();
        result = CreateContractController.errorCheck(opp.Id);
        system.assertEquals(null, result);
        System.runAs(u1){
            result = CreateContractController.errorCheck(opp.Id);
            system.assertEquals('No Contractee relationship exists on account', result);
        }
        test.stopTest();
    }
    */

}