/**
* Company : PwC.
* @description : Test Class for L2O_OpportunityValidationRuleClass apex
* ************************************************************************************************************************************
* History : 
* @date 31/03/2022
* @author Neha Sharma
*/
@isTest
public class L2O_OpportunityValidationRuleClass_Test {


/**
* @name  testSetup 
* @description To create setup records for test class.
* @params  none
**/
@testSetup
static void testSetup() {
    
    List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);   
    L2O_DataFactoryTest.createContact(true,accountList); 
    L2O_DataFactoryTest.createUsers(true,1,'System Administrator');
    L2O_DataFactoryTest.createUsers(true,1,'Sales');
    L2O_DataFactoryTest.createUsers(true,1,'Contract / Legal');
    L2O_DataFactoryTest.createUsers(true,1,'Client Success');
    L2O_DataFactoryTest.createOpportunity(true,accountList);
    
    
    
}
/**
* @name  testOpportunityDefaultValues 
* @description To create setup records for test class.
* @params  none
**/
@isTest static void testOpportunityDefaultValues() {
    Test.startTest();
    
    List<Opportunity> opportunity =[SELECT Id,stageName FROM Opportunity WHERE Name != null LIMIT 1];
    system.assertEquals(opportunity[0].stageName,'Prospect','Stage is prospect');
    Test.stopTest();
}
/**
* @name  testOpportunityStageAccessDiscovery 
* @description test test discovery opportunity.
* @params  none
**/
@isTest static void testOpportunityStageAccessDiscovery() {
    Test.startTest();
    User salesExec=[SELECT Id,lastname,ManagerId FROM User 
                    WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Sales' LIMIT 1];
    
    system.runAs(salesExec){
        //Fetch Account
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1); 
        //Create Opportunity
        List<Opportunity> opportunitySalesExec = L2O_DataFactoryTest.createOpportunity(true,accountList);
        //Fetch Contact
        List<Contact> conList = L2O_DataFactoryTest.createContact(true,accountList); 
        Contact conTemp = conList[0];
         //Create OpportunityContactRole
        List<OpportunityContactRole> contactRoleList = L2O_DataFactoryTest.createContactRoles(true,opportunitySalesExec,conTemp.id); 
        ContactRoleList[0].Role = 'Broker';
        update ContactRoleList[0];
        opportunitySalesExec[0].stageName = 'Discovery';
        opportunitySalesExec[0].L2O_Benefit_Consultant_Involved_in_Deal__c = 'Consultant introduced us, but was not involved in selling';
        database.SaveResult[] results = Database.update(opportunitySalesExec, false); // false = allow partial failure, no exception
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            
            isProperErrorReceived |= error.getMessage().containsIgnoreCase(System.Label.L2O_DiscoveryStageErrorMessage_fromProspect);
        }
        System.assertEquals(false,isProperErrorReceived,'We expected a different error message for discovery stage');
        
        
    }
    Test.stopTest();
}
/**
* @name  testOpportunityStageAccessDiscovery 
* @description test test Proposal opportunity.
* @params  none
**/
@isTest static void testOpportunityStageAccessProposal() {
    Test.startTest();
    User salesExec=[SELECT Id,lastname,ManagerId FROM User 
                    WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Sales' LIMIT 1];

    
    system.runAs(salesExec){
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> opportunitySalesExec = L2O_DataFactoryTest.createOpportunity(true,accountList);
        
        opportunitySalesExec[0].stageName = 'Proposal';
        database.SaveResult[] results = Database.update(opportunitySalesExec, false); // false = allow partial failure, no exception
        System.assertNotEquals(true, results[0].isSuccess(),'Opportunity should not have saved for proposal');
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            isProperErrorReceived |= error.getMessage().containsIgnoreCase(System.Label.L2O_Proposal_validation_error_message);
        }
        System.assertEquals(true,isProperErrorReceived,'We expected a different error message for proposal stage');
        
        
    }
    Test.stopTest();
}
/**
* @name  testOpportunityStageAccessContracting 
* @description test test contracting opportunity.
* @params  none
**/
@isTest static void testOpportunityStageAccessContracting() {
    Test.startTest();
    User contractOps=[SELECT Id,lastname,ManagerId FROM User 
                    WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Contract / Legal' LIMIT 1];
    
    
    system.runAs(contractOps){
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);
        //List<Account> accountList = [SELECT id FROM Account WHERE Id !=null LIMIT 1] ;
        List<Opportunity> opportunityContractOps = L2O_DataFactoryTest.createOpportunity(true,accountList);
        
        opportunityContractOps[0].stageName = 'Contracting';
        database.SaveResult[] results = Database.update(opportunityContractOps, false); // false = allow partial failure, no exception
        System.assertNotEquals(true, results[0].isSuccess(),'Opportunity should not have saved for contracting stage');
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            
            isProperErrorReceived |= error.getMessage().containsIgnoreCase(System.Label.L2O_Contracting_validation_error_message);
        }
        System.assertEquals(true,isProperErrorReceived,'We expected a different error message for contracting stage');
        
        
    }
    Test.stopTest();
}
/**
* @name  testOpportunityStageAccessClosedWon 
* @description test test closed won opportunity.
* @params  none
**/   
@isTest static void testOpportunityStageAccessClosedWon() {
    Test.startTest();
    User contractOps=[SELECT Id,lastname,ManagerId FROM User 
                    WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Contract / Legal' LIMIT 1];

    
    system.runAs(contractOps){
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);
      //List<Account> accountList = [SELECT id FROM Account WHERE Id !=null LIMIT 1] ;
        List<Opportunity> opportunityContractOps = L2O_DataFactoryTest.createOpportunity(true,accountList);
        
        opportunityContractOps[0].stageName = 'Closed Won';
        database.SaveResult[] results = Database.update(opportunityContractOps, false); // false = allow partial failure, no exception
        System.assertNotEquals(false, results[0].isSuccess(),'Opportunity should not have saved for closd won stage');
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            
            isProperErrorReceived |= error.getMessage().containsIgnoreCase(System.Label.L2O_ClosedWon_validation_error_message);
        }
        System.assertEquals(false,isProperErrorReceived,'We expected a different error message for closed won');
        
        
    }
    Test.stopTest();
}
/**
* @name  testOpportunityStageAccessReviewNegotiation 
* @description test test review opportunity.
* @params  none
**/     
@isTest static void testOpportunityStageAccessReviewNegotiation() {
    Test.startTest();
    User contractOps=[SELECT Id,lastname,ManagerId FROM User 
                    WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Contract / Legal' LIMIT 1];

    
    system.runAs(contractOps){
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);
       //List<Account> accountList = [SELECT id FROM Account WHERE Id !=null LIMIT 1] ; 
        List<Opportunity> opportunityContractOps = L2O_DataFactoryTest.createOpportunity(true,accountList);
        
        opportunityContractOps[0].stageName = 'Review/Negotiation';
        database.SaveResult[] results = Database.update(opportunityContractOps, false); // false = allow partial failure, no exception
        System.assertNotEquals(true, results[0].isSuccess(),'Opportunity should not have saved for review negotiation');
        Boolean isProperErrorReceived = false;
        for(Database.Error error: results[0].getErrors()) {
            
            isProperErrorReceived |= error.getMessage().containsIgnoreCase(System.Label.L2O_Review_negotiation_validation_error_message);
        }
        System.assertEquals(true,isProperErrorReceived,'We expected a different error message for negotiation');
        
        
    }
    Test.stopTest();
}
    
    /**
* @name  testUserRoleofOppOwner 
* @description test updation of Channel and Sub-Channel Segment if User have specific Role.
* @params  none
**/
    @isTest static void testUserRoleofOppOwner(){
        Test.startTest();
        User userRec=[SELECT Id,lastname,ManagerId FROM User 
                      WHERE lastname LIKE 'TestDataFactory%' AND Profile.Name = 'Sales' LIMIT 1];
        List<UserRole> usrRoleList = [SELECT Id,Name FROM UserRole WHERE Name = 'Employer - SVP'];
        userRec.UserRoleId = usrRoleList[0].Id;
        update userRec;
        system.runAs(userRec){
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);
        List<Opportunity> opportunitys = L2O_DataFactoryTest.createOpportunity(true,accountList);
        system.assertEquals(opportunitys[0].L2O_Sub_Channel_Segment__c,'ASO','Sub-Channel mSegment is ASO');
        Test.stopTest();
        }
    }
    /**
* @name  testOppPrimaryQuoteStatus 
* @description test Opportunity primay Quote Status.
* @params  none
**/
    @isTest static void testOppPrimaryQuoteStatus(){
         Test.startTest();
    //Fetch Account
        List<Account> accountList = [select id from Account WHERE Name LIKE '%Test%' limit 1]; 
        //Fetch Contact
        Contact conTemp = [SELECT Id FROM Contact WHERE LastName != NULL LIMIT 1];
        //Create Opportunity
        List<Opportunity> opportunitySalesExec = L2O_DataFactoryTest.createOpportunity(true,accountList);
        opportunitySalesExec[0].stageName = 'Discovery';
        opportunitySalesExec[0].L2O_Benefit_Consultant_Involved_in_Deal__c = 'No Involvement';
            update opportunitySalesExec;
        L2O_DataFactoryTest.createContactRoles(true,opportunitySalesExec,conTemp.id); 
         List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,opportunitySalesExec); 
        quoteList[0].SBQQ__Primary__c = true;
        update quoteList;
        system.assertEquals(quoteList[0].SBQQ__Primary__c,true,'Quote is Primary');
         Test.stopTest();
 }
}