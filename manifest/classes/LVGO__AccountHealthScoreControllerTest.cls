@isTest
public class AccountHealthScoreControllerTest {
    @TestSetup
    static void setupData() {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
    }
    
    private static Account__c getClientAccount() {
        return [SELECT Id FROM Account__c LIMIT 1];
    }
    
    private static List<Health_Score__c> getHealthScores(Id accId) {
        return [SELECT Id FROM Health_Score__c WHERE Account__c = :accId];
    }
    
    @isTest
    static void hsControllerTest() {
        Account__c acc = getClientAccount();
        Test.startTest();
        AccountHealthScoreController.getHealthScores(acc.Id);
        Test.stopTest();
        List<Health_Score__c> hsList = getHealthScores(acc.Id);
        system.assertEquals(32, hsList.size());
    }
}