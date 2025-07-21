trigger ContentDocumentTrigger on ContentDocument (before delete) {
    SFMC__c sfmc = SFMC__c.getOrgDefaults();
    if(Trigger.Isbefore && Trigger.IsDelete) {
        if(sfmc.Enable_ContentDocumentTrigger__c) {
            List<ContentVersion> conVer = [SELECT Id,Title, SFMC_Id__c,VersionData, ContentDocument.Description,contentdocument.parentId, FileExtension, Description FROM ContentVersion WHERE contentdocument.parentId = '058f40000005c1LAAQ' AND contentDocumentId IN: Trigger.Old];
            Database.executeBatch(new SFMC_LogoDeleteBatch(conVer)); 
        }
    } 
}