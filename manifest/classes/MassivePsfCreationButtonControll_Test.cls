@IsTest
private class MassivePsfCreationButtonControll_Test {
    @TestSetup
    static void testsetup() {
        Account umrAcct = TestDataFactory.createUMR();           
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
        
        List<Product2> pd = new List<Product2>();    
        
        Product2 prod = new Product2(
            Name = 'Dermatology',
            Family = 'Dermatology',
            ProductCode = 'DERM',
            IsActive = true
        );
        pd.add(prod);
        
        Product2 prod2 = new Product2(
            Name = 'Dermatology',
            Family = 'Dermatology',
            ProductCode = 'DERMFEE',
            IsActive = true
        );
        pd.add(prod2);
        
        Product2 prod3 = new Product2(
            Name = 'Tobacco Cessation',
            Family = 'Tobacco Cessation',
            ProductCode = 'TCPROGFEE',
            IsActive = true
        );
        pd.add(prod3);
        
        
        Product2 prod3_1 = new Product2(
            Name = 'Tobacco Cessation',
            Family = 'Tobacco Cessation',
            ProductCode = 'TCPROGFEE',
            IsActive = true
        );
        pd.add(prod3_1);
        
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
            ProductCode = 'BHNPT',
            IsActive = true
        );
        pd.add(prod5);
        
        Product2 prod6 = new Product2(
            Name = 'Behavioral Health',
            Family = 'Behavioral Health',
            ProductCode = 'BHP1T',
            IsActive = true
        );
        pd.add(prod6);
        
        Product2 prod7 = new Product2(
            Name = 'Behavioral Health',
            Family = 'Behavioral Health',
            ProductCode = 'BHPOT',
            IsActive = true
        );
        pd.add(prod7);
        
        Product2 prod8 = new Product2(
            Name = 'Behavioral Health',
            Family = 'Behavioral Health',
            ProductCode = 'BH',
            IsActive = true
        );
        pd.add(prod8);
        
        insert pd;  
        
        List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();
 
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
            SBQQ__Product__c = prod3.Id
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
            SBQQ__Product__c = prod8.Id
        );
        subL.add(sub4);
    
        insert subL;
        
        
        Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(
            Member_Group__c = grp.Id,
            Consult_Fee_Mbr_Pd__c = 0.80,
            Consults_per_Family__c = 4,
            Consult_Fee_Plan_Pd__c = 0.80,
            Consult_Frequency__c = 'Per Year',
            Subscription__c = sub.Id,
            Product_Start_Date__c  = Date.Today()
            
        );
        insert gpRec;
     
        
		List<Asset> assetL = new List<Asset>();
        
        Asset ast = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.30,
            Number_of_Lives__c = null,
            Teladoc_Net_Fee__c = null,
            InstallDate = Date.today(),
            Product2Id = prod2.Id,
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
            Product2Id = prod3.Id,
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
            Product2Id = prod5.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub4.Id
        );
        assetL.add(ast3);
        
        Asset ast4 = new Asset(
            AccountId = a.Id,
            Consult_Fees__c = 0.60,
            Number_of_Lives__c = 1000,
            Teladoc_Net_Fee__c = 0.80,
            InstallDate = Date.today(),
            Product2Id = prod6.Id,
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
            Product2Id = prod7.Id,
            Name = 'test asset',
            SBQQ__RequiredBySubscription__c = sub4.Id
        );
        assetL.add(astt);
        
        insert assetL;
    }
    
    @IsTest
    static void webServiceCallTest() {
        SBQQ__Subscription__c subBH = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.ProductCode ='BH'];
        
        MassPsfCreationButtonController.callMassiveCreation(subBH.Id);
    }
    
    @isTest
    static void countRecord() {
        SBQQ__Subscription__c sub = [SELECT id FROM SBQQ__Subscription__c LIMIT 1];
        MassPsfCreationButtonController.doCount(sub.Id);
    }
}