@isTest
public class Task_Trg_Test {
  static Task tTask;
  static void createTestData() {
    tTask = new Task(Subject = 'Email: TEST', activityDate = system.today());
    insert tTask;
  }

  testMethod static void triggerInAction() {
    test.startTest();
    createTestData();
    tTask = [SELECT Due_Date__c, activityDate FROM Task WHERE Id = :tTask.Id];
    system.assertEquals(tTask.Due_Date__c, tTask.activityDate);
    tTask.ActivityDate = system.today() - 3;
    update tTask;
    Task updateTask = [
      SELECT Due_Date__c, activityDate
      FROM Task
      WHERE Id = :tTask.Id
    ];
    system.assertEquals(updateTask.Due_Date__c, updateTask.activityDate);
    test.stopTest();
  }
}