@IsTest
private class AccountDefaultsTests {
  @IsTest
  static void SourceTest() {
    Account new_account = TestDataFactory.createAccountUMR();
    Account res_account = [
      SELECT
        id,
        name,
        source__c,
        Business_Region__c,
        Language__c,
        CurrencyIsoCode,
        GUID__c
      FROM Account
      WHERE id = :new_account.Id
      LIMIT 1
    ];

    System.assertEquals(false, String.isBlank(res_account.GUID__c));
    System.assertEquals('HUB', res_account.Source__c);
    System.assertEquals('USA', res_account.Business_Region__c);
    System.assertEquals('English', res_account.Language__c);
    System.assertEquals('USD', res_account.CurrencyIsoCode);
  }
}