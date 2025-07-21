@isTest
private class LocationTrigger_Test {
  @isTest
  static void testLocation() {
    Account a = TestDataFactory.createAccount('Aetna');
    a.guid__c = '393BC4D4-533B-51C5-FC74-4844F0BBBB7B';
    update a;
    Location__c location = TestDataFactory.createLocation(a.Id);
    location.former_guid__c = a.guid__c;
  }
}