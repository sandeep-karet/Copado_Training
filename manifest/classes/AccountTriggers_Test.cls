@isTest
private class AccountTriggers_Test {
  @IsTest
  static void testPersonatorResultCodeDesc() {
    Test.startTest();
    Account acc = new Account();
    acc.Name = 'Test Acct 1';
    acc.BillingCity = 'New York';
    acc.BillingCountry = 'United States';
    acc.BillingState = 'New York';
    acc.BillingPostalCode = '10011';
    acc.BillingStreet = '47 W 13th St';
    insert acc;

    acc.Billing_Address_Personator_Result_Codes__c = 'AS01';
    update acc;

    Account updatedAcc = [
      SELECT Id, Billing_Address_Status_Message__c
      FROM Account
      WHERE Name = 'Test Acct 1'
      LIMIT 1
    ];
    system.assertEquals(
      'AS01 - Valid Address',
      updatedAcc.Billing_Address_Status_Message__c
    );

    Test.stopTest();
  }
}