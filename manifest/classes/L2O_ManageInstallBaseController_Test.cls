/**
* Company : PwC.
* @description : Test Class for L2O_ManageInstallBaseController apex
* *******************************************************************************************************************************************
* History : 
* @date 06/07/2022
* @author Lakshitha Salian
*/
@isTest
public class L2O_ManageInstallBaseController_Test {
    
    /**
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    
    @testSetup static void testSetup(){
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
    } 
    
    /**
    * @name  testGetAllContracts
    * @description To test Contract record fetch
    * @params  none
    **/
    @isTest static void testGetAllContracts(){
        List<Contract> testResult = new List<Contract>();
        Test.startTest();
        List<Account> accountList = [SELECT Id FROM Account WHERE Name LIKE '%Test_Customer%' LIMIT 1];
        testResult.addAll(L2O_ManageInstallBaseController.getAllContracts(accountList[0].id));
       
        //Check the Contract status is activated.
        for(Contract con: testResult){
            System.assertEquals('Activated',con.Status,'To check the Contract Status is Activated.');
        }
        
        //Check the Contracts returned if no Id passed.
        String nullId = '';
        List<Contract> testErrorResult = new List<Contract>();
        testErrorResult.addAll(L2O_ManageInstallBaseController.getAllContracts(nullId));
        System.assertEquals(0,testErrorResult.size(),'To check the size of returned Contracts List.');
        
        //To cover the catch block
        L2O_ManageInstallBaseController.isErrorFlag = true;
        L2O_ManageInstallBaseController.getAllContracts(nullId);
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ManageInstallBaseController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('getAllContracts',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();  
    }
    
    /**
    * @name  testUpdateContract
    * @description To test Contract record update
    * @params  none
    **/
    @isTest static void testUpdateContract(){
        Test.startTest();
        Contract contract = [SELECT Id FROM Contract WHERE ContractTerm = 12 LIMIT 1];
        String subtype = 'Change Order';
        L2O_ManageInstallBaseController.updateContract(contract.Id,subtype);
        Contract updatedContract = [SELECT Id,L2O_Amendment_Opportunity_SubType__c FROM Contract WHERE ContractTerm = 12 LIMIT 1]; 
        System.assertEquals('Change Order',updatedContract.L2O_Amendment_Opportunity_SubType__c,'To check the Contract Sub Type is Change Order.');
        
		subtype = 'Test'; 
        String response = L2O_ManageInstallBaseController.updateContract(contract.Id,subtype);
        System.assertEquals('Error',response,'To check the method returned Error.');
        Test.stopTest();
       
    }
    
    /**
    * @name  testGetMetaDataSettings
    * @description To test L2O_ManageInstallBase__mdt record fetch
    * @params  none
    **/
    @isTest static void testGetMetaDataSettings(){
        List<L2O_ManageInstallBase__mdt> testResult = new List<L2O_ManageInstallBase__mdt>();
        Test.startTest();
        testResult.addAll(L2O_ManageInstallBaseController.getMetaDataSettings());
        
        for(L2O_ManageInstallBase__mdt mtd: testResult){
            System.assertEquals('L2O_Manage Install Base Flow Text',mtd.MasterLabel,'To check the Metadata master label.');
        }
        
        //To cover the catch block
        L2O_ManageInstallBaseController.isErrorFlag = true;
        L2O_ManageInstallBaseController.getMetaDataSettings();
        List<SDF_LGR_Log__c> lstErrorLog = [SELECT Id,Class__c,Reference__c,Level__c,Message__c
                                            FROM SDF_LGR_Log__c
                                            WHERE Class__c = 'L2O_ManageInstallBaseController'];
        System.assertEquals(1,lstErrorLog.size(),'To cover the catch block.'); 
        System.assertEquals('getMetaDataSettings',lstErrorLog[0].Reference__c,'To check the method of error.');
        Test.stopTest();
    }
}