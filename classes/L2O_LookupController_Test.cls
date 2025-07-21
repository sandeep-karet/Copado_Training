/**
* Company : PwC.
* @description : Test Class for L2O_LookupController apex
* ************************************************************************************************************************************
* History : 
* @date 01/12/2022
* @author Vaishnavi H
*/
@isTest
public class L2O_LookupController_Test {
    
    /**
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    @testSetup
    static void testSetup() {
        
        //Create Test account, opp & contact
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList); 
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        for(Contact con: conList){
            con.AccountId = accountList[0].Id;
        }
        update conList;

        //Create test contactroles
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        List<Product2> productList = L2O_DataFactoryTest.createProduct();
        List<SBQQ__Quote__c> quoteList = L2O_DataFactoryTest.createQuote(true, oppList);
        List<Asset> assetList = L2O_DataFactoryTest.createAsset(true,accountList[0].Id,productList);

        //Create QuoteLines
        L2O_DataFactoryTest.createQuoteLines(true,quoteList,productList,assetList);
        
    }
    
    /**
    * @name  testLookUp
    * @description To test the list valid search records
    * @params  none
    **/
    
    @isTest static void testLookUp() {

        Test.startTest();

        //query the test data
        List<Account> lstAccountRecord = [SELECT Id,Name FROM Account WHERE Name != null LIMIT 1];
        List<Contact> lstContactRecord = [SELECT Id,LastName,AccountId FROM Contact WHERE AccountId =:lstAccountRecord[0].Id LIMIT 1];
        List<Opportunity> lstOpportunityRecord = [SELECT Id,Name,AccountId FROM Opportunity WHERE AccountId =:lstAccountRecord[0].Id LIMIT 1];
                
        //set the searchTerm and filter criteria
        String searchTerm = 'Test';
        String filter = '' + lstAccountRecord[0].Id;
               
        //verify the searchTerm results via class method
        Account[] returnScenerio1 = L2O_LookupController.lookUp(searchTerm,'Account',filter);
        System.assertEquals(lstAccountRecord[0].Id, returnScenerio1[0].Id,'Account Found');
        Contact[] returnScenerio2 = L2O_LookupController.lookUp(searchTerm,'Contact',filter);
        System.assertEquals(lstContactRecord[0].Id, returnScenerio2[0].Id,'Contact Found');
        Opportunity[] returnScenerio3 = L2O_LookupController.lookUp(searchTerm,'Opportunity','');
        System.assertEquals(lstOpportunityRecord[0].Id, returnScenerio3[0].Id,'Opportunity Found');
        
        //To cover the catch block
        L2O_LookupController.isErrorFlag = true;
        L2O_LookupController.lookUp(searchTerm,'Account',filter);
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_LookupController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('ERROR',lstErrorLog[0].Level__c,'To check the method of error.');
        
        Test.stopTest();
    }

}