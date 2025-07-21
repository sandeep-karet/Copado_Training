@isTest
private class subTermBchTest {
  @TestSetup
  static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Account> acct = new List<Account>();
    Account a = new Account(Name = 'Test01', Source__c = 'HUB');
    acct.add(a);

    insert acct;

    List<Mbr_Group__c> mg = new List<Mbr_Group__c>();
    Mbr_Group__c grp = new Mbr_Group__c(
      Name__c = 'testgrp1',
      Client_Account__c = a.Id,
      Status__c = 'ACTIVE',
      Active_Date__c = Date.today()
    );
    mg.add(grp);
    Mbr_Group__c grp2 = new Mbr_Group__c(
      Name__c = 'testgrp2',
      Client_Account__c = a.Id,
      Status__c = 'ACTIVE',
      Active_Date__c = Date.today()
    );
    mg.add(grp2);
    insert mg;

    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = a.Id,
      Mbr_Group__c = mg[0].Id
    );
    insert r;

    List<Product2> pd = new List<Product2>();
    Product2 prod = new Product2(
      Name = 'GLOBALCARE',
      Family = 'GLOBAL CARE',
      ProductCode = 'GLOBALCARE',
      IsActive = true
    );
    pd.add(prod);

    Product2 prod2 = new Product2(
      Name = 'Dermatology',
      Family = 'Dermatology',
      ProductCode = 'DERM',
      IsActive = true
    );
    pd.add(prod2);

    Product2 prod3 = new Product2(
      Name = 'Tobacco Cessation',
      Family = 'Tobacco Cessation',
      ProductCode = 'TC',
      IsActive = true
    );
    pd.add(prod3);

    Product2 prod4 = new Product2(
      Name = 'General Medical',
      Family = 'General Medical',
      ProductCode = 'GM',
      IsActive = true
    );
    pd.add(prod4);

    Product2 prod5 = new Product2(
      Name = 'Behavioral Health',
      Family = 'Behavioral Health',
      ProductCode = 'BH',
      IsActive = true
    );
    pd.add(prod5);

    Product2 prod6 = new Product2(
      Name = 'Back Care',
      Family = 'Musculoskelatal',
      ProductCode = 'TDBC',
      IsActive = true
    );
    pd.add(prod6);

    Product2 prod7 = new Product2(
      Name = 'test1',
      Family = 'Musculoskelatal',
      ProductCode = 'TDBC',
      IsActive = true
    );
    pd.add(prod7);

    Product2 prod8 = new Product2(
      Name = 'Nutrition',
      Family = 'Nutrition',
      ProductCode = 'NUT',
      IsActive = true
    );
    pd.add(prod8);

    Product2 prod9 = new Product2(
      Name = 'NUTFEE',
      Family = 'Nutrition',
      ProductCode = 'NUTFEE',
      IsActive = true
    );
    pd.add(prod9);

    insert pd;

    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = a.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod.Id,
      Termination_Date__c = Date.newInstance(2016, 12, 9)
    );
    insert sub;
  }

  static testMethod void test() {
    SBQQ__Subscription__c sub = [
      SELECT Status__c, Termination_Date__c
      FROM SBQQ__Subscription__c
    ];
    system.assertEquals('Active', sub.Status__c);
    Test.startTest();
    subTerm_Bch testing = new subTerm_Bch();
    DataBase.executeBatch(testing);
    Test.stopTest();
    system.assertEquals(
      'Terminated',
      [SELECT Status__c FROM SBQQ__Subscription__c].Status__c
    );
  }
}