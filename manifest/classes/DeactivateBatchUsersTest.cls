/* This class is code coverage for DeactivateBatchHelper class
* SCDEV-3888
*/
@IsTest
private class DeactivateBatchUsersTest {
    
    @testSetup static void testSendReminderEmails() {
        // Create common test users
        List<User> testUsersProfiles = new List<User>();
        for(Integer i = 0; i < 5 ; i++){
            testUsersProfiles.add(new User(FirstName = 'TestUser'+ i, 
                                           LastName = 'TestUser' + i,
                                           UserName = 'TestUser' + i + '@teladochealth.com',
                                           Email = 'TestUser' + i + '@teladochealth.testing.com',
                                           Alias = 'TUsr' + i,
                                           EmailEncodingKey = 'UTF-8',
                                           LanguageLocaleKey = 'en_US',
                                           LocaleSidKey = 'en_US',
                                           TimeZoneSidKey = 'America/Chicago',
                                           ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id
                                          ));
        }
        insert testUsersProfiles;
    	}
    
    @isTest static void testDeactivate() {
        //Get Analytics Cloud User as a test user by SOQL quey
        User aCIU = [SELECT Id, Name, ProfileId, Profile.Name, Email, LastLoginDate, CreatedDate FROM User WHERE FirstName = 'TestUser1' LIMIT 1];
        Test.setCreatedDate(aCIU.Id, Date.today().addDays(-63));
        update aCIU;
        
        Test.startTest();
        DeactivateBatchHelper.deactiveReminderDate = Date.today().addDays(-53);
        DeactivateInactiveUsers dActivate = new DeactivateInactiveUsers();
        database.executeBatch(dActivate);
        DeactivateBatchHelper.sendReminderEmail();
        Integer invocations = Limits.getEmailInvocations();
        Messaging.SingleEmailMessage remindEmail = new Messaging.SingleEmailMessage();
        remindEmail.setBccSender(false);
        remindEmail.setSaveAsActivity(false);
        remindEmail.setToAddresses(new String[] {aCIU.Email} );
        remindEmail.setSubject('Testing Attention Testing Subject');
		remindEmail.setPlainTextBody('testing email reminder body');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {remindEmail});
        Test.stopTest();
		}
    
}