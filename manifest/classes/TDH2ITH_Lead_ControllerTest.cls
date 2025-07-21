@isTest
public class TDH2ITH_Lead_ControllerTest {
  @TestSetup
  static void testsetup() {
    List<Lead> testLeads = TestDataFactory.createLeads(1);
  }

  @isTest
  static void getLead_test() {
    Test.startTest();
    Lead ld = [SELECT Id FROM Lead LIMIT 1];
    Lead ldResult = TDH2ITH_Lead_Controller.getLead(ld.Id);
    system.assertNotEquals(null, ldResult);
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_200() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new MockTDH2ITH_Test());
    TDH2ITH_Lead_Controller.resWrapper wrapper = TDH2ITH_Lead_Controller.sendRecord(
      ld
    );
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_non200() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new FailMockTDH2ITH_Test());
    TDH2ITH_Lead_Controller.resWrapper wrapper = TDH2ITH_Lead_Controller.sendRecord(
      ld
    );
    Test.stopTest();
  }

  @isTest
  static void testPostCallout_401() {
    Test.startTest();
    Lead ld = [SELECT Id, ownerId FROM Lead LIMIT 1];
    Test.setMock(HttpCalloutMock.class, new MockTDH2ITH401_Test());
    TDH2ITH_Lead_Controller.resWrapper wrapper = TDH2ITH_Lead_Controller.sendRecord(
      ld
    );
    Test.stopTest();
  }
}