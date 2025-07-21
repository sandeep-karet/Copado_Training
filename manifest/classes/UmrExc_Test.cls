@isTest
private class UmrExc_Test {
  @TestSetup
  static void setup() {
    Account umrAcct = new Account();
    umrAcct.Name = 'UMR';
    umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
    umrAcct.Source__c = 'HUB';
    umrAcct.CurrencyIsoCode = 'USD';
    umrAcct.Business_Region__c = 'USA';
    umrAcct.Account_Type__c = 'Health Plan';
    umrAcct.GUID__c = '1BB95CCB-765E-17A8-6778-6846FB556025';
    insert umrAcct;
    Account benefitAcct = new Account();
    benefitAcct.Name = 'testAcct';
    benefitAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    benefitAcct.Friendly_Account_Name__c = 'TestAmendAccount';
    benefitAcct.Source__c = 'HUB';
    benefitAcct.CurrencyIsoCode = 'USD';
    benefitAcct.Business_Region__c = 'USA';
    benefitAcct.Account_Type__c = 'Health Plan';
    insert benefitAcct;
    AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c();
    agcpi.Batch_Key__c = '1561491697487';
    agcpi.CurrencyIsoCode = 'USD';
    agcpi.Item_Key__c = '271459';
    agcpi.Source__c = 'UMR';
    insert agcpi;
  }

  @IsTest
  static void testFetchUmrAcctRel() {
    Test.startTest();
    Account Umr = [SELECT Id FROM Account WHERE Name = 'UMR'];
    Account testAcct = [SELECT Id FROM Account WHERE Name = 'testAcct'];
    AcctGrpConParsing_Item__c agcpi = [
      SELECT Id
      FROM AcctGrpConParsing_Item__c
    ];
    Acct_Rel__c acctRel = UmrExc.Create_UMR_AcctRel(
      umr,
      testAcct,
      agcpi.Id,
      system.today()
    );
    system.assertNotEquals(null, acctRel);
    Test.stopTest();
  }

  @IsTest
  static void testUpdateEndDate() {
    Account Umr = [SELECT Id, Guid__c FROM Account WHERE Name = 'UMR'];
    Account testAcct = [
      SELECT Id, Guid__c
      FROM Account
      WHERE Name = 'testAcct'
    ];
    AcctGrpConParsing_Item__c agcpi = [
      SELECT Id
      FROM AcctGrpConParsing_Item__c
    ];
    Acct_Rel__c new_AcctRel = new Acct_Rel__c(
      Svc_Acct__c = Umr.Id,
      Benefit_Sponsor__c = testAcct.Id,
      Relationship_Type__c = 'Contractee',
      Contract_Type__c = 'Insurance',
      Line_of_Business__c = 'Commercial_Administrative_Services_Only_ASO',
      Start_Date__c = system.today()
    );
    insert new_AcctREl;
    Test.startTest();
    UmrExc.updateAcctRelEndDate(
      umr.Guid__c,
      testAcct.Guid__c,
      Date.today(),
      agcpi.Id
    );
    system.assertEquals(
      Date.today(),
      [SELECT End_Date__c FROM Acct_Rel__c].End_Date__c
    );
    Test.stopTest();
  }
}