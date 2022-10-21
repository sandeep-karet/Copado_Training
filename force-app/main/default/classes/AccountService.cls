/**
* AccountService Class
* 
* 
*/
public class AccountService {
    
    public static final String DEFAULT_CONTENT_NOTE_TITLE = System.Label.Default_Content_Note_Type;
    public static final Id ACCOUNT_HEALTH_SCORE_RECORD_TYPE_ID = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Account_Health_Score').getRecordTypeId();
    public static final Id PROGRAM_HEALTH_SCORE_RECORD_TYPE_ID = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Program_Health_Score').getRecordTypeId();
    public static List<ContentNote> nte = new List<ContentNote>();
    public static List<ContentDocumentLink> lnk = new List<ContentDocumentLink>();
    
    public static void autoCreateNote(List<Account__c> accounts){
        Set<Id>  acctId= new Set<Id>(); 
        Set<Id> contentDocumentIds = new Set<Id>();
        
        for(Account__c Accts : accounts){   
            acctId.add(Accts.Id);
            //get all contentdocumentids so that you can query on contentnote
            for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN : acctId]){
                contentDocumentIds.add(conDoc.ContentDocumentId);
            }
        }
        //get all the content notes using contentDocumentIds
        List<ContentNote> contentNotes = [SELECT Id,Title, Content from ContentNote 
                                          WHERE Title =:DEFAULT_CONTENT_NOTE_TITLE AND Id In: contentDocumentIds ];
        if(!contentNotes.isEmpty()){
            updateExistingNotes(accounts,contentNotes);
        }else{
            addNewNotes(accounts);
        }
    }            
    // this method will update the existing Account Health Notes with new notes
    public static void updateExistingNotes(List<Account__c> accounts, List<ContentNote> contentNotes){
        string content;           
        for(Account__c Accts : accounts){
            for(ContentNote contentnote :contentNotes){
                if(contentnote.Title != NULL && contentnote.Title == DEFAULT_CONTENT_NOTE_TITLE){  
                    content=(contentnote.Content.toString() +'<br/>'+'<br/>'+ Accts.Client_Risk_Notes__c);
                    contentnote.Content=blob.valueOf(content);
                    nte.add(contentnote);                           
                }
            }
        } 
        if(!nte.isEmpty()){
            try{
                update nte;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
        nte.clear();
    }
    
    // this method will add new Account Health Notes to an Account 
    public static void addNewNotes(List<Account__c> accounts){
        
        for(Account__c Accts : accounts){
            ContentNote cnt = new ContentNote();  
            cnt.Content = Blob.valueof(Accts.Client_Risk_Notes__c);
            cnt.Title = DEFAULT_CONTENT_NOTE_TITLE ;
            nte.add(cnt);
        } 
        if(!nte.isEmpty()){
            insert nte;
        }
        for(Account__c Accts : accounts){
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = Accts.Id;
            clnk.ContentDocumentId = nte[0].Id;
            clnk.ShareType = 'V';
            clnk.Visibility='AllUsers';
            lnk.add(clnk);
        }
        if(!lnk.isEmpty()){
            try{
                insert lnk;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }  
        nte.clear();
        lnk.clear();
    }
    public static void createHealthScores(List<Account__c> accList) {
        List<Health_Score__c> hsListToCreate = new List<Health_Score__c>();
        
        Health_Score_Elements__mdt[] hsElementsMDT = [SELECT Id, Element_Section__c, Health_Score_Record_Type__c, 
                                                      Health_Segment__c, Program__c, Recommended_Action_Steps__c, Sort_Order__c, Display_Fields__c FROM Health_Score_Elements__mdt];
        
        for (Account__c acc : accList) {
            for (Health_Score_Elements__mdt hsMdt: hsElementsMDT) {
                Health_Score__c hs = new Health_Score__c();
                hs.Account__c = acc.Id;
                hs.Health_Segment__c = hsMdt.Health_Segment__c;
                if (hsMdt.Health_Score_Record_Type__c == 'Program Health Score') {
                    hs.RecordTypeId = PROGRAM_HEALTH_SCORE_RECORD_TYPE_ID;
                    hs.Program__c = hsMdt.Program__c;
                }
                else {
                    hs.RecordTypeId = ACCOUNT_HEALTH_SCORE_RECORD_TYPE_ID;
                }
                hs.Element_Section__c = hsMdt.Element_Section__c;
                hs.Recommended_Action_Steps__c = hsMdt.Recommended_Action_Steps__c;
                hs.Sort_Order__c = hsMdt.Sort_Order__c;
                hs.Display_Fields__c = hsMdt.Display_Fields__c;
                hsListToCreate.add(hs);
            }
        }
        if (!hsListToCreate.isEmpty()) {
            Insert hsListToCreate;
        }       
    }
    
    public static void updateHealthScores (List<Account__c> newAccounts, Map<Id, Account__c> oldAccounts) {
        List<Health_Score__c> hsListToUpdate = new List<Health_Score__c>();
        List<Health_Score__c> hsList = [SELECT Id, RecordType.Name, Program__c, Health_Segment__c, Actual_Result__c, Account__r.Enrollment_Percentage_rPwDs__c,
                                        Account__r.Enrollment_Percentage_rPwHs__c, Account__r.Activation__c, Account__r.Activated_Percent_HTN__c, 
                                        Account__r.Usage_Last_30_day_Diabetes__c, Account__r.Usage_Last_30_day_HTN__c,
                                        Account__r.Email_Coverage_Percentage_DM__c, Account__r.Email_Coverage_Percentage_HTN__c
                                        FROM Health_Score__c WHERE Account__c IN :newAccounts AND RecordType.Name != 'Account Health Score'];
        if (hsList.size() > 0) {
            for (Health_Score__c hs : hsList) {
                if (hs.Account__r.Enrollment_Percentage_rPwDs__c != oldAccounts.get(hs.Account__c).Enrollment_Percentage_rPwDs__c
                    && hs.Health_Segment__c == 'Enrollment' && hs.Program__c == 'Diabetes') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Enrollment_Percentage_rPwDs__c);
                    }
                if (hs.Account__r.Enrollment_Percentage_rPwHs__c != oldAccounts.get(hs.Account__c).Enrollment_Percentage_rPwHs__c
                    && hs.Health_Segment__c == 'Enrollment' && hs.Program__c == 'Hypertension') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Enrollment_Percentage_rPwHs__c);
                    }
                if (hs.Account__r.Activation__c != oldAccounts.get(hs.Account__c).Activation__c
                    && hs.Health_Segment__c == 'Activation' && hs.Program__c == 'Diabetes') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Activation__c);
                    }
                if (hs.Account__r.Activated_Percent_HTN__c != oldAccounts.get(hs.Account__c).Activated_Percent_HTN__c
                    && hs.Health_Segment__c == 'Activation' && hs.Program__c == 'Hypertension') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Activated_Percent_HTN__c);
                    }
                if (hs.Account__r.Usage_Last_30_day_Diabetes__c != oldAccounts.get(hs.Account__c).Usage_Last_30_day_Diabetes__c
                    && hs.Health_Segment__c == 'Active 30' && hs.Program__c == 'Diabetes') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Usage_Last_30_day_Diabetes__c);
                    }
                if (hs.Account__r.Usage_Last_30_day_HTN__c != oldAccounts.get(hs.Account__c).Usage_Last_30_day_HTN__c
                    && hs.Health_Segment__c == 'Active 30' && hs.Program__c == 'Hypertension') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Usage_Last_30_day_HTN__c);
                    }
                if (hs.Account__r.Email_Coverage_Percentage_DM__c != oldAccounts.get(hs.Account__c).Email_Coverage_Percentage_DM__c
                    && hs.Health_Segment__c == 'Email Coverage' && hs.Program__c == 'Diabetes') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Email_Coverage_Percentage_DM__c);
                    }
                if (hs.Account__r.Email_Coverage_Percentage_HTN__c != oldAccounts.get(hs.Account__c).Email_Coverage_Percentage_HTN__c
                    && hs.Health_Segment__c == 'Email Coverage' && hs.Program__c == 'Hypertension') {
                        hs.Actual_Result__c = String.valueOf(hs.Account__r.Email_Coverage_Percentage_HTN__c);
                    }
                hsListToUpdate.add(hs);
            }
        }
        if (!hsListToUpdate.isEmpty()) {
            try {
                update hsListToUpdate;
            }
            catch(DMLException e) {
                system.debug('The following exception has occurred:' + e.getMessage());
            }
        }
    }
}