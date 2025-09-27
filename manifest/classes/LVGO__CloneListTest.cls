/*
    CloneListTest.cls
    
    Last Modified March 28 2019
    
    Test Class for CloneListUtil.cls and ChildRelationship.cls
*/
@isTest
public with sharing class CloneListTest {

    static testmethod void testCloneListControllerOne() {
        
        List<Account__c> allAccounts = new List<Account__c>();
        
        //Create client Account
        Account__c clientAccount = new Account__c();
        clientAccount.Name = 'Client Account';
        
        //Create partner Accounts
        Account__c partnerAccountOne = new Account__c();
        partnerAccountOne.Name = 'Partner Account 1';
        
        Account__c partnerAccountTwo = new Account__c();
        partnerAccountTwo.Name = 'Partner Account 2';
        
        allAccounts.add(clientAccount);
        allAccounts.add(partnerAccountOne);
        allAccounts.add(partnerAccountTwo);
        
        insert allAccounts;
        
        Id clientAccountId = [SELECT Id from Account__c WHERE Id = :clientAccount.Id].Id;
        
        //Create parent Client Overview record (this will be deep cloned)
        Contract__c testClientOverview = new Contract__c();
        testClientOverview.Account__c = clientAccountId;
        testClientOverview.name = 'Client Overview Record';
        testClientOverview.RecordTypeId = System.Label.Program_Agreement_Record_Type;
            
        insert testClientOverview;
        
        Id clientOverviewId = [SELECT ID FROM Contract__c WHERE Id = :testClientOverview.id].Id;
        
        List<Contract__c> programOverviews = new List<Contract__c>();
        
        //Insert related Program Overview Records
        Contract__c testProgramOverviewOne = new Contract__c();
        testProgramOverviewOne.name = 'Program Overview Record 1';
        testProgramOverviewOne.Account__c = clientAccountId;
        testProgramOverviewOne.Program_Name__c = 'Diabetes';
        testProgramOverviewOne.Client_Overview__c = clientOverviewId;
        testProgramOverviewOne.RecordTypeId = System.Label.Program_Schedule_Record_Type;
        
        Contract__c testProgramOverviewTwo = new Contract__c();
        testProgramOverviewTwo.name = 'Client Overview Record';
        testProgramOverviewTwo.Account__c = clientAccountId;
        testProgramOverviewTwo.Program_Name__c = 'Hypertension';
        testProgramOverviewTwo.Client_Overview__c = clientOverviewId;
        testProgramOverviewTwo.RecordTypeId = System.Label.Program_Schedule_Record_Type;

        programOverviews.add(testProgramOverviewOne);
        programOverviews.add(testProgramOverviewTwo);
        
        insert programOverviews;
        
        //Create Contract-level Partnership Relationship records
        List<Relationship__c> allRelationships = new List<Relationship__c>();
        
        Relationship__c testRelationshipOne = new Relationship__c();
        //testRelationshipOne.RelationshipType__C = 'Activity Tracking Devices'; //Relationship Type should be "Contract Path"
        testRelationshipOne.RelationshipType__C = 'Contract Path';
        testRelationshipOne.Master_Contract__c = clientOverviewId;
        testRelationshipOne.Partner_Contract_Partnership__c = [select Id FROM Account__c WHERE Id = :partnerAccountOne.Id].Id;
        testRelationshipOne.Contract_Partnership__c = clientOverviewId;
        allRelationships.add(testRelationshipOne);       
        
        Relationship__c testRelationshipTwo = new Relationship__c();
        //testRelationshipTwo.RelationshipType__C = 'Asthma'; //Relationship Type should be "Billing Partner"
        testRelationshipTwo.RelationshipType__C = 'Billing Partner';
        testRelationshipTwo.Master_Contract__c = clientOverviewId;
        testRelationshipTwo.Partner_Contract_Partnership__c = [select Id FROM Account__c WHERE Id = :partnerAccountTwo.Id].Id;
        testRelationshipTwo.Contract_Partnership__c = clientOverviewId;
        allRelationships.add(testRelationshipTwo);
        
        insert allRelationships;

        Test.startTest();
        List<List<String>> testSourceInformation = new List<List<String>>();
        //Source Object Name, Child Object Name, Parent Id
        List<String> allInfo = new List<String>{'Contract__c', 'Contract__c, Relationship__c', string.valueof(clientOverviewId)};
        
            testSourceInformation.add(allInfo);
        
        List<String> clonedParentId = clientOverviewServices.copyChildRecords(testSourceInformation);
        Test.stopTest();
        Contract__c clonedParentRecord = [SELECT Name, Is_Cloned__c FROM Contract__c WHERE Id = :Id.valueOf(clonedParentId.get(0))];
        
        System.assertEquals(TRUE, clonedParentRecord.Is_Cloned__c);
        System.assertEquals(2, [SELECT Id FROM Contract__c WHERE Client_Overview__c = :Id.valueOf(clonedParentId.get(0))].size());
        System.assertEquals(2, [SELECT Id FROM Relationship__c WHERE RelationshipType__c = 'Contract Path'].size());
        System.assertEquals(2, [SELECT Id FROM Relationship__c WHERE RelationshipType__c = 'Billing Partner'].size());
        //System.assertNotEquals(null, clonedParentId);
        //System.debug(System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
        
    }       
}