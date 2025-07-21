public with sharing class PSFByProductController {
    @AuraEnabled
    public static String findObjType(Id objId) {
        String sobjectType = objId.getSObjectType().getDescribe().getName();
        return sobjectType;
    }
    
    @AuraEnabled
    public static List<subListWrapper> findSub(String groupId){        
        Mbr_Group__c mb = [SELECT Client_Account__r.Id FROM Mbr_Group__c WHERE Id =: groupId];
        List<Mbr_Group_Role__c> mbr = [SELECT Source_Account__r.Id FROM Mbr_Group_Role__c where Mbr_Group__c = :groupId AND (Role_Type__c = 'Payer' OR Role_Type__c ='Contractee')];		
        Set<Id> acctSet = new Set<Id>();
        for(Mbr_Group_Role__c mbrL : mbr){
            acctSet.add(mbrL.Source_Account__r.Id);
        }
        acctSet.add(mb.Client_Account__r.Id);
        system.debug(acctSet);
        List<SBQQ__Subscription__c> subList = [SELECT Id, Name, SBQQ__StartDate__c, Status__c, Consult_Type__c,
                                               Consult_Fees__c, Current_Membership_Fee__c,
                                               SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, Fee_Type__c,
                                               SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__Account__r.name
                                               FROM SBQQ__Subscription__c
                                               WHERE SBQQ__Account__c in :acctSet
                                               AND Status__c != 'Terminated'
                                               AND SBQQ__Quantity__c > 0
                                               ORDER BY SBQQ__Product__r.ProductCode];
        
        List<Plan_Specific_Fees__c> existingPSF = [SELECT Subscription__r.Name FROM Plan_Specific_Fees__c WHERE Member_Group__c =: groupID];
        List<subListWrapper> subListWrapper = new List<subListWrapper>();
        
        for(SBQQ__Subscription__c sub : subList){            
            subListWrapper.add(new subListWrapper(false, sub));          
        }
        for(subListWrapper subW : subListWrapper){	
			for(Plan_Specific_Fees__c psf : existingPSF){
                if(subW.objSub.Name == psf.Subscription__r.Name){
                    subW.isUsed = true;  
                }
            }
        }
        
        
        for(subListWrapper sub : subListWrapper){
            system.debug(sub.isUsed);
        }
        
        return subListWrapper;
        
    }
       
    public class subListWrapper{
        @auraEnabled
        public Boolean isUsed {get; set;}
        @auraEnabled
        public SBQQ__Subscription__c objSub {get; set;}
        public subListWrapper(boolean isUsed, SBQQ__Subscription__c objSub){
            this.isUsed = isUsed;
            this.objSub = objSub;
        }
    }
    
    @AuraEnabled
    public static String mgName(String groupId){
        Mbr_Group__c mb = [SELECT Name__c FROM Mbr_Group__c WHERE Id =: groupId];
        String Name = mb.Name__c;
        return Name;
    }
    
    @AuraEnabled
    public static feeWrapper getAsset(String subId, String productCode){
        system.debug(subId + '  ' + productCode );
        List<feeWrapper> feeWrapper =  new List<feeWrapper>();
        List<Asset> assetList = [SELECT Name, Consult_Fees__c, Product2.ProductCode FROM Asset WHERE SBQQ__RequiredBySubscription__c =: subId];
        system.debug(assetList);
        if(assetList.size() > 0){
            if(productCode == 'GM'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null ,null));
            }else if(productCode == 'DERM'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null ,null , null));
            }else if(productCode == 'BH'){
                decimal bhFistMbr, bhOnMbr, bhNonMbr;
                for(Asset a : assetList){                
                    if(a.Product2.ProductCode == 'BHP1T'){
                        bhFistMbr = a.Consult_Fees__c;
                    }else if(a.Product2.ProductCode == 'BHPOT'){
                        bhOnMbr = a.Consult_Fees__c;
                    }else if(a.Product2.ProductCode == 'BHNPT'){
                        bhNonMbr = a.Consult_Fees__c;
                    }
                }
                feeWrapper.add(new feeWrapper(true, null, bhFistMbr, bhOnMbr, bhNonMbr));
            }else if(productCode == 'GLOBALCARE'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null, null));
            }else if(productCode == 'NUT'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null, null));
            }else if(productCode == 'TDBC'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null, null));
            }else if(productCode == 'TC'){
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null, null));
            }else{
                feeWrapper.add(new feeWrapper(true, assetList[0].Consult_Fees__c, null, null, null));
            }
        }else{
            feeWrapper.add(new feeWrapper(false, null, null, null, null));
        }        
        
        
        return feeWrapper[0];
    }
    
    public class feeWrapper{
        @auraEnabled
        public boolean isFee {get; set;}
        @auraEnabled
        public decimal cfMbr {get; set;}
        @auraEnabled
        public decimal bhFistMbr {get; set;}
        @auraEnabled
        public decimal bhOnMbr {get; set;}
        @auraEnabled
        public decimal bhNonMbr {get; set;}
        
        public feeWrapper(boolean isFee, decimal cfMbr, decimal bhFistMbr, decimal bhOnMbr, decimal bhNonMbr){
            this.isFee = isFee;
            this.cfMbr = cfMbr;
            this.bhFistMbr = bhFistMbr;
            this.bhOnMbr = bhOnMbr;
            this.bhNonMbr = bhNonMbr;   
        }
    }
    
    @AuraEnabled
    public static void deletePSF(String recordId){
        Plan_Specific_Fees__c psf = [SELECT Id FROM Plan_Specific_Fees__c WHERE Id = :recordId];
        delete psf;
    }

    @AuraEnabled
    public static List<Plan_Specific_Fees__History> getHistories(String recordId){
        List<Plan_Specific_Fees__History> psf = [SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue
                                                 FROM Plan_Specific_Fees__History WHERE ParentId = :recordId ORDER BY CreatedDate DESC];
        return psf;
    }
    
    @AuraEnabled
    public static Plan_Specific_Fees__c getPSF(String recordId){
                
        return [SELECT Id, Member_Group__r.Id, Member_Group__r.Name__c, Subscription__r.Name, Subscription__r.Id, Subscription__r.SBQQ__Product__r.Name, Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, 
                Subscription__r.SBQQ__Account__r.Name, Subscription__r.Status__c, Subscription__r.Consult_Type__c, Subscription__r.Current_Membership_Fee__c, Subscription__r.SBQQ__Product__r.ProductCode,
                Subscription__r.Sort_Order__c, Subscription__r.SBQQ__StartDate__c, Actual_Copay_May_Be_Less__c,USGH_APP_Opt_Out__c,Subscription__r.Vendor_Partner__c, DERMConsult_Fee_Mbr_Pd__c, DERMConsult_Fee_Plan_Pd__c,
                Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, Consult_Fee_Initial_Diagnostic_Mbr_Pd__c, Consult_Fee_Initial_Diagnostic_Plan_Pd__c,
                Consult_Fee_Ongoing_MD_Mbr_Pd__c, Consult_Fee_Ongoing_MD_Plan_Pd__c, Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c, Consult_Fee_Ongoing_Non_MD_Plan_Pd__c,
                TC_Client_Case_Rate_Fee__c, TC_Mbr_Case_Rate_Fee__c
                FROM Plan_Specific_Fees__c WHERE Id =: recordId];         
    }
   
}