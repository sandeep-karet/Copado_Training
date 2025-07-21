@IsTest
private class Attachment_After_Test {
    @IsTest
    static void Attachment_After_Test(){
        Account acct = TestDataFactory.createParentAccount();
        List<Attachment> attlist = new List<Attachment>();
        for (Integer i = 0; i < 2; i++) {
            
            Attachment att= new Attachment();
            att.Body=Blob.valueOf('bodyStr');
            att.Name='test' + i ;
            att.parentId=acct.Id; 
            attlist.add(att);
        }        
        insert attlist;      
        List<ContentDocumentLink> cdl = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId in ( SELECT Id FROM Account WHERE Id =: acct.Id ) and LinkedEntity.Type='Account'];
        system.assertEquals(2, cdl.size());
    } 
}