/**
* Company : PwC.
* @description : Test Class for L2O_OrderItemTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 20/07/2023
* @author Neha Sheikh
*/

@istest
public class L2O_OrderItemTriggerHandler_Test {
    
    @testSetup
    /**
    * @name  testSetup()
    * @description Sets up Test Data for the Class
    * @params  none
    */ 
    static void testSetup() {
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,2);
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);    
        L2O_DataFactoryTest.createContract(oppList,quoteList,accountList[0].id);
        L2O_DataFactoryTest.createContract(oppList,quoteList,accountList[1].id);
        
        List<Contract> contractList = [SELECT Id, Status FROM Contract WHERE ContractTerm = 12 LIMIT 1 ];
        contractList[0].Status = 'Activated';
        update contractList;
    
        Id standardPriceBookId = Test.getStandardPricebookId();
        Order ord = new Order();
        ord.ContractId=contractList[0].Id;
        ord.AccountId=accountList[0].Id;
        ord.EffectiveDate=date.today()+7;
        ord.Status='Draft';
        ord.OpportunityId=oppList[0].Id;
        ord.Pricebook2Id = standardPriceBookId;
        insert ord;
        
        
        Product2 pd = new Product2(Name='Pord A',isActive=true);
        pd.IsActive = true;
        insert pd;
        
        //PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
		//Id standardPriceBookId = pb2Standard.Id;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=pd.Id, UnitPrice=99, isActive=true);
        insert pbe;
        
        Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :pd.Id];
        System.assertEquals(pd.Name,p2ex.Name,'Pord A');
        
        OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=ord.Id, Quantity=1, UnitPrice=99);
		insert ordPd; 
       
    }
    
    
    /**
	* @name  testcatchException()
	* @description Tests L2O_OrderItemTriggerHandler class catch block
	* @params  none
	*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_OrderItemTriggerHandler helper = new L2O_OrderItemTriggerHandler();
        helper.beforeInsert();
        helper.beforeUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Class__c = 'L2O_OrderItemTriggerHandler' LIMIT 1];
        // Case testing
        System.assertEquals('L2O_OrderItemTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }

}