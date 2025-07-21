/**
* Company : PwC.
* @description : Test Class for L2O_AccountClientStatusMonthsBatch_Test Class
* ************************************************************************************************************************************
* History : 
* @date 30/09/2022
* @author Neha Sharma
*/
@isTest
public class L2O_AccountClientStatusMonthsBatch_Test {
    public static Id pricebookId = Test.getStandardPricebookId();
   
    /**
* @name  testSetup()
* @description Sets up Test Data for the Class
* @params  none
*/ 
    @testSetup static void testSetup() {
        //Create Account
        List<Account> accountList = L2O_DataFactoryTest.createAccount(true,1);
        accountList[0].L2O_Business_Region__c = 'USA';
        update accountList;
        //Create Contact
        List<Contact> contactList= L2O_DataFactoryTest.createContact(true,accountList);
        Date dateToday = system.today();
        //creating Opportunity 
        List<Opportunity> opportunityList = new List<Opportunity>();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        // Update Pricebook
        update standardPricebook;
        for(Integer obj = 0; obj < accountList.size(); obj++){
            opportunityList.add(new Opportunity(Name='Test_Opportunity'+obj,Type='New Business',StageName='Prospect',
                                                CloseDate=dateToday.addMonths(8),AccountId=accountList[obj].Id, Pricebook2Id = standardPricebook.Id,L2O_Subtype__c = 'Initial Sale',
                                                L2O_Contract_Path__c = 'Direct', 
                                                L2O_Channel_Segment__c ='Employer',
                                                L2O_Contract_Path_Sub_type__c = 'None',
                                                L2O_Initial_of_Lives__c=2300,
                                                L2O_Sub_Channel_Segment__c='Downmarket',
                                                L2O_Sub_Type_Detail__c = 'Reporting Purposes Only'));                
        }
        // Create Opportunity
        insert opportunityList;
        //Create Contact Role   
        List<OpportunityContactRole> contactRoleList = L2O_DataFactoryTest.createContactRoles(true,opportunityList,contactList[0].Id);
        update contactRoleList[0];
        //creating Quote Record
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(Integer obj = 0; obj < opportunityList.size(); obj++){
            quoteList.add(new SBQQ__Quote__c(SBQQ__Primary__c= true,ApprovalStatus__c='Approved',SBQQ__Status__c='Accepted',SBQQ__Opportunity2__c=opportunityList[obj].Id, 
                                             SBQQ__Account__c=opportunityList[obj].AccountId));                
        }
        insert quoteList;
        //creating Contract Record
        List<Contract> contractList = new List<Contract>();
        for(Integer obj = 0; obj < accountList.size(); obj++){
            ContractList.add(new Contract(Status='Draft',StartDate=dateToday.addMonths(-8),ContractTerm=1,AccountId=accountList[obj].Id,SBQQ__Quote__c=quoteList[obj].Id));                
        }
        insert contractList;
        //Updates
        for(Integer obj = 0; obj < accountList.size(); obj++){
            opportunityList[obj].SBQQ__PrimaryQuote__c=quoteList[obj].Id;
            opportunityList[obj].StageName='Closed Won';
            accountList[obj].L2O_Account_Status__c='Client';
        }
        update opportunityList;
        update accountList;
        for(Integer obj = 0; obj < accountList.size(); obj++){
          
            accountList[obj].L2O_Client_status_date__c  = dateToday.addMonths(-8);
        }
        update accountList;
    }
    
    /**
* @name  test1()
* @description Tests whether Status field on Account is changed
* @params  none
*/ 
    @IsTest static void test1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new L2O_RunTerritoryCalloutMock_Test());
    
        L2O_AccountClientStatusMonthsScheduler batch = new L2O_AccountClientStatusMonthsScheduler() ;
        batch.execute(null);
        Test.stopTest();
        Account testAccount = [SELECT Id,L2O_Account_Status__c,L2O_6_Month_passed_after_client_status__c from Account WHERE Name='Test_Customer0'];
        // Case Testing
        System.assertEquals(true,testAccount.L2O_6_Month_passed_after_client_status__c,'Status Verified');
    }
}