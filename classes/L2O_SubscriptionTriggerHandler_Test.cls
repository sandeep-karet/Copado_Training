/**
* Company : PwC.
* @description : Test Class for L2O_SubscriptionTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 04/14/2023
* @author Vaishnavi H
*/

@istest
public class L2O_SubscriptionTriggerHandler_Test {
    
    /**
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    @testSetup
    static void testSetup() { 
        
        //Create test data
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList); 
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 

        //Create Contact roles
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);  

        //Create Quote  
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);   
        
        //Create Contract
        L2O_DataFactoryTest.createContract(oppList,QuoteList,accountList[0].id); 
        }
    
    /**
	* @name  testcatchException()
	* @description Tests L2O_SubscriptionTriggerHandler class catch block
	* @params  none
	*/
    @istest
    public static void testcatchException() {

        Test.startTest();

        //Calling trigger methods
        L2O_SubscriptionTriggerHandler helper = new L2O_SubscriptionTriggerHandler();
        helper.beforeInsert();
        helper.afterInsert();
        helper.beforeUpdate();
        helper.afterUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Class__c = 'L2O_SubscriptionTriggerHandler' LIMIT 1];
        System.assertEquals('L2O_SubscriptionTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }
    
    /**
    * @name  testsetGUID()
    * @description Tests Auto updated L2O_GUID__c field onrecord creation
    * @params  none
    */
    @istest
    public static void testsetGUID() {

        //query Contract
        Contract temCon= [SELECT Id FROM Contract WHERE AccountId !=NULL LIMIT 1];

        //Create Product
        List<Product2> prodList = L2O_DataFactoryTest.createProduct(); 
        SBQQ__Subscription__c tempSubcription = new SBQQ__Subscription__c(SBQQ__Contract__c = temCon.Id,
                                                                          SBQQ__Product__c = prodList[0].Id,
                                                                         SBQQ__Quantity__c = 2);
        Test.startTest();
        insert tempSubcription;
        Test.stopTest();

        SBQQ__Subscription__c fetchSubcription = [SELECT Id,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c != '' LIMIT 1];
        System.assertEquals(temCon.Id,fetchSubcription.SBQQ__Contract__c,'Creation Test Successful');
    }
    
    /**
    * @name  testUpdateContract()
    * @description Tests Auto updated L2O_GUID__c field onrecord creation
    * @params  none
    */
    @istest
    public static void testUpdateContract() {

        //query Contract
        Contract temCon= [SELECT Id,StartDate FROM Contract WHERE AccountId !=NULL LIMIT 1];

        //Create Product
        List<Product2> prodList = L2O_DataFactoryTest.createProduct(); 
        SBQQ__Subscription__c tempSubcription = new SBQQ__Subscription__c(SBQQ__Contract__c = temCon.Id,
                                                                          SBQQ__Product__c = prodList[0].Id,
                                                                         SBQQ__Quantity__c = 2);
        
        insert tempSubcription;
        SBQQ__Subscription__c revisedSub = new SBQQ__Subscription__c(SBQQ__Contract__c = temCon.Id,
                                                                          SBQQ__Product__c = prodList[0].Id,
                                                                         SBQQ__Quantity__c = 2);
        insert revisedSub;
        Test.startTest();

        //Modify the start date of the subscription
        temCon.StartDate = System.today()+7;
        tempSubcription.SBQQ__SubscriptionStartDate__c = System.today();
        tempSubcription.SBQQ__SubscriptionEndDate__c = System.today()+12;
        tempSubcription.SBQQ__RevisedSubscription__c = revisedSub.Id;
        update temCon;
        update tempSubcription;

        Test.stopTest();
        
        SBQQ__Subscription__c fetchSubcription = [SELECT Id,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c != '' LIMIT 1];
        System.assertEquals(temCon.Id,fetchSubcription.SBQQ__Contract__c,'Creation Test Successful');
    }


}