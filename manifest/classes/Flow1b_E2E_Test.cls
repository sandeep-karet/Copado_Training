@IsTest
private class Flow1b_E2E_Test {
  @TestSetup
  public static void setup() {
    F1b_Remove_Setting__c f1bSetting = F1b_Remove_Setting__c.getOrgDefaults();
    f1bSetting.Key_Word__c = 'NONE;!!!';
    insert f1bSetting;
  }
  @IsTest
  static void Flow1b_E2E_Test() {
    List<AcctGrpConParsing_Item__c> tmpAgcpis = Test.loadData(
      AcctGrpConParsing_Item__c.sObjectType,
      'flow1b_agcpi_no_error_Tests'
    );
    for (AcctGrpConParsing_Item__c tmpAgcpi : tmpAgcpis) {
      tmpAgcpi.processed__c = false;
    }
    update tmpAgcpis;
    String result = Flow1b_E2E.Flow1b_E2E('123');
    Boolean checkResult = result.contains('NO_RECORDS_FOUND');
    system.assertNotEquals(true, checkResult);
  }

  @IsTest
  static void Flow1b_E2E_No_Record_Test() {
    String result = Flow1b_E2E.Flow1b_E2E('123');
    Boolean checkResult = result.contains('NO_RECORDS_FOUND');
    system.assertNotEquals(false, checkResult);
  }
}