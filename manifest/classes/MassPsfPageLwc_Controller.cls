public with sharing class MassPsfPageLwc_Controller {
    @AuraEnabled
    public static String findObjType(Id objId) {
        String sobjectType = objId.getSObjectType().getDescribe().getName();
        return sobjectType;
    }
    
    @AuraEnabled
    public static List<subListWrapper> findSub(String groupId){        
        Mbr_Group__c mb = [SELECT Client_Account__r.Id FROM Mbr_Group__c WHERE Id =: groupId];
        List<Mbr_Group_Role__c> mbr = [SELECT Source_Account__r.Id FROM Mbr_Group_Role__c where Mbr_Group__c = :groupId AND  Role_Type__c ='Contractee'];       
        Set<Id> acctSet = new Set<Id>();
        for(Mbr_Group_Role__c mbrL : mbr){
            acctSet.add(mbrL.Source_Account__r.Id);
        }
        acctSet.add(mb.Client_Account__r.Id);
        List<SBQQ__Subscription__c> subList = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,Vendor_Partner__c,
                                               Consult_Fees__c, Current_Membership_Fee__c, Bundle_Type__c,
                                               SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, SBQQ__Product__r.Promotion_Enabled__c, Fee_Type__c, Disable_Teletherapy__c, Disable_Coaching__c,
                                               SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate,
                                               SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c, SBQQ__Account__r.Name, SBQQ__Account__r.GUID__c,
                                               (SELECT Id, Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r) 
                                               FROM SBQQ__Subscription__c
                                               WHERE SBQQ__Account__c in :acctSet
                                               AND Status__c != 'Terminated'
                                               AND SBQQ__Quantity__c >= 0
                                               AND SBQQ__Product__r.psf_disable__c = false
                                               ];
        
        
        
        List<Plan_Specific_Fees__c> existingPSF = [SELECT Subscription__r.Name FROM Plan_Specific_Fees__c WHERE Member_Group__c =: groupID];
        List<subListWrapper> subListWrapper = new List<subListWrapper>();
        
        for(SBQQ__Subscription__c sub : subList){
            Map<String, Asset> assetMap = new Map<String, Asset>();
            Boolean hasAsset = false;
            for (Asset asset: sub.SBQQ__ChildAssets__r) {
                assetMap.put(asset.Product2.ProductCode, asset);
                hasAsset = true;
            }
            if (hasAsset) {
                subListWrapper.add(new subListWrapper(false, sub, assetMap));    
            } else {
                subListWrapper.add(new subListWrapper(false, sub, null)); 
            }
        }
        for(subListWrapper subW : subListWrapper){  
            for(Plan_Specific_Fees__c psf : existingPSF) {
                if(subW.objSub.Id == psf.Subscription__r.Id) {
                    subW.isUsed = true;  
                }
            }
        }
        subListWrapper.sort();
        return subListWrapper;
    }
    
    public class subListWrapper implements Comparable{
        @auraEnabled
        public Boolean isUsed {get; set;}
        @auraEnabled
        public SBQQ__Subscription__c objSub {get; set;}
        @auraEnabled
        public Map<String, Asset> assetMap {get; set;}
        public subListWrapper(boolean isUsed, SBQQ__Subscription__c objSub, Map<String, Asset> assetMap){
            this.isUsed = isUsed;
            this.objSub = objSub;
            this.assetMap = assetMap;
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            subListWrapper compareToSubList = (subListWrapper)compareTo;
            if (isUsed == compareToSubList.isUsed) {
                if (objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate == compareToSubList.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate){
                    if (objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name == compareToSubList.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name){
                        if (objSub.SBQQ__Product__r.Name == compareToSubList.objSub.SBQQ__Product__r.Name){
                            return 0;
                        } else if (objSub.SBQQ__Product__r.Name < compareToSubList.objSub.SBQQ__Product__r.Name){
                            return -1;
                        } else {
                            return 1;
                        }
                    } else if (objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name < compareToSubList.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name){
                        return -1;
                    } else {
                        return 1;
                    }
                } else if (objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate > compareToSubList.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate){
                    return -1;
                } else {
                    return 1;
                }
            } else if (isUsed && !compareToSubList.isUsed) {
                return -1;
            } else {
                return 1;
            }
        }
    }
    
    @AuraEnabled
    public static String mgName(String groupId){
        Mbr_Group__c mb = [SELECT Name__c FROM Mbr_Group__c WHERE Id =: groupId];
        String Name = mb.Name__c;
        return Name;
    }
    
    @AuraEnabled
    public static List<psfWrapper> getPSF(String recordId) {
        List<psfWrapper> psfWrapper =  new List<psfWrapper>();
        Map<String, Asset> assetMap = new Map<String, Asset>();
        List<Plan_Specific_Fees__c> currentPSF = [SELECT Member_Group__r.Id, PG__c, GM_100_Covered__c,MH_100_Covered__c, DERM_100_Covered__c,Member_Group__r.Name__c, Subscription__c, Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.opp_guid__c, Subscription__r.SBQQ__Product__r.ProductCode, Subscription__r.SBQQ__Product__r.Promotion_Enabled__c, Subscription__r.Disable_Teletherapy__c, Subscription__r.Disable_Coaching__c, 
                                                  Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, Asset__c, Asset__r.Product2.ProductCode, Disable_Teletherapy__c, Disable_Coaching__c,
                                                  Bill_to_Account__c,Sold_to_Account__c,Payer_Account__c  FROM Plan_Specific_Fees__c WHERE Id =: recordId];
        SBQQ__Subscription__c sub = [SELECT Id, Name,Vendor_Partner__c, SBQQ__Product__r.Name, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.opp_guid__c, SBQQ__Account__r.Name, SBQQ__Account__r.GUID__c, Status__c, Consult_Type__c, Fee_Type__c,
                                     Current_Membership_Fee__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Promotion_Enabled__c, Sort_Order__c, SBQQ__StartDate__c, Disable_Teletherapy__c, Disable_Coaching__c, SBQQ__Account__c
                                     FROM SBQQ__Subscription__c WHERE Id =: currentPSF[0].Subscription__c];
        if (((currentPSF[0].Subscription__r.SBQQ__Product__r.ProductCode == 'MYSTR3' && currentPSF[0].Subscription__r.Disable_Teletherapy__c == 'NO' )|| currentPSF[0].Subscription__r.SBQQ__Product__r.ProductCode == 'PRIM360CARE' || currentPSF[0].Subscription__r.SBQQ__Product__r.ProductCode == 'BH' || currentPSF[0].Subscription__r.SBQQ__Product__r.ProductCode == 'DERM'|| currentPSF[0].Subscription__r.SBQQ__Product__r.ProductCode == 'TC') && currentPSF[0].Asset__c == null) {
            psfWrapper.add(new psfWrapper(currentPSF, sub, true, null));
            return psfWrapper;
        }
        if (sub.SBQQ__Product__r.ProductCode != 'BH' && sub.SBQQ__Product__r.ProductCode != 'MH' && sub.SBQQ__Product__r.ProductCode != 'PRIM360CARE' && ((sub.SBQQ__Product__r.ProductCode == 'MYSTR3' && sub.Disable_Teletherapy__c == 'YES') || (sub.SBQQ__Product__r.ProductCode != 'MYSTR3')))  {
            List<Asset> asset = [SELECT Id, Product2.ProductCode, Consult_Fees__c FROM Asset WHERE SBQQ__Requiredbysubscription__c =: sub.Id];
            if (asset.size() > 0) {
                assetMap.put(asset[0].Product2.ProductCode, asset[0]);
                psfWrapper.add(new psfWrapper(currentPSF, sub, null, assetMap));
            } else {
                psfWrapper.add(new psfWrapper(currentPSF, sub, null, null));
            }
            return psfWrapper;
        } else {
            List<Asset> asset = [SELECT Id, Product2.ProductCode, Consult_Fees__c FROM Asset WHERE SBQQ__Requiredbysubscription__c =: sub.Id];
            List<Plan_Specific_Fees__c> psfList = [SELECT Member_Group__r.Id, Member_Group__r.Name__c, Subscription__c, Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, 
                                                   Asset__r.Product2.ProductCode, Asset__c, PG__c,GM_100_Covered__c,MH_100_Covered__c, DERM_100_Covered__c, Bill_to_Account__c,
                                                   Sold_to_Account__c,Payer_Account__c
                                                   FROM Plan_Specific_Fees__c WHERE Subscription__c =: currentPSF[0].Subscription__c 
                                                   AND Member_Group__c =: currentPSF[0].Member_Group__c AND Asset__c != null];
            for (Asset ast : asset) {
                assetMap.put(ast.Product2.ProductCode, ast);
            }
            psfWrapper.add(new psfWrapper(psfList, sub, null, assetMap));
            return psfWrapper;
        }  
    }
    
    public class psfWrapper {
        @auraEnabled
        public List<Plan_Specific_Fees__c> psf {get; set;}
        @auraEnabled
        public SBQQ__Subscription__c sub {get; set;}
        @auraEnabled
        public Boolean isError {get; set;}
        @auraEnabled
        public Map<String, Asset> assetMap {get; set;}
        public psfWrapper(List<Plan_Specific_Fees__c> psf, SBQQ__Subscription__c sub, Boolean isError, Map<String, Asset> assetMap) {
            this.psf = psf;
            this.sub = sub;
            this.isError = isError;
            this.assetMap = assetMap;
        }
    }
    
    @AuraEnabled
    public static List<Plan_Specific_Fees__History> getHistories(String mbrGrpId, String subId) {
        List<Plan_Specific_Fees__c> psfList = [SELECT Id FROM Plan_Specific_Fees__c WHERE Subscription__c =: subId and Member_Group__c =: mbrGrpId];
        List<String> psfIdList = new List<String>();
        for (Plan_Specific_Fees__c psf: psfList) {
            psfIdList.add(psf.Id);
        }
        List<Plan_Specific_Fees__History> psfHistory = [SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue
                                                        FROM Plan_Specific_Fees__History WHERE ParentId IN: psfIdList ORDER BY CreatedDate DESC];
        return psfHistory;
    }
    
    @AuraEnabled
    public static List<String> createPSF(List<Plan_Specific_Fees__c> psfList) {
        List<String> errorMsg = new List<String>();
        Database.SaveResult[] sr = Database.insert(psfList, false);
        for (Database.SaveResult rowSr : sr) {
            if (!rowSr.isSuccess()) {
                for (Database.Error rowError : rowSr.getErrors()) {
                    errorMsg.add(rowError.getMessage());                  
                }
            }
        }
        return errorMsg;
    } 
    
    @AuraEnabled
    public static Boolean CalculateDelta(List<String> fields, Plan_Specific_Fees__c sfPsf, Plan_Specific_Fees__c lwcPsf) {
        Boolean isEdit = false;
        for (String field: fields) {
            if (sfPsf.get(field) != lwcPsf.get(field)) {
                if(field == 'USGH_APP_Opt_Out__c'){
                    lwcPsf.USGH_APP_Opt_Out__c = lwcPsf.USGH_APP_Opt_Out__c == null ? false : lwcPsf.USGH_APP_Opt_Out__c;
                }
                sfPsf.put(field, lwcPsf.get(field));
                isEdit = true;
            }
        }        
        return isEdit;
    }
    
    @AuraEnabled
    public static String updatePSF(List<Plan_Specific_Fees__c> psfList, String mbrGrpId, String subId) {
        String errorMsg;
        List<Plan_Specific_Fees__c> updatePsfList = new List<Plan_Specific_Fees__c>();
        List<String> fieldDeltas = new List<String>{'PG__c','GM_100_Covered__c','MH_100_Covered__c', 'DERM_100_Covered__c','Product_Start_Date__c', 'Product_End_Date__c', 'Actual_Copay_May_Be_Less__c', 'Consult_Fee_Mbr_Pd__c', 'Consult_Fee_Plan_Pd__c', 'Asset__c', 'Bill_to_Account__c', 'Sold_to_Account__c', 'Payer_Account__c','USGH_APP_Opt_Out__c','GLP_1_Model__c', 'Promotion__c'};
        List<Plan_Specific_Fees__c> matchPsfList = [SELECT Id, Asset__c, PG__c, Psf_ProductCode__c, Product_Start_Date__c, Product_End_Date__c, Actual_Copay_May_Be_Less__c, Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c,GM_100_Covered__c,MH_100_Covered__c, DERM_100_Covered__c, Payer_Account__c, Sold_to_Account__c, Bill_to_Account__c,USGH_APP_Opt_Out__c,GLP_1_Model__c,Promotion__c 
                                                   FROM Plan_Specific_Fees__c WHERE Subscription__c =: subId and Member_Group__c =: mbrGrpId];
        for (Plan_Specific_Fees__c matchPsf: matchPsfList) {
            for (Plan_Specific_Fees__c lwcPsf: psfList) {
                if (matchPsf.Asset__c == null) {
                    Boolean isEdit = CalculateDelta(fieldDeltas, matchPsf, lwcPsf);
                        if (isEdit) 
                            updatePsfList.add(matchPsf);
                } else {
                    if (matchPsf.Asset__c == lwcPsf.Asset__c) {
                        Boolean isEdit = CalculateDelta(fieldDeltas, matchPsf, lwcPsf);
                        if (isEdit) 
                            updatePsfList.add(matchPsf);
                    }
                }
            }
        }
 
        try {
            update updatePsfList;
            errorMsg = null;
        } catch (exception e) {
            system.debug(e.getMessage());
            errorMsg = e.getMessage();
        }
        return errorMsg;
    }
    
    @AuraEnabled
    public static String deletePSF(String mbrGrpId, String subId) {
        String errorMsg;
        List<Plan_Specific_Fees__c> psfList = [SELECT Id FROM Plan_Specific_Fees__c WHERE Subscription__c =: subId and Member_Group__c =: mbrGrpId];
        try {
            delete psfList;
            errorMsg = null;
        } catch (exception e) {
            errorMsg = e.getMessage();
        }
        return errorMsg;
    }

    @AuraEnabled
    public static List<mbrGrpListWrapper> getMbrGrpRoles(String mbrGrpId, String psfRecordId) {     

        List<mbrGrpListWrapper> mbrGrpListWrapper = new List<mbrGrpListWrapper>();

        List<Mbr_Group_Role__c> mbrGrpRoleList = [SELECT Id, Role_Type__c, Source_Account__c, Source_Account__r.Id, Source_Account__r.Name, Source_Account__r.GUID__c FROM Mbr_Group_Role__c WHERE Mbr_Group__c = :mbrGrpId 
                                                        AND (Role_Type__c = 'Billing' OR Role_Type__c = 'Payer')];
        
        if(!String.isBlank(psfRecordId)) {
            Plan_Specific_Fees__c existingPSF = [SELECT Subscription__r.Name, Name, Member_Group__c, Member_Group__r.Name, 
                                                    Bill_to_Account__c, Bill_To_Account_GUID__c,
                                                    Sold_to_Account__c, Sold_To_Account_GUID__c, Payer_Account__c, 
                                                    Payer_Account_GUID__c FROM Plan_Specific_Fees__c WHERE Member_Group__c =: mbrGrpId and Id =: psfRecordId];

            for(Mbr_Group_Role__c mbrGrpRole : mbrGrpRoleList) {
                if((mbrGrpRole.Role_Type__c == 'Billing' && mbrGrpRole.Source_Account__c == existingPSF.Bill_to_Account__c )|| 
                   (mbrGrpRole.Role_Type__c == 'Payer' && mbrGrpRole.Source_Account__c == existingPSF.Payer_Account__c)) {
                    mbrGrpListWrapper.add(new mbrGrpListWrapper(true, mbrGrpRole));  
                }
                else {
                    mbrGrpListWrapper.add(new mbrGrpListWrapper(false, mbrGrpRole));  
                }  
            }
        }
        else {
            for(Mbr_Group_Role__c mbrGrpRole : mbrGrpRoleList) {
                mbrGrpListWrapper.add(new mbrGrpListWrapper(false, mbrGrpRole));  
            }  
        }
        return mbrGrpListWrapper;
    }


    public class MbrGrpListWrapper{
        @auraEnabled
        public Boolean isAccInUse {get; set;}
        @auraEnabled 
        public Mbr_Group_Role__c objMbrGrpRole {get; set;}
        
        public mbrGrpListWrapper(boolean isAccInUse, Mbr_Group_Role__c objMbrGrpRole){
            this.isAccInUse = isAccInUse;
            this.objMbrGrpRole = objMbrGrpRole;
        }
    }
}