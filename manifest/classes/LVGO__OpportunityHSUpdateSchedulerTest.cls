@isTest
private class OpportunityHSUpdateSchedulerTest {
    static testMethod void myTestMethod() {        
         test.startTest();
         OpportunityHSUpdateScheduler scheduleClass = new OpportunityHSUpdateScheduler();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, scheduleClass);
         test.stopTest();
    }
}