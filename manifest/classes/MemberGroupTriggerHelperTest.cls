/**
 * Created by amruthakommuri on 2019-05-08.
 */

@isTest
private class MemberGroupTriggerHelperTest {
  @testSetup
  static void setupdata() {
    Account umrAcct = TestDataFactory.createUMR();
    //create an account record
    Account accObj = new Account();
    accObj.Name = 'TestAmendAccount';
    accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    accObj.Friendly_Account_Name__c = 'TestAmendAccount';
    accObj.Source__c = 'HUB';
    accObj.CurrencyIsoCode = 'USD';
    accObj.Business_Region__c = 'USA';
    accObj.Account_Type__c = 'Health Plan';
    insert accObj;

    Document newDoc = new Document();
    newDoc.Body = Blob.valueOf('Text Image');
    newDoc.ContentType = 'application/pdf';
    newDoc.DeveloperName = 'my_document';
    newDoc.IsPublic = true;
    newDoc.Name = 'Test Document';
    newDoc.FolderId = [SELECT id FROM folder WHERE name = 'Quotes'].id;
    insert newDoc;

    Document newDoc2 = new Document();
    newDoc2.Body = Blob.valueOf('Text Image');
    newDoc2.ContentType = 'application/pdf';
    newDoc2.DeveloperName = 'MK_TDH_HZ_2';
    newDoc2.IsPublic = true;
    newDoc2.Name = 'MK_TDH_HZ_2';
    newDoc2.FolderId = [SELECT id FROM folder WHERE name = 'Quotes'].id;
    insert newDoc2;

    ContentVersion cv = new ContentVersion();
    cv.Title = 'My Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;

    ContentVersion cv2 = new ContentVersion();
    cv2.Title = 'MK_TDH_HZ_2';
    cv2.PathOnClient = 'MK_TDH_HZ_2.pdf';
    cv2.VersionData = Blob.valueOf('Test Content');
    cv2.IsMajorVersion = true;
    insert cv2;

    List<ContentVersion> testContent = [
      SELECT ContentDocumentId
      FROM ContentVersion
    ];
    ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0]
    .Id;

    for (ContentVersion cvs : testContent) {
      ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();
      newWorkspaceDoc.ContentWorkspaceId = workspaceId;
      newWorkspaceDoc.ContentDocumentId = cvs.ContentDocumentId;
      insert newWorkspaceDoc;
    }

    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];
    for (ContentDocument cd : documents) {
      cd.parentId = workspaceId;
      update cd;
    }

    //ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion];

    logo_setting__c ls = logo_setting__c.getOrgDefaults();
    ls.isDocument__c = true;
    insert ls;
  }

  @isTest
  static void validateLogos() {
    List<Account> accList = [
      SELECT Id
      FROM Account
      WHERE Name = 'TestAmendAccount'
    ];

    Mbr_Group__c grpObj = new Mbr_Group__c();
    grpObj.Name__c = 'Test Group';
    grpObj.Client_Account__c = accList[0].Id;
    grpObj.Logo_Tag_ID__c = 'Test Document';
    grpObj.Logo1_ID__c = 'Test Document';
    grpObj.Logo2_ID__c = 'Test Document';
    grpObj.Logo3_ID__c = 'Test Document';
    grpObj.AltLogo1_ID__c = 'Test Document';
    grpObj.AltLogo2_ID__c = 'Test Document';
    insert grpObj;

    List<Mbr_Group__c> mbrList = [
      SELECT id, Logo1_ID__c, GUID__c
      FROM Mbr_Group__c
    ];
    List<Document> docList = [SELECT id FROM Document];

    system.assertEquals(mbrList[0].Logo1_ID__c == 'Test Document', true);
    system.assertEquals(mbrList[0].GUID__c != null, true);

    logo_setting__c ls = logo_setting__c.getOrgDefaults();
    ls.isDocument__c = false;
    update ls;

    Mbr_Group__c grpObj2 = new Mbr_Group__c();
    grpObj2.Name__c = 'Test Group';
    grpObj2.Client_Account__c = accList[0].Id;
    grpObj2.Logo_Tag_ID__c = 'My Document';
    grpObj2.Logo1_ID__c = 'My Document';
    grpObj2.Logo2_ID__c = 'My Document';
    grpObj2.Logo3_ID__c = 'My Document';
    grpObj2.AltLogo1_ID__c = 'My Document';
    grpObj2.AltLogo2_ID__c = 'My Document';
    insert grpObj2;
  }

  @isTest
  static void validateBlankLogo1ID() {
    List<Account> accList = [
      SELECT Id
      FROM Account
      WHERE Name = 'TestAmendAccount'
    ];

    Mbr_Group__c grpObj = new Mbr_Group__c();
    grpObj.Name__c = 'Test Group';
    grpObj.Client_Account__c = accList[0].Id;
    grpObj.Logo_Tag_ID__c = 'Test Document';
    grpObj.Logo1_ID__c = 'Test Document';
    grpObj.Logo2_ID__c = 'Test Document';
    grpObj.Logo3_ID__c = 'Test Document';
    grpObj.AltLogo1_ID__c = 'Test Document';
    grpObj.AltLogo2_ID__c = 'Test Document';
    insert grpObj;

    List<Mbr_Group__c> mbrList = [SELECT id, Logo1_ID__c FROM Mbr_Group__c];
    List<Document> docList = [SELECT id FROM Document];

    try {
      mbrList[0].Logo1_ID__c = null;
      update mbrList[0];
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains('Invalid Document Name')
        ? true
        : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }
  }

  @isTest
  static void umrLogoValidationTest() {
    List<Account> accList = [SELECT Id FROM Account WHERE Name = 'UMR'];

    Mbr_Group__c testGroup = new Mbr_Group__c();
    testGroup.Client_Account__c = accList[0].Id;
    testGroup.Name__c = 'test 111';
    insert testGroup;

    Mbr_Group__c umrGroup = [SELECT Logo1_ID__c FROM Mbr_Group__c];
    system.assertEquals('MK_TDH_HZ_2', umrGroup.Logo1_ID__c);
  }

  //test method for createMemberGroupRole method
  @isTest
  static void createMemberGroupRoleTest() {
    Test.startTest();
    List<Account> accList = [SELECT Id FROM Account WHERE Name = 'UMR'];

    Mbr_Group__c testGroup = new Mbr_Group__c();
    testGroup.Client_Account__c = accList[0].Id;
    testGroup.Name__c = 'test 111';
    insert testGroup;
    Test.stopTest();
    Mbr_Group_Role__c memGrpRole = [
      SELECT id, Mbr_Group__c, Source_Account__c, Role_Type__c
      FROM Mbr_Group_Role__c
      WHERE Mbr_Group__c = :testGroup.Id
    ];

    //Member Group insertion will auto-create a MEmber Group role with Role type 'Billing'
    system.assertEquals('Billing', memGrpRole.Role_Type__c);
  }
}