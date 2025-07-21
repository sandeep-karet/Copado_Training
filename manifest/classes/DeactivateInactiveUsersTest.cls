@isTest
public class DeactivateInactiveUsersTest {
    @TestSetup
    private static void testusersetup(){
        List<User> testusers = new List<User>();
        for(Integer i=0;i<10;i++) {
            testusers.add(new User(Alias = 'TUsr' + i,
                                   FirstName = 'TestUser' + i,
                                   LastName = 'TestUser' + i,
                                   Email = 'TestUser' + i + '@teladochealth.testing.com',
                                   EmailEncodingKey = 'UTF-8',
                                   LanguageLocaleKey = 'en_US',
                                   LocaleSidKey = 'en_US',
                                   ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                                   TimeZoneSidKey = 'America/Chicago',
                                   Username = 'TestUser' + i + '@teladochealth.com',
                                   IsActive = true));
		}
        insert testusers;
        Datetime createsixty = Datetime.now().addDays(-60);
        Test.setCreatedDate(testusers[0].Id, createsixty);
        
	}
    @isTest
    static void executeTest() {
		//User iUT  = [SELECT Id, Name, ProfileId, Profile.Name, Email, LastLoginDate, CreatedDate FROM User WHERE FirstName = 'TestUser1' LIMIT 1];
        //Test.setCreatedDate(iUT.Id, Date.today().addDays(-35));
        //update iUT;
        
        Test.startTest();
        DeactivateInactiveUsers userbatch = new DeactivateInactiveUsers();
        userbatch.query = 'SELECT Id, Name, IsActive FROM User WHERE IsActive = True AND (LastLoginDate < LAST_N_DAYS:35 OR (LastLoginDate = NULL AND CreateDate < LAST_N_DAYS:60))';
        Database.executeBatch(userbatch, 1);
        Test.stopTest();
        
    }
    
    @isTest 
    static void upsertXTest() {
        Profile usrXstd = [SELECT Id, Name FROM Profile WHERE Name = 'Read Only'];
        Test.startTest();
        User nXuser = new User(Alias = 'tstXusr',
                                   Email = 'tst.Xusr@teladochealth.tddev.com',
                                   EmailEncodingKey = 'UTF-8',
                                   LastName = 'UserX',
                                   LanguageLocaleKey = 'en_US',
                                   LocaleSidKey = 'en_US',
                                   ProfileId = usrXstd.Id,
                                   TimeZoneSidKey = 'America/Chicago',
                                   Username = 'tst.Xusr@teladochealth.tddev.com',
                                   IsActive = true);
        insert nXuser;
        DeactivateInactiveUsers dXusers = new DeactivateInactiveUsers();
        Database.BatchableContext bc;
        dXusers.start(bc);
        List<User> uXser = new List<User>();
        uXser.add(nXuser);
        dXusers.execute(bc,uXser);
        Test.StopTest();
        
    }
    
    
    @isTest
    static void testSchedule() {
        Test.StartTest();
        DeactivateInactiveUsers testschedule = new DeactivateInactiveUsers();
        String cron = '0 0 3 1/1 * ? *';
        system.schedule('Test Status Check', cron, testschedule);
        Test.StopTest();
    }
}