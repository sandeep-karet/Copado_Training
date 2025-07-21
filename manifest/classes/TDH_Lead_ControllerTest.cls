/*************************************************************************     
* @description This class is used as Test class for TDH_Lead_Controller apex class
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class TDH_Lead_ControllerTest {
    @TestSetup
    static void testsetup() {
        List<Lead> testLeads = GCRM_TestDataFactory_Test.createLeads(1);
       system.assertNotEquals(null, testLeads,'Success');
        Lead ld = [SELECT Id FROM Lead  LIMIT 1];
        ld.Transferred_To__c ='ITH';
        update ld;
    }
    
    @isTest
    static void getLeadTest(){
        Test.startTest();
        Lead ld = [SELECT Id FROM Lead  LIMIT 1];
        Lead ldResult = TDH_Lead_Controller.getLead(ld.Id);
        system.assertNotEquals(null, ldResult,'Success');
        Test.stopTest();
    }
    
    @isTest
    static void testPostCallout200() {
        Test.startTest();
        Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead  LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockTDH2ITH_Test()); 
        TDH_Lead_Controller.ResWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
        system.assertNotEquals(null, wrapper,'Success');
        Test.stopTest();
        
    }
    
    @isTest
    static void testPostCalloutNon200() {
        Test.startTest();
        Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead  LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new FailMockTDH2ITH_Test()); 
        TDH_Lead_Controller.ResWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
        system.assertNotEquals(null, wrapper,'Success');
        Test.stopTest();
        
    }
    
    @isTest
    static void testPostCallout401() {
        Test.startTest();
        Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead  LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockTDH2ITH401_Test()); 
        TDH_Lead_Controller.ResWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
        system.assertNotEquals(null, wrapper,'Success');
        Test.stopTest();
        
    }   
}