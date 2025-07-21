@IsTest
private class PlanSpecificFeeController_Test {
  /*
    @IsTest
    static void testPSF() {
        Account umrAcct = new Account();
        umrAcct.Name = 'UMR';
        umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
        umrAcct.Source__c = 'HUB';
        umrAcct.CurrencyIsoCode = 'USD';
        umrAcct.Business_Region__c = 'USA';
        umrAcct.Account_Type__c = 'Health Plan';
        insert umrAcct;

        try {
            PageReference pageRef = Page.PSFByProduct;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(new Plan_Specific_Fees__c());
            //Plan_Specific_Fees__c tmpPlanSpecificFees = (Plan_Specific_Fees__c)sc.getRecord();

            PlanSpecificFeeController psfc = new PlanSpecificFeeController(sc);
            psfc.selProduct();
            psfc.selGroup();
            psfc.selProduct();
            psfc.SaveAndNew();
            psfc.Save();
        } catch (Exception e) {
            System.debug ('this will catch blank Url, etc.');
        }
        List<Account> acct = new List<Account>();
        Account a = new Account(
            Name = 'Test01',
            Source__c = 'HUB'
        );
        acct.add(a);
        
        insert acct;
        

        List<Mbr_Group__c> mg = new List<Mbr_Group__c>();
        Mbr_Group__c grp = new Mbr_Group__c(
            Name__c = 'testgrp1',
            Client_Account__c = a.Id,
            Status__c = 'ACTIVE',
            Active_Date__c = Date.today()
        );
        mg.add(grp);
        Mbr_Group__c grp2 = new Mbr_Group__c(
            Name__c = 'testgrp2',
            Client_Account__c = a.Id,
            Status__c = 'ACTIVE',
            Active_Date__c = Date.today()
        );
        mg.add(grp2);
        insert mg;
        
        
        Mbr_Group_Role__c r = new Mbr_Group_Role__c
                (       Role_Type__c = 'Payer',
                        Source_Account__c = a.Id,
                        Mbr_Group__c = mg[0].Id
                );
        insert r;
  
        List<Product2> pd = new List<Product2>();
        Product2 prod = new Product2(
            Name = 'GLOBALCARE',
            Family = 'GLOBAL CARE',
            ProductCode = 'GLOBALCARE',
            IsActive = true
        );
        pd.add(prod);
        
        Product2 prod2 = new Product2(
            Name = 'Dermatology',
            Family = 'Dermatology',
            ProductCode = 'DERM',
            IsActive = true
        );
        pd.add(prod2);
        
        Product2 prod3 = new Product2(
            Name = 'Tobacco Cessation',
            Family = 'Tobacco Cessation',
            ProductCode = 'TC',
            IsActive = true
        );
        pd.add(prod3);
        
        Product2 prod4 = new Product2(
            Name = 'General Medical',
            Family = 'General Medical',
            ProductCode = 'GM',
            IsActive = true
        );
        pd.add(prod4);
        
        Product2 prod5 = new Product2(
            Name = 'Behavioral Health',
            Family = 'Behavioral Health',
            ProductCode = 'BH',
            IsActive = true
        );
        pd.add(prod5);
        
        Product2 prod6 = new Product2(
            Name = 'Back Care',
            Family = 'Musculoskelatal',
            ProductCode = 'TDBC',
            IsActive = true
        );
        pd.add(prod6);
        
        Product2 prod7 = new Product2(
            Name = 'test1',
            Family = 'Musculoskelatal',
            ProductCode = 'TDBC',
            IsActive = true
        );
        pd.add(prod7);
        
        Product2 prod8 = new Product2(
            Name = 'Nutrition',
            Family = 'Nutrition',
            ProductCode = 'NUT',
            IsActive = true
        );
        pd.add(prod8);
        
        Product2 prod9 = new Product2(
            Name = 'NUTFEE',
            Family = 'Nutrition',
            ProductCode = 'NUTFEE',
            IsActive = true
        );
        pd.add(prod9);
      
        insert pd;
        
        Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
            Member_Group__c = grp.Id,
            Consult_Fee_Mbr_Pd__c = 0.80,
            Consults_per_Family__c = 4,
            Consult_Fee_Plan_Pd__c = 0.80,
            Consult_Frequency__c = 'Per Year'
        );
        insert gpRec;
        
        
        List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod9.Id
        );
        subL.add(sub12);
        
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod6.Id
        );
        subL.add(sub11);
       
        SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod8.Id
        );
        subL.add(sub9);
        
        SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod7.Id
        );
        subL.add(sub8);
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod.Id
        );
        subL.add(sub);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod5.Id
        );
        subL.add(sub2);
        
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod4.Id
        );
        subL.add(sub3);
        
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod3.Id
        );
        subL.add(sub4);
        
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod2.Id
        );
        subL.add(sub5);
        
        insert subL;
        
        
        gpRec.Subscription__c = sub.Id;
        gpRec.Product_Start_Date__c = Date.Today();
        gpRec.Actual_Copay_May_Be_Less__c = TRUE;
        update gpRec;
        
		List<Asset> assetL = new List<Asset>();
        
        Asset ast = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = null,
            Number_of_Lives__c = null,
            Teladoc_Net_Fee__c = null,
            InstallDate = Date.today(),
            Product2Id = prod.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub.Id
        );
        assetL.add(ast);
        
        Asset ast2 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Psych/MD-ONGOING-Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast2);
        
        Asset ast3 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod3.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub3.Id
        );
        assetL.add(ast3);
        
        Asset ast4 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub4.Id
        );
        assetL.add(ast4);
        
        Asset astt = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub9.Id
        );
        assetL.add(astt);
        
        Asset astt1 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub11.Id
        );
        assetL.add(astt1);
        
        Asset astt2 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub12.Id
        );
        assetL.add(astt2);
        
        Asset ast5 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = null,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod5.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub5.Id
        );
        assetL.add(ast5);
        
        Asset ast6 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Psych/MD-1stvisitonly-Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast6);
        
        Asset ast7 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Non-Psychiatrist- Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast7);
        insert assetL;

        // Reload with relationship
        Map<Id, Asset> m = new Map<Id, Asset>([
                SELECT Id,Name,AccountId,Consult_Fees__c,Number_of_Lives__c,Teladoc_Net_Fee__c,
                        InstallDate,Product2.ProductCode,Product2Id,SBQQ__RequiredBySubscription__c,
                        SBQQ__RequiredBySubscription__r.Name
                FROM Asset
        ]);

        ast = m.get(ast.Id);
        ast2 = m.get(ast2.Id);
        ast3 = m.get(ast3.Id);
        ast4 = m.get(ast4.Id);
        ast5 = m.get(ast5.Id);

        System.debug('MyProduct' + prod4.ProductCode + ' id:' + prod4.Id);
        System.debug('MyCode' + ast4.Product2.ProductCode);
        try {
            testPSFPage(null, null);
        } catch (Exception e) {
            System.debug('should be error here');
        }		
        testPSFPage(grp, sub);
        testPSFPage(grp, sub2);
        testPSFPage(grp, sub3);
        testPSFPage(grp, sub4);
        testPSFPage(grp, sub5);
        // final run - delete a PSF record
        testPSFPage(gpRec, sub, true);
    }
    
    @IsTest
    static void testPSF_differentProdcut() {
		Account umrAcct = new Account();
        umrAcct.Name = 'UMR';
        umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
        umrAcct.Source__c = 'HUB';
        umrAcct.CurrencyIsoCode = 'USD';
        umrAcct.Business_Region__c = 'USA';
        umrAcct.Account_Type__c = 'Health Plan';
        insert umrAcct;
        try {
            PageReference pageRef = Page.PSFByProduct;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(new Plan_Specific_Fees__c());
            //Plan_Specific_Fees__c tmpPlanSpecificFees = (Plan_Specific_Fees__c)sc.getRecord();

            PlanSpecificFeeController psfc = new PlanSpecificFeeController(sc);
            psfc.selProduct();
            psfc.selGroup();
            psfc.selProduct();
            psfc.SaveAndNew();
            psfc.Save();
        } catch (Exception e) {
            System.debug ('this will catch blank Url, etc.');
        }
        List<Account> acct = new List<Account>();
        Account a = new Account(
            Name = 'Test01',
            Source__c = 'HUB'
        );
        acct.add(a);
        
        insert acct;
        

        List<Mbr_Group__c> mg = new List<Mbr_Group__c>();
        Mbr_Group__c grp = new Mbr_Group__c(
            Name__c = 'testgrp1',
            Client_Account__c = a.Id,
            Status__c = 'ACTIVE',
            Active_Date__c = Date.today()
        );
        mg.add(grp);
        Mbr_Group__c grp2 = new Mbr_Group__c(
            Name__c = 'testgrp2',
            Client_Account__c = a.Id,
            Status__c = 'ACTIVE',
            Active_Date__c = Date.today()
        );
        mg.add(grp2);
        insert mg;
        
        
        Mbr_Group_Role__c r = new Mbr_Group_Role__c
                (       Role_Type__c = 'Payer',
                        Source_Account__c = a.Id,
                        Mbr_Group__c = mg[0].Id
                );
        insert r;
  
        List<Product2> pd = new List<Product2>();
        Product2 prod = new Product2(
            Name = 'GLOBALCARE',
            Family = 'GLOBAL CARE',
            ProductCode = 'GLOBALCARE',
            IsActive = true
        );
        pd.add(prod);
        
        Product2 prod2 = new Product2(
            Name = 'Dermatology',
            Family = 'Dermatology',
            ProductCode = 'DERM',
            IsActive = true
        );
        pd.add(prod2);
        
        Product2 prod3 = new Product2(
            Name = 'Tobacco Cessation',
            Family = 'Tobacco Cessation',
            ProductCode = 'TC',
            IsActive = true
        );
        pd.add(prod3);
        
        Product2 prod4 = new Product2(
            Name = 'General Medical',
            Family = 'General Medical',
            ProductCode = 'GM',
            IsActive = true
        );
        pd.add(prod4);
        
        Product2 prod5 = new Product2(
            Name = 'Behavioral Health',
            Family = 'Behavioral Health',
            ProductCode = 'BH',
            IsActive = true
        );
        pd.add(prod5);
        
        Product2 prod6 = new Product2(
            Name = 'Back Care',
            Family = 'Musculoskelatal',
            ProductCode = 'TDBC',
            IsActive = true
        );
        pd.add(prod6);
        
        Product2 prod7 = new Product2(
            Name = 'test1',
            Family = 'Musculoskelatal',
            ProductCode = 'TDBC',
            IsActive = true
        );
        pd.add(prod7);
        
        Product2 prod8 = new Product2(
            Name = 'Nutrition',
            Family = 'Nutrition',
            ProductCode = 'NUT',
            IsActive = true
        );
        pd.add(prod8);
        
        Product2 prod9 = new Product2(
            Name = 'NUTFEE',
            Family = 'Nutrition',
            ProductCode = 'NUTFEE',
            IsActive = true
        );
        pd.add(prod9);
      
        insert pd;
        
        Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
            Member_Group__c = grp.Id,
            Consult_Fee_Mbr_Pd__c = 0.80,
            Consults_per_Family__c = 4,
            Consult_Fee_Plan_Pd__c = 0.80,
            Consult_Frequency__c = 'Per Year'
        );
        insert gpRec;
        
        
        List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod9.Id
        );
        subL.add(sub12);
        
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod6.Id
        );
        subL.add(sub11);
       
        SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod8.Id
        );
        subL.add(sub9);
        
        SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod7.Id
        );
        subL.add(sub8);
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod.Id
        );
        subL.add(sub);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod5.Id
        );
        subL.add(sub2);
        
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod4.Id
        );
        subL.add(sub3);
        
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod3.Id
        );
        subL.add(sub4);
        
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(
            SBQQ__Account__c = a.Id,
            Status__c = 'Active',
            SBQQ__Quantity__c = 500,
            Consult_Fees__c = 0.90,
            SBQQ__Product__c = prod2.Id
        );
        subL.add(sub5);
        
        insert subL;
        
        
        gpRec.Subscription__c = sub.Id;
        gpRec.Product_Start_Date__c = Date.Today();
        gpRec.Actual_Copay_May_Be_Less__c = TRUE;
        update gpRec;
        
		List<Asset> assetL = new List<Asset>();
        
        Asset ast = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = null,
            Number_of_Lives__c = null,
            Teladoc_Net_Fee__c = null,
            InstallDate = Date.today(),
            Product2Id = prod.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub.Id
        );
        assetL.add(ast);
        
        Asset ast2 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Psych/MD-ONGOING-Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast2);
        
        Asset ast3 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod3.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub3.Id
        );
        assetL.add(ast3);
        
        Asset ast4 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub4.Id
        );
        assetL.add(ast4);
        
        Asset astt = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub9.Id
        );
        assetL.add(astt);
        
        Asset astt1 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod4.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub11.Id
        );
        assetL.add(astt1);
        
        Asset astt2 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub12.Id
        );
        assetL.add(astt2);
        
        Asset ast5 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = null,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod5.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub5.Id
        );
        assetL.add(ast5);
        
        Asset ast6 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Psych/MD-1stvisitonly-Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast6);
        
        Asset ast7 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
            Name = 'Consult Fee- Non-Psychiatrist- Total',
            SBQQ__RequiredBySubscription__c = sub2.Id
        );
        assetL.add(ast7);
        insert assetL;

        // Reload with relationship
        Map<Id, Asset> m = new Map<Id, Asset>([
                SELECT Id,Name,AccountId,Consult_Fees__c,Number_of_Lives__c,Teladoc_Net_Fee__c,
                        InstallDate,Product2.ProductCode,Product2Id,SBQQ__RequiredBySubscription__c,
                        SBQQ__RequiredBySubscription__r.Name
                FROM Asset
        ]);

        ast = m.get(ast.Id);
        ast2 = m.get(ast2.Id);
        ast3 = m.get(ast3.Id);
        ast4 = m.get(ast4.Id);
        ast5 = m.get(ast5.Id);

        System.debug('MyProduct' + prod4.ProductCode + ' id:' + prod4.Id);
        System.debug('MyCode' + ast4.Product2.ProductCode);
        try {
            testPSFPage(null, null);
        } catch (Exception e) {
            System.debug('should be error here');
        }	
        
        testPSFPage(gpRec, sub, false);
        testPSFPage(gpRec, sub2, false);
        testPSFPage(gpRec, sub3, false);
        testPSFPage(gpRec, sub4, false);
        testPSFPage(grp, sub11);
        testPSFPage(grp, sub9);
    }

    private static void testPSFPage(Mbr_Group__c grp, SBQQ__Subscription__c sub) {
        // WITH GROUP ONLY
        Account umrAcct = new Account();
        umrAcct.Name = 'UMR';
        umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
        umrAcct.Source__c = 'HUB';
        umrAcct.CurrencyIsoCode = 'USD';
        umrAcct.Business_Region__c = 'USA';
        umrAcct.Account_Type__c = 'Health Plan';
        insert umrAcct;
        PageReference pageRef = Page.PSFByProduct;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Plan_Specific_Fees__c());
        Plan_Specific_Fees__c tmpPlanSpecificFees = (Plan_Specific_Fees__c) sc.getRecord();
        tmpPlanSpecificFees.Member_Group__c = grp.Id;

        PlanSpecificFeeController psfc = new PlanSpecificFeeController(sc);
        psfc.selProduct();
        psfc.selGroup();

        psfc.selSubId = sub.Id;
        psfc.selProduct();
        psfc.SaveAndNew();
        psfc.Save();
    }

    private static void testPSFPage(Plan_Specific_Fees__c gpRec, SBQQ__Subscription__c sub, Boolean deleteSub) {
        // WITH SPECIFIC PSF
        Account umrAcct = new Account();
        umrAcct.Name = 'UMR';
        umrAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        umrAcct.Friendly_Account_Name__c = 'TestAmendAccount';
        umrAcct.Source__c = 'HUB';
        umrAcct.CurrencyIsoCode = 'USD';
        umrAcct.Business_Region__c = 'USA';
        umrAcct.Account_Type__c = 'Health Plan';
        insert umrAcct;
        PageReference pageRef = Page.PSFByProduct;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(gpRec);
        ApexPages.currentPage().getParameters().put('Id', gpRec.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + sub.Id);
        PlanSpecificFeeController psfc = new PlanSpecificFeeController(sc);

        psfc.selSubId = sub.Id;
        psfc.selProduct();

        psfc.groupProdRec.Consult_Fee_Mbr_Pd__c = .3;
        psfc.groupProdRec.Consult_Fee_Plan_Pd__c = .3;

        psfc.groupProdRec.TC_Mbr_Case_Rate_Fee__c = .3;
        psfc.groupProdRec.TC_Client_Case_Rate_Fee__c = .3;

        psfc.groupProdRec.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c = .3;
        psfc.groupProdRec.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c = .3;

        psfc.groupProdRec.Consult_Fee_Ongoing_MD_Mbr_Pd__c = .3;
        psfc.groupProdRec.Consult_Fee_Ongoing_MD_Plan_Pd__c = .3;

        psfc.groupProdRec.Consult_Fee_Initial_Diagnostic_Plan_Pd__c = .3;
        psfc.groupProdRec.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c = .3;

        psfc.groupProdRec.DERMConsult_Fee_Mbr_Pd__c = .3;
        psfc.groupProdRec.DERMConsult_Fee_Plan_Pd__c = .3;

        psfc.SaveAndNew();
        psfc.Save();
        psfc.Cancel();

        if (deleteSub) {
            psfc.DeleteSub();
            // second time should force error...
            psfc.DeleteSub();
        }
    }
*/
}