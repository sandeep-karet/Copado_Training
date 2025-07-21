trigger PSF_Flow_Trigger on Plan_Specific_Fees__c (after insert, after update, after delete) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        List<String> mbrIdList = new List<String>();
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
            for (Plan_Specific_Fees__c psf: Trigger.New) {
                mbrIdList.add(psf.Member_Group__c); 
            }
        }
        if (Trigger.isDelete) {
            for (Plan_Specific_Fees__c psf: Trigger.Old) {
                system.debug('delete psf mb: ' + psf.Member_Group__c);
                mbrIdList.add(psf.Member_Group__c); 
            }
        }
        List<Mbr_Group__c> mbrList = [SELECT Id, (SELECT Subscription__r.SBQQ__Product__r.Disable_Flow__c FROM Plan_Specific_Fees_By_Product__r) FROM Mbr_Group__c WHERE Id IN: mbrIdList];
        for (Mbr_Group__c mbrGrp: mbrList) {
            Boolean disableFlowProd = false;
            for (Plan_Specific_Fees__c psf: mbrGrp.Plan_Specific_Fees_By_Product__r) {
                system.debug(psf.Subscription__r.SBQQ__Product__r.Disable_Flow__c);
                if (psf.Subscription__r.SBQQ__Product__r.Disable_Flow__c) {
                    disableFlowProd = true;
                }
            }
            if (disableFlowProd) {
                mbrGrp.Disable_Flow__c = true;
            } else {
                mbrGrp.Disable_Flow__c = false;
            }
        }
        update mbrList;    
    }
}