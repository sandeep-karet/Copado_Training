@isTest
private class OppCloseSch_Test {
  public static testMethod void testschedule() {
    Test.StartTest();
    OppCloseSch sh1 = new OppCloseSch();
    String sch = '0 0 23 * * ?';
    system.schedule('Merge Job', sch, sh1);
    Test.stopTest();
  }
}