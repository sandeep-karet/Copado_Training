@isTest
private class subTermSch_Test {
  public static testMethod void testschedule() {
    Test.StartTest();
    subTermSch sh1 = new subTermSch();
    String sch = '0 0 23 * * ?';
    system.schedule('Merge Job', sch, sh1);
    Test.stopTest();
  }
}