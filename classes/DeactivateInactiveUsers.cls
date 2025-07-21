//SCDEV-2447 Deactivating Inactive Users
	
global class DeactivateInactiveUsers implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    
    global String query = '';
    global String cron = '';
    global Integer numSuccess   = 0;
	global Integer numRecords   = 0;
	global String dmlFailures   = null;
	global String errorString   = 'Id, Name, Username, Status, Message';
    global static final String PROFILESTOBEIGNORED = System.Label.Ignore_Profiles_From_Deactivation;
    global static final String NOTIFIEDPARTIES = System.Label.User_Deactivation_Notified_Parties;
    global static final String EMAILSUBJECT = System.Label.User_Deactivation_Email_Subject;
    global static final String USERSTOBEIGNORED = System.Label.Ignore_Users_From_Deactivation;
    global static final String dateStr = Date.today().format();
    
    global void execute(SchedulableContext scheduleDIU) {
        Database.executeBatch(new DeactivateInactiveUsers());
    }
    
	//Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        final String method = 'Start';
        System.debug('Entering method: ' + method);        
        try {
            System.debug('Constructing query');
            //querying for inactive users longer than 30 days or users who were created and have not logged in for 30 days
            query = 'SELECT Id, Name, Username, LastLoginDate, IsActive, CreatedDate FROM User WHERE IsActive = TRUE ' + 
            		'AND (LastLoginDate < LAST_N_DAYS:30 OR (LastLoginDate = NULL AND CreatedDate < LAST_N_DAYS:30))' +
                	'AND Profile.Name NOT IN ('+PROFILESTOBEIGNORED+') AND Name NOT IN ('+USERSTOBEIGNORED+') AND UserType = \'Standard\'';
            if(Test.isRunningTest()) {
                query += ' AND (FirstName LIKE \'TestUser%\' AND LastName LIKE \'TestUser%\') LIMIT 50';
            }
        }
        catch(Exception ex) {
            System.debug('Exiting method: ' + method);
            System.debug(ex);
        }
        System.debug('Exiting method ' + method);
        return Database.getQueryLocator(query);
        
    }
    
    //Execute Method
    global void Execute(Database.BatchableContext bc, List<User>InactiveResult) {
        System.debug('bc'+ bc);
        System.debug('InactiveResult' + InactiveResult);

        for(User usr : InactiveResult) {
			usr.IsActive = false;

		}
        List<Database.SaveResult> lstSR = Database.update(InactiveResult,false);
		for (Integer i = 0; i < InactiveResult.size(); i++) {
			Database.SaveResult sr = lstSR[i];
			numRecords++ ;
			if(!sr.isSuccess()) {
				errorString += '\n' + InactiveResult[i].Id + ',' + InactiveResult[i].Name + ',' + InactiveResult[i].Username + ', Failure,';
				for(Database.Error er :sr.getErrors()){
					errorString += er.getMessage();
                    System.debug('Error : ' + errorString);
				}
			} else {
				numSuccess++ ;
				errorString += '\n' + InactiveResult[i].Id + ',' + InactiveResult[i].Name + ',' + InactiveResult[i].Username + ', Success';
                System.debug('Error 2 :' + errorString);
			}
		}
        System.debug('Execute Method' + bc);
    }
    
    //Finish Method
    global void finish(Database.BatchableContext bc) {
        
        DeactivateBatchHelper.sendReminderEmail();

		final String method = 'Finish';
		System.debug('Entering method: ' + method);

		System.debug('Creating email to report changes');

		Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
		Blob csvBlob = Blob.valueOf(errorString);
		String csvName = 'Deactivate User Sync Batch Results ' + dateStr + '.csv ';
		csvAttachment.setFileName(csvName);
		csvAttachment.setBody(csvBlob);

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{NOTIFIEDPARTIES});
		mail.setSubject(EMAILSUBJECT);
		String emailFooter = 'Please contact Sales Cloud support for any assistance';
		mail.setPlainTextBody('Results for Deactivated Users:\n\n' + numSuccess + ' of ' + numRecords +' Updated' + '\n\n' + emailFooter);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});

		System.debug('Printing result: ' + mail.plainTextBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		System.debug('Exiting method: ' + method);
	}
}