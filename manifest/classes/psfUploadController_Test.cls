@isTest
private class psfUploadController_Test {
  @TestSetup
  public static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Account> acct = new List<Account>();
    Account a = TestDataFactory.createAccount('Test01');
    acct.add(a);
    List<Mbr_Group__c> mg = TestDataFactory.createMbrGroup(a.Id);
    Mbr_Group_Role__c r = TestDataFactory.createGroupRole(
      mg[0].Id,
      'Payer',
      a.Id,
      null
    );
    insert r;
    List<Product2> pd = new List<Product2>();
    Product2 prod8 = TestDataFactory.CreateProductWithDynamicVals(
      'Nutrition',
      'Nutrition',
      'NUT'
    );
    pd.add(prod8);
    Product2 prod9 = TestDataFactory.CreateProductWithDynamicVals(
      'NUTFEE',
      'Nutrition',
      'NUTFEE'
    );
    pd.add(prod9);
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
    Product2 prod4 = TestDataFactory.CreateProductWithDynamicVals(
      'Behavioral Health',
      'Behavioral Health',
      'BH'
    );
    pd.add(prod4);
    insert pd;

    SBQQ__Subscription__c sub = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod8.Id
    );
    insert sub;

    SBQQ__Subscription__c sub2 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      a.Id,
      prod4.Id
    );
    insert sub2;

    List<Asset> assetL = new List<Asset>();
    Asset ast = TestDataFactory.createAssetNoInsert(
      'test asset',
      60,
      a.Id,
      null,
      prod5.Id,
      sub.Id
    );
    ast.Number_of_Lives__c = null;
    ast.Teladoc_Net_Fee__c = null;
    ast.InstallDate = Date.today();
    assetL.add(ast);

    Asset ast3 = TestDataFactory.createAssetNoInsert(
      'test asset',
      60,
      a.Id,
      null,
      prod5.Id,
      sub2.Id
    );
    ast3.Number_of_Lives__c = 1000;
    ast3.Teladoc_Net_Fee__c = 0.80;
    ast3.InstallDate = Date.today();
    assetL.add(ast3);

    Asset ast4 = TestDataFactory.createAssetNoInsert(
      'test asset',
      60,
      a.Id,
      null,
      prod6.Id,
      sub2.Id
    );
    ast4.Number_of_Lives__c = 1000;
    ast4.Teladoc_Net_Fee__c = 0.80;
    ast4.InstallDate = Date.today();
    assetL.add(ast4);

    Asset astt = TestDataFactory.createAssetNoInsert(
      'test asset',
      60,
      a.Id,
      null,
      prod7.Id,
      sub2.Id
    );
    astt.Number_of_Lives__c = 1000;
    astt.Teladoc_Net_Fee__c = 0.80;
    astt.InstallDate = Date.today();
    assetL.add(astt);

    insert assetL;
  }

  static testMethod void testfileupload() {
    Test.startTest();
    Mbr_Group__c grp = [SELECT Id FROM Mbr_Group__c LIMIT 1];
    SBQQ__Subscription__c sub = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE Sbqq__product__r.productCode = 'NUT'
    ];
    SBQQ__Subscription__c sub1 = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE Sbqq__product__r.productCode = 'BH'
    ];
    String str =
      'Member Group ID,Product Start Date,Actual Copay May Be Less,Consult Fee Plan Paid,Consult Fee Member Paid,Subscription ID,Asset Product Code\n' +
      grp.Id +
      ',12/1/2021,true,85,0,' +
      sub.Id +
      ',DERMFEE\n' +
      grp.Id +
      ',12/1/2021,true,60,0,' +
      sub1.Id +
      ',BHNPT\n' +
      grp.Id +
      ',12/1/2021,true,60,0,' +
      sub1.Id +
      ',BHP1T\n' +
      grp.Id +
      ',12/1/2021,true,60,0,' +
      sub1.Id +
      ',BHPOT\n' +
      grp.Id +
      ',12/1/2021,true,600,0,' +
      sub1.Id +
      ',BHNPT\n' +
      grp.Id +
      ',12/1/2021,true,60,0,' +
      sub1.Id +
      ',BHP1T\n' +
      grp.Id +
      ',12/1/2021,true,60,0,' +
      sub1.Id +
      ',BHPOT';

    ContentVersion contentVersionInsert = TestDataFactory.createContentVersion(
      str
    );
    insert contentVersionInsert;
    ContentVersion contentVersionSelect = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersionInsert.Id
      LIMIT 1
    ];

    psfUploadController.readCSVFile(contentVersionSelect.ContentDocumentId);
    Test.stopTest();
  }
}