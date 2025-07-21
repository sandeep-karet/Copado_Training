@isTest
private class Contact_Group_sch_Test {
  static testMethod void rollupTest() {
    Test.StartTest();
    Contact_Grp_Rollup_Sch sh1 = new Contact_Grp_Rollup_Sch();
    String sch = '0 0 23 * * ?';
    system.schedule('Test  Check', sch, sh1);
    Test.stopTest();
  }

  static testMethod void zeroTest() {
    Test.StartTest();
    Contact_Grp_Zero_sch sh1 = new Contact_Grp_Zero_sch();
    String sch = '0 0 23 * * ?';
    system.schedule('Test  Check', sch, sh1);
    Test.stopTest();
  }
}