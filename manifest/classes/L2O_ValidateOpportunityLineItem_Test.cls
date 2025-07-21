/**
* Company : PwC.
* @description : Test Class for L2O_ValidateOpptyLineItemController apex controller
* ************************************************************************************************************************************
* History : 
* @date 19/07/2023
* @author Neha Sheikh
*/

@isTest
public class L2O_ValidateOpportunityLineItem_Test {
    
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
        L2O_DataFactoryTest.createOpportunity(true,accountList);
        L2O_DataFactoryTest.createProduct();
    }
    /**
	* @name  testDeleteOppLineItemAsSysAdmin()
	* @description Tests whether System Administrator can delete the OpportunityLineItem record.
	*/
    @isTest
    static void testDeleteOppLineItemAsSysAdmin() {
        // Create a test User with the required profile
        User sysAdminUser =[SELECT Id,lastname,ManagerId FROM User 
                            WHERE lastname LIKE 'TestDataFactory%' 
                            AND Profile.Name = 'System Administrator' LIMIT 1];
        List<Opportunity> lstOppty = [SELECT Id,Name,stageName FROM Opportunity WHERE Name != null];
        List<Product2> lstProduct = [SELECT Id,Name FROM Product2 WHERE Name != null];
        
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(
            OpportunityId = lstOppty[0].Id,
            Product2Id = lstProduct[0].Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert testOppLineItem;
        
        // Set the test context user
        System.runAs(sysAdminUser) {
            // Instantiate the standard controller for the test OpportunityLineItem
            ApexPages.StandardController controller = new ApexPages.StandardController(testOppLineItem);
            
            // Create an instance of the class to be tested
            L2O_ValidateOpptyLineItemController oppLineItemController = new L2O_ValidateOpptyLineItemController(controller);
            
            // Verify that the OpportunityLineItem is correctly retrieved in the constructor
            System.assertEquals(testOppLineItem.Id, oppLineItemController.oppLineItem.Id,'Successfully Matched the OpportunityLineItem Id');
            
            // Verify that the related Opportunity ID is correctly retrieved
            System.assertEquals(lstOppty[0].Id, oppLineItemController.relatedOpptyId,'Successfully Matched the related Opportunity Id');
            
            // Verify that the opportunity name and product name are correctly concatenated
            String expectedName = '"' + lstOppty[0].Name + ' ' + lstProduct[0].Name + '"';
            System.assertEquals(expectedName, oppLineItemController.oppProductName,'Successfully Matched the Opportunity + Product Name');
            
            // Verify that the deleteOppLineItem method works for System Administrator
            oppLineItemController.deleteOppLineItem();
            OpportunityLineItem testOppLineItm = [SELECT Id,IsDeleted FROM OpportunityLineItem WHERE Id = :testOppLineItem.Id ALL ROWS];
            System.assertEquals(testOppLineItm.IsDeleted, true,'Record deleted successfully');
            
        }
    }
     /**
	* @name  testHandleCatch()
	* @description To cover the catch block of L2O_ValidateOpptyLineItemController.getUserProfile()
	*/
    @isTest
    static void testHandleCatch() {
        Test.startTest();
        //To cover the catch block
        L2O_ValidateOpptyLineItemController.isErrorFlag = true;
        L2O_ValidateOpptyLineItemController.getUserProfile();
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ValidateOpptyLineItemController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('getUserProfile',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();  
    }
}