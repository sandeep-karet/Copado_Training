@IsTest
private class opportunityReopenLwcControllerTest {
    @TestSetup
    static void setup(){
        SBQQ.TriggerControl.disable();
        Dev_Settings__c DS = Dev_Settings__c.getInstance();
        DS.Disable_Triggers__c = true;
        Account umrAcct = TestDataFactory.createUMR();
        Account accObj = TestDataFactory.createAccountUMR();
        
        Mbr_Group__c mbrGrp = TestDataFactory.createMbrGroup(accObj.Id)[0];
        
        //create an opportunity record
        Opportunity opp = TestDataFactory.createOpportunity(accObj.Id);
        opp.LeadSource = 'Sales';
        insert opp;
        
        SBQQ__Quote__c sbqqQte = TestDataFactory.createQuote(opp.Id);
        insert sbqqQte;
        
        //create Gen Med - Consult Fee product
        Product2 prod = TestDataFactory.createSingleProduct('GM - Consult Fee', 'General Medical', 'GMCF');
        insert Prod;
        
        SBQQ__QuoteLine__c quoline = TestDataFactory.createQuoteLine(sbqqQte.Id, prod.Id);
        insert quoline;
        
        
        //create a contract 
        Contract cont = TestDataFactory.createContractNoInsert(accObj.Id, opp.id, null);
        cont.Status = 'Draft';
        cont.CurrencyIsoCode ='USD';
        cont.StartDate = Date.Today();
        cont.ContractTerm = 12;
        insert cont;
        
        
        //Gen Med
        SBQQ__Subscription__c sub = TestDataFactory.createSub(accObj.Id, cont.Id)[0];
        
        //Create Assets
        
        Asset asset1 = TestDataFactory.createAssetNoInsert('GM - Consult Fee', 49, accObj.Id, NULL, prod.Id, sub.Id);
        asset1.Quantity = 500;
        asset1.CurrencyIsoCode = 'USD';
        asset1.SBQQ__QuoteLine__c = quoline.Id;      
        insert asset1;
        
        Plan_Specific_Fees__c psf = TestDataFactory.createPlanSpecificFees(asset1.Id, mbrGrp.Id, sub.Id);
        insert psf;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Manager'];
        User u1 = TestDataFactory.createUser(p.Id);
        /*new User(Alias = 'standt1',Country='United Kingdom',Email='test12345@testtest.com',EmailEncodingKey='UTF-8', 
                           LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test1234@testzxcas.org');*/
		u1.Alias = 'standt1';
        insert u1;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = TestDataFactory.createUser(p.Id);
        /*new User(Alias = 'standt2',Country='United Kingdom',Email='test123455@testtest.com',EmailEncodingKey='UTF-8', 
                           LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p2.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test12345@testzxcas.org');*/
        u2.Alias = 'standt2';
        u2.UserName = 'test12345@testzxcas.org';
        insert u2;
        SBQQ.TriggerControl.enable();
    }
    
    @IsTest
    static void getContractTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<Contract> contList = opportunityReopenLwcController.getContract(opp.Id);
        system.assertEquals(1, contList.size());           
    }
    
    @IsTest
    static void getSubsTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<SBQQ__Subscription__c> subList = opportunityReopenLwcController.getSubs(opp.Id);
        system.assertEquals(1, subList.size());            
    }
    
    @IsTest
    static void getPsfTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<Plan_Specific_Fees__c> psfList = opportunityReopenLwcController.getPsf(opp.Id);
        system.assertEquals(1, psfList.size());         
    }
    
    @IsTest
    static void getAssetTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<Asset> assetList = opportunityReopenLwcController.getAsset(opp.Id);
        system.assertEquals(1, assetList.size());         
    }
    
    @IsTest
    static void getRecordTypeTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];      
        List<RecordType> rtList = opportunityReopenLwcController.getRecordType();
        system.assertEquals(4, rtList.size());         
    }
    
    @IsTest
    static void deleteChildRecordTest() {
        Test.startTest();
        PSF_Permission_Setting__c objDS=new PSF_Permission_Setting__c(SetupOwnerId=UserInfo.getUserId(),User_Permission__c=true);
        insert objDS;
        List<Contract> contList = [SELECT Id FROM Contract];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c];
        List<Plan_Specific_Fees__c> psfList = [SELECT Id FROM Plan_Specific_Fees__c];
        List<Asset> assetList = [SELECT Id FROM Asset];            
        opportunityReopenLwcController.deleteChildRecord(psfList, contList, assetList, subList);
        List<Contract> contLis2t = [SELECT Id FROM Contract];
        List<SBQQ__Subscription__c> subLis2t = [SELECT Id FROM SBQQ__Subscription__c];
        List<Plan_Specific_Fees__c> psfList2 = [SELECT Id FROM Plan_Specific_Fees__c];
        List<Asset> assetList2 = [SELECT Id FROM Asset]; 
        system.assertEquals(0 ,contLis2t.size()); 
        system.assertEquals(0 ,subLis2t.size());         
        system.assertEquals(0 ,psfList2.size());         
        system.assertEquals(0 ,assetList2.size());   
         Test.stopTest();
    }    
    
    @IsTest
    static void editOppAccountQuoteTest() { 
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];   
        opportunityReopenLwcController.editOppAccountQuote(opp.Id, '012f4000000S3qjAAC');
        Account acct = [SELECT Type FROM Account WHERE Name != 'UMR'];
        Opportunity opp2 = [SELECT Id, SBQQ__Contracted__c, RecordTypeId FROM Opportunity];  
        SBQQ__Quote__c qte = [SELECT recordtypeId FROM SBQQ__Quote__c];
        system.assertEquals('Prospect', acct.Type);
        system.assertEquals('012f4000000S3qjAAC', opp2.recordtypeId);
        system.assertEquals(false, opp2.SBQQ__Contracted__c);
        system.assertEquals(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Teladoc').getRecordTypeId(), qte.recordtypeId);    
        Test.stopTest();
    }
    
    @IsTest
    static void checkOppReadyTest() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'standt1'];
        User u2 = [SELECT Id FROM User WHERE Alias = 'standt2'];
        System.runAs(u1){
            Opportunity opp = [SELECT Id FROM Opportunity];
            String errorMsg = opportunityReopenLwcController.checkOppReady(opp.Id);
            system.assertEquals(true, errorMsg.contains('Only System Administrator can re-open an opportunity'));            
        }
        System.runAs(u2){
            Opportunity opp = [SELECT Id FROM Opportunity];
            String errorMsg = opportunityReopenLwcController.checkOppReady(opp.Id);
            system.assertEquals(false, errorMsg.contains('Opportunity stage is not Closed Won or Contracting'));            
        }
    }
    
    @IsTest
    static void checkAccountTest() {
        Test.startTest();
        Account acct = [SELECT Id FROM Account WHERE Name = 'TestAmendAccount'];
        Contract cont = [SELECT Id FROM Contract];
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'TestOpp3';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Employer – Teladoc and HY Products').getRecordTypeId();
        opp2.AccountId = acct.Id;
        opp2.Type = 'New Business';
        opp2.Business_Region__c = 'USA';
        opp2.CurrencyIsoCode = 'USD';
        opp2.StageName = 'Prospect';
        opp2.Probability = 10;
        opp2.Initial_of_Lives__c = 500;
        opp2.CloseDate = Date.Today();
        opp2.SBQQ__AmendedContract__c = cont.Id;
        opp2.SBQQ__Contracted__c = true;    
        opp2.LeadSource = 'Sales';
        insert opp2;
        
        opportunityReopenLwcController.checkAmendOpp(opp.Id);
        Test.StopTest();

    }
    
    @IsTest
    static void clearContractedFieldTest() {
        Opportunity opp = [SELECT Id FROM Opportunity];
		opp.Contracted_Date__c = Date.Today();
        opp.Contract_Service_Agreement_Status__c = 'Executed';
        update opp;
        opportunityReopenLwcController.clearContractedField(opp.Id);
        
        system.assertEquals(null, [SELECT Contracted_Date__c FROM Opportunity].Contracted_Date__c);            
        system.assertEquals(null, [SELECT Contract_Service_Agreement_Status__c FROM Opportunity].Contract_Service_Agreement_Status__c);            
    }
    
}