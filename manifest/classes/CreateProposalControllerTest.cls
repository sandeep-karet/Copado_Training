@IsTest
private class CreateProposalControllerTest {
     @TestSetup
    static void setup(){
        Test.Starttest();
        Account parentAcctTest = TestDataFactory.createParentAccount();
        
        Opportunity opp = TestDataFactory.createOpportunity(parentAcctTest.Id);
        insert opp; 
        Test.Stoptest();
    }
    
    @IsTest
    static void errorCheckTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];
        String result = CreateProposalController.errorCheck(opp.Id); 
        system.assertEquals('No Quote is selected to include in Octiv Proposal for the Opportunity, Can not create a Proposal', result);
         
        SBQQ__Quote__c quoteObj = new SBQQ__Quote__c();
        quoteObj.SBQQ__Status__c = 'pending';
        quoteObj.Include_in_Octiv_Proposal__c = true;
        quoteObj.Approval_Custom_Consult_Fees__c = true;
        quoteObj.SBQQ__Primary__c = true;
        quoteObj.SBQQ__Opportunity2__c = opp.Id;
        insert quoteObj;
        Test.Starttest();
        //SBQQ.TriggerControl.disable();
        result = CreateProposalController.errorCheck(opp.Id); 
        system.assertEquals('Quote Included in Octiv Proposal is not approved, Can not create a Proposal', result);
        quoteObj.Approval_Custom_Consult_Fees__c = false;
        update quoteObj;
        result = CreateProposalController.errorCheck(opp.Id); 
        system.assertEquals(null, result);
        //SBQQ.TriggerControl.enable();
        Test.StopTest();
        
    }

}