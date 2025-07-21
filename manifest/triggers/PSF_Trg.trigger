trigger PSF_Trg on Plan_Specific_Fees__c (before insert, before update, after insert, after update, before delete) {
    
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    Set<Id> mbr_grp_ids = new Set<Id>();
    Set<Id> sub_ids = new Set<Id>();
    if (!DS.Disable_Triggers__c) {

        //Validation to check there is only single record with Same Product
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (Plan_Specific_Fees__c tmpPsf : trigger.new) {
                    mbr_grp_ids.add(tmpPsf.Member_Group__c);
                    sub_ids.add(tmpPsf.Subscription__c);
                }
                List<Plan_Specific_Fees__c> scopedFees = [
                        select Member_Group__c, Subscription__c
                        from Plan_Specific_Fees__c
                        where Member_Group__c in :mbr_grp_ids and Subscription__c in :sub_ids
                ];
                Set<String> mappedFees = new Set<String>();
                for (Plan_Specific_Fees__c tmpPsf : scopedFees) {
                    mappedFees.add(tmpPsf.Member_Group__c + '_' + tmpPsf.Subscription__c);
                }
                for (Plan_Specific_Fees__c tmpPsf : trigger.new) {
                    if (mappedFees.contains(tmpPsf.Member_Group__c + '_' + tmpPsf.Subscription__c))
                        tmpPsf.addError('This member group + subscription combination already exists.');
                }
            }
            if (Trigger.isInsert || Trigger.isUpdate) {
                Set<Id> assetId = new Set<Id>();
                for (Plan_Specific_Fees__c psf : Trigger.new) {
                    assetId.add(psf.Asset__c);
                }
                List<Asset> assetList = [SELECT Id, Consult_Fees__c, Product2.ProductCode FROM Asset WHERE Id IN :assetId];
                for (Plan_Specific_Fees__c psf : Trigger.new) {
                    for (Asset ast : assetList) {
                        if (psf.Asset__c == ast.Id) {
                            ast.Consult_Fees__c = ast.Consult_Fees__c != null ? ast.Consult_Fees__c : 0;
                            psf.Consult_Fee_Mbr_Pd__c = psf.Consult_Fee_Mbr_Pd__c != null ? psf.Consult_Fee_Mbr_Pd__c : 0;
                            psf.Consult_Fee_Plan_Pd__c = psf.Consult_Fee_Plan_Pd__c != null ? psf.Consult_Fee_Plan_Pd__c : 0;
                            if (psf.Consult_Fee_Mbr_Pd__c < 0 || psf.Consult_Fee_Plan_Pd__c < 0) {
                                psf.addError('Fee value can not be negative');
                            }
                            if (ast.Consult_Fees__c != (psf.Consult_Fee_Mbr_Pd__c + psf.Consult_Fee_Plan_Pd__c)) {
                                psf.addError('Member Paid $' + psf.Consult_Fee_Mbr_Pd__c + ' + Plan Paid $' + psf.Consult_Fee_Plan_Pd__c + ' does not equal Consult Fees $'
                                        + ast.Consult_Fees__c + ' for productCode ' + ast.Product2.productcode);
                            }
                        }
                    }
                }
            }
            //Prevent users without System Administrator access to delete the PSF Record
            if(Trigger.isDelete){
                for(Plan_Specific_Fees__c psf : trigger.old){
                    If(PSF_Permission_Setting__c.getInstance().User_Permission__c == False) {
                        psf.addError('Contact your System Administrator to delete the record.');
                    }
             	}
            }
        }

		/*
        //Set Service Brand on member group based on the PSF productCode. Set EMO->BestDoctors  EMO2 -> Teladoc
        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
            Map<Id, Mbr_Group__c> mbrMap = new Map<Id, Mbr_Group__c>([select id, Service_Brand__c from Mbr_Group__c where id in :mbr_grp_ids]);
            Map<Id, Plan_Specific_Fees__c> pftMap = new Map<Id, Plan_Specific_Fees__c>([Select id,Member_Group__r.Service_Brand__c,Subscription__r.SBQQ__Product__r.ProductCode from Plan_Specific_Fees__c where id in :Trigger.newMap.keySet()]);
            System.debug('MeberGroup Map ' + mbrMap);
            List<Mbr_Group__c> Mbr2Update = new List<Mbr_Group__c>();
            for (Plan_Specific_Fees__c temp : Trigger.new) {
                Plan_Specific_Fees__c psf = pftMap.get(temp.id);
                System.debug('PSF Service Brand' + psf.Member_Group__r.Service_Brand__c);
                System.debug('PSF Product' + psf.Subscription__r.SBQQ__Product__r.ProductCode);
                if (psf.Member_Group__r.Service_Brand__c == null && psf.Subscription__r.SBQQ__Product__r.ProductCode != null) {
                    Mbr_Group__c mbrGroup = mbrMap.get(psf.Member_Group__c);
                    if (psf.Subscription__r.SBQQ__Product__r.ProductCode == 'EMO') {
                        mbrGroup.Service_Brand__c = 'BestDoctors';
                        Mbr2Update.add(mbrGroup);
                    } else if (psf.Subscription__r.SBQQ__Product__r.ProductCode == 'EMO2') {
                        mbrGroup.Service_Brand__c = 'Teladoc';
                        Mbr2Update.add(mbrGroup);
                    }
                }
            }
            if (Mbr2Update != null && Mbr2Update.size() > 0) {
                Database.update(Mbr2Update);
            }
        }
		*/
    }
}