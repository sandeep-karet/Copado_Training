@isTest
private class StringUtilsBatchTest {
  @testSetup
  static void setup() {
    List<Task> tasks = new List<Task>();
    //Insert 5 tasks
    for (Integer i = 0; i < 5; i++) {
      tasks.add(
        new Task(
          Subject = 'TestTask' + i,
          ActivityDate = System.today() + 5,
          Description = 'Testing \\n\\r \\t script using \\r batch apex code \\n\\r. This is a \\n test class \\n\\r for the same.'
        )
      );
    }
    insert tasks;
  }

  static testMethod void testbatch() {
    System.Test.StartTest();
    StringUtilsBatch sub = new StringUtilsBatch('Task', 'Description');
    Database.executeBatch(sub, 100);
    system.debug([SELECT COUNT() FROM Task WHERE Subject LIKE 'TestTask%']);
    System.Test.StopTest();

    // System.assetEquals(1,[Select Description from Task where Subject LIKE 'TestTask%']);
  }
}