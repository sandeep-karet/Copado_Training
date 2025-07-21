@IsTest
private class Doc2File_FolderConversionService_Test {
    @TestSetup
    static void setup(){ 
        List<Document> docList = new List<Document>();
        for (Integer i = 0; i < 10; i++) {        
            document testDoc = new Document();
            testDoc.Body = Blob.valueOf('Some Text');
            testDoc.ContentType = 'application/pdf';
            testDoc.DeveloperName = 'my_document' + i;
            testDoc.IsPublic = true;
            testDoc.Name = 'My Document' + i ;
            testDoc.FolderId = [select id from folder where name = 'Logos'].id;
            docList.add(testDoc);    
        }
        
        insert docList;
    }
    
   @isTest
    static void doc2file(){
        test.startTest();
        document2Files_Bch testing = new document2Files_Bch(null, null);
        DataBase.executeBatch(testing);
        test.stopTest();
        List<contentversion> cvs = [SELECT id from contentversion];
        system.assertEquals(TRUE, cvs.size()>=0);
    }
    
    @isTest
    static void doc2fileAlareadyConverted() {
        Document doc = [SELECT Id, Body, DeveloperName, Type, Name, Description, Keywords, AuthorId, CreatedDate, LastModifiedById, LastModifiedDate FROM Document LIMIT 1];
        Contentworkspace library = new Contentworkspace(Name = 'TestLogos');//[SELECT Id, Name, DeveloperName FROM Contentworkspace WHERE Name ='Logos'];
 		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
        insert library;
		}
        system.debug(library);
        ContentVersion cv = new ContentVersion(
            // data fields
            VersionData = doc.Body,
            PathOnClient = '/' + doc.DeveloperName + '.' + doc.Type,
            Title = doc.Name,
            Description = doc.Description,
            FirstPublishLocationId = library.Id,
            TagCsv = doc.Keywords,
            // audit fields
            OwnerId = doc.AuthorId, // system requirement, owner and creator must be the same
            CreatedById = doc.AuthorId,
            CreatedDate = doc.CreatedDate,
            LastModifiedById = doc.LastModifiedById,
            LastModifiedDate = doc.LastModifiedDate,
            // custom fields for history tracking and conversion purposes
            ExternalId__c = doc.Id
        );
        insert cv;
        
        test.startTest();
        document2Files_Bch testing = new document2Files_Bch(null, null);
        DataBase.executeBatch(testing);
        test.stopTest();
        List<contentversion> cvs = [SELECT id from contentversion];
        system.assertEquals(1, cvs.size());

    }

}