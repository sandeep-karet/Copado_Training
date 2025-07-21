@isTest
public class TDH_Lead_ControllerTest {
  @TestSetup
  static void testsetup() {
    List<Lead> testLeads = TestDataFactory.createLeads(1);
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    ld.Transferred_To__c = 'ITH';
    update ld;
  }

  @isTest
  static void getLead_test() {
    Test.startTest();
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    Lead ldResult = TDH_Lead_Controller.getLead(ld.Id);
    system.assertNotEquals(null, ldResult);
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_200() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new MockTDH2ITH_Test());
    TDH_Lead_Controller.resWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_non200() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new FailMockTDH2ITH_Test());
    TDH_Lead_Controller.resWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_401() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId, Transferred_To__c FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new MockTDH2ITH401_Test());
    TDH_Lead_Controller.resWrapper wrapper = TDH_Lead_Controller.sendRecord(ld);
    Test.stopTest();
  }
}