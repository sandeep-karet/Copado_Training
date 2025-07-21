@isTest
private class MD_Personator_Test {
  @testSetup
  static void setup() {
    test.starttest();
    List<Account> accounts = new List<Account>();
    List<Contact> contacts = new List<Contact>();

    for (Integer i = 0; i < 20; i++) {
      accounts.add(
        new Account(
          name = 'Account ' + i,
          billingcity = 'New York',
          billingcountry = 'United States'
        )
      );
    }
    insert accounts;

    for (Account account : accounts) {
      contacts.add(
        new Contact(
          firstname = 'first',
          MailingCity = 'New York',
          MailingCountry = 'United States',
          lastname = 'last',
          accountId = account.id
        )
      );
    }
    insert contacts;
    test.stoptest();
  }

  static testMethod void PersonatorBatchStartSchedulerTest() {
    try {
      test.starttest();
      MD_PersonatorBatchScheduler.startSchedule();
      test.stopTest();
    } catch (Exception ex) {
    }
  }
  static testMethod void PersonatorBatchSchedulerTest() {
    test.starttest();

    Datetime dt = Datetime.now().addSeconds(2);
    String schCronExp = dt.format('s m H d M \'?\' yyyy');

    MD_PersonatorBatchScheduler sch = new MD_PersonatorBatchScheduler();
    Id schedId = System.Schedule(
      'Personator Address Validation Test Job' + System.now().format(),
      schCronExp,
      sch
    );

    test.stopTest();
  }
}