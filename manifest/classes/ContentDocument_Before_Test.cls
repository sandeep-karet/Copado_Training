@IsTest
private class ContentDocument_Before_Test {
    @isTest
    static void ContentDoc_Before_Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='test12345@testtest.com',EmailEncodingKey='UTF-8', 
                           LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testzxcas.org');
        insert u1;
        
        
        System.runAs(u1){
            try {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'fileName'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'fileName'; // Display name of the files  
            conVer.VersionData = Blob.valueOf('test to generate PDF');
            insert conVer;
            } catch (exception e){}
        }
    }
    
}