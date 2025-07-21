trigger Attachment_After on Attachment (after insert) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> cdlList = new LIst<ContentDocumentLink>();
        
        for(Attachment att : trigger.new){    
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.OwnerId = att.OwnerId;
            cv.Title = att.Name;
            cv.PathOnClient = att.Name;
            cv.VersionData = att.body;
            cv.ExternalId__c  = att.Id;
            cv.Attachment_Parent_Record_Id__c = att.parentId;
            cvList.add(cv);
        }
        try {
            insert cvList;
        } catch (UnexpectedException e) {
            system.debug('error message: '+  e);
        }   
        
        List<ContentVersion> cvcdList = new List<ContentVersion>();
        cvcdList = [SELECT Id, Attachment_Parent_Record_Id__c, ContentDocumentId FROM ContentVersion WHERE Id In: cvList];
        
        
        for(ContentVersion cvcd: cvcdList){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cvcd.ContentDocumentId;
            cdl.LinkedEntityId = cvcd.Attachment_Parent_Record_Id__c;
            cdl.ShareType = 'V';
            cdlList.add(cdl);
        }
        
        try {
            insert cdlList;
            
        } catch (UnexpectedException e) {
            system.debug('error message: '+  e);
        } 
    }
}