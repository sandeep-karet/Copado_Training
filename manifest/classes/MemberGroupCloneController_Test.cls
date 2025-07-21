@IsTest
private class MemberGroupCloneController_Test {
  @IsTest
  static void findMgTest() {
    Account umrAcct = TestDataFactory.createUMR();
    ContentVersion cv = new ContentVersion();
    cv.Title = 'My Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;

    document testDoc = new Document();
    testDoc.Body = Blob.valueOf('Some Text');
    testDoc.ContentType = 'application/pdf';
    testDoc.DeveloperName = 'my_document';
    testDoc.IsPublic = true;
    testDoc.Name = 'My Document';
    testDoc.FolderId = [SELECT id FROM folder WHERE name = 'Logos'].id;
    insert testDoc;
    Account acct = new Account(Name = 'Test01', Source__c = 'HUB');
    insert acct;
    Mbr_Group__c grp = new Mbr_Group__c(
      Name__c = 'testgrp1',
      Client_Account__c = acct.Id,
      Status__c = 'ACTIVE',
      Active_Date__c = Date.today()
    );
    String grpId = MemberGroupCloneController.createMbrGroup(grp);
    system.assertEquals(grp.Id, grpId);
  }
}