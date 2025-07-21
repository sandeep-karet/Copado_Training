/**
* Company : PwC.
* @description : Test Class for L2O_UserTriggerHandler_Test apex
* ************************************************************************************************************************************
* History : 
* @date 10/05/2022
* @author Aviral Dhodi
*/

@istest
public class L2O_AccountTriggerHandler_Test {
    @testSetup
    /**
* @name  testSetup()
* @description Sets up Test Data for the Class
* @params  none
*/ 
    static void testSetup() {
        //Creating Test user
        Id userProfileId = UserInfo.getProfileId();
		Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId LIMIT 1];
        List<User> testUsersList = L2O_DataFactoryTest.createUsers(true, 1, userProfile.Name);
     
        //Creating Account Records
        list<Account> accList= L2O_DataFactoryTest.createAccount(true,2);
        
        //creating account team member records
        List<AccountTeamMember> atm_insert = new List<AccountTeamMember>();
        AccountTeamMember teamMember1 = new AccountTeamMember(
            UserId = testUsersList[0].Id,
            AccountId = accList[0].Id,
            TeamMemberRole='Broker ASO Partner',
            OpportunityAccessLevel = 'None',
            CaseAccessLevel = 'None',
            AccountAccessLevel = 'Read'
        );
        
        AccountTeamMember teamMember2 = new AccountTeamMember(
            UserId =  UserInfo.getUserId(),
            AccountId = accList[0].Id,
            TeamMemberRole='Sales Rep',
            OpportunityAccessLevel = 'None',
            CaseAccessLevel = 'None',
            AccountAccessLevel = 'Read'
        );
        atm_insert.add(teamMember1);
        atm_insert.add(teamMember2);
        insert atm_insert;
        
        accList[1].L2O_GUID__c = 'Abc';
        update accList[1];
        accList[0].Name = 'Test_Customer2';
        accList[0].OwnerId=testUsersList[0].Id;
        update accList[0];
    }
    /**
* @name  recordCreate()
* @description Tests whether GUID is valid for new Account Record
* @params  none
*/
    @istest
    public static void recordCreate() {
        Test.startTest();
        Account testAccount = [SELECT Id, L2O_GUID__c FROM Account WHERE Name =: 'Test_Customer2'];
        Test.stopTest();
        System.assertEquals(True,L2O_GlobalIdUtils.isGuid(testAccount.L2O_GUID__c),'Creation Test Successful');   
    }
    
    /**
* @name  recordUpdate()
* @description Tests whether GUID is valid for updated Account Record
* @params  none
*/
    @istest
    public static void recordUpdate() {
        Test.startTest();
        Account testAccount = [SELECT Id, L2O_GUID__c FROM Account WHERE Name =: 'Test_Customer1'];
        Test.stopTest();
        System.assertEquals(True,L2O_GlobalIdUtils.isGuid(testAccount.L2O_GUID__c),'Updation Test Successful');   
    }
    
    /**
* @name  errorTest()
* @description Tests whether GUID is valid for new Account Record
* @params  none
*/
    @istest
    public static void errorTest() {
        List <Account> testAccountList = [SELECT Id, L2O_GUID__c FROM Account WHERE Name =: 'Test_Customer1'];
        testAccountList[0].L2O_Account_Status__c = 'Client';
        Test.startTest();
        database.SaveResult[] results = Database.update(testAccountList, false);
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            isProperErrorReceived |= error.getMessage().containsIgnoreCase('Account Should have at least one Closed Won Opportunity to move Account Status to "Client"');
        }
        System.assertEquals(false,isProperErrorReceived,'We expected a different error message');
        Test.stopTest();  
    }
    
  /*****************************************************
    /* Method Name        : keepAccountTeams
    /* CreatedDate   	  : 29-12-2023
    /* Author             : Preethi
    /* Method Description : To test the function L2O_AccountTriggerHelperService.keepAccountTeamMembers()
    /* Jira Ticket		  : SCDEV-4598
  ******************************************************/
    @istest
    public static void keepAccountTeams() 
    {
        Test.startTest();
        Account testAccount = [SELECT Id,Name,(Select UserId,AccountId from AccountTeamMembers)  FROM Account WHERE Name =: 'Test_Customer2'];
        Test.stopTest();
        System.assertEquals(2,testAccount.AccountTeamMembers.size(),'Account team members are getting deleted');   
    }
    /**
* @name  testcatchException()
* @description Tests L2O_AccountTriggerHandler class catch block
* @params  none
*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_AccountTriggerHandler helper = new L2O_AccountTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        helper.afterInsert();
        helper.afterUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Name != '' LIMIT 1];
        System.assertEquals('L2O_AccountTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }
}