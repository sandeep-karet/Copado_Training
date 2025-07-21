/************************************************************
 * Class Name     : Test_GCRM_Process_PreSales
 * Created By     : Rajalajshmi R
 * Date           : 19-Sep-2023
 * Classes Covered: GCRM_Process_PreSales,GCRM_Processorder_Utility
**************************************************************/
@istest
public class Test_GCRM_Process_PreSales {
     @testSetup static void setupg2lcrmitem(){
        Test.StartTest();
        list<Product2> prodlist = new list<Product2>();

        Product2 prod1 = TestDataFactory.createSingleProduct('Mental Health Complete', 'Livongo - Behavioral Health', 'MYSTR3');
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        prodlist.add(Prod1);

        Product2 prod2 = TestDataFactory.createSingleProduct('Psychiatry Initial Visit Fee', 'Behavioral Health', 'BHP1T');
        prod2.SBQQ__SubscriptionType__c = 'Renewable';
        prodlist.add(Prod2);

        Product2 prod3 = TestDataFactory.createSingleProduct('Psychiatry Ongoing Visit Fee', 'Behavioral Health', 'BHPOT');
        prod3.SBQQ__SubscriptionType__c = 'Renewable';
        prodlist.add(Prod3);

        Product2 prod4 = TestDataFactory.createSingleProduct('Therapy Ongoing Visit Fee', 'Behavioral Health', 'BHNPT');
        prod4.SBQQ__SubscriptionType__c = 'Renewable';
        prodlist.add(Prod4);
        insert Prodlist;
        
        Pricebook2 TeladocPriceBook = new Pricebook2(
            Name = 'Teladoc Price Book',
            CurrencyISOCode = 'USD',
            IsActive = true
        );
        insert TeladocPriceBook;
        Pricebook2 CanadaPricebook = new Pricebook2(
            Name = 'Canada Pricebook',
            CurrencyISOCode = 'CAD',
            IsActive = true
        );
        insert CanadaPricebook;
        Id StandardPricebook = Test.getStandardPricebookId();
        
        PricebookEntry[] spbEntry = TestDataFactory.createPriceBookEntries(Prodlist, StandardPricebook);
        insert spbEntry;
        PricebookEntry[] tpbEntry = TestDataFactory.createPriceBookEntries(Prodlist, TeladocPriceBook.Id);
        insert tpbEntry;
        
        PricebookEntry[] cdbEntry = TestDataFactory.createPriceBookEntries(Prodlist, CanadaPricebook.Id);
        insert cdbEntry;
        
        List<G2LCRM_Item__c> itemsToinsert = new List<G2LCRM_Item__c>();
        G2LCRM_Item__c presalepayload1 = new G2LCRM_Item__c();
        presalepayload1.Action__c = 'create';
        presalepayload1.Body__c = '{\n  \"header\": {\n    \"cdmName\": \"PreSale\",\n    \"sourceSystemName\": \"tdoc-ca-presale-papi\",\n    \"sourceTrnxId\": \"d0b202f3-2fe1-4bf1-83ae-61f36febc4be\",\n    \"muid\": \"76fea720-537a-11ee-ba6a-0eed30f88455\",\n    \"createDatetime\": \"2023-09-15T03:09:34.000Z\",\n    \"action\": \"create\"\n  },\n  \"body\": {\n    \"account\": {\n      \"accountId\": \"0018C00000Z9JfAQAV\",\n      \"accountGUID\": \"19ECE108-B422-F017-9FB4-591AFCADBC2B\",\n      \"accountName\": \"Integration Testing Account\",\n      \"createdDate\": \"2023-09-07T18:01:03.000Z\",\n      \"businessRegion\": \"USA\",\n      \"accountType\": \"Employer\",\n      \"accountSource\": \"Sales\",\n      \"currencyIsoCode\": \"USD\",\n      \"addresses\": [\n        {\n          \"type\": \"Billing\",\n          \"city\": \"Chicago\",\n          \"country\": \"United States\",\n          \"postalCode\": \"60611\",\n          \"state\": \"Illinois\",\n          \"street\": \"444 North Michigan Avenue, Suite 3400\"\n        },\n        {\n          \"type\": \"Shipping\",\n          \"city\": \"Chicago\",\n          \"country\": \"United States\",\n          \"state\": \"Illinois\",\n          \"street\": \"444 North Michigan Avenue, Suite 3400\"\n        }\n      ],\n      \"contractCoTermination\": \"Never\",\n      \"isPreserveBundle\": true,\n      \"isAssetQuantitiesCombined\": false,\n      \"isCoTermedContractsCombined\": false\n    },\n    \"opportunity\": {\n      \"opportunityId\": \"0068C000005MDUuQAO\",\n      \"opportunityGUID\": \"919CA22A-13C1-B394-7DFB-2CC1138B9A98\",\n      \"accountId\": \"0018C00000Z9JfAQAV\",\n      \"accountGUID\": \"19ECE108-B422-F017-9FB4-591AFCADBC2B\",\n      \"opportunityName\": \"Test MDQ Opp\",\n      \"createdDate\": \"2023-09-15T03:42:51.000Z\",\n      \"createdById\": \"0058C000001EeKiQAK\",\n      \"leadSource\": \"Sales\",\n      \"initialNumOfLives\": 10000.0,\n      \"closeDate\": \"2023-09-30\",\n      \"businessRegion\": \"USA\",\n      \"opportunityType\": \"New Business\",\n      \"currencyIsoCode\": \"USD\",\n      \"stageName\": \"Contracting\",\n      \"priceBook2Id\": \"01s8c000002j6X6AAI\",\n      \"primaryQuoteId\": \"a2w8C000000I2tvQAC\"\n    },\n    \"quote\": {\n      \"quoteId\": \"a2w8C000000I2tvQAC\",\n      \"quoteName\": \"Q-00464\",\n      \"accountId\": \"0018C00000Z9JfAQAV\",\n      \"opportunityGUID\": \"919CA22A-13C1-B394-7DFB-2CC1138B9A98\",\n      \"createdDate\": \"2023-09-15T03:44:16.000Z\",\n      \"isPrimary\": true,\n      \"businessRegion\": \"USA\",\n      \"subscriptionTerm\": 36.0,\n      \"quoteLines\": [\n        {\n          \"quoteLineId\": \"a2s8C000000TUpWQAW\",\n          \"quoteLineName\": \"QL-0004217\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:50.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 414000.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"listPrice\": 23.0,\n          \"membershipFee\": 23.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"bundleType\": \"Standalone\",\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOsuQAE\",\n          \"productCode\": \"MYSTR3\",\n          \"parentProductCode\": \"NULL\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Mental Health Complete\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2023-09-14\",\n          \"effectiveEndDate\": \"2026-09-13\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpXQAW\",\n          \"quoteLineName\": \"QL-0004218\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 235.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHP1T\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2023-09-14\",\n          \"effectiveEndDate\": \"2024-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpYQAW\",\n          \"quoteLineName\": \"QL-0004219\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 235.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHP1T\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2024-09-14\",\n          \"effectiveEndDate\": \"2025-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpZQAW\",\n          \"quoteLineName\": \"QL-0004220\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 235.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHP1T\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2025-09-14\",\n          \"effectiveEndDate\": \"2026-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpaQAG\",\n          \"quoteLineName\": \"QL-0004221\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 105.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHPOT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2023-09-14\",\n          \"effectiveEndDate\": \"2024-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpbQAG\",\n          \"quoteLineName\": \"QL-0004222\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 105.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHPOT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2024-09-14\",\n          \"effectiveEndDate\": \"2025-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpcQAG\",\n          \"quoteLineName\": \"QL-0004223\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 105.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHPOT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2025-09-14\",\n          \"effectiveEndDate\": \"2026-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpdQAG\",\n          \"quoteLineName\": \"QL-0004224\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 95.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHNPT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2023-09-14\",\n          \"effectiveEndDate\": \"2024-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpeQAG\",\n          \"quoteLineName\": \"QL-0004225\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 95.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHNPT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2024-09-14\",\n          \"effectiveEndDate\": \"2025-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        },\n        {\n          \"quoteLineId\": \"a2s8C000000TUpfQAG\",\n          \"quoteLineName\": \"QL-0004226\",\n          \"quoteId\": \"a2w8C000000I2tvQAC\",\n          \"createdDate\": \"2023-09-15T03:45:51.000Z\",\n          \"participantQuantity\": \"10000.0\",\n          \"effectiveQuantity\": 500.0,\n          \"netTotal\": 0.0,\n          \"consultType\": \"Standard\",\n          \"feeType\": \"PPPM\",\n          \"consultFee\": 95.0,\n          \"listPrice\": 0.0,\n          \"feeCode\": \"BHNPT\",\n          \"membershipFee\": 0.0,\n          \"effectiveSubscriptionTerm\": 36.0,\n          \"isAnchor\": false,\n          \"productId\": \"01t8C000001tOy9QAE\",\n          \"productCode\": \"VISITFEE\",\n          \"parentProductCode\": \"MYSTR3\",\n          \"grandparentProductCode\": \"NULL\",\n          \"productName\": \"Visit Fee\",\n          \"productSubscriptionType\": \"Renewable\",\n          \"effectiveStartDate\": \"2025-09-14\",\n          \"effectiveEndDate\": \"2026-09-13\",\n          \"requiredBy\": \"a2s8C000000TUpWQAW\"\n        }\n      ]\n    }\n  }\n}';
        presalepayload1.CDM_Name__c = 'PreSale';
        presalepayload1.MUID__c = 'ace30c50-5389-11ee-ba6a-0eed30f88455';
        presalepayload1.Processor__c = 'PreSale';
        presalepayload1.Source_System_Name__c = 'Salesforce GCRM';
        presalepayload1.Source_Trnx_Id__c = '13a41b02-7462-4c3d-a602-6d7cdd63a08e';
        itemsToinsert.add(presalepayload1);
         
        insert itemsToinsert;
        Test.StopTest();
    }
    @isTest
    public static void testpreSaleProcessing(){
       
       /* GCRM_Process_PreSales gcrmPre = new GCRM_Process_PreSales();
         Test.startTest();
        gcrmPre.ProcessPayload('ace30c50-5389-11ee-ba6a-0eed30f88455');
        Test.StopTest(); */
        
        Test.startTest();
        String MUID3 ='ace30c50-5389-11ee-ba6a-0eed30f88455';
        GCRM_Process_V3_Bch batchTest2 = new GCRM_Process_V3_Bch(MUID3,false);
        Database.executeBatch(batchTest2);
        Test.stopTest();
    }
    
    @isTest
    public static void testpreSaleProcessingV4(){
       	
        Test.startTest();
        insert new G2LCRM_Flow__c(
      	SetupOwnerId = UserInfo.getOrganizationId(),
      	G2LCRM_V4_Flow__c = true
    	);
        String MUID4 ='ace30c50-5389-11ee-ba6a-0eed30f88455';
        GCRM_Process_V3_Bch batchTest2 = new GCRM_Process_V3_Bch(MUID4,false);
        Database.executeBatch(batchTest2);
        Test.stopTest();
    }
    
}