//SCDEV-3387 Email notification for impending User Deactivations
public class DeactivateBatchHelper {
    @TestVisible static Date deactiveReminderDate = Date.today().addDays(-23);
    public static void sendReminderEmail() {
        try{
            String PROFILESTOBEIGNORED = System.Label.Ignore_Profiles_From_Deactivation;
            String USERSTOBEIGNORED = System.Label.Ignore_Users_From_Deactivation;
            String query = 'SELECT Id, Name,Profile.Name,Email, Username, LastLoginDate, IsActive, CreatedDate FROM User WHERE IsActive = TRUE ' + 
                'AND (LastLoginDate != LAST_N_DAYS:23 OR (LastLoginDate = NULL AND CreatedDate != LAST_N_DAYS:23))' +
                'AND Profile.Name NOT IN ('+PROFILESTOBEIGNORED+') AND Name NOT IN ('+USERSTOBEIGNORED+') AND UserType = \'Standard\'';
            if(Test.isRunningTest()) {
                query += ' AND (FirstName LIKE \'TestUser%\' AND LastName LIKE \'TestUser%\') LIMIT 50';
            }
            List<User>  remindUsersList = database.query(query);
            
            EmailTemplate ude = [SELECT Id,  Subject, Body FROM EmailTemplate WHERE Name = 'User Deactivation Reminder'];
            
            System.debug('Users List' + remindUsersList);
            //Constructing email for list of Users
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            for (User rUL : remindUsersList) {
                Messaging.SingleEmailMessage remindEmail = new Messaging.SingleEmailMessage();
                remindEmail.setSenderDisplayName('Teladoc Health Sales Cloud');
                remindEmail.setToAddresses(new List<String>{rUL.Email}); 
                remindEmail.setSubject(ude.Subject);
                remindEmail.setPlainTextBody(ude.Body);
                
                emailMessageList.add(remindEmail);
            }
            
            //Send Email
            Messaging.sendEmail(emailMessageList); /* false is part of the 'opt_allorNone' parameter which is set to TRUE by default,
															which will not allow emails to send due to error such as invalid emails */ 
        }
        catch(Exception ex) {
            System.debug(ex);
        }
    }
    
    
}