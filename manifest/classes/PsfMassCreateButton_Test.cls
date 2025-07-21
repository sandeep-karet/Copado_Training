@IsTest
private class PsfMassCreateButton_Test {
  @TestSetup
  static void testsetup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Account> acct = new List<Account>();
    Account a = TestDataFactory.createAccount('Test01');
    List<Mbr_Group__c> mg = TestDataFactory.createMbrGroup(a.Id);
    List<Product2> pd = new List<Product2>();

    Product2 prod = TestDataFactory.CreateProductWithDynamicVals(
      'Dermatology',
      'Dermatology',
      'DERM'
    );
    pd.add(prod);
    Product2 prod2 = TestDataFactory.CreateProductWithDynamicVals(
      'Dermatology',
      'Dermatology',
      'DERMFEE'
    );
    pd.add(prod2);
    Product2 prod3 = TestDataFactory.CreateProductWithDynamicVals(
      'Tobacco Cessation',
      'Tobacco Cessation',
      'TCPROGFEE'
    );
    pd.add(prod3);
    Product2 prod3_1 = TestDataFactory.CreateProductWithDynamicVals(
      'Tobacco Cessation',
      'Tobacco Cessation',
      'TCPROGFEE'
    );
    pd.add(prod3_1);
    Product2 prod4 = TestDataFactory.CreateProductWithDynamicVals(
      'General Medical',
      'General Medical',
      'GM'
    );
    pd.add(prod4);
    Product2 prod5 = TestDataFactory.CreateProductWithDynamicVals(
      'Behavioral Health',
      'Behavioral Health',
      'BHNPT'
    );
    pd.add(prod5);
    Product2 prod6 = TestDataFactory.CreateProductWithDynamicVals(
      'Behavioral Health',
      'Behavioral Health',
      'BHP1T'
    );
    pd.add(prod6);
    Product2 prod7 = TestDataFactory.CreateProductWithDynamicVals(
      'Behavioral Health',
      'Behavioral Health',
      'BHPOT'
    );
    pd.add(prod7);
    Product2 prod8 = TestDataFactory.CreateProductWithDynamicVals(
      'Behavioral Health',
      'Behavioral Health',
      'BH'
    );
    pd.add(prod8);
    insert pd;

    List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();
    SBQQ__Subscription__c sub = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod.Id
    );
    subL.add(sub);
    SBQQ__Subscription__c sub2 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod3.Id
    );
    subL.add(sub2);
    SBQQ__Subscription__c sub3 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod4.Id
    );
    subL.add(sub3);
    SBQQ__Subscription__c sub4 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod8.Id
    );
    subL.add(sub4);
    insert subL;

    Plan_Specific_Fees__c gpRec = TestDataFactory.createSinglePlanSpecificFees(
      mg[0].Id,
      sub.Id
    );
    List<Asset> assetL = new List<Asset>();
    Asset ast = TestDataFactory.createAssetNoInsert(
      'test asset',
      0.30,
      a.Id,
      null,
      prod2.Id,
      sub.Id
    );
    assetL.add(ast);

    Asset ast3 = TestDataFactory.createAssetNoInsert(
      'test asset',
      0.60,
      a.Id,
      null,
      prod5.Id,
      sub4.Id
    );
    ast3.Number_of_Lives__c = 1000;
    ast3.Teladoc_Net_Fee__c = 0.80;
    ast3.InstallDate = Date.today();
    assetL.add(ast3);

    Asset ast4 = TestDataFactory.createAssetNoInsert(
      'test asset',
      0.60,
      a.Id,
      null,
      prod6.Id,
      sub4.Id
    );
    ast4.Number_of_Lives__c = 1000;
    ast4.Teladoc_Net_Fee__c = 0.80;
    ast4.InstallDate = Date.today();

    assetL.add(ast4);
    Asset astt = TestDataFactory.createAssetNoInsert(
      'test asset',
      0.60,
      a.Id,
      null,
      prod7.Id,
      sub4.Id
    );
    astt.Number_of_Lives__c = 1000;
    astt.Teladoc_Net_Fee__c = 0.80;
    astt.InstallDate = Date.today();
    assetL.add(astt);
    insert assetL;
  }

  @IsTest
  static void webServiceCallTest() {
    SBQQ__Subscription__c subBH = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Product__r.ProductCode = 'BH'
    ];

    PsfMassCreateButton.massCreate(subBH.Id);
  }
}