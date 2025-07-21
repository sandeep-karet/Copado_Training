@isTest
private class PerformanceGuaranteeControllerTest {
    
    @testSetup   
     static void setup() {

         //create an account record
         Account accObj = TestDataFactoryForPG_Test.createAccount('TestAccount');        

         Id pricebookId = Test.getStandardPricebookId();
        //create an opportunity record
        Opportunity oppObj2 = TestDataFactoryForPG_Test.createOpportunity(accObj.Id);
        oppObj2.Name = 'TestAmendmentOpp2';
        oppObj2.Pricebook2Id = pricebookId;
        oppObj2.LeadSource = 'Sales';
        insert oppObj2;
        
        Opportunity oppObj = TestDataFactoryForPG_Test.createOpportunity(accObj.Id);
        oppObj.Name = 'TestAmendmentOpp';
        oppObj.Pricebook2Id = pricebookId;
        oppObj.LeadSource = 'Sales';
        insert oppObj;


        // create Aggrment record
       
      
         
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
         
        Opportunity opp = [SELECT Id,accountId FROM Opportunity WHERE Name = 'TestAmendmentOpp'];
         
        /*Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];*/
         
        //Apttus__APTS_Agreement__c agreement = TestDataFactoryForPG_Test.createApttusAPTSAgreement(acc.Id, opp.Id);
        //insert agreement;


        Apttus__APTS_Agreement__c agreementRecord = new Apttus__APTS_Agreement__c();
        agreementRecord.Apttus__Account__c = opp.accountId;
        agreementRecord.Name = 'Test Agreement';
        agreementRecord.OwnerId = userinfo.getUserId();
        agreementRecord.Apttus__Contract_Start_Date__c = system.today();
        agreementRecord.Apttus__Contract_End_Date__c = System.Today() + 5;
        agreementRecord.Apttus__Related_Opportunity__c = opp.Id;
        agreementRecord.Apttus__Status_Category__c = 'Request';
        agreementRecord.Apttus__Status__c = 'Request';
        insert agreementRecord;


        // create Aggrment Line Item record
        List<Apttus__AgreementLineItem__c> lineItems = new List<Apttus__AgreementLineItem__c>();
        for(Integer i =1; i<6; i++){
            Apttus__AgreementLineItem__c  lineItemRecord = new Apttus__AgreementLineItem__c();          
            lineItemRecord.APTS_ProductName__c = 'APTS_Product_Family__c';
            lineItemRecord.APTS_Membership_Fee__c = 10.00 * i;
            lineItemRecord.APTS_Fee_Type__c = 'PEPM';
            lineItemRecord.Apttus__AgreementId__c = agreementRecord.ID;

            lineItems.add(lineItemRecord);
        }

        Insert lineItems;

        // create PG Records;
        List<Performance_Guarantees__c> pgItems = new List<Performance_Guarantees__c>();
        for(Integer i =1; i<4; i++){
            Performance_Guarantees__c pgRecord = new Performance_Guarantees__c();
            pgRecord.Product_Family__c ='Expert Medical Service';
            pgRecord.Guarantee_Type__c ='Call Center';
            pgRecord.PG_Status__c = 'Active';
            pgRecord.Credit_or_Refund__c ='Credit';
            pgRecord.Calculation_Method__c ='Average';
            pgRecord.Evaluation_Frequency__c ='Semi-Annually';
            pgRecord.PG_Level__c = 'Book of Business';
            pgRecord.Guarantee_Description__c ='none';
            pgRecord.Agreement__c = agreementRecord.ID;     
            pgRecord.Fees_at_Risk_Type__c ='PPPM';
            pgRecord.PG_Start_Date__c = Date.newInstance(2022, 10, 20);
            pgRecord.Fees_At_Risk_Payment_Term__c =4567;
            pgRecord.Fees_At_Risk_Payment_Timeframe__c =654;
            pgRecord.Fees_At_Risk_Unit__c ='Dollar';
            pgRecord.PG_Initial_Measurement_Term_Recurring__c='Yes';
            pgRecord.PG_Initial_Measurement_Term__c=4;
            pgRecord.Source_Document__c = '2334';
            pgItems.add(pgRecord);
        }
        Insert pgItems;
    }
   
    @isTest
    static void testgetLineitems()
    {
        Test.startTest();
        Apttus__APTS_Agreement__c agrmt = [SELECT ID,Name FROM Apttus__APTS_Agreement__c WHERE OwnerId = :userinfo.getUserId() limit 1];         
        List<Apttus__AgreementLineItem__c> agrLineitems = PerformanceGuaranteeController.getLineItems(agrmt.ID);
        Test.stopTest();   
        System.assertEquals(5, agrLineitems.size(), 'Should return list of Agreement Line Item for selected Agreement');
    }

    @isTest
    static void testgetPGAssociationrecords()
    {
         Test.startTest();
        Apttus__APTS_Agreement__c agrmt = [SELECT ID FROM Apttus__APTS_Agreement__c WHERE OwnerId = :userinfo.getUserId() limit 1]; 
        List<Apttus__AgreementLineItem__c> agrLineitems = PerformanceGuaranteeController.getLineItems(agrmt.ID);
        List<Performance_Guarantees__c> pgList = PerformanceGuaranteeController.getPGRecords(agrmt.ID);

        List<PerformanceGuaranteeController.PGWrapper> pGWrapperList = new  List<PerformanceGuaranteeController.PGWrapper> ();
        PerformanceGuaranteeController.PGWrapper record = new PerformanceGuaranteeController.PGWrapper();
        record.Id = pgList[0].Id;
        record.LineItemId =  agrLineitems[0].Id;
        pGWrapperList.add(record);
        

        PerformanceGuaranteeController.PGWrapper record2 = new PerformanceGuaranteeController.PGWrapper();
        record2.Id = pgList[1].Id;
        record2.LineItemId = agrLineitems[1].Id;
        pGWrapperList.add(record2);    
        
        PerformanceGuaranteeController.updateRecords(pGWrapperList);        
        
        List<PG_Association__c> records =PerformanceGuaranteeController.getPGAssociationRecords(agrmt.Id);

        System.assertEquals(2, records.size(), 'Should return list of PG Association object for selected Agreement');        
        Test.stopTest();  
    }

    @isTest
    static void testgetPGrecords()
    {
        Test.startTest();
        Apttus__APTS_Agreement__c agrmt = [SELECT ID FROM Apttus__APTS_Agreement__c WHERE OwnerId = :userinfo.getUserId() limit 1];        
        List<Performance_Guarantees__c> pgList = PerformanceGuaranteeController.getPGRecords(agrmt.ID);
        Test.stopTest();    
        System.assertEquals(3, pgList.size(), 'Should return list of Performance Guarantees Item for selected Agreement');        
        
    }

    @isTest
    static void testgetupdaterecords()
    {
        
        Test.startTest();
        Apttus__APTS_Agreement__c agrmt = [SELECT ID FROM Apttus__APTS_Agreement__c WHERE OwnerId = :userinfo.getUserId() limit 1]; 
        List<Apttus__AgreementLineItem__c> agrLineitems = PerformanceGuaranteeController.getLineItems(agrmt.ID);
        List<Performance_Guarantees__c> pgList = PerformanceGuaranteeController.getPGRecords(agrmt.ID);

        List<PerformanceGuaranteeController.PGWrapper> pGWrapperList = new  List<PerformanceGuaranteeController.PGWrapper> ();
        PerformanceGuaranteeController.PGWrapper record = new PerformanceGuaranteeController.PGWrapper();
        record.Id = pgList[0].Id;
        record.LineItemId =  agrLineitems[0].Id;
        pGWrapperList.add(record);
        

        PerformanceGuaranteeController.PGWrapper record2 = new PerformanceGuaranteeController.PGWrapper();
        record2.Id = pgList[1].Id;
        record2.LineItemId = agrLineitems[1].Id;
        pGWrapperList.add(record2);     
       

        PerformanceGuaranteeController.updateRecords(pGWrapperList);

        List<PG_Association__c> records = [SELECT ID, Agreement_Line_Item__c,Performance_Guarantee__c FROM PG_Association__c 
                                            WHERE Agreement_Line_Item__c IN (Select Id FROM Apttus__AgreementLineItem__c 
                                            WHERE Apttus__AgreementId__c= :agrmt.Id)];   
        
        
             
        System.assertEquals(2, records.size(), 'Should create record of PG Association object for selected Agreement line item and Performance Guarantee record.');        
        Test.stopTest();   
    }

    @isTest
    static void testupdateandDeleterecords()
    {
        
        Test.startTest();
        Apttus__APTS_Agreement__c agrmt = [SELECT ID FROM Apttus__APTS_Agreement__c WHERE OwnerId = :userinfo.getUserId() limit 1]; 
        List<Apttus__AgreementLineItem__c> agrLineitems = PerformanceGuaranteeController.getLineItems(agrmt.ID);
        List<Performance_Guarantees__c> pgList = PerformanceGuaranteeController.getPGRecords(agrmt.ID);

        
        
        List<PerformanceGuaranteeController.PGWrapper> pGWrapperList = new  List<PerformanceGuaranteeController.PGWrapper> ();
        PerformanceGuaranteeController.PGWrapper record = new PerformanceGuaranteeController.PGWrapper();
        record.Id = pgList[0].Id;
        record.LineItemId =  agrLineitems[0].Id;
        pGWrapperList.add(record);
        

        PerformanceGuaranteeController.PGWrapper record2 = new PerformanceGuaranteeController.PGWrapper();
        record2.Id = pgList[1].Id;
        record2.LineItemId = agrLineitems[1].Id;
        pGWrapperList.add(record2);       

        PerformanceGuaranteeController.updateRecords(pGWrapperList);       
        
        
        List<PerformanceGuaranteeController.PGWrapper> pGWrapperList2 = new  List<PerformanceGuaranteeController.PGWrapper> ();
        record = new PerformanceGuaranteeController.PGWrapper();
        record.Id =  pgList[2].Id;
        record.LineItemId = agrLineitems[2].Id;
        pGWrapperList2.add(record);
       

        List<String>existingPGIds = new List<String>();
        for (PG_Association__c pgRecord: [SELECT ID, Agreement_Line_Item__c,Performance_Guarantee__c FROM PG_Association__c 
                        WHERE Agreement_Line_Item__c IN (Select Id FROM Apttus__AgreementLineItem__c 
                        WHERE Apttus__AgreementId__c= :agrmt.Id)]){
                            
           existingPGIds.add(pgRecord.Id);

        }       

        List<PG_Association__c> records = PerformanceGuaranteeController.insertAndDeleteRecords(pGWrapperList2,existingPGIds,agrmt.ID);        
        
       
        System.assertEquals(1, records.size(), 'Should return updated list of PG Association object for newly created record of PG_Association object only.');        
        Test.stopTest();   
    }
    
}