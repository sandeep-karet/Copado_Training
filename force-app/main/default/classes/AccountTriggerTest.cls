@isTest
public class AccountTriggerTest {
    
    private static List<Account__c> getAccountId(){
        Account__c clientAccount = TestFactory.createClientAccount();
        List<Account__c> accounts = new List<Account__c>();
        accounts.add(clientAccount);
        insert accounts; 
        return accounts;
    }
    
    private static List<Account__c> getAccountIdWithExistingNotes(){
        Account__c clientAccount = TestFactory.createClientAccount();
        List<Account__c> Accts=new List<Account__c>();
        Accts.add(clientAccount); 
        insert Accts; 
        Accts[0].Client_Risk_Notes__c='Unit Testing on Trigger Class';
        update Accts; 
        return Accts;
    }
    
    
    private static List<ContentDocumentLink> getContentDocumentLink(Set<Id> idSet) {
        return [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :idset];
    }
    
    private static List<ContentNote> getContentNote(set<Id> idSet) {
        return [SELECT Id,Title,Content,TextPreview,OwnerId from ContentNote where Id In: idSet];
    }
    
    
    @isTest
    static void createNewNotes(){
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        // New Notes creation testing when account health notes is added for the first time.
        List<Account__c> Accts=getAccountId();            
        set<Id> acctId=new Set<Id>();      
        Accts[0].Client_Risk_Notes__c='Unit Testing on Trigger Class';
        acctId.add(Accts[0].Id);
        Test.startTest();
        update Accts;
        Test.stopTest();
        
        List<ContentDocumentLink> conDoc=getContentDocumentLink(acctId);
        Set<Id> cLinkId = new Set<Id>();
        System.assertEquals(1, conDoc.size());
        for (ContentDocumentLink cLink: conDoc) {
            cLinkId.add(cLink.ContentDocumentId);
        } 
        
        List<ContentNote> conNote=getContentNote(cLinkId);
        system.assertEquals(1, conNote.size());
        system.assertEquals('Account Health Notes', conNote[0].Title);
        system.assertEquals('Unit Testing on Trigger Class', conNote[0].Content.toString());
        system.assertEquals('Unit Testing on Trigger Class', conNote[0].TextPreview);
        System.assertEquals(System.UserInfo.getUserId(), conNote[0].OwnerId);   
        
    }
    
    @isTest
    static void appendToExistingNotes(){
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        insert asw;
        
        // Update notes 
        List<Account__c> Accts=getAccountIdWithExistingNotes();            
        set<Id> acctId=new Set<Id>();  
        Accts[0].Client_Risk_Notes__c='Append this Notes';
        acctId.add(Accts[0].Id);
        Test.startTest();
        update Accts;
        Test.stopTest();    
        
        
        List<ContentDocumentLink> conDoc=getContentDocumentLink(acctId);
        Set<Id> cLinkId = new Set<Id>();
        System.assertEquals(1, conDoc.size());
        for (ContentDocumentLink cLink: conDoc) {
            cLinkId.add(cLink.ContentDocumentId);
        } 
        
        List<ContentNote> updatedNote=getContentNote(cLinkId);
        
        system.assertEquals(1, updatedNote.size());
        system.assertEquals('Account Health Notes', updatedNote[0].Title);
        system.assertEquals('Unit Testing on Trigger Class Append this Notes', updatedNote[0].TextPreview);
        system.assertEquals(System.UserInfo.getUserId(), updatedNote[0].OwnerId);             
    }
    
    @isTest
    static void healthScoresTest() {
        List<Account__c> accList = getAccountId();
        for (Account__c acc : accList) {
            acc.Enrollment_Percentage_rPwDs__c = 100;
            acc.Enrollment_Percentage_rPwHs__c = 100;
            acc.Activation__c = 100;
            acc.Activated_Percent_HTN__c = 100;
            acc.Usage_Last_30_day_Diabetes__c = 100;
            acc.Usage_Last_30_day_HTN__c = 100;
            acc.Email_Coverage_Percentage_DM__c = 100;
            acc.Email_Coverage_Percentage_HTN__c = 100;
        }
        Test.startTest();
        update accList;
        Test.stopTest();
        List<Health_Score__c> hsList = [SELECT Id, Actual_Result__c, Program__c, Health_Segment__c, Account__r.Enrollment_Percentage_rPwDs__c, 
                                        Account__r.Enrollment_Percentage_rPwHs__c, Account__r.Activation__c, Account__r.Activated_Percent_HTN__c, 
                                        Account__r.Usage_Last_30_day_Diabetes__c, Account__r.Usage_Last_30_day_HTN__c, Account__r.Email_Coverage_Percentage_DM__c, 
                                        Account__r.Email_Coverage_Percentage_HTN__c FROM Health_Score__c WHERE Account__c IN :accList 
                                        AND (Health_Segment__c = 'Enrollment' OR Health_Segment__c = 'Activation' OR Health_Segment__c = 'Active 30' 
                                             OR Health_Segment__c = 'Email Coverage')];
        for (Health_Score__c hs : hsList) {
            if (hs.Program__c == 'Diabetes') {
                if (hs.Health_Segment__c == 'Enrollment') {
                    System.assertEquals(String.valueOf(hs.Account__r.Enrollment_Percentage_rPwDs__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Activation') {
                    System.assertEquals(String.valueOf(hs.Account__r.Activation__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Active 30') {
                    System.assertEquals(String.valueOf(hs.Account__r.Usage_Last_30_day_Diabetes__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Email Coverage') {
                    System.assertEquals(String.valueOf(hs.Account__r.Email_Coverage_Percentage_DM__c), hs.Actual_Result__c);
                }
            }
            else if (hs.Program__c == 'Hypertension') {
                if (hs.Health_Segment__c == 'Enrollment') {
                    System.assertEquals(String.valueOf(hs.Account__r.Enrollment_Percentage_rPwHs__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Activation') {
                    System.assertEquals(String.valueOf(hs.Account__r.Activated_Percent_HTN__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Active 30') {
                    System.assertEquals(String.valueOf(hs.Account__r.Usage_Last_30_day_HTN__c), hs.Actual_Result__c);
                }
                else if (hs.Health_Segment__c == 'Email Coverage') {
                    System.assertEquals(String.valueOf(hs.Account__r.Email_Coverage_Percentage_HTN__c), hs.Actual_Result__c);
                }
            }
        }       
    }
}