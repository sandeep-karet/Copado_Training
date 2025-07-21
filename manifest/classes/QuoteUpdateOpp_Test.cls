@IsTest
Private class QuoteUpdateOpp_Test {
	@TestSetup
    static void setup(){
        Account acct = TestDataFactory.createParentAccount();
        Opportunity oppObj = TestDataFactory.createOpportunity(acct.Id);
		insert oppObj;
        
        SBQQ__Quote__c qte2 = TestDataFactory.createQuote(oppObj.Id);
        qte2.SBQQ__Account__c = acct.Id;
        insert qte2;
        
        SBQQ__Quote__c qte1 = TestDataFactory.createQuote(oppObj.Id);
		qte1.SBQQ__Account__c = acct.Id;
        qte1.SBQQ__StartDate__c = date.today();
        insert qte1;
        
        //qte1.SBQQ__StartDate__c = date.today();
        //update qte1;
 
    }
    @IsTest
    static void updateOppDate(){
        Opportunity oppObj = [SELECT CloseDate, Id FROM Opportunity];
        List<SBQQ__Quote__c> qte = [SELECT Id, SBQQ__StartDate__c FROM  SBQQ__Quote__c];
     //   system.assertEquals(date.today(), qte[0].SBQQ__StartDate__c);
        system.assertEquals(date.today(), qte[1].SBQQ__StartDate__c);
        system.assertEquals(date.today(), [SELECT CloseDate FROM Opportunity WHERE Id =: oppObj.Id].CloseDate);

        
    }
}