@IsTest
private class MemberGroupV2Controller_Test {
    @TestSetup
    static void setup(){    
        Account umrAcct = TestDataFactory.createUMR();        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'MK_TDH_HZ_2';
        cv2.PathOnClient = 'MK_TDH_HZ_2.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        Insert cv2;
        
        List<ContentVersion> testContent = [SELECT ContentDocumentId FROM ContentVersion]; 
        ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0].Id;
        
        for (ContentVersion cvs : testContent){
            ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
            newWorkspaceDoc.ContentWorkspaceId = workspaceId; 
            newWorkspaceDoc.ContentDocumentId = cvs.ContentDocumentId; 
            insert newWorkspaceDoc;
        }
        
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        for (ContentDocument cd: documents) {
            cd.parentId = workspaceId;
            update cd;
        }
        
        List<Account> acct = new List<Account>();
        Account a = new Account(
            Name = 'Test01',
            Source__c = 'HUB'
        );
        acct.add(a);
        
        insert acct;
        Mbr_Group__c grp = new Mbr_Group__c(
            Name__c = 'testgrp1',
            Client_Account__c = a.Id,
            Status__c = 'ACTIVE',
            Active_Date__c = Date.today()
        );
        insert grp;
    }
    
    @IsTest
    static void searchLogoDoc() {
        MemberGroupV2Controller.searchLogoDoc('MK_TDH_HZ_2');
    } 
    
    @IsTest
    static void getRecordInfo() {
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test01'];
        MemberGroupV2Controller.getRecordInfo(acct.Id);
        Mbr_Group__c mbrGroup = [SELECT Id FROM Mbr_Group__c];
        MemberGroupV2Controller.getRecordInfo(mbrGroup.Id);    }
}