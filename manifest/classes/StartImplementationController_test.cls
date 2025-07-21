@isTest
private class StartImplementationController_test {
	//Defined test dataset
	@testSetup static void testSetup() {
        SBQQ.TriggerControl.disable();
        Account umrAcct = TestDataFactory.createUMR();        

        Account accObj = TestDataFactory.createAccountUMR();

        List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();

        Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
        insert acctRel1;

        Id pricebookId = Test.getStandardPricebookId();

        //test.startTest();
        //create an opportunity record
        Opportunity oppObj = TestDataFactory.createOpportunityWithPriceBook(accObj.Id, pricebookId, null);
        oppObj.LeadSource = 'Sales';
        insert oppObj;

        //create Gen Med product
        Product2 prod2 = TestDataFactory.createSingleProduct('General Medical', 'General Medical', 'GM');
        insert prod2;

        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ prod2 }, pricebookId)[0];
        insert pbEntry;

        //Create a quote record
        SBQQ__Quote__c quoObj = TestDataFactory.createQuote(oppObj.Id);

        insert quoObj;

        //Create quotelines
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(quoObj.Id, prod2.Id);
        Insert quoline1;

        OpportunityLineItem opl = TestDataFactory.createOLI(oppObj.Id, pbEntry.Id, null);
        opl.TotalPrice = 500 * pbEntry.UnitPrice;
        insert opl;
        SBQQ.TriggerControl.enable();
        
    }
    @isTest
    static void happyPath() {
        Test.startTest();
        SBQQ.TriggerControl.disable();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Opportunity opp = [SELECT Id, Contract_Path__c FROM Opportunity];
        Account accObj = TestDataFactory.createAccountUMR();
        User u1 = TestDataFactory.createUser(p.Id);
        insert u1;  
        opp.Contract_Path__c =  accObj.Id;//System.Label.TD_Teladoc_Account;
        opp.StageName = 'Contracting';
        opp.SBQQ__Contracted__c = true;
        update opp;
        System.runAs(u1) {
            try {
                StartImplementationController.startImplementation(opp.Id);
            }catch (Exception e){}
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    
    @isTest
    static void invalidStage() {
        Test.startTest();
        SBQQ.TriggerControl.disable();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Opportunity opp = [SELECT Id FROM Opportunity];
        User u1 = TestDataFactory.createUser(p.Id);
        insert u1;
        
        System.runAs(u1) {
            try {     
                StartImplementationController.startImplementation(opp.Id);
            }catch (Exception e){}
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }
    @isTest
    static void noPrimary() {
        Test.startTest();
        SBQQ.TriggerControl.disable();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Opportunity opp = [SELECT Id FROM Opportunity];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c];
        quote.SBQQ__Primary__c = false;
        update quote;
        User u1 = TestDataFactory.createUser(p.Id);
        insert u1;
        
        System.runAs(u1) {
            try {     
                StartImplementationController.startImplementation(opp.Id);
            }catch (Exception e){}
        }
        SBQQ.TriggerControl.enable();
        Test.StopTest();
    }
}