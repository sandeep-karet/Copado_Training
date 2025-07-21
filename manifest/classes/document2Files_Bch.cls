global without sharing class document2Files_Bch implements Database.Batchable<SObject> {
    private final String folder;   
    private final DateTime createDate;   

    
    global document2Files_Bch(String folderName, String fileDate){
        if(folderName == Null)
            folder = 'Logos';
        else
            folder = folderName;
        
        if(fileDate == Null)
            createDate = Datetime.valueOf('2010-01-01 00:00:00');
        else
            createDate = Datetime.valueOf(fileDate);
    }
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator([
            SELECT  Id, Name, DeveloperName, Description, ContentType, Type, Body, Url, Keywords, FolderId, Folder.Name, Folder.DeveloperName, AuthorId, CreatedById, CreatedDate,
                	LastModifiedById, LastModifiedDate
            FROM Document
            WHERE Folder.Name =: folder
            AND CreatedDate >=: createDate
        ]);
    }

    global void execute( Database.BatchableContext context, List<Document> documents ) {
        SavePoint sp = Database.setSavepoint();
        try {
            Doc2File_FolderConversionService service = new Doc2File_FolderConversionService();
            service.convertDocumentsToFiles( documents );
        } catch ( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, e );
        }

    }

    global void finish( Database.BatchableContext context ) {
       
    }
}