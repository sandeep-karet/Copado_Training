/**************************************************************************************************
* author        : Utkarsh Chaurasia
* date          : 10/03/2022
* Name          : QuoteExtControllerTest
* @description  : Test Class for QuoteExtController for enabling Quote Object Advanced Approval Process
* History       :
**************************************************************************************************/
@isTest
private class QuoteExtControllerTest {
    
    /**
     * @name  testSubmit()
     * @description To create test scenario on Submit action
     * @params  none
     */
    private static void testSubmit() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c,'Quote is not Approved.');
    }
    
    /**
     * @name testRecall()
     * @description To create test scenario in Recall action
     * @params  none
     */
    private static void testRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c,'Quote is not successfully Recalled.');
    }
}