@isTest
public class LaunchTinderboxController_Test {
  public static testMethod void unitTest1() {
    Account acc = new Account(Name = 'Test Account', Source__c = 'HUB');
    insert acc;
    Opportunity oppt = new Opportunity(
      Name = 'New mAWS Deal',
      AccountID = acc.id,
      StageName = 'Prospect',
      Amount = 3000,
      Tbox_template__c = 'Test',
      CloseDate = System.today(),
      Sub_Type__c = 'Renewal' //EMS Migration
    );
    insert oppt;
    ApexPages.currentPage().getParameters().put('id', oppt.Id);
    ApexPages.currentPage().getParameters().put('bid', 'proposal');
    LaunchTinderboxController controller = new LaunchTinderboxController();
    controller.gotoTinderbox();

    ApexPages.currentPage().getParameters().put('bid', 'contract');
    LaunchTinderboxController controller1 = new LaunchTinderboxController();
    controller1.gotoTinderbox();
    ApexPages.currentPage().getParameters().put('bid', 'baa');
    LaunchTinderboxController controller2 = new LaunchTinderboxController();
    controller2.gotoTinderbox();
  }
}