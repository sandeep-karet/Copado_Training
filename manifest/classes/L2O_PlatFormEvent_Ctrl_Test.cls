/**
* Company : PwC.
* @description : Test Class for L2O_PlatFormEvent_Ctrl
* ************************************************************************************************************************************
* History : 
* @date 08/07/2022
* @author Neha Sheikh
*/

@isTest
public class L2O_PlatFormEvent_Ctrl_Test {
    
    @testSetup
    /**
* @name  testSetup()
* @description Sets up Test Data for the Class
* @params  none
*/ 
    
    static void testSetup() {
        // create test data
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);
        List<Product2> prodList = L2O_DataFactoryTest.createProduct();
        List<Asset> asstList = L2O_DataFactoryTest.createAsset(true,accountList[0].id,prodList);
        List<SBQQ__Quoteline__c> quoteLineList =  L2O_DataFactoryTest.createQuoteLines(true,quoteList,prodList,asstList);   
        
        //Update quote list
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec : [SELECT Id,SBQQ__Status__c,SBQQ__Primary__c
                                       FROM SBQQ__Quote__c 
                                       WHERE  SBQQ__Status__c != null] ){
                                           quoteRec.SBQQ__Status__c ='Accepted' ;
                                           quoteRec.SBQQ__Primary__c = true;                           
                                           lstQuote.add(quoteRec);
                                       }
        if(!quoteLineList.isEmpty()){
             update lstQuote;
        }
       
        //Update opportunity list
        List<Opportunity> lstOppty = [SELECT Id,Name,stageName,SBQQ__PrimaryQuote__c,SBQQ__Ordered__c
                                      FROM Opportunity 
                                      WHERE Name != null];
        for(integer count = 0;count<lstOppty.size();count++){
            lstOppty[count].SBQQ__PrimaryQuote__c = lstQuote[count].Id; 
            if(count == 0){ 
                lstOppty[count].stageName = L2O_Constants.OPPTY_STAGE_CLOSED_OWN;
                lstOppty[count].SBQQ__Ordered__c = true;
            }
        }
        update lstOppty;
        
    }
    /**
* @name testUpdateRecords()
* @description Test when OrderITem record get 'Activated', Platform Event should publish and update the respective fields
* @params  none
*/ 
    @isTest static void testUpdateOrderRecords() { 
        List<Order> ordUpdt = new List<Order>();
        Test.startTest();
        // Query the related order 
        List<Order> lstOrder = [SELECT Id,Status,AccountId
                                FROM Order
                                WHERE AccountId != NULL
                                LIMIT 1];
        // Query the related account
        Account acc = [SELECT Id,L2O_Broadcast_Message__c
                       FROM Account 
                       WHERE Id =:lstOrder[0].AccountId LIMIT 1];
        
        // L2O_Broadcast_Message__c field on Account will be true post Platform Event fire
        System.assertEquals(True,acc.L2O_Broadcast_Message__c,'');
        for(Order ord : [SELECT Id,L2O_Broadcast_Message__c FROM Order WHERE Status = 'Activated']){
            ord.L2O_Broadcast_Message__c = true;
            ordUpdt.add(ord);
        }
        //update Order
        update ordUpdt; 
        Test.stopTest();
    }
    /**
* @name testUpdateRecords()
* @description Test when Account Name,Biiling/Shipping Address get change, Platform Event should publish and update the respective fields
* @params  none
*/ 
    @isTest static void testUpdateAccRecords() { 
        // Query the created Account record
        List<Account> lstAccount = [SELECT Id,Name,BillingPostalCode,BillingStreet,L2O_Last_Integration_Date__c, 
                                    L2O_Broadcast_Message__c,L2O_GUID__c
                                    FROM Account 
                                    WHERE Name != null];
        Test.startTest();
        //update Account list
        for(integer count = 0;count<lstAccount.size();count++){
            lstAccount[count].Name = 'test - update ';
            lstAccount[count].ShippingPostalCode = '1234';
            lstAccount[count].BillingPostalCode = '1234';
            lstAccount[count].L2O_Broadcast_Message__c = true;
        }
        update lstAccount;
        // L2O_Platform_Event_Published__c record will create post the Account Broadcast platform event fire.
        L2O_Platform_Event_Published__c insForAcc = [SELECT id,L2O_Object_Id__c,L2O_Status__c FROM L2O_Platform_Event_Published__c
                                                     WHERE L2O_Object_Id__c =: lstAccount[0].L2O_GUID__c LIMIT 1];
        System.assertEquals('Success',insForAcc.L2O_Status__c,'');
        Test.stopTest();
        
    }
}