@isTest
private class EdsMwUtil_Test {
  @testSetup
  static void Setup_Test_Scenario() {
    Account umrAcct = TestDataFactory.createUMR();

    Group adminQueue = [
      SELECT Id, name, type
      FROM group
      WHERE name = 'Admin Config User Queue' AND type = 'Queue'
      LIMIT 1
    ];
    RecordType flow_rt = [
      SELECT id, developername
      FROM recordtype
      WHERE sobjecttype = 'Task' AND developername = 'Flow'
    ];

    // Create account
    Account new_acct = new Account(
      name = 'Test Account',
      Friendly_Account_Name__c = 'Test Account',
      Business_Region__c = 'USA'
    );
    insert new_acct;

    // Create groups and attach to account
    List<Mbr_Group__c> test_groups = new List<Mbr_Group__c>();

    for (integer i = 1; i < 5; i++) {
      Mbr_Group__c new_group = new Mbr_Group__c(
        name__c = 'Test Group ' + i,
        client_account__c = new_acct.Id,
        Logo1_ID__c = '',
        OneAppAccess__c = 'No'
      );
      test_groups.add(new_group);
    }
    insert test_groups;

    List<mbr_group_role__c> group_Roles = new List<mbr_group_role__c>();
    for (integer i = 1; i < 4; i++) {
      mbr_group_role__c new_grouprole = new mbr_group_role__c(
        Role_Type__c = 'Payer',
        source_account__c = new_acct.Id,
        mbr_group__c = test_groups[i].Id
      );
      mbr_group_role__c new_grouprole1 = new mbr_group_role__c(
        Role_Type__c = 'Benefit Sponsor',
        source_account__c = new_acct.Id,
        mbr_group__c = test_groups[i].Id
      );
      group_Roles.add(new_grouprole);
      group_Roles.add(new_grouprole1);
    }
    insert group_Roles;
    // Create case
    Case newCase = new Case();
    newCase.Subject =
      'New Account Setup (' +
      new_acct.Name +
      ') - ' +
      date.today().format();
    newCase.AccountId = new_acct.Id;
    newCase.status = 'Not Started';
    newCase.ownerId = adminQueue.id;
    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Admin Config')
      .getRecordTypeId();

    // Save the Case
    newCase.Description =
      'New account setup requested for (' +
      new_acct.Name +
      ' ) - Link to account setup form pdf: ' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.FileDownload?file=' +
      new_acct.id;
    insert newCase;

    // Create a pre-existing task
    Mbr_Group__c pre_existing_group = test_groups[0];
    Task new_task = new Task(
      WhatId = newCase.Id,
      subject = pre_existing_group.Name__c,
      group_guid__c = pre_existing_group.guid__c,
      RecordTypeId = flow_rt.Id,
      Flow_Response__c = 0
    );

    insert new_task;
  }
  @isTest
  private static void Gather_Flow_Data() {
    Mbr_Group__c a_group = [
      SELECT client_account__c, guid__c
      FROM Mbr_Group__c
      LIMIT 1
    ];
    insertpsfData(a_group.client_account__c, a_group.Id);
    EdsMwUtil.gatherFlowData(a_group.GUID__c);
  }
  @isTest
  private static void Gather_Flow_Data_Emo() {
    Mbr_Group__c a_group = [
      SELECT client_account__c, guid__c
      FROM Mbr_Group__c
      LIMIT 1
    ];
    insertpsfemo(a_group.client_account__c, a_group.Id);
    EdsMwUtil.gatherFlowData(a_group.GUID__c);
  }
  @isTest
  private static void Gather_Flow_Data_Bundle() {
    Mbr_Group__c a_group = [
      SELECT client_account__c, guid__c
      FROM Mbr_Group__c
      LIMIT 1
    ];
    insertpsfbudle(a_group.client_account__c, a_group.Id);
    EdsMwUtil.gatherFlowData(a_group.GUID__c);
  }
  public static void insertpsfbudle(String acctId, String groupId) {
    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = acctId,
      Mbr_Group__c = groupId
    );
    insert r;

    mbr_group_role__c new_grouprole1 = new mbr_group_role__c(
      Role_Type__c = 'Benefit Sponsor',
      Source_Account__c = acctId,
      mbr_group__c = groupId
    );
    insert new_grouprole1;

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

    Product2 prod10 = new Product2(
      Name = 'Expert Medical Opinion',
      Family = 'Expert Medical Services',
      ProductCode = 'EMO',
      IsActive = true
    );
    pd.add(prod10);

    Product2 prod11 = new Product2(
      Name = 'BD - Core Bundle (US Employer)',
      Family = 'Expert Medical Services',
      ProductCode = 'BD-USEMP-BUNDLE',
      IsActive = true
    );
    pd.add(prod11);

    insert pd;

    List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();

    SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod9.Id
    );
    subL.add(sub12);
    SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod11.Id
    );
    subL.add(sub21);

    SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod6.Id
    );
    subL.add(sub11);

    SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod8.Id
    );
    subL.add(sub9);

    SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod7.Id
    );
    subL.add(sub8);

    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod.Id
    );
    subL.add(sub);

    SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod5.Id
    );
    subL.add(sub2);

    SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod4.Id
    );
    subL.add(sub3);

    SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod3.Id
    );
    subL.add(sub4);

    SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod2.Id
    );
    subL.add(sub5);

    insert subL;

    Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
      Member_Group__c = groupId,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub21.Id
    );
    insert gpRec;
  }
  public static void insertpsfemo(String acctId, String groupId) {
    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = acctId,
      Mbr_Group__c = groupId
    );
    insert r;

    mbr_group_role__c new_grouprole1 = new mbr_group_role__c(
      Role_Type__c = 'Benefit Sponsor',
      Source_Account__c = acctId,
      mbr_group__c = groupId
    );
    insert new_grouprole1;

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

    Product2 prod10 = new Product2(
      Name = 'Expert Medical Opinion',
      Family = 'Expert Medical Services',
      ProductCode = 'EMO',
      IsActive = true
    );
    pd.add(prod10);

    Product2 prod11 = new Product2(
      Name = 'BD - Core Bundle (US Employer)',
      Family = 'Expert Medical Services',
      ProductCode = 'BD-USEMP-BUNDLE',
      IsActive = true
    );
    pd.add(prod11);

    insert pd;

    List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();

    SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod9.Id
    );
    subL.add(sub12);
    SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod10.Id
    );
    subL.add(sub21);

    SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod6.Id
    );
    subL.add(sub11);

    SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod8.Id
    );
    subL.add(sub9);

    SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod7.Id
    );
    subL.add(sub8);

    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod.Id
    );
    subL.add(sub);

    SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod5.Id
    );
    subL.add(sub2);

    SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod4.Id
    );
    subL.add(sub3);

    SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod3.Id
    );
    subL.add(sub4);

    SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod2.Id
    );
    subL.add(sub5);

    insert subL;

    Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
      Member_Group__c = groupId,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub21.Id
    );
    insert gpRec;
  }
  public static void insertpsfData(String acctId, String groupId) {
    Mbr_Group_Role__c r = new Mbr_Group_Role__c(
      Role_Type__c = 'Payer',
      Source_Account__c = acctId,
      Mbr_Group__c = groupId
    );
    insert r;

    mbr_group_role__c new_grouprole1 = new mbr_group_role__c(
      Role_Type__c = 'Benefit Sponsor',
      Source_Account__c = acctId,
      mbr_group__c = groupId
    );
    insert new_grouprole1;

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

    Product2 prod10 = new Product2(
      Name = 'Expert Medical Opinion',
      Family = 'Expert Medical Services',
      ProductCode = 'EMO',
      IsActive = true
    );
    pd.add(prod10);

    Product2 prod11 = new Product2(
      Name = 'BD - Core Bundle (US Employer)',
      Family = 'Expert Medical Services',
      ProductCode = 'BD-USEMP-BUNDLE',
      IsActive = true
    );
    pd.add(prod11);

    insert pd;

    List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();

    SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod9.Id
    );
    subL.add(sub12);
    SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod10.Id
    );
    subL.add(sub21);
    SBQQ__Subscription__c sub22 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod11.Id
    );
    subL.add(sub22);

    SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod6.Id
    );
    subL.add(sub11);

    SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod8.Id
    );
    subL.add(sub9);

    SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod7.Id
    );
    subL.add(sub8);

    SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod.Id
    );
    subL.add(sub);

    SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod5.Id
    );
    subL.add(sub2);

    SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod4.Id
    );
    subL.add(sub3);

    SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod3.Id
    );
    subL.add(sub4);

    SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(
      SBQQ__Account__c = acctId,
      Status__c = 'Active',
      SBQQ__Quantity__c = 500,
      Consult_Fees__c = 0.90,
      SBQQ__Product__c = prod2.Id
    );
    subL.add(sub5);

    insert subL;

    Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
      Member_Group__c = groupId,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub21.Id
    );
    Plan_Specific_Fees__c gpRec1 = new Plan_Specific_Fees__c(
      Member_Group__c = groupId,
      Consult_Fee_Mbr_Pd__c = 0.80,
      Consults_per_Family__c = 4,
      Consult_Fee_Plan_Pd__c = 0.80,
      Consult_Frequency__c = 'Per Year',
      Subscription__c = sub22.Id
    );
    insert gpRec;
    insert gpRec1;

    List<Asset> assetL = new List<Asset>();

    Asset ast = new Asset(
      AccountId = acctId,
      Consult_Fees__c = null,
      Number_of_Lives__c = null,
      Teladoc_Net_Fee__c = null,
      InstallDate = Date.today(),
      Product2Id = prod.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub.Id
    );
    assetL.add(ast);

    Asset ast2 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod2.Id,
      Name = 'Consult Fee- Psych/MD-ONGOING-Total',
      SBQQ__RequiredBySubscription__c = sub2.Id
    );
    assetL.add(ast2);

    Asset ast3 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod3.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub3.Id
    );
    assetL.add(ast3);

    Asset ast4 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod4.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub4.Id
    );
    assetL.add(ast4);

    Asset astt = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod4.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub9.Id
    );
    assetL.add(astt);

    Asset astt1 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod4.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub11.Id
    );
    assetL.add(astt1);

    Asset astt2 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub12.Id
    );
    assetL.add(astt2);

    Asset ast5 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = null,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod5.Id,
      Name = 'test asset',
      SBQQ__RequiredBySubscription__c = sub5.Id
    );
    assetL.add(ast5);

    Asset ast6 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod2.Id,
      Name = 'Consult Fee- Psych/MD-1stvisitonly-Total',
      SBQQ__RequiredBySubscription__c = sub2.Id
    );
    assetL.add(ast6);

    Asset ast7 = new Asset(
      AccountId = acctId,
      Consult_Fees__c = 0.60,
      Number_of_Lives__c = 1000,
      Teladoc_Net_Fee__c = 0.80,
      InstallDate = Date.today(),
      Product2Id = prod2.Id,
      Name = 'Consult Fee- Non-Psychiatrist- Total',
      SBQQ__RequiredBySubscription__c = sub2.Id
    );
    assetL.add(ast7);
    insert assetL;

    // Reload with relationship
    Map<Id, Asset> m = new Map<Id, Asset>(
      [
        SELECT
          Id,
          Name,
          AccountId,
          Consult_Fees__c,
          Number_of_Lives__c,
          Teladoc_Net_Fee__c,
          InstallDate,
          Product2.ProductCode,
          Product2Id,
          SBQQ__RequiredBySubscription__c,
          SBQQ__RequiredBySubscription__r.Name
        FROM Asset
      ]
    );

    ast = m.get(ast.Id);
    ast2 = m.get(ast2.Id);
    ast3 = m.get(ast3.Id);
    ast4 = m.get(ast4.Id);
    ast5 = m.get(ast5.Id);
  }
  @isTest
  private static void doGetTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/Sfdc2Eds/*';
    req.httpMethod = 'POST';
    String body = '{"attributes":{"type":"Q_Item__c"},"Payload__c":"{  \'CreatedbyId\' : \'0055G000005GjjYQAS\',  \'Createddate\' : \'2023-06-01\',  \'Account\' : {    \'Id\' : \'0017h000014pNg8AAE\',    \'Name\' : \'Nestle Holdings, Inc.\',    \'Type\' : \'Customer\',    \'Account_Type__c\' : \'Employer\',    \'Website\' : null,    \'Phone\' : \'17036824600\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Guid__c\' : \'734AB69A-4DDF-FC5F-D8C1-66D27BCCA315\',    \'BillingStreet\' : \'1812 N Moore St\',    \'BillingCity\' : \'Arlington\',    \'BillingState\' : \'Virginia\',    \'BillingPostalCode\' : \'22209-1815\',    \'BillingCountry\' : \'United States\',    \'Total_US_Employees_Benefits_Enrolled__c\' : null,    \'Members__c\' : null,    \'Sales_Ranking__c\' : null,    \'CIM__c\' : null,    \'Rev_Synergy__c\' : \'Net New Client (All Solutions)\',    \'Livongo_Account_Record_Type__c\' : null,    \'Account_Health_Score__c\' : null,    \'LOB\' : null  },  \'Opportunity\' : {    \'AccountId\' : \'0017h000014pNg8AAE\',    \'Id\' : \'0067h00000HmpcGAAR\',    \'Name\' : \'CON0000681-166229 - Nestle Holdings, Inc.\',    \'StageName\' : \'Closed Won\',    \'OwnerId\' : \'005f4000003H8aHAAS\',    \'Contracted_Date__c\' : null,    \'CloseDate\' : \'2023-05-22\',    \'Next_Steps__c\' : null,    \'Opp_Guid__c\' : \'F0891A99-54C4-DEC2-B3CE-C1C9803C14AA\',    \'Initial_of_Lives__c\' : \'3500\',    \'Decision_Date__c\' : \'2023-05-22\',    \'Pricebook2Id\' : \'01sf40000073UUUAA2\',    \'Ann_Rec_Rev__c\' : \'0.00\',    \'Primary_Carrier_LOB__c\' : null,    \'Monthly_Recurring_Revenue__c\' : \'0.00\',    \'LeadSource\' : \'Sales\',    \'Probability\' : \'100\',    \'Reason_for_Loss__c\' : null,    \'Type\' : \'New Business\',    \'Sub_Channel__c\' : \'Undefined\',    \'ForecastCategoryName\' : \'Closed\',    \'Primary_Carrier_Account__c\' : null,    \'Benefit_Consultant_Involved_in_Deal__c\' : null,    \'CIM__c\' : null,    \'Forecast_Manager_Call__c\' : null,    \'Request_CIM__c\' : \'false\',    \'Primary_Carrier__c\' : null,    \'Num_of_Broker_Rel__c\' : \'0\',    \'Sub_Type__c\' : null,    \'Box_Contract_URL__c\' : null,    \'Parent_Opportunity__c\' : null,    \'CIM_Assignment_Completed__c\' : \'false\',    \'Msg_Bus_Manual_Trigger__c\' : \'false\',    \'ContractOps_Notes__c\' : null,    \'ContractOps_Owner__c\' : null,    \'ContractOps_Stage__c\' : null,    \'ContractOps_Status__c\' : null,    \'CPQ_Pricebook__c\' : null,    \'Contract_Path__c\' : null  },  \'OpportunityLineItem\' : [ {    \'Id\' : \'00k7h00000BFb2sAAD\',    \'SalesPrice\' : \'0.00\',    \'ParentsProductCode\' : null,    \'ProductCode\' : \'CCCPB\',    \'Name\' : \'CON0000681-166229 - Nestle Holdings, Inc. Chronic Care Complete\',    \'Anchor\' : \'false\',    \'ParticipantQuantity\' : null,    \'SubscriptionTerm\' : \'12\',    \'TotalPrice\' : \'0.00\',    \'NetArr\' : null,    \'AdminFee\' : null,    \'AtRiskFee\' : null,    \'UpFrontFee\' : null,    \'DisableTeletherapy\' : \'YES\',    \'DisableBHCoaching\' : \'NO\'  } ]}","ItemKey__c":"DE3C1C1E-5197-18DB-9539-270433A22EA1","Status__c":"Pending","Src__c":"TDH","Dst__c":"LVN","Parser_Name__c":"Opportunity_Parser","Type__c":"Incoming"}';
    req.requestBody = Blob.valueOf(body);
    RestContext.request = req;
    RestContext.response = res;
    EdsMwUtil.doGet();
  }
}