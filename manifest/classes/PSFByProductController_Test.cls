@IsTest
private class PSFByProductController_Test {
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
    }
    
    @IsTest
    static void findSub() {
        Mbr_Group__c mg = [SELECT Id, Client_Account__r.Id FROM Mbr_Group__c WHERE Name__c ='testgrp1' LIMIT 1];
        string mgId = string.valueOf(mg.id);
        PSFByProductController.findSub(mgId);             
    }
    
    @IsTest
    static void mgName() {
        Mbr_Group__c mg = [SELECT Id, Client_Account__r.Id FROM Mbr_Group__c WHERE Name__c ='testgrp1' LIMIT 1];
        string mgId = string.valueOf(mg.id);
        String NameString = PSFByProductController.mgName(mgId);  
        system.assertEquals('testgrp1', NameString);
    }
    
    @IsTest
    static void getAsset() {
        SBQQ__Subscription__c sub = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'Behavioral Health'
                                     LIMIT 1];
        String pCode = String.ValueOf(sub.SBQQ__Product__r.ProductCode);
        String subId = String.ValueOf(sub.Id);
        PSFByProductController.getAsset(subId, pCode);  
        
        SBQQ__Subscription__c sub1 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'General Medical'
                                     LIMIT 1];
        String pCode1 = String.ValueOf(sub1.SBQQ__Product__r.ProductCode);
        String subId1 = String.ValueOf(sub1.Id);
        PSFByProductController.getAsset(subId1, pCode1);
        
        SBQQ__Subscription__c sub2 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'Tobacco Cessation'
                                     LIMIT 1];
        String pCode2 = String.ValueOf(sub2.SBQQ__Product__r.ProductCode);
        String subId2 = String.ValueOf(sub2.Id);
        PSFByProductController.getAsset(subId2, pCode2);
        
        SBQQ__Subscription__c sub3 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'GLOBALCARE'
                                     LIMIT 1];
        String pCode3 = String.ValueOf(sub3.SBQQ__Product__r.ProductCode);
        String subId3 = String.ValueOf(sub3.Id);
        PSFByProductController.getAsset(subId3, pCode3);
        
        SBQQ__Subscription__c sub4 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'Dermatology'
                                     LIMIT 1];
        String pCode4 = String.ValueOf(sub4.SBQQ__Product__r.ProductCode);
        String subId4 = String.ValueOf(sub4.Id);
        PSFByProductController.getAsset(subId4, pCode4);
        
        SBQQ__Subscription__c sub5 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                     Consult_Fees__c, Current_Membership_Fee__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                     FROM SBQQ__Subscription__c 
                                     WHERE SBQQ__Product__r.Name = 'Nutrition'
                                     LIMIT 1];
        String pCode5 = String.ValueOf(sub5.SBQQ__Product__r.ProductCode);
        String subId5 = String.ValueOf(sub5.Id);
        PSFByProductController.getAsset(subId5, pCode5);
        
        SBQQ__Subscription__c sub6 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                      Consult_Fees__c, Current_Membership_Fee__c,
                                      SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                      SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                      FROM SBQQ__Subscription__c 
                                      WHERE SBQQ__Product__r.Name = 'test1'
                                      LIMIT 1];
        String pCode6 = String.ValueOf(sub6.SBQQ__Product__r.ProductCode);
        String subId6 = String.ValueOf(sub6.Id);
        PSFByProductController.getAsset(subId6, pCode6);
        
        SBQQ__Subscription__c sub7 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                      Consult_Fees__c, Current_Membership_Fee__c,
                                      SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                      SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                      FROM SBQQ__Subscription__c 
                                      WHERE SBQQ__Product__r.Name = 'Back Care'
                                      LIMIT 1];
        String pCode7 = String.ValueOf(sub7.SBQQ__Product__r.ProductCode);
        String subId7 = String.ValueOf(sub7.Id);
        PSFByProductController.getAsset(subId7, pCode7);
        
        SBQQ__Subscription__c sub8 = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                      Consult_Fees__c, Current_Membership_Fee__c,
                                      SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Sort_Order__c,
                                      SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                      FROM SBQQ__Subscription__c 
                                      WHERE SBQQ__Product__r.Name = 'NUTFEE'
                                      LIMIT 1];
        String pCode8 = String.ValueOf(sub8.SBQQ__Product__r.ProductCode);
        String subId8 = String.ValueOf(sub8.Id);
        PSFByProductController.getAsset(subId8, pCode8);
    }
    
    @IsTest
    static void deletePSF() {
        PSF_Permission_Setting__c objDS=new PSF_Permission_Setting__c(SetupOwnerId=UserInfo.getUserId(),User_Permission__c=true);
        insert objDS;
        Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
        String psfId = string.valueOf(psf.id);
        PSFByProductController.deletePSF(psfId);  
        system.assertEquals(0, [SELECT count() FROM Plan_Specific_Fees__c]);
    }
    
    @IsTest
    static void getHistories() {
        Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c];
        String psfId = string.valueOf(psf.id);
        List<Plan_Specific_Fees__History> psfHist = PSFByProductController.getHistories(psfId);  
        system.assertEquals(0, psfHist.size());
    }
    @IsTest
    static void getPSF() {
        Plan_Specific_Fees__c psf = [SELECT Id, Member_Group__c FROM Plan_Specific_Fees__c];
        String psfId = string.valueOf(psf.id);
        Plan_Specific_Fees__c psfInfo = PSFByProductController.getPSF(psfId);  
        system.assertEquals(psf.Member_Group__c, psfInfo.Member_Group__c);
    }
    
    @IsTest
    static void findObjTypeTest() {
        Account acct = [SELECT Id FROM Account WHERE Name != 'UMR'];
        String objType = PSFByProductController.findObjType(acct.Id);
        system.assertEquals('Account' , objType);
    }
  
}