@isTest
public class ContentVersionTriggerTest {
 
    public static final String Title = System.Label.Default_Content_Note_Type;
    public static final String ERROR_MSG = System.Label.Content_Note_Error_Message;
    public static string Error;
    
    @isTest
    static void checkContentVersionTitle(){
        
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        
        ContentVersion conVer=new ContentVersion();
        conVer.Title=Title;
        conVer.PathOnClient='Account Health Notes.snote';
        conVer.ContentUrl='';
        conver.VersionData=Blob.valueof('ContentVersionTriggerTest');
        insert conVer;
        conVer.Title=Title+'testing';
        Test.startTest();
        try {
            update conVer;
        }catch(Exception e){
                        System.debug('Err:: '+e.getMessage());
                        Error= e.getMessage();
            
         }
        Test.stopTest();         
        Boolean expectedError = Error.contains(ERROR_MSG);
        system.assertEquals(expectedError, TRUE);
    }
}