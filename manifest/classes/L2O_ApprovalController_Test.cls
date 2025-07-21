/**
* Company : PwC.
* @description : Test Class for L2O_ApprovalController apex
* ************************************************************************************************************************************
* History : 
* @date 14/04/2022
* @author Harshita Paliwal
*/
@isTest
public class L2O_ApprovalController_Test {
   
    /**  
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    @testSetup
    static void testSetup() {
       
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList); 
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        List<SBQQ__Quote__c> quoteList = L2O_DataFactoryTest.createQuote(true, oppList);
        L2O_DataFactoryTest.createApproval(true, quoteList);
        
    }
    /**
    * @name  testApprovalRecords
    * @description To test the approval records with status approved.
    * @params  none
    **/
    @isTest static void testApprovalRecords() {
		List<Account> accountRecord = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunityRecord = [SELECT Id,stageName FROM Opportunity WHERE AccountId =:accountRecord[0].Id LIMIT 1]; 
        List<SBQQ__Quote__c> quoteRecord = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:opportunityRecord[0].Id AND SBQQ__Account__c=:accountRecord[0].Id LIMIT 1];
        List<sbaa__Approval__c> approvalRecord = [SELECT Id FROM sbaa__Approval__c WHERE Quote__c =:quoteRecord[0].Id LIMIT 1];
        
        Test.startTest();
        //update Approval
  		approvalRecord[0].sbaa__Status__c = 'Approved';  
        update approvalRecord;
        
        List<sbaa__Approval__c> approvalRecordTest = [SELECT sbaa__Status__c FROM sbaa__Approval__c WHERE Quote__c=:quoteRecord[0].Id];
        
        L2O_ApprovalController approvalControllerTest = new L2O_ApprovalController();
        approvalControllerTest.quoteId = quoteRecord[0].Id;
        List<sbaa__Approval__c> approvalRecordList = approvalControllerTest.listofapprovalRecords;

        System.assertEquals(approvalRecordTest.get(0).sbaa__Status__c, approvalRecordList.get(0).sbaa__Status__c,'Approval record status is approved!');
        
        Test.stopTest();     
    }
    
    /**
    * @name  testRejectionRecords
    * @description To test the approval records with status rejected.
    * @params  none
    **/
    @isTest static void testRejectionRecords() {
        List<Account> account = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunity = [SELECT Id,stageName FROM Opportunity WHERE AccountId =:account[0].Id LIMIT 1]; 
        List<SBQQ__Quote__c> quoteRecord = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:opportunity[0].Id AND SBQQ__Account__c=:account[0].Id LIMIT 1];
        List<sbaa__Approval__c> rejectionRecord = [SELECT Id FROM sbaa__Approval__c WHERE Quote__c =:quoteRecord[0].Id LIMIT 1];
        
        Test.startTest();
        //update Approval
        rejectionRecord[0].sbaa__Status__c = 'Rejected';  
        update rejectionRecord;
        
        List<sbaa__Approval__c> rejectionRecordTest = [SELECT sbaa__Status__c FROM sbaa__Approval__c WHERE Quote__c=:quoteRecord[0].Id];
        
        L2O_ApprovalController approvalControllerTest = new L2O_ApprovalController();
        approvalControllerTest.quoteId = quoteRecord[0].Id;
        List<sbaa__Approval__c> rejectionRecordList = approvalControllerTest.listOfRejectionRecords;
        
		System.assertEquals(rejectionRecordTest.get(0).sbaa__Status__c, rejectionRecordList.get(0).sbaa__Status__c,'Rejected record status is rejected');
         
        Test.stopTest();     
    }
    
    /**
    * @name  testQuoteValues
    * @description To test the Quote default fields.
    * @params  none
    **/
    @isTest static void testQuoteValues() {
		List<Account> accountRecord = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunityRecord = [SELECT Id,stageName FROM Opportunity WHERE AccountId =:accountRecord[0].Id LIMIT 1]; 
        List<SBQQ__Quote__c> quoteRecord = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:opportunityRecord[0].Id AND SBQQ__Account__c=:accountRecord[0].Id LIMIT 1];
 
        Test.startTest();
  	
        L2O_ApprovalController approvalControllerTest = new L2O_ApprovalController();
        approvalControllerTest.quoteId = quoteRecord[0].Id;
        SBQQ__Quote__c quoteValue = approvalControllerTest.quoteValues;

        System.assertEquals(quoteValue.Id, quoteRecord[0].Id,'Quote Id for controller and database is same');
        
        Test.stopTest();     
    }
    
}