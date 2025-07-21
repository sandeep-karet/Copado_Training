@isTest
private class GrpTermSchTest {
  public static testMethod void testschedule() {
    Test.StartTest();
    GrpTermSch sh1 = new GrpTermSch();
    String sch = '0 0 23 * * ?';
    system.schedule('Test  Check', sch, sh1);
    Test.stopTest();
  }
}