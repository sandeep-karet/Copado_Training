@IsTest
private class MassPsfPageLwc_Controller_Test {
    @TestSetup
    static void testsetup() {
        
        PSF_Permission_Setting__c objDS=new PSF_Permission_Setting__c(SetupOwnerId=UserInfo.getUserId(),User_Permission__c=true);
        insert objDS;
        Account umrAcct = TestDataFactory.createUMR();
        Account a = new Account(Name = 'Test01', Source__c = 'HUB');
		insert a;
        Account testAcc = new Account(Name = 'Test02', Source__c = 'HUB');
		insert testAcc;
        
        List<Mbr_Group__c> mg = new List<Mbr_Group__c>();
        Mbr_Group__c grp = new Mbr_Group__c(Name__c = 'testgrp1', Client_Account__c = a.Id, Status__c = 'ACTIVE', Active_Date__c = Date.today());
        mg.add(grp);
        Mbr_Group__c grp2 = new Mbr_Group__c(Name__c = 'testgrp2', Client_Account__c = a.Id, Status__c = 'ACTIVE', Active_Date__c = Date.today());
        mg.add(grp2);
        insert mg;
        Mbr_Group_Role__c r = new Mbr_Group_Role__c(Role_Type__c = 'Payer', Source_Account__c = testAcc.Id, Mbr_Group__c = mg[0].Id);
        insert r;
        Mbr_Group_Role__c r2 = new Mbr_Group_Role__c(Role_Type__c = 'Billing', Source_Account__c = testAcc.Id, Mbr_Group__c = mg[0].Id);
        insert r2;
        Mbr_Group_Role__c r3 = new Mbr_Group_Role__c(Role_Type__c = 'Contractee', Source_Account__c = testAcc.Id, Mbr_Group__c = mg[0].Id);
        insert r3;
		
        List<Product2> pd = new List<Product2>();
        Product2 prod = new Product2(Name = 'GLOBALCARE', Family = 'GLOBAL CARE', ProductCode = 'GLOBALCARE', IsActive = true);
        pd.add(prod);
        Product2 prod2 = new Product2(Name = 'Dermatology', Family = 'Dermatology', ProductCode = 'DERM', IsActive = true);
        pd.add(prod2);
        Product2 prod3 = new Product2( Name = 'Tobacco Cessation', Family = 'Tobacco Cessation', ProductCode = 'TC', IsActive = true);
        pd.add(prod3);
        Product2 prod4 = new Product2(Name = 'General Medical', Family = 'General Medical', ProductCode = 'GM', IsActive = true);
        pd.add(prod4);
        Product2 prod5 = new Product2(Name = 'Behavioral Health', Family = 'Behavioral Health', ProductCode = 'BH', IsActive = true);
        pd.add(prod5);
        Product2 prod6 = new Product2(Name = 'Back Care', Family = 'Musculoskelatal', ProductCode = 'TDBC', IsActive = true);
        pd.add(prod6);
        Product2 prod7 = new Product2(Name = 'test1', Family = 'Musculoskelatal', ProductCode = 'TDBC', IsActive = true);
        pd.add(prod7);
        Product2 prod8 = new Product2(Name = 'Nutrition', Family = 'Nutrition', ProductCode = 'NUT', IsActive = true);
        pd.add(prod8);
        Product2 prod9 = new Product2(Name = 'NUTFEE', Family = 'Nutrition', ProductCode = 'NUTFEE', IsActive = true);
        pd.add(prod9);
        insert pd;
        Plan_Specific_Fees__c gpRec = new Plan_Specific_Fees__c(Member_Group__c = grp.Id, Consult_Fee_Mbr_Pd__c = 0.80, Consults_per_Family__c = 4, Consult_Fee_Plan_Pd__c = 0.80, Consult_Frequency__c = 'Per Year');
        insert gpRec;
        List<SBQQ__Subscription__c> subL = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod9.Id);
        subL.add(sub12);
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod6.Id);
        subL.add(sub11);
        SBQQ__Subscription__c sub9 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod8.Id);
        subL.add(sub9);
        SBQQ__Subscription__c sub8 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod7.Id);
        subL.add(sub8);
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod.Id);
        subL.add(sub);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod5.Id);
        subL.add(sub2);       
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod4.Id);
        subL.add(sub3);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c( SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod3.Id);
        subL.add(sub4);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c( SBQQ__Account__c = a.Id, Status__c = 'Active', SBQQ__Quantity__c = 500, Consult_Fees__c = 0.90, SBQQ__Product__c = prod2.Id);
        subL.add(sub5);
        insert subL;
        gpRec.Subscription__c = sub.Id;
        gpRec.Product_Start_Date__c = Date.Today();
        gpRec.Actual_Copay_May_Be_Less__c = TRUE;
        update gpRec;
        List<Asset> assetL = new List<Asset>();
        Asset ast = new Asset(AccountId = a.Id, Consult_Fees__c = null, Number_of_Lives__c = null, Teladoc_Net_Fee__c = null, InstallDate = Date.today(), Product2Id = prod.Id, Name = 'test asset', SBQQ__RequiredBySubscription__c = sub.Id);
        assetL.add(ast); 
        Asset ast3 = new Asset(AccountId = a.Id, Consult_Fees__c = 0.60, Number_of_Lives__c = 1000, Teladoc_Net_Fee__c = 0.80, InstallDate = Date.today(), Product2Id = prod3.Id, Name = 'test asset', SBQQ__RequiredBySubscription__c = sub3.Id);
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
        insert assetL;
    }
    
    @IsTest
    static void findSub() {
        Mbr_Group__c mg = [SELECT Id, Client_Account__r.Id FROM Mbr_Group__c WHERE Name__c ='testgrp1' LIMIT 1];
        string mgId = string.valueOf(mg.id);
        MassPsfPageLwc_Controller.findSub(mgId);             
    }
    
    @IsTest
    static void mgName() {
        Mbr_Group__c mg = [SELECT Id, Client_Account__r.Id FROM Mbr_Group__c WHERE Name__c ='testgrp1' LIMIT 1];
        string mgId = string.valueOf(mg.id);
        String NameString = MassPsfPageLwc_Controller.mgName(mgId);  
        system.assertEquals('testgrp1', NameString);
    }
    
    @IsTest
    static void deletePSF() {
        Plan_Specific_Fees__c psf = [SELECT Id, Subscription__c, Member_Group__c FROM Plan_Specific_Fees__c];
        MassPsfPageLwc_Controller.deletePSF(psf.Member_Group__c, psf.Subscription__c);  
        system.assertEquals(0, [SELECT count() FROM Plan_Specific_Fees__c]);
    }
    
    @IsTest
    static void getHistories() {
        Plan_Specific_Fees__c psf = [SELECT Id, Member_Group__c, Subscription__c FROM Plan_Specific_Fees__c];
        List<Plan_Specific_Fees__History> psfHist = MassPsfPageLwc_Controller.getHistories(psf.Member_Group__c, psf.Subscription__c); 
        system.assertEquals(0, psfHist.size());
    }
    @IsTest
    static void getPSF() {
        Plan_Specific_Fees__c psf = [SELECT Id, Member_Group__c FROM Plan_Specific_Fees__c];
        MassPsfPageLwc_Controller.getPSF(psf.id);  
    }
    
     @IsTest
    static void getMbrGrpRoles() {
        //Mbr_Group__c mg = [SELECT Id, Client_Account__r.Id FROM Mbr_Group__c WHERE Name__c ='testgrp1' LIMIT 1];
        List<Mbr_Group_Role__c> mbrGrpList = [SELECT Id, Role_Type__c, Source_Account__c, Mbr_Group__c FROM Mbr_Group_Role__c WHERE 
                                              Role_Type__c IN ('Payer', 'Contractee', 'Billing')];
        string mgId = string.valueOf(mbrGrpList[0].Mbr_Group__c);
        string psfId = '';
        system.debug('PSFS:: ' + mgId);
        MassPsfPageLwc_Controller.getMbrGrpRoles(mgId,psfId);  
        Plan_Specific_Fees__c psfRecord = [SELECT Id, Member_Group__c FROM Plan_Specific_Fees__c WHERE Member_Group__c =:mgId LIMIT 1];
        MassPsfPageLwc_Controller.getMbrGrpRoles(mgId,psfRecord.Id); 
        
    }
    
    @IsTest
    static void findObjTypeTest() {
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test01'];
        String objType = MassPsfPageLwc_Controller.findObjType(acct.Id);
        system.assertEquals('Account' , objType);
    }
    
    @IsTest
    static void createUpdateDeleteBHTest() {
        List<Plan_Specific_Fees__c> psfList = new List<Plan_Specific_Fees__c>();
        Mbr_Group__c mbrGroup = [SELECT Id FROM Mbr_Group__c LIMIT 1];
        SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.ProductCode = 'BH'];
        Asset BHP1TAsset = [SELECT Id FROM Asset WHERE Name = 'Consult Fee- Psych/MD-1stvisitonly-Total'];
        Asset BHPOTAsset = [SELECT Id FROM Asset WHERE Name = 'Consult Fee- Psych/MD-ONGOING-Total'];
        Asset BHNPTAsset = [SELECT Id FROM Asset WHERE Name = 'Consult Fee- Non-Psychiatrist- Total'];
        Plan_Specific_Fees__c psf1 = new Plan_Specific_Fees__c();
        psf1.Asset__c = BHP1TAsset.Id;
        psf1.Consult_Fee_Mbr_Pd__c = 0.6;
        psf1.Member_Group__c = mbrGroup.Id;
        psf1.Subscription__c = sub.Id;
        psfList.add(psf1);
        Plan_Specific_Fees__c psf2 = new Plan_Specific_Fees__c();
        psf2.Asset__c = BHPOTAsset.Id;
        psf2.Consult_Fee_Mbr_Pd__c = 0.6;
        psf2.Member_Group__c = mbrGroup.Id;
        psf2.Subscription__c = sub.Id;
        psfList.add(psf2);
        Plan_Specific_Fees__c psf3 = new Plan_Specific_Fees__c();
        psf3.Asset__c = BHNPTAsset.Id;
        psf3.Consult_Fee_Mbr_Pd__c = 0.6;
        psf3.Member_Group__c = mbrGroup.Id;
        psf3.Subscription__c = sub.Id;
        psfList.add(psf3);
        MassPsfPageLwc_Controller.createPSF(psfList);
        system.assertEquals(4, [SELECT Count() FROM Plan_Specific_Fees__c]);
		psf1.Actual_Copay_May_Be_Less__c = true;
        List<Plan_Specific_Fees__c> updateList = new List<Plan_Specific_Fees__c>();
        updateList.add(psf1);
        updateList.add(psf2);
        updateList.add(psf3);
        MassPsfPageLwc_Controller.updatePSF(updateList, mbrGroup.Id, sub.Id);
        MassPsfPageLwc_Controller.deletePSF(mbrGroup.Id, sub.Id);
        system.assertEquals(1, [SELECT Count() FROM Plan_Specific_Fees__c]);
    }
  
}