@IsTest
private class AGCPI_PRE_Test {
  @IsTest
  static void Test_Batch_Key() {
    String batchid = String.valueOf(DateTime.now().getTime());
    AcctGrpConParsing_Item__c tmpAgcpi = new AcctGrpConParsing_Item__c(
      Source__c = 'UMR',
      Batch_Key__c = batchid,
      Item_Key__c = '12345',
      Item_Data__c = '{}',
      Item_Defaults__c = '{}'
    );
    List<AcctGrpConParsing_Item__c> newAgcpi = new List<AcctGrpConParsing_Item__c>{
      tmpAgcpi
    };
    DateTime tmpTime = DateTime.newInstance(
      Long.ValueOf(tmpAgcpi.Batch_Key__c)
    );
    System.Debug(tmpTime);
    Database.SaveResult[] sr = Database.insert(newAgcpi);
    tmpAgcpi = [
      SELECT id, Batch_Time__c
      FROM AcctGrpConParsing_Item__c
      WHERE Item_Key__c = '12345'
    ];
    System.assertNotEquals(null, tmpAgcpi.Batch_Time__c);
  }
}