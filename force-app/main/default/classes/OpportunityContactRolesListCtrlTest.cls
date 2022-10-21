@isTest
public class OpportunityContactRolesListCtrlTest {
    @TestSetup
    static void setupData() {
        Account__c testAccount = TestFactory.createClientAccount();
        insert testAccount;

        List<Opportunity__c> oList = new List<Opportunity__c>();
        Opportunity__c opp1 = TestFactory.createOpportunity();
        opp1.Account__c = testAccount.Id;
        opp1.Name += ' 1';
        oList.add(opp1);

        Opportunity__c opp2 = TestFactory.createOpportunity();
        opp2.Account__c = testAccount.Id;
        opp2.Name += ' 2';
        oList.add(opp2);
        insert oList;

        List<Contact__c> cList = new List<Contact__c>();
        Contact__c c1 = new Contact__c();
        c1.FirstName__c = 'A';
        c1.LastName__c = 'Test1';
        cList.add(c1);

        Contact__c c2 = new Contact__c();
        c2.FirstName__c = 'B';
        c2.LastName__c = 'Test2';
        cList.add(c2);
        insert cList;

        List<OpportunityContactRole> oppContactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole oppContactRole1 = new OpportunityContactRole();
        oppContactRole1.ContactId = c1.Id;
        oppContactRole1.OpportunityId = opp1.Id;
        oppContactRole1.Role = 'Business Decision Maker';
        oppContactRolesList.add(oppContactRole1);

        OpportunityContactRole oppContactRole2 = new OpportunityContactRole();
        oppContactRole2.ContactId = c2.Id;
        oppContactRole2.OpportunityId = opp1.Id;
        oppContactRole2.Role = 'Sales Lead / POC';
        oppContactRolesList.add(oppContactRole2);

        OpportunityContactRole oppContactRole3 = new OpportunityContactRole();
        oppContactRole3.ContactId = c2.Id;
        oppContactRole3.OpportunityId = opp2.Id;
        oppContactRole3.Role = 'Billing POC';
        oppContactRolesList.add(oppContactRole3);
        insert oppContactRolesList;
    }

    @isTest
    static void testGetOpportunityContactRolesWithContactsAssociatedToOpp() {
        Opportunity__c o = [SELECT Id, Name FROM Opportunity__c WHERE Name = 'Test Opportunity 1'];

        Test.startTest();

        List<OpportunityContactRole> oppContactRoles = OpportunityContactRolesListCtrl.getOpportunityContactRoles(o.Id);

        Test.stopTest();

        //Contacts with the desired Role are associated with this Opp, so result should be non-zero
        System.assertNotEquals(0, oppContactRoles.size());
        //2 were inserted, result should be 2
        System.assertEquals(2, oppContactRoles.size());
    }

    @isTest
    static void testGetOpportunityContactRolesWithNoContactsWithDesiredRoleAssociatedToOpp() {

       Opportunity__c o = [SELECT Id, Name FROM Opportunity__c WHERE Name = 'Test Opportunity 2'];

        Test.startTest();

        List<OpportunityContactRole> oppContactRoles = OpportunityContactRolesListCtrl.getOpportunityContactRoles(o.Id);

        Test.stopTest();

        //No Contacts with Role of 'Business Decision Maker' or 'Sales Lead / POC' are associated, so result should be 0
        System.assertEquals(0, oppContactRoles.size());
    }
}