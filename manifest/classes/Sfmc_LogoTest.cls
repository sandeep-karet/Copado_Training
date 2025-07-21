@isTest
private class Sfmc_LogoTest {
  @testSetup
  static void testSetupMethod() {
    String filecontent = 'Logo123';

    ContentVersion conVer = new ContentVersion();
    conVer.ContentLocation = 'S';
    conVer.PathOnClient = 'Logo123.jpg';
    conVer.Title = 'Logo123';
    conVer.VersionData = EncodingUtil.base64Decode(filecontent);
    conVer.Description = 'test';
    insert conVer;

    ContentVersion conv = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Title = 'Logo123'
    ];
    ContentDocument conDoc = [
      SELECT Id, ParentId, Description
      FROM ContentDocument
      WHERE Id = :conv.ContentDocumentId
    ];
    conDoc.Description = 'Test';
    update conDoc;

    SFMC__c sfmc = SFMC__c.getOrgDefaults();
    sfmc.CategoryName__c = 'Testing';
    sfmc.CategoryId__c = '123456';
    sfmc.EndpointUrl__c = 'endpointURL';
    sfmc.Token_EndpointUrl__c = 'TokenEndPointURL';
    upsert sfmc SFMC__c.Id;
  }

  @isTest
  static void Logo_TestCreate() {
    List<ContentVersion> conList = [
      SELECT
        Id,
        Title,
        ContentDocument.Description,
        contentdocument.parentId,
        versiondata,
        FileExtension,
        Description
      FROM ContentVersion
      WHERE Title = 'Logo123'
    ];
    SFMC__c sfmc = SFMC__c.getInstance(UserInfo.getProfileId());
    Test.setMock(HttpCalloutMock.class, new SFMC_LogoMockCallout());
    Test.startTest();
    SFMC_LogoUploadBatch fob = new SFMC_LogoUploadBatch();
    Database.QueryLocator ql = fob.start(null);
    fob.execute(null, conList);
    fob.Finish(null);
    Test.stopTest();
  }

  @isTest
  static void Logo_TestDelete() {
    List<ContentVersion> conList = [
      SELECT
        Id,
        Title,
        SFMC_Id__c,
        ContentDocument.Description,
        contentdocument.parentId,
        versiondata,
        FileExtension,
        Description
      FROM ContentVersion
      WHERE Title = 'Logo123'
    ];
    conList[0].SFMC_Id__c = '12345';
    List<ContentDocument> conDoc = [
      SELECT Id, ParentId, Description
      FROM ContentDocument
      WHERE Id = :conList[0].ContentDocumentId
    ];
    SFMC__c sfmc = SFMC__c.getInstance(UserInfo.getProfileId());

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new SFMC_LogoMockCallout());
    delete conDoc;
    SFMC_LogoDeleteBatch fob = new SFMC_LogoDeleteBatch(conList);
    fob.execute(null, conList);
    fob.Finish(null);
    system.assertEquals(
      0,
      [
          SELECT Id, ParentId, Description
          FROM ContentDocument
          WHERE Id = :conList[0].ContentDocumentId
        ]
        .size()
    );
    Test.stopTest();
  }
}