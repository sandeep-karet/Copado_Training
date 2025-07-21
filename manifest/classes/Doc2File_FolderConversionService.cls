public class Doc2File_FolderConversionService {

    
    public static Map<String, ContentWorkspace> toMapByKeyField( SObjectField mapKeyField, List<ContentWorkspace> records ) {
        Map<String, ContentWorkspace> recordsMap = new Map<String, ContentWorkspace>();

        for ( ContentWorkspace record : records ) {
            String mapKey = String.valueOf( record.get( mapKeyField ) );
            recordsMap.put( mapKey, record );
        }

        return recordsMap;
    }
    
    public Map<ID, ID> getAlreadyConvertedDocumentIdsMap( Set<ID> documentIds, Set<ID> libraryIds ) {

        // map of old Document ids to new file ids
        Map<ID, ID> convertedDocumentIdsMap = new Map<ID, ID>();

        for ( List<ContentDocumentLink> links : [
            SELECT
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.ExternalId__c
            FROM
                ContentDocumentLink
            WHERE
                LinkedEntityId IN :libraryIds
                AND
                ContentDocument.LatestPublishedVersion.ExternalId__c IN :documentIds
        ]) {

            for ( ContentDocumentLink link : links ) {

                if ( link.ContentDocument != null && link.ContentDocument.LatestPublishedVersion != null ) {

                    if ( documentIds.contains( link.ContentDocument.LatestPublishedVersion.ExternalId__c ) ) {
                        convertedDocumentIdsMap.put( link.ContentDocument.LatestPublishedVersion.ExternalId__c, link.ContentDocument.LatestPublishedVersionId );
                    }

                }

            }

        }
        system.debug('already converted number:' + convertedDocumentIdsMap.size());

        return convertedDocumentIdsMap;
    }
    
    public void convertDocumentsToFiles( List<Document> documents ) {
        
        Set<ID> documentIds = new Set<ID>();
        Set<ID> folderIds = new Set<ID>();
        for ( Document doc : documents ) {
            documentIds.add( doc.Id );
            // folderid of the logoes folder
            folderIds.add( doc.FolderId );
        }
        
        Set<String> libraryNames = new Set<String>();
        //<logo folder id, logo folder>
        Map<ID, Folder> foldersMap = new Map<ID, Folder>([ SELECT Id, Name, DeveloperName FROM Folder WHERE Id IN :folderIds ]);
        for ( Folder f : foldersMap.values() ) {
            libraryNames.add(f.Name);
        }     
      
        Map<ID, ContentWorkspace> librariesMap = new Map<ID, ContentWorkspace>([ SELECT Id, Name FROM ContentWorkspace WHERE Name IN :libraryNames ]);
        Map<String, ContentWorkspace> libraryNamesMap = toMapByKeyField( ContentWorkspace.Name, librariesMap.values() );
        Map<ID, ID> alreadyConvertedDocumentIdsMap = getAlreadyConvertedDocumentIdsMap( documentIds, librariesMap.keySet() );
        
        // todo add error handling and logging like in ConvertAttachmentsToFilesService.cls
        List<ContentVersion> newFileVersions = new List<ContentVersion>();
        
        for ( Document doc : documents ) {
            
            // todo log a skipped conversion result like attachment converter project
            if ( alreadyConvertedDocumentIdsMap.containsKey( doc.Id ) ) {
                System.debug( 'Document has already been converted, skipping... ' + doc );
                continue;
            }
            
            Folder f = foldersMap.get( doc.FolderId );
            String libraryName = ( f.Name );
            ContentWorkspace library = libraryNamesMap.get( libraryName );   
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
            
            // some doc are empty for some reason, need to check in
            String bodyData = String.valueOf(cv.versionData);
            if(bodyData != 'blob[0]'){
                newFileVersions.add(cv);
            }
        }
        system.debug(newFileVersions);
        insert newFileVersions;
    }
}