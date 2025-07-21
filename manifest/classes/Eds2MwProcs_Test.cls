@isTest
private class Eds2MwProcs_Test {
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
        Logo1_ID__c = ''
      );
      test_groups.add(new_group);
    }
    insert test_groups;

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
  static void Generate_Flow_Tasks() {
    List<Mbr_Group__c> test_groups = [SELECT id, guid__c FROM mbr_group__c];
    Set<String> target_groups = new Set<String>();
    for (Mbr_group__c tmp_group : test_groups)
      target_groups.add(tmp_group.guid__c);

    Case test_case = [SELECT id FROM case LIMIT 1];
    Eds2MwProcs.CreateTasTasks(target_groups, test_case.Id);
    Eds2MwProcs.CreateTasTasks(target_groups, test_case.Id);
  }
  @isTest
  static void FlowOut_Test() {
    RecordType flow_rt = [
      SELECT id
      FROM recordtype
      WHERE sobjecttype = 'Task' AND developername = 'Flow'
    ];
    String qString =
      'select id, subject, group_guid__c from Task where recordtypeid = \'' +
      flow_rt.Id +
      '\' and Flow_Response__c in (500,0) order by lastmodifieddate desc limit 1';
    Test.setMock(HttpCalloutMock.class, new FlowHttpCalloutMock());
    FlowOut_Bch fob = new FlowOut_Bch(qString);
    Test.startTest();
    Database.executeBatch(fob);
    Test.stopTest();
  }
  @isTest
  static void FlowOut_Failin_Test() {
    RecordType flow_rt = [
      SELECT id
      FROM recordtype
      WHERE sobjecttype = 'Task' AND developername = 'Flow'
    ];
    String qString =
      'select id, subject, group_guid__c from Task where recordtypeid = \'' +
      flow_rt.Id +
      '\' and Flow_Response__c in (500,0) order by lastmodifieddate desc limit 1';
    Test.setMock(HttpCalloutMock.class, new FlowHttpCalloutFailureMock());
    FlowOut_Bch fob = new FlowOut_Bch(qString);
    Test.startTest();
    Database.executeBatch(fob);
    Test.stopTest();
  }
}