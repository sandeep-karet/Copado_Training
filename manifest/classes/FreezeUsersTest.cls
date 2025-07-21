@isTest
private class FreezeUsersTest {
  //Test Freeze
  @isTest
  private static void testFreeze() {
    Test.startTest();
    FreezeUsers.Freeze();
    Test.stopTest();
  }
  //Test Thaw
  @isTest
  private static void testThaw() {
    Test.startTest();
    FreezeUsers.Thaw();
    Test.stopTest();
  }
}