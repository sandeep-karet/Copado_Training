@isTest
public class FreezeUsersTest {
    static testMethod void unitTest() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;
        User tuser = new User(  firstname = 'Test FirstName',
                              lastName = 'Test LastName ',
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1].Id,
                              UserRoleId = ur.Id,
                              isActive = true);
        insert tuser;
        Test.startTest();
        FreezeUsers.Freeze();
        FreezeUsers.FreezeNonApi();
        FreezeUsers.Thaw();
        Test.stopTest();
    }
}