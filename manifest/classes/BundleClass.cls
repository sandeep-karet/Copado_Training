public class BundleClass {
    public static Map<SBQQ__Subscription__c, bhSubAssetWrapper> bhSubAssetMap { get; set; }
    public static Map<SBQQ__Subscription__c, p360SubAssetWrapper> p360SubAssetMap { get; set; }
    public static Map<SBQQ__Subscription__c, mhSubAssetWrapper> mhSubAssetMap { get; set; }
    public static Map<String, List<Plan_Specific_Fees__c>> existingBHPsf { get; set; }
    public static Map<String, List<Plan_Specific_Fees__c>> existingp360Psf { get; set; }
    public static Map<String, List<Plan_Specific_Fees__c>> existingMHPsf { get; set; }

    public class bhSubAssetWrapper{
        public Asset BHP1TAsset {get; set;}
        public Asset BHPOTAsset {get; set;}
        public Asset BHNPTAsset {get; set;}
        public bhSubAssetWrapper(Asset BHP1TAsset, Asset BHPOTAsset, Asset BHNPTAsset) {
            this.BHP1TAsset = BHP1TAsset;
            this.BHPOTAsset = BHPOTAsset;
            this.BHNPTAsset = BHNPTAsset;
        }
    }
    public class p360SubAssetWrapper{
        public Asset PRIMCARECFAsset {get; set;}
        public Asset PRIMCAREACFAsset {get; set;}
        public Asset NEWPATCFAsset {get; set;}
        public Asset PRIMCAREFCFAsset {get; set;}
        public p360SubAssetWrapper(Asset PRIMCARECFAsset, Asset PRIMCAREACFAsset, Asset NEWPATCFAsset, Asset PRIMCAREFCFAsset) {
            this.PRIMCARECFAsset = PRIMCARECFAsset;
            this.PRIMCAREACFAsset = PRIMCAREACFAsset;
            this.NEWPATCFAsset = NEWPATCFAsset;
            this.PRIMCAREFCFAsset = PRIMCAREFCFAsset;
        }
    }
    
    public class mhSubAssetWrapper{
        public Asset BHPOTAsset {get; set;}
        public Asset BHPOOTAsset {get; set;}
        public Asset BHNPTAsset {get; set;}
        public Asset BHP1TAsset {get; set;}
        public mhSubAssetWrapper(Asset BHPOTAsset, Asset BHPOOTAsset, Asset BHNPTAsset, Asset BHP1TAsset) {
            this.BHPOTAsset = BHPOTAsset;
            this.BHPOOTAsset = BHPOOTAsset;
            this.BHNPTAsset = BHNPTAsset;
            this.BHP1TAsset = BHP1TAsset;
        }
    }
    
    public static void createBhMhSubAssetMap(String parentGUID) {
        if (bhSubAssetMap == Null) {
			bhSubAssetMap = new Map<SBQQ__Subscription__c, bhSubAssetWrapper>();
		}
        if (p360SubAssetMap == Null) {
			p360SubAssetMap = new Map<SBQQ__Subscription__c, p360SubAssetWrapper>();
		}
        if (mhSubAssetMap == Null) {
			mhSubAssetMap = new Map<SBQQ__Subscription__c, mhSubAssetWrapper>();
		}	
        for (SBQQ__Subscription__c sub: [SELECT Id, Fee_Type__c, SBQQ__Product__r.ProductCode, Current_Membership_Fee__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c, (SELECT Id, Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r) 
                                         FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Guid__c =: parentGUID AND SBQQ__Product__r.ProductCode = 'BH' 
                                         AND (SBQQ__SubscriptionStartDate__c <= TODAY OR Termination_Date__c = Null) ORDER BY SBQQ__SubscriptionStartDate__c DESC]) {
            Asset BHP1T, BHPOT, BHNPT;                                 
            for (Asset asset: sub.SBQQ__ChildAssets__r) {
                if (asset.Product2.ProductCode == 'BHP1T') {
                        BHP1T 
                            
                            = asset;
                } else if (asset.Product2.ProductCode == 'BHPOT') { 
                        BHPOT = asset;
                } else if (asset.Product2.ProductCode == 'BHNPT') {
                        BHNPT = asset;
                } 
            }
            bhSubAssetMap.put(sub, new bhSubAssetWrapper(BHP1T, BHPOT, BHNPT));                           
        }
        for (SBQQ__Subscription__c sub: [SELECT Id, Fee_Type__c, SBQQ__Product__r.ProductCode, Current_Membership_Fee__c,  SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c,(SELECT Id, Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r) 
                                         FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Guid__c =: parentGUID AND SBQQ__Product__r.ProductCode = 'PRIM360CARE' 
                                         AND (SBQQ__SubscriptionStartDate__c <= TODAY OR Termination_Date__c = Null) ORDER BY SBQQ__SubscriptionStartDate__c DESC]) {
            Asset PRIMCARECF, PRIMCAREACF, NEWPATCF, PRIMCAREFCF;                                 
            for (Asset asset: sub.SBQQ__ChildAssets__r) {
                if (asset.Product2.ProductCode == 'PRIMCARECF') {
                        PRIMCARECF = asset;
                } else if (asset.Product2.ProductCode == 'PRIMCAREACF') { 
                        PRIMCAREACF = asset;
                } else if (asset.Product2.ProductCode == 'NEWPATCF') {
                        NEWPATCF = asset;
                }
                else if (asset.Product2.ProductCode == 'PRIMCAREFCF') {
                        PRIMCAREFCF = asset;
                }
 
            }
            p360SubAssetMap.put(sub, new p360SubAssetWrapper(PRIMCARECF, PRIMCAREACF, NEWPATCF, PRIMCAREFCF));                           
        }
        for (SBQQ__Subscription__c sub: [SELECT Id, Fee_Type__c, SBQQ__Product__r.ProductCode, Current_Membership_Fee__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c, (SELECT Id, Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r) 
                                         FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Guid__c =: parentGUID AND SBQQ__Product__r.ProductCode = 'MH' 
                                         AND (SBQQ__SubscriptionStartDate__c <= TODAY OR Termination_Date__c = Null) ORDER BY SBQQ__SubscriptionStartDate__c DESC]) {
            Asset BHPOT, BHPOOT, BHNPT, BHP1T;                                 
            for (Asset asset: sub.SBQQ__ChildAssets__r) {
                if (asset.Product2.ProductCode == 'BHPOT') {
                        BHPOT = asset;
                } else if (asset.Product2.ProductCode == 'BHPOOT') { 
                        BHPOOT = asset;
                } else if (asset.Product2.ProductCode == 'BHNPT') {
                        BHNPT = asset;
                } else if (asset.Product2.ProductCOde == 'BHP1T') {
                    	BHP1T = asset;
                }
            }
            mhSubAssetMap.put(sub, new mhSubAssetWrapper(BHPOT, BHPOOT, BHNPT, BHP1T));                           
        }   
    }
  
    public Map<String, Plan_Specific_Fees__c> findBH(Map<String, Plan_Specific_Fees__c> bhPsfMap, SBQQ__Subscription__c sub, String opportunityGUID) {
        if (bhSubAssetMap == Null) {
            return null;
		}
        Map<String, Plan_Specific_Fees__c> updatedPSF = new Map<String, Plan_Specific_Fees__c>();
        Plan_Specific_Fees__c BHP1T, BHPOT, BHNPT;
        for (String productCode: bhPsfMap.keySet()) {
            switch on productCode {
                when 'BHP1T' {
                    BHP1T = bhPsfMap.get(productCode);
                }
                when 'BHPOT' {
                    BHPOT = bhPsfMap.get(productCode);
                }
                when 'BHNPT' {
                    BHNPT = bhPsfMap.get(productCode);
                }
            }  
        }
        for (SBQQ__Subscription__c mapSub: bhSubAssetMap.keySet()) {
            if (mapSub.Fee_Type__c == sub.Fee_Type__c && mapSub.Current_Membership_Fee__c == sub.Current_Membership_Fee__c && ((opportunityGUID!=null && opportunityGUID == mapSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c) || (opportunityGUID==null || opportunityGUID=='')) &&
                bhSubAssetMap.get(mapSub).BHP1TAsset.Consult_Fees__c == (BHP1T.Consult_Fee_Mbr_Pd__c + BHP1T.Consult_Fee_Plan_Pd__c) &&
                bhSubAssetMap.get(mapSub).BHPOTAsset.Consult_Fees__c == (BHPOT.Consult_Fee_Mbr_Pd__c + BHPOT.Consult_Fee_Plan_Pd__c) &&
                bhSubAssetMap.get(mapSub).BHNPTAsset.Consult_Fees__c == (BHNPT.Consult_Fee_Mbr_Pd__c + BHNPT.Consult_Fee_Plan_Pd__c)) {
                    BHP1T.Asset__c = bhSubAssetMap.get(mapSub).BHP1TAsset.Id;
                    BHPOT.Asset__c = bhSubAssetMap.get(mapSub).BHPOTAsset.Id;
                    BHNPT.Asset__c = bhSubAssetMap.get(mapSub).BHNPTAsset.Id;
                    BHP1T.Subscription__c = mapSub.Id;
                    BHPOT.Subscription__c = mapSub.Id;
                    BHNPT.Subscription__c = mapSub.Id;
                    updatedPSF.put('BHP1T', BHP1T);
                    updatedPSF.put('BHPOT', BHPOT);
                    updatedPSF.put('BHNPT', BHNPT);
                    break;
                }
        }
        if (updatedPSf.size() != 3)
            return null;
        else 
            return updatedPSF;
    }
    public Map<String, Plan_Specific_Fees__c> findp360(Map<String, Plan_Specific_Fees__c> p360PsfMap, SBQQ__Subscription__c sub, String opportunityGUID	) {
        if (p360SubAssetMap == Null) {
            return null;
		}
        Map<String, Plan_Specific_Fees__c> updatedPSF = new Map<String, Plan_Specific_Fees__c>();
        Plan_Specific_Fees__c PRIMCARECF, PRIMCAREACF, NEWPATCF, PRIMCAREFCF;
        for (String productCode: p360PsfMap.keySet()) {
            switch on productCode {
                when 'PRIMCARECF' {
                    PRIMCARECF = p360PsfMap.get(productCode);
                }
                when 'PRIMCAREACF' {
                    PRIMCAREACF = p360PsfMap.get(productCode);
                }
                when 'NEWPATCF' {
                    NEWPATCF = p360PsfMap.get(productCode);
                }
                when 'PRIMCAREFCF' {
                    PRIMCAREFCF = p360PsfMap.get(productCode);
                }
            }  
        }
        for (SBQQ__Subscription__c mapSub: p360SubAssetMap.keySet()) {
            if (mapSub.Fee_Type__c == sub.Fee_Type__c && mapSub.Current_Membership_Fee__c == sub.Current_Membership_Fee__c && ((opportunityGUID!=null && opportunityGUID == mapSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c) || (opportunityGUID==null || opportunityGUID=='')) &&
                p360SubAssetMap.get(mapSub).PRIMCARECFAsset.Consult_Fees__c == (PRIMCARECF.Consult_Fee_Mbr_Pd__c + PRIMCARECF.Consult_Fee_Plan_Pd__c) &&
                p360SubAssetMap.get(mapSub).PRIMCAREACFAsset.Consult_Fees__c == (PRIMCAREACF.Consult_Fee_Mbr_Pd__c + PRIMCAREACF.Consult_Fee_Plan_Pd__c) &&
                p360SubAssetMap.get(mapSub).NEWPATCFAsset.Consult_Fees__c == (NEWPATCF.Consult_Fee_Mbr_Pd__c + NEWPATCF.Consult_Fee_Plan_Pd__c) &&
                p360SubAssetMap.get(mapSub).PRIMCAREFCFAsset.Consult_Fees__c == (PRIMCAREFCF.Consult_Fee_Mbr_Pd__c + PRIMCAREFCF.Consult_Fee_Plan_Pd__c)) {
                    PRIMCARECF.Asset__c = p360SubAssetMap.get(mapSub).PRIMCARECFAsset.Id;
                    PRIMCAREACF.Asset__c = p360SubAssetMap.get(mapSub).PRIMCAREACFAsset.Id;
                    NEWPATCF.Asset__c = p360SubAssetMap.get(mapSub).NEWPATCFAsset.Id;
                    PRIMCAREFCF.Asset__c = p360SubAssetMap.get(mapSub).PRIMCAREFCFAsset.Id;
                    PRIMCARECF.Subscription__c = mapSub.Id;
                    PRIMCAREACF.Subscription__c = mapSub.Id;
                    NEWPATCF.Subscription__c = mapSub.Id;
                    PRIMCAREFCF.Subscription__c = mapSub.Id;
                    updatedPSF.put('PRIMCARECF', PRIMCARECF);
                    updatedPSF.put('PRIMCAREACF', PRIMCAREACF);
                    updatedPSF.put('NEWPATCF', NEWPATCF);
                    updatedPSF.put('PRIMCAREFCF', PRIMCAREFCF);
                    break;
                }
        }
        if (updatedPSf.size() != 4)
            return null;
        else 
            return updatedPSF;
    }
    
    public Map<String, Plan_Specific_Fees__c> findMH(Map<String, Plan_Specific_Fees__c> mhPsfMap, SBQQ__Subscription__c sub, String opportunityGUID) {
        if (mhSubAssetMap == Null) {
            return null;
		}
        Map<String, Plan_Specific_Fees__c> updatedPSF = new Map<String, Plan_Specific_Fees__c>();
        Plan_Specific_Fees__c BHPOT, BHPOOT, BHNPT, BHP1T;
        for (String productCode: mhPsfMap.keySet()) {
            switch on productCode {
                when 'BHPOT' {
                    BHPOT = mhPsfMap.get(productCode);
                }
                when 'BHPOOT' {
                    BHPOOT = mhPsfMap.get(productCode);
                }
                when 'BHNPT' {
                    BHNPT = mhPsfMap.get(productCode);
                }
                when 'BHP1T' {
                    BHP1T = mhPsfMap.get(productCode);
                }
            }  
        }
        for (SBQQ__Subscription__c mapSub: mhSubAssetMap.keySet()) {
            if (mapSub.Fee_Type__c == sub.Fee_Type__c && mapSub.Current_Membership_Fee__c == sub.Current_Membership_Fee__c && ((opportunityGUID!=null && opportunityGUID == mapSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c) || (opportunityGUID==null || opportunityGUID=='')) &&
                mhSubAssetMap.get(mapSub).BHPOTAsset.Consult_Fees__c == (BHPOT.Consult_Fee_Mbr_Pd__c + BHPOT.Consult_Fee_Plan_Pd__c) &&
                mhSubAssetMap.get(mapSub).BHPOOTAsset.Consult_Fees__c == (BHPOOT.Consult_Fee_Mbr_Pd__c + BHPOOT.Consult_Fee_Plan_Pd__c) &&
                mhSubAssetMap.get(mapSub).BHNPTAsset.Consult_Fees__c == (BHNPT.Consult_Fee_Mbr_Pd__c + BHNPT.Consult_Fee_Plan_Pd__c) && 
                mhSubAssetMap.get(mapSub).BHP1TAsset.Consult_Fees__c == (BHP1T.Consult_Fee_Mbr_Pd__c + BHP1T.Consult_Fee_Plan_Pd__c)) {
                    BHPOT.Asset__c = mhSubAssetMap.get(mapSub).BHPOTAsset.Id;
                    BHPOOT.Asset__c = mhSubAssetMap.get(mapSub).BHPOOTAsset.Id;
                    BHNPT.Asset__c = mhSubAssetMap.get(mapSub).BHNPTAsset.Id;
                    BHP1T.Asset__c = mhSubAssetMap.get(mapSub).BHP1TAsset.Id;
                    BHPOT.Subscription__c = mapSub.Id;
                    BHPOOT.Subscription__c = mapSub.Id;
                    BHNPT.Subscription__c = mapSub.Id;
                    BHP1T.Subscription__c = mapSub.Id;
                    updatedPSF.put('BHPOT', BHPOT);
                    updatedPSF.put('BHPOOT', BHPOOT);
                    updatedPSF.put('BHNPT', BHNPT);
                    updatedPSF.put('BHP1T', BHP1T);
                    break;
                }
        }
        if (updatedPSf.size() != 4)
            return null;
        else 
            return updatedPSF;
    }
   
    public void createExistingKey(String prodCode, List<Plan_Specific_Fees__c> psfList) {
        if (existingBHPsf == Null) {
			existingBHPsf = new Map<String, List<Plan_Specific_Fees__c>>();
		}
        if (existingMHPsf == Null) {
			existingMHPsf = new Map<String, List<Plan_Specific_Fees__c>>();
		}
        Map<String, List<Plan_Specific_Fees__c>> psfMap = new Map<String, List<Plan_Specific_Fees__c>>();
        for (Plan_Specific_Fees__c psf : psfList) {
            if (psfMap.containsKey(psf.Subscription__c)) {
                psfMap.get(psf.Subscription__c).add(psf);
                psfMap.put(psf.Subscription__c, psfMap.get(psf.Subscription__c));
            } else {
                List<Plan_Specific_Fees__c> newList = new List<Plan_Specific_Fees__c>();
                newList.add(psf);
                psfMap.put(psf.Subscription__c, newList);
            }  
        }
        if (prodCode == 'BH') {
            for (String subId: psfMap.keyset()) {
                String BHP1TMbr, BHPOTMbr, BHNPTMbr, startDate, endDate, payLess;
                List<Plan_Specific_Fees__c> oldBHPsf = new List<Plan_Specific_Fees__c>();
                for (Plan_Specific_Fees__c psf: psfMap.get(subId)) {
                    switch on psf.PSF_ProductCode__c {
                        when 'BHP1T' {
                            BHP1TMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                            startDate = String.valueOf(psf.Product_Start_Date__c);
                            endDate = String.valueOf(psf.Product_End_Date__c);
                            payLess = String.valueOf(psf.Actual_Copay_May_Be_Less__c);
                        }
                        when 'BHPOT' {
                            BHPOTMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                        when 'BHNPT' {
                            BHNPTMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                    }
                    oldBHPsf.add(psf);
                }
                String key = startDate + '__' + String.valueOf(subId) + '__' + endDate + '__' + payLess + '__' + BHP1TMbr + '__' + BHPOTMbr + '__' + BHNPTMbr;
                existingBHPsf.put(key, oldBHPsf);
            }
        }if (prodCode == 'PRIM360CARE') {
            for (String subId: psfMap.keyset()) {
                String PRIMCARECFMbr, PRIMCAREACFMbr, NEWPATCFMbr,PRIMCAREFCFMbr, startDate, endDate, payLess;
                List<Plan_Specific_Fees__c> oldp360Psf = new List<Plan_Specific_Fees__c>();
                for (Plan_Specific_Fees__c psf: psfMap.get(subId)) {
                    switch on psf.PSF_ProductCode__c {
                        when 'PRIMCARECF' {
                            PRIMCARECFMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                            startDate = String.valueOf(psf.Product_Start_Date__c);
                            endDate = String.valueOf(psf.Product_End_Date__c);
                            payLess = String.valueOf(psf.Actual_Copay_May_Be_Less__c);
                        }
                        when 'PRIMCAREACF' {
                            PRIMCAREACFMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                        when 'NEWPATCF' {
                            NEWPATCFMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                        when 'PRIMCAREFCF' {
                            PRIMCAREFCFMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                    }
                    oldp360Psf.add(psf);
                }
                String key = startDate + '__' + String.valueOf(subId) + '__' + endDate + '__' + payLess + '__' + PRIMCARECFMbr + '__' + PRIMCAREACFMbr + '__' + NEWPATCFMbr + '__' + PRIMCAREFCFMbr;
                existingp360Psf.put(key, oldp360Psf);
            }
        } else if (prodCode == 'MH') {
            for (String subId: psfMap.keyset()) {
                String BHPOTMbr, BHPOOTMbr, BHNPTMbr, BHP1TMbr, startDate, endDate, payLess;
                List<Plan_Specific_Fees__c> oldMhPsf = new List<Plan_Specific_Fees__c>();
                for (Plan_Specific_Fees__c psf: psfMap.get(subId)) {
                    switch on psf.PSF_ProductCode__c {
                        when 'BHPOT' {
                            BHPOTMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                            startDate = String.valueOf(psf.Product_Start_Date__c);
                            endDate = String.valueOf(psf.Product_End_Date__c);
                            payLess = String.valueOf(psf.Actual_Copay_May_Be_Less__c);
                        }
                        when 'BHPOOT' {
                            BHPOOTMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                        when 'BHNPT' {
                            BHNPTMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                        when 'BHP1T' {
                            BHP1TMbr = String.valueOf(psf.Consult_Fee_Mbr_Pd__c.setscale(2));
                        }
                    }
                    oldMhPsf.add(psf);
                }
                String key = startDate + '__' + String.valueOf(subId) + '__' + endDate + '__' + payLess + '__' + BHPOTMbr + '__' + BHPOOTMbr + '__' + BHNPTMbr + '__' + BHP1TMbr;
                existingMHPsf.put(key, oldMhPsf);
            }
        }
    }

    public Map<String, List<Plan_Specific_Fees__c>> buildNewKey(String subProdCode, Map<String, Plan_Specific_Fees__c> bhMap) {
        Map<String, List<Plan_Specific_Fees__c>> newKey = new Map<String, List<Plan_Specific_Fees__c>>();
        List<Plan_Specific_Fees__c> psfList = new List<Plan_Specific_Fees__c>();
        if (subProdCode == 'BH') {
            String BHP1TMbr, BHPOTMbr, BHNPTMbr, startDate, endDate, payLess, subId, key;
            for (String prodCode: bhMap.keySet()) {
                switch on prodCode {
                    when 'BHP1T' {
                        BHP1TMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                        startDate = String.valueOf(bhMap.get(prodCode).Product_Start_Date__c);
                        endDate = String.valueOf(bhMap.get(prodCode).Product_End_Date__c);
                        payLess = String.valueOf(bhMap.get(prodCode).Actual_Copay_May_Be_Less__c);
                        subId = String.valueOf(bhMap.get(prodCode).Subscription__c);
                    }
                    when 'BHPOT' {
                        BHPOTMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                    when 'BHNPT' {
                        BHNPTMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                }
                psfList.add(bhMap.get(prodCode));
            }
            key = startDate + '__' + subId + '__' + endDate + '__' + payLess + '__' + BHP1TMbr + '__' + BHPOTMbr + '__' + BHNPTMbr;
            newKey.put(key, psfList);
        }if (subProdCode == 'PRIM360CARE') {
            String PRIMCARECFMbr, PRIMCAREACFMbr, NEWPATCFMbr,PRIMCAREFCFMbr, startDate, endDate, payLess, subId, key;
            for (String prodCode: bhMap.keySet()) {
                switch on prodCode {
                    when 'PRIMCARECF' {
                        PRIMCARECFMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                        startDate = String.valueOf(bhMap.get(prodCode).Product_Start_Date__c);
                        endDate = String.valueOf(bhMap.get(prodCode).Product_End_Date__c);
                        payLess = String.valueOf(bhMap.get(prodCode).Actual_Copay_May_Be_Less__c);
                        subId = String.valueOf(bhMap.get(prodCode).Subscription__c);
                    }
                    when 'PRIMCAREACF' {
                        PRIMCAREACFMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                    when 'NEWPATCF' {
                        NEWPATCFMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                     when 'PRIMCAREFCF' {
                        PRIMCAREFCFMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                }
                psfList.add(bhMap.get(prodCode));
            }
            key = startDate + '__' + subId + '__' + endDate + '__' + payLess + '__' + PRIMCARECFMbr + '__' + PRIMCAREACFMbr + '__' + NEWPATCFMbr + '__' + PRIMCAREFCFMbr;
            newKey.put(key, psfList);
        } else if (subProdCode == 'MH') {
            String BHPOTMbr, BHPOOTMbr, BHNPTMbr, BHP1TMbr, startDate, endDate, payLess, subId, key;
            for (String prodCode: bhMap.keySet()) {
                switch on prodCode {
                    when 'BHPOT' {
                        BHPOTMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                        startDate = String.valueOf(bhMap.get(prodCode).Product_Start_Date__c);
                        endDate = String.valueOf(bhMap.get(prodCode).Product_End_Date__c);
                        payLess = String.valueOf(bhMap.get(prodCode).Actual_Copay_May_Be_Less__c);
                        subId = String.valueOf(bhMap.get(prodCode).Subscription__c);
                    }
                    when 'BHPOOT' {
                        BHPOOTMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                    when 'BHNPT' {
                        BHNPTMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                    when 'BHP1T' {
                        BHP1TMbr = String.valueOf(bhMap.get(prodCode).Consult_Fee_Mbr_Pd__c.setscale(2));
                    }
                }
                psfList.add(bhMap.get(prodCode));
            }
            key = startDate + '__' + subId + '__' + endDate + '__' + payLess + '__' + BHPOTMbr + '__' + BHPOOTMbr + '__' + BHNPTMbr + '__' + BHP1TMbr;
            newKey.put(key, psfList);
        }
        return newKey;
    }
    
    public static void insertPsf(Map<String, List<Plan_Specific_Fees__c>> psfMap, String mbrGroupId, String agcpiId) {
        List<Plan_Specific_Fees__c> createPSFList = new List<Plan_Specific_Fees__c>();
        for (List<Plan_Specific_Fees__c> psfList: psfMap.values()) {
            for (Plan_Specific_Fees__c psf: psfList) {
                Plan_Specific_Fees__c clonePSF = psf.clone(false);
                clonePSF.Member_Group__c = mbrGroupId;
                createPSFList.add(clonePSF);
            }
        }
        Database.SaveResult[] srbh = Database.insert(createPSFList, false);
        for (Database.SaveResult rowSr : srbh) {
            if (!rowSr.isSuccess()) {
                for (Database.Error rowError : rowSr.getErrors()) {
                    F1bUtils_v2.LogException(agcpiId, 'PLAN_SPECIFIC_FEES__C', 'ERROR', 'PSF_INSERT_FAILED',
                                             rowError.getMessage());
                }
            }
        }
    }  
    
    public static void deletePsf(Map<String, List<Plan_Specific_Fees__c>> psfMap, String agcpiId) {
        List<Plan_Specific_Fees__c> deletePsfList = new List<Plan_Specific_Fees__c>();
        for (List<Plan_Specific_Fees__c> psfList: psfMap.values()) {
            deletePsfList.addAll(psfList);
        }
        Database.DeleteResult[] dr = Database.delete(deletePsfList, false);
        boolean isError = false;
        for (Database.DeleteResult rowSr : dr) {
            if (!rowSr.isSuccess()) {
                isError = true;
                for (Database.Error rowError : rowSr.getErrors()) {
                    F1bUtils_v2.LogException(agcpiId, 'PLAN_SPECIFIC_FEES__C', 'ERROR', 'PSF_DELETE_FAILED',
                                             rowError.getMessage());
                }
            }
        }
        if (!isError)
            psfMap.clear(); 
    }
}