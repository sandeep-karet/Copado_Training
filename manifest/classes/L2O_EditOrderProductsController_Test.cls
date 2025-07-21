/**
* Company : PwC.
* @description : Test Class for L2O_EditOrderProductsController apex
* ************************************************************************************************************************************
* History : 
* @date 01/12/2022
* @author 
*/
@isTest
public class L2O_EditOrderProductsController_Test {
    /**
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    @testSetup static void testSetup() {

        //Create test data
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,2);
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);    
        L2O_DataFactoryTest.createContract(oppList,quoteList,accountList[0].id);
        L2O_DataFactoryTest.createContract(oppList,quoteList,accountList[1].id);
        
        //Activate the Contract
        List<Contract> contractList = [SELECT Id, Status FROM Contract WHERE ContractTerm = 12 LIMIT 1 ];
        contractList[0].Status = 'Activated';
        update contractList;
        
        //Fetch Standard Pricebook
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        //Create test Order
        Order ord = new Order();
        ord.ContractId=contractList[0].Id;
        ord.AccountId=accountList[0].Id;
        ord.EffectiveDate=date.today()+7;
        ord.Status='Draft';
        ord.OpportunityId=oppList[0].Id;
        ord.Pricebook2Id = standardPriceBookId;
        insert ord;
        
        //Create test Product
        Product2 pd = new Product2(Name='Prod A',isActive=true);
        pd.IsActive = true;
        insert pd;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=pd.Id, UnitPrice=99, isActive=true);
        insert pbe;
        
        //Create test Order Product
        OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=ord.Id, Quantity=1, UnitPrice=99);
		insert ordPd; 

    }
    
    /**
    * @name  testGetOrderProducts
    * @description To test method which returns orderItems for orderid
    * @params  none
    **/
    @isTest static void testGetOrderProducts() {
        
        Test.startTest();
        //query the test Order    
    	Order testOrder = [SELECT Id,Name FROM Order WHERE Id != null LIMIT 1]; 
        
        //To cover the block
        //Fetch order products of test order via class method
        L2O_EditOrderProductsController.isErrorFlag = false;
        List<OrderItem> lstOrderItems = L2O_EditOrderProductsController.getOrderProducts(testOrder.Id);
        
        Integer lstOrderItemSize = lstOrderItems.size();
      
        System.assertEquals(1,lstOrderItemSize,'Order Items found.'); 
        
        //To cover the catch block
        L2O_EditOrderProductsController.isErrorFlag = true;
        L2O_EditOrderProductsController.getOrderProducts(testOrder.Id);
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_EditOrderProductsController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('getOrderProducts',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();
    }
    
    /**
    * @name  testSaveOrderProducts
    * @description To test result of updating the Order Products
    * @params  none
    **/
    @isTest static void testSaveOrderProducts() {
        
        Test.startTest();
        //query the test Order    
    	Order testOrder = [SELECT Id,Name FROM Order WHERE Id != null LIMIT 1]; 
        //query the Order Items   
    	List<OrderItem> updateTestOrderItems = [SELECT Id,SBQQ__RequiredBy__c,SBQQ__Activated__c,L2O_Hold_Order__c,
                                         		L2O_Send_RMA__c,L2O_PO_Number__c,
                                         		SBQQ__ShippingAccount__c,Shipping_Contact__c
                                        		FROM OrderItem
                                        		WHERE OrderId =:testOrder.Id]; 
        

        //Save the Order Products via the class method
        L2O_EditOrderProductsController.isErrorFlag = false;
        String response1 = L2O_EditOrderProductsController.saveOrderProducts(updateTestOrderItems);
        System.assertEquals('Success',response1,'Order Items updated.'); 

        //query the Order Items   
    	List<OrderItem> updateNoOrderItems = [SELECT Id,SBQQ__RequiredBy__c,SBQQ__Activated__c,L2O_Hold_Order__c,
                                         		L2O_Send_RMA__c,L2O_PO_Number__c,
                                         		SBQQ__ShippingAccount__c,Shipping_Contact__c
                                        		FROM OrderItem
                                        		WHERE SBQQ__Activated__c =true]; 
        
        L2O_EditOrderProductsController.isErrorFlag = false;
        String response2 = L2O_EditOrderProductsController.saveOrderProducts(updateNoOrderItems);
        System.assertEquals('No records to update!',response2,'No Order Items to be updated.'); 
        
        //To cover the catch block
        L2O_EditOrderProductsController.isErrorFlag = true;
        L2O_EditOrderProductsController.saveOrderProducts(updateTestOrderItems);
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_EditOrderProductsController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('saveOrderProducts',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();
    }

}