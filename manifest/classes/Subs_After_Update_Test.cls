@IsTest
private class Subs_After_Update_Test {
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

    List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();

    SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(
      SBQQ__Account__c = a.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod9.Id,
      Termination_Date__c = Date.newInstance(2020, 12, 9)
    );
    subL.add(sub1);

    SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
      SBQQ__Account__c = a.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod6.Id,
      Termination_Date__c = Date.newInstance(2020, 12, 10)
    );
    subL.add(sub2);

    SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
      SBQQ__Account__c = a.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod8.Id,
      Termination_Date__c = Date.newInstance(2020, 12, 11)
    );
    subL.add(sub3);

    SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
      SBQQ__Account__c = a.Id,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod7.Id,
      Termination_Date__c = Date.newInstance(2020, 12, 12)
    );
    subL.add(sub4);

    insert subL;
    Plan_Specific_Fees__c psf1 = new Plan_Specific_Fees__c(
      Member_Group__c = grp.Id,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub1.Id
    );
    insert psf1;

    Plan_Specific_Fees__c psf2 = new Plan_Specific_Fees__c(
      Member_Group__c = grp.Id,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub2.Id
    );
    insert psf2;

    Plan_Specific_Fees__c psf3 = new Plan_Specific_Fees__c(
      Member_Group__c = grp.Id,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub3.Id
    );
    insert psf3;

    Plan_Specific_Fees__c psf4 = new Plan_Specific_Fees__c(
      Member_Group__c = grp.Id,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub4.Id
    );
    insert psf4;
  }

  static testMethod void test() {
    test.startTest();
    Date sub1Date = Date.newInstance(2020, 12, 9);
    SBQQ__Subscription__c sub1 = [
      SELECT Id, Status__c, Termination_Date__c
      FROM SBQQ__Subscription__c
      WHERE Termination_Date__c = :sub1Date
    ];
    sub1.Termination_Date__c = Date.newInstance(2020, 4, 9);
    Date sub2Date = Date.newInstance(2020, 12, 10);
    SBQQ__Subscription__c sub2 = [
      SELECT Id, Status__c, Termination_Date__c
      FROM SBQQ__Subscription__c
      WHERE Termination_Date__c = :sub2Date
    ];
    sub2.Termination_Date__c = Date.newInstance(2020, 4, 10);
    Date sub3Date = Date.newInstance(2020, 12, 11);
    SBQQ__Subscription__c sub3 = [
      SELECT Id, Status__c, Termination_Date__c
      FROM SBQQ__Subscription__c
      WHERE Termination_Date__c = :sub3Date
    ];
    sub3.Termination_Date__c = Date.newInstance(2020, 4, 11);
    Date sub4Date = Date.newInstance(2020, 12, 12);
    SBQQ__Subscription__c sub4 = [
      SELECT Id, Status__c, Termination_Date__c
      FROM SBQQ__Subscription__c
      WHERE Termination_Date__c = :sub4Date
    ];
    sub4.Termination_Date__c = Date.newInstance(2020, 4, 12);
    List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
    subList.add(sub1);
    subList.add(sub2);
    subList.add(sub3);
    subList.add(sub4);
    update subList;
    test.stopTest();

    system.assertEquals(
      sub1.Termination_Date__c,
      [
        SELECT Product_End_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Subscription__c = :sub1.Id
      ]
      .Product_End_Date__c
    );
    system.assertEquals(
      sub2.Termination_Date__c,
      [
        SELECT Product_End_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Subscription__c = :sub2.Id
      ]
      .Product_End_Date__c
    );
    system.assertEquals(
      sub3.Termination_Date__c,
      [
        SELECT Product_End_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Subscription__c = :sub3.Id
      ]
      .Product_End_Date__c
    );
    system.assertEquals(
      sub4.Termination_Date__c,
      [
        SELECT Product_End_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Subscription__c = :sub4.Id
      ]
      .Product_End_Date__c
    );
  }
}