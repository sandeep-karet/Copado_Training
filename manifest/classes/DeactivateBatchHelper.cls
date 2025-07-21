//SCDEV-3387 Email notification for impending User Deactivations
public class DeactivateBatchHelper {
    @TestVisible static Date deactiveReminderDate = Date.today().addDays(-23);
    public static void sendReminderEmail() {
        try{
            String PROFILESTOBEIGNORED = System.Label.Ignore_Profiles_From_Deactivation;
            //String USERSTOBEIGNORED = System.Label.Ignore_Users_From_Deactivation;
            String query = 'SELECT Id, Name,Profile.Name,Email, Username, LastLoginDate, IsActive, CreatedDate FROM User WHERE IsActive = TRUE ' + 
                'AND (LastLoginDate != LAST_N_DAYS:53 OR (LastLoginDate = NULL AND CreatedDate != LAST_N_DAYS:53))' +
                'AND Profile.Name NOT IN ('+PROFILESTOBEIGNORED+') AND UserType = \'Standard\'';
            if(Test.isRunningTest()) {
                query += ' AND (FirstName LIKE \'TestUser%\' AND LastName LIKE \'TestUser%\') LIMIT 50';
            }
            List<User>  remindUsersList = database.query(query);
            
            EmailTemplate emailTemplateRecord = [SELECT Id,  Subject, Body,htmlvalue FROM EmailTemplate WHERE Name = 'User Deactivation Reminder'];
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] orgWideEmailAddress = [select Id from OrgWideEmailAddress where Address = 'SFCRMnotifications@teladochealth.com'];

            for (User userRec : remindUsersList) {
                Messaging.SingleEmailMessage remindEmail = new Messaging.SingleEmailMessage();
                if(!orgWideEmailAddress.IsEmpty())
                {
                    remindEmail.setOrgWideEmailAddressId(orgWideEmailAddress.get(0).Id);
                }
                remindEmail.setSenderDisplayName('Teladoc Health Sales Cloud');
                remindEmail.setToAddresses(new List<String>{userRec.Email});
                emailTemplateRecord.Body = emailTemplateRecord.Body.replace('LINK TO LCRM','<br/><a href="'+System.URL.getOrgDomainUrl().ToExternalForm()+'">LINK TO LCRM</a>');
                remindEmail.setSubject(emailTemplateRecord.Subject);
                remindEmail.setHtmlBody(emailTemplateRecord.Body);
                
                emailMessageList.add(remindEmail);
            }
            
            Messaging.sendEmail(emailMessageList); 
        }
        catch(Exception ex) {
            System.debug(ex);
        }
    }
    
    
}