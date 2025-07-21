@IsTest
private class F1BspInfo_Test {
  @IsTest
  static void F1BspInfo_Test() {
    Account acct = new Account(
      Name = 'Test',
      Friendly_Account_Name__c = 'TestAmendAccount',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Account_Type__c = 'Health Plan',
      Report_Recipient_Emails__c = 'test@gmail.com',
      Members__c = 100,
      Total_US_Employees_Benefits_Enrolled__c = 1000,
      Special_Instructions_for_Implementatio__c = 'no instruction',
      Guid__c = ' 28B90FAF-3315-D249-299D-7BDE3EE7AD57'
    );
    insert acct;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/F1BspInfo/v1/28B90FAF-3315-D249-299D-7BDE3EE7AD57';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    String result = F1BspInfo.fetchStatus();
    system.assertEquals(true, result != null);
  }
}