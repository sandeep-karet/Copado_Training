@isTest
public class G2LItemErrorReportEmailTest {
    
    @isTest
    static void testSendErrorReport() {
        // Create test data
        G2LCRM_Item__c testItem = new G2LCRM_Item__c(
            Account_GUID__c = 'B9B68C58-3EAB-68AE-F3B8-4433E2278448',
            Key_Trnx__c='bde0a872bd2e92e3329acbae3280afe1',
            Source_System_Name__c = 'Test System',
            Opp_GUId__c = '93CF60F2-CD6A-819A-6867-570633534CBE',
            Order_GUID__c = 'ECC654FF-B19C-B5FB-FD97-62A209B923A5',
            Processor__c = 'Test Processor',
            Action__c = 'create',
            Source_Trnx_Id__c='2f5c8565-ee99-4648-b78a-7dde73f2064a',
            MUID__c = '55c3be71-829e-11ef-b6d6-e62cadde80e1',
            CDM_Name__c = 'Order',
            Body__c = '{' +
            '"header": {' +
            '"cdmName": "Order",' +
            '"sourceSystemName": "tdoc-ca-order-papi-v1-dev",' +
            '"sourceTrnxId": "2f5c8565-ee99-4648-b78a-7dde73f2064a",' +
            '"muid": "55c3be71-829e-11ef-b6d6-e62cadde80e1",' +
            '"createDatetime": "2024-10-04T22:10:42.000Z",' +
            '"action": "Create"' +
            '},' +
            '"body": {' +
            '"order": {' +
            '"orderItems": [' +
            '{' +
            '"orderItemGUID": "7D169FD9-0B2F-51EB-390D-91E916CEEFB7",' +
            '"orderItemId": "802Wr000004WAJCIA4",' +
            '"orderItemNumber": "0000124329",' +
            '"servicingPlatform": "TDH",' +
            '"productCode": "HY-CMUSEMP-BUNDLE-2.1",' +
            '"productName": "Healthiest You Complete Bundle 2.1",' +
            '"productFamily": "General Medical",' +
            '"productId": "01t8c00000RMLLsAAP",' +
            '"productSubscriptionType": "Renewable",' +
            '"billingFrequency": "Annual",' +
            '"contractAction": "New",' +
            '"defaultSubscriptionTerm": 1,' +
            '"endDate": "2024-12-31",' +
            '"hasHoldOrder": false,' +
            '"isActivated": true,' +
            '"isRMA": false,' +
            '"listPrice": 0,' +
            '"membershipFee": 0,' +
            '"orderedQuantity": 10000,' +
            '"prorateMultiplier": 12,' +
            '"serviceDate": "2024-01-01",' +
            '"status": "Activated",' +
            '"totalPrice": 0,' +
            '"unitOfMeasure": "Each",' +
            '"unitPrice": 0,' +
            '"currencyIsoCode": "USD",' +
            '"quoteLine": {' +
            '"doesSaleHvAdolescents": false' +
            '},' +
            '"addresses": [' +
            '{' +
            '"type": "Shipping",' +
            '"city": "Chicago",' +
            '"country": "United States",' +
            '"countryCode": "US",' +
            '"postalCode": "60611",' +
            '"state": "Illinois",' +
            '"stateCode": "IL",' +
            '"street": "444 North Michigan Avenue, Suite 3400"' +
            '}' +
            ']' +
            '},' +
            // Additional order items would follow here in the same format...
            ']' +
            '}' +
            '}' +
            '}',
            
            Status__c = 'Processed with Error'
        );
        insert testItem;
        
        G2LItemLog__c testLog = new G2LItemLog__c(
            MUID__c = '55c3be71-829e-11ef-b6d6-e62cadde80e1',
            G2LCRM_Item__c = testItem.Id,
            Module__c = 'Test Module',
            Method__c = 'Test Method',
            ErrorType__c='Error',
            Parsing_Results__c = 'Error Parsing Results'
        );
        insert testLog;
        
        // Call the method under test
        Test.startTest();
        G2LItemErrorReportEmail.sendErrorReport('55c3be71-829e-11ef-b6d6-e62cadde80e1');
        Test.stopTest();
        
    }
}