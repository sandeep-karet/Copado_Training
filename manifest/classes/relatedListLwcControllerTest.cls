@IsTest
private class relatedListLwcControllerTest {
    @TestSetup
    static void setup(){
        Account umrAcct = TestDataFactory.createUMR();        
        Account accObj = TestDataFactory.createAccountUMR();
        
        Mbr_Group__c mbrGrp = TestDataFactory.createMbrGroup(accObj.Id)[0];
        
        //create an opportunity record
        Opportunity opp = TestDataFactory.createOpportunity(accObj.Id);     
        opp.LeadSource = 'Sales';
        insert opp;
       
        SBQQ__Quote__c sbqqQte = TestDataFactory.createQuote(opp.Id);
        insert sbqqQte;
        
        //create Gen Med - Consult Fee product
        Product2 prod = TestDataFactory.createSingleProduct('GM - Consult Fee', 'General Medical', 'GMCF');
        insert Prod;
        
        SBQQ__QuoteLine__c quoline = TestDataFactory.createQuoteLine(sbqqQte.Id, prod.Id);
        insert quoline;
        
         

        
    }
    
    @IsTest
    static void getQteLineTest() {
        SBQQ__Quote__c qte = [SELECT Id FROM SBQQ__Quote__c];      
        List<SBQQ__QuoteLine__c> qteLineList = relateListLwcController.getQteLine(qte.Id);
        system.assertEquals(1, qteLineList.size());           
    }
    
    @IsTest
    static void getOppProdTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<OpportunityLineItem> oppProdList = relateListLwcController.getOppProd(opp.Id);
        system.assertEquals(0, oppProdList.size());           
    }
    
    @IsTest
    static void getOppQteTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<SBQQ__Quote__c> qteList = relateListLwcController.getOppQte(opp.Id);
        system.assertEquals(1, qteList.size());           
    }
}