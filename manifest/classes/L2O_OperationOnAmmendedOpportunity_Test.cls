/**
* Company : PwC.
* @description : Test Class for L2O_OperationOnAmmendedOpportunity apex
* ************************************************************************************************************************************
* History : 
* @date 12/04/2022
* @author Neha Sharma
*/
@isTest
public class L2O_OperationOnAmmendedOpportunity_Test {
    /**
* @name  testSetup 
* @description To create setup records for test class.
* @params  none
**/
    @testSetup
    static void testSetup() {
        // create test data
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList);  
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true, accountList);
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);
        Contract contract = new Contract();
        contract.AccountId = accountList[0].id;
        contract.SBQQ__Opportunity__c = oppList[0].id;
        contract.StartDate = System.today();
        contract.Status = 'Draft';
        contract.ContractTerm = 36;
        insert contract;
        
    }
    
    
    /**
* @name  testQuoteDefaultValues
* @description To test the Quote default fields with automated values.
* @params  none
**/
    @isTest static void testAmendedOpportunityContactRole() {
        Test.startTest();
        List<Contract> contract = [SELECT Id,AccountId FROM Contract WHERE ID != null LIMIT 1];
        //create Opportunity
        Opportunity opp = new Opportunity();
        opp.name = 'testing contact role amend';
        opp.AccountId = contract[0].AccountId;
        opp.StageName = 'Prospect';
        opp.CloseDate = system.today();
        opp.SBQQ__AmendedContract__c = contract[0].id;
        opp.Type = 'Existing Business';
        opp.L2O_Initial_of_Lives__c=2300;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.L2O_Contract_Path__c = 'Direct';
        opp.L2O_Contract_Path_Sub_type__c = 'None';
        opp.L2O_Channel_Segment__c ='Employer';
        opp.L2O_Subtype__c = 'Change Order';
        insert opp;
        System.assert(opp.id != null,'pass');
    }       
/**
* @name  testQuoteDefaultValues
* @description To test the Quote default fields with automated values.
* @params  none
**/
    @isTest static void testRenewOpportunityContactRole() {
        Test.startTest();
        List<Contract> contract = [SELECT Id,AccountId FROM Contract WHERE ID != null LIMIT 1];
        //create Opportunity
        Opportunity opp = new Opportunity();
        opp.name = 'testing contact role amend';
        opp.AccountId = contract[0].AccountId;
        opp.StageName = 'Prospect';
        opp.CloseDate = system.today();
        opp.SBQQ__RenewedContract__c = contract[0].id;
        opp.Type = 'Existing Business';
        opp.L2O_Initial_of_Lives__c=2300;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.L2O_Contract_Path__c = 'Direct';
        opp.L2O_Contract_Path_Sub_type__c = 'None';
        opp.L2O_Channel_Segment__c ='Employer';
        opp.L2O_Subtype__c = 'Change Order';
        insert opp;
        System.assert(opp.id != null,'pass');
       
    }
}