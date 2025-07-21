/**
* Company : PwC.
* @description : Test Class for L2O_RenewalQuote apex
* ************************************************************************************************************************************
* History : 
* @date 29/04/2022
* @author Harshita Paliwal
*/
@isTest
public class L2O_RenewalQuote_Test {
    
    /**
* @name  testSetup 
* @description To create setup records for test class.
* @params  none
**/
    @testSetup
    static void testSetup() {
        //create test data
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList); 
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        L2O_DataFactoryTest.createQuote(true, oppList);
        
    }
    
    /**
* @name  testUpdateRenewalQuoted
* @description To test the RenewalQuoted lightning component.
* @params  none
**/
    @isTest static void testUpdateRenewalQuoted() {
        
        Test.startTest();
        
        List<Account> lstAccountRecord = [SELECT Id, Name FROM Account WHERE Name != null LIMIT 1];
        
        List<Opportunity> lstOpportunityRecord = [SELECT Id, AccountId, CloseDate, L2O_Contract_Path__c,L2O_Channel_Segment__c,
                                                  L2O_Sub_Channel_Segment__c, Pricebook2Id FROM Opportunity 
                                                  WHERE AccountId =:lstAccountRecord[0].Id];
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__PriceBook__c FROM SBQQ__Quote__c 
                                          WHERE SBQQ__Opportunity2__c =:lstOpportunityRecord[0].Id LIMIT 1];
        
        
        //create Contract
        Contract contract = new Contract(Status = 'Draft', StartDate = lstOpportunityRecord[0].CloseDate, AccountId = lstOpportunityRecord[0].AccountId,
                                         ContractTerm = 12, SBQQ__Quote__c =  quoteList[0].Id, SBQQ__Opportunity__c = lstOpportunityRecord[0].Id, 
                                         SBQQ__RenewalQuoted__c = true,
                                         L2O_Contract_Path__c = 'Direct',
                                         L2O_Channel_Segment__c ='Employer',
                                         L2O_Sub_Channel_Segment__c='ASO');
        insert contract;
        
        Opportunity opportunityTest = [SELECT Id,SBQQ__RenewedContract__c,Name FROM Opportunity WHERE AccountId =:lstAccountRecord[0].Id AND SBQQ__RenewedContract__c != null LIMIT 1]; 
        
        L2O_RenewalQuote.updateRenewalQuoted(opportunityTest.Id);
		// case testing        
        System.assertEquals(opportunityTest.SBQQ__RenewedContract__c, contract.Id ,'Renewal Contract is updated!');
        
        Test.stopTest();     
    }
    
    /**
* @name  testUpdateRenewalOpportunity
* @description To test the RenewalOpportunity without RenewalQuote lightning component.
* @params  none
**/
    @isTest static void testUpdateRenewalOpportunity() {
        
        
        List<Account> lstAccountRecord = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        
        List<Opportunity> lstOpportunityRecord = [SELECT Id, AccountId, CloseDate FROM Opportunity WHERE AccountId =:lstAccountRecord[0].Id LIMIT 1]; 
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c 
                                          WHERE SBQQ__Opportunity2__c =:lstOpportunityRecord[0].Id AND SBQQ__Account__c =:lstAccountRecord[0].Id LIMIT 1];
        
        //create Contract
        Contract contract = new Contract(Status = 'Draft',StartDate = lstOpportunityRecord[0].CloseDate,AccountId = lstOpportunityRecord[0].AccountId,
                                         ContractTerm = 12, SBQQ__Quote__c =  quoteList[0].Id, SBQQ__Opportunity__c = lstOpportunityRecord[0].Id, 
                                         SBQQ__RenewalForecast__c = true, SBQQ__RenewalQuoted__c = false,
                                         L2O_Contract_Path__c = 'Direct',
                                         L2O_Channel_Segment__c ='Employer',
                                         L2O_Sub_Channel_Segment__c='ASO');
        insert contract; 
        
        Opportunity opportunityTest = [SELECT Id,SBQQ__RenewedContract__c FROM Opportunity WHERE AccountId =:lstAccountRecord[0].Id And SBQQ__RenewedContract__c != null LIMIT 1]; 
        Test.startTest();
        L2O_RenewalQuote.updateRenewalQuoted(opportunityTest.Id);
        // Case Testing
        System.assertEquals(opportunityTest.SBQQ__RenewedContract__c, contract.Id ,'Renewal Contract is updated!');
        
        Test.stopTest();     
    }
}