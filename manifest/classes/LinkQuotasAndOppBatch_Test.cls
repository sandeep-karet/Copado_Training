@isTest
private class LinkQuotasAndOppBatch_Test {
    @testSetup 
    static void setupdata() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = TestDataFactory.createUser(p.Id);
        insert u1;
        
        
        Account umrAcct = TestDataFactory.createUMR();        

        Account accObj = TestDataFactory.createAccountUMR();
        Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
        insert acctRel1;
        system.debug('after insert');
        Id pricebookId = Test.getStandardPricebookId();

        test.startTest();
        //create an opportunity record
        Opportunity oppObj = TestDataFactory.createOpportunityWithPriceBook(accObj.Id, pricebookId, u1.Id);
        insert oppObj;

        //create Gen Med product
        Product2 prod2 = TestDataFactory.createProducts(new List<String>{ 'General Medical' })[0];
        insert prod2;

        PricebookEntry pbEntry = TestDataFactory.createPriceBookEntries(new List<Product2>{ prod2 }, pricebookId)[0];
        insert pbEntry;
        //Create a quote record
        SBQQ__Quote__c quoObj = TestDataFactory.createQuote(oppObj.Id);
        quoObj.CPQ_Pricebook__c = 'Broker';
        insert quoObj;

        //Create quotelines
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(quoObj.Id, prod2.Id);
        Insert quoline1;  
        Test.stopTest();
  
    }
    
    static testMethod void test(){        
		Test.startTest();
        User u1 = [SELECT Id FROM User WHERE Alias = 'jimbo'];
        Opportunity opp = [select id from Opportunity limit 1];
        PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry];
        OpportunityLineItem opl = TestDataFactory.createOLI(opp.Id, pbEntry.Id, null);
        opl.Quantity = 500;
        opl.TotalPrice = 500 * pbEntry.UnitPrice;
        insert opl;
        
        opp.Contracted_Date__c = Date.Today();
        opp.Contract_Service_Agreement_Status__c = 'N/A - Under Master Agreement';
        //opp.Contract_Path__c =  System.Label.TD_Teladoc_Account;
        opp.StageName = 'Closed Won';
        update opp;
   
        Quotas__c quotas = TestDataFactory.createQuotas(u1.Id);
        insert quotas; 
        
        LinkQuotasAndOppBatch testing = new LinkQuotasAndOppBatch();
        DataBase.executeBatch(testing);
        
        Test.stopTest();
        QuotasUpdateBatch testing2 = new QuotasUpdateBatch();
        DataBase.executeBatch(testing2);
		
        
    }
    
}