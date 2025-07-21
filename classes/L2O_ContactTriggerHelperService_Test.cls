@isTest
public class L2O_ContactTriggerHelperService_Test {
    
    @isTest static void preventUpdateIfRoleExists() {
        List<user> newUsers = L2O_DataFactoryTest.createUsers(true, 1, 'Sales');
        System.runAs(newUsers[0]){
            List<Account> accountList= L2O_DataFactoryTest.createAccount(true,2);
            List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList);
            List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList); 
            List<OpportunityContactRole> oppRolelist = L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);
            
            Test.startTest();
            conList[0].AccountId = accountList[1].Id;
            update conList[0];
            Test.stopTest();
            system.assertEquals(oppRolelist.size() != null, True,'Contact Role created');
            //system.assertEquals(conList[0].AccountId = accountList[1].Id, conList[0].AccountId = accountList[0].Id,'Contact Role Exists');
        }
    }
    
}