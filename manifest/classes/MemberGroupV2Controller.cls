public without sharing class MemberGroupV2Controller {   
    @AuraEnabled
    public static mbrGroupWrapper getRecordInfo(Id objId) {
        String recordId;
        String userInfo = UserInfo.getOrganizationId();
        Boolean logo = false;
        Boolean logo1 = false;
        Boolean logo3 = false;
        Boolean logo4 = false;
        Boolean altLogo1 = false;
        Boolean altLogo2 = false;
        String objType = objId.getSObjectType().getDescribe().getName();
        ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0].Id;
        if (objType == 'Mbr_Group__c') {
            recordId = objId;
            Mbr_Group__c mbrGroup = [SELECT Id, Active_Date__c, Logo_Tag_ID__c, Logo1_ID__c, Logo3_ID__c, Logo4_ID__c, AltLogo1_ID__c, AltLogo2_ID__c FROM Mbr_Group__c WHERE Id =: recordId];
            if (mbrGroup.Logo_Tag_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.Logo_Tag_ID__c];
                if (logoList.size() > 0) {
                    logo = true;
                } 
            }
            if (mbrGroup.Logo1_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.Logo1_ID__c];
                if (logoList.size() > 0) {
                    logo1 = true;
                } 
            }
            if (mbrGroup.Logo3_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.Logo3_ID__c];
                if (logoList.size() > 0) {
                    logo3 = true;
                } 
            }
            if (mbrGroup.Logo4_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.Logo4_ID__c];
                if (logoList.size() > 0) {
                    logo4 = true;
                } 
            }
            if (mbrGroup.AltLogo1_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.AltLogo1_ID__c];
                if (logoList.size() > 0) {
                    altLogo1 = true;
                } 
            }
            if (mbrGroup.AltLogo2_ID__c != null) {
                List<ContentVersion> logoList = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: mbrGroup.AltLogo2_ID__c];
                if (logoList.size() > 0) {
                    altLogo2 = true;
                } 
            }
            mbrGroupWrapper mbrGroupWrapper = new mbrGroupWrapper(objType, recordId, userInfo, logo, logo1, logo3, logo4, altLogo1, altLogo2, null, mbrGroup.Active_Date__c); 
            return mbrGroupWrapper;
        } else {
            List <ContentVersion> defaultLogo = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title = 'MK_TDH_HZ_2'];
            recordId = null;
            String logoId = null;
            if (defaultLogo.size() > 0) {
                logoId = defaultLogo[0].ContentDocument.Id;
            }
            mbrGroupWrapper mbrGroupWrapper = new mbrGroupWrapper(objType, recordId, userInfo, false, true, false, false, false, false, logoId, null); 
            return mbrGroupWrapper;
        }
    }
    
    public class mbrGroupWrapper {
        @auraEnabled
        public String objType {get; set;}
        @auraEnabled
        public String recordId {get; set;}
        @auraEnabled
        public String userInfo {get; set;}
        @auraEnabled
        public Boolean logo {get; set;}
        @auraEnabled
        public Boolean logo1 {get; set;}
        @auraEnabled
        public Boolean logo3 {get; set;}
        @auraEnabled
        public Boolean logo4 {get; set;}
        @auraEnabled
        public Boolean altLogo1 {get; set;}
        @auraEnabled
        public Boolean altLogo2 {get; set;}
        @auraEnabled
        public String defaultLogo {get; set;}
        @auraEnabled
        public Date activeDate {get; set;}
        public mbrGroupWrapper(String objType, String recordId, String userInfo, Boolean logo, Boolean logo1, Boolean logo3, Boolean logo4, Boolean altLogo1, Boolean altLogo2, String defaultLogo, Date activeDate) {
            this.objType = objType;
            this.recordId = recordId;    
            this.userInfo = userInfo;
            this.logo = logo;
            this.logo1 = logo1;
            this.logo3 = logo3;
            this.logo4 = logo4;
            this.altLogo1 = altLogo1;
            this.altLogo2 = altLogo2;
            this.defaultLogo = defaultLogo;
            this.activeDate = activeDate;
        }
    } 
    
    @AuraEnabled
    public static docWrapper searchLogoDoc(String logoName) {        
        List<docWrapper> docWrapper = new List<docWrapper>();
        ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0].Id;
        List <ContentVersion> logo = [SELECT ContentDocument.Id, Title FROM ContentVersion USING SCOPE EVERYTHING WHERE ContentDocument.ParentId = :workspaceId AND Title =: logoName];
        if (logo.size() > 0) {
            String info = UserInfo.getOrganizationId();
            docWrapper.add(new docWrapper(logo[0].ContentDocument.Id, info));
            return docWrapper[0];           
        } else {
            return null;       
        } 
        
    }
    
    public class docWrapper{
        @auraEnabled
        public Id docId {get; set;}
        @auraEnabled
        public String userInfo {get; set;}
        public docWrapper(Id docId, String userInfo) {
            this.docId = docId;
            this.userInfo = userInfo;
        }
    }    
}