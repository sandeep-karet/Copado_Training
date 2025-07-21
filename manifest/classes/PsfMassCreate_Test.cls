@IsTest
private class PsfMassCreate_Test {
  @TestSetup
  static void testsetup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Account> acct = new List<Account>();
      Test.startTest();
    Account a = TestDataFactory.createAccountUMRNoInsert();
    acct.add(a);
    insert acct;

    List<Mbr_Group__c> mg = TestDataFactory.createMbrGroupList(a.Id);

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
      acct[0].Id,
      pd[0].Id
    );
    subL.add(sub);

    SBQQ__Subscription__c sub2 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      acct[0].Id,
      prod3.Id
    );
    subL.add(sub2);

    SBQQ__Subscription__c sub3 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      acct[0].Id,
      prod4.Id
    );
    subL.add(sub3);

    SBQQ__Subscription__c sub4 = TestDataFactory.createSBQQSubscripWithProdNoInsert(
      acct[0].Id,
      prod8.Id
    );
    subL.add(sub4);
    insert subL;

    Plan_Specific_Fees__c gpRec = TestDataFactory.createSinglePlanSpecificFees(
      mg[0].Id,
      sub.Id
    );
Test.stopTest();
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
  static void psfCreateTest() {
    SBQQ__Subscription__c subGM = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Product__r.ProductCode = 'GM'
    ];
    PsfMassCreate.CreateForSubscription(subGM.Id);
    List<Plan_Specific_Fees__c> subscriptionPsf = [
      SELECT id, Member_Group__c
      FROM Plan_Specific_Fees__c
      WHERE subscription__c = :subGM.Id
    ];
    System.assertEquals(10, subscriptionPsf.size());
Test.startTest();
    SBQQ__Subscription__c subDERM = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Product__r.ProductCode = 'DERM'
    ];
    PsfMassCreate.CreateForSubscription(subDERM.Id);
    subscriptionPsf = [
      SELECT id, Member_Group__c
      FROM Plan_Specific_Fees__c
      WHERE subscription__c = :subDERM.Id
    ];
    System.assertEquals(10, subscriptionPsf.size());

    SBQQ__Subscription__c subTC = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Product__r.ProductCode = 'TCPROGFEE'
    ];
    PsfMassCreate.CreateForSubscription(subTC.Id);
    subscriptionPsf = [
      SELECT id, Member_Group__c
      FROM Plan_Specific_Fees__c
      WHERE subscription__c = :subTC.Id
    ];
    System.assertEquals(10, subscriptionPsf.size());

    SBQQ__Subscription__c subBH = [
      SELECT Id
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Product__r.ProductCode = 'BH'
    ];
      Test.stopTest();
    PsfMassCreate.CreateForSubscription(subBH.Id);
    subscriptionPsf = [
      SELECT id, Member_Group__c
      FROM Plan_Specific_Fees__c
      WHERE subscription__c = :subBH.Id
    ];
    System.assertEquals(30, subscriptionPsf.size());
  }
}