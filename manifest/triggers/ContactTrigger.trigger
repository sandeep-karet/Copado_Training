trigger ContactTrigger on Contact (before insert, before update) {
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        ContactTriggerHelper.setGUID(Trigger.new);

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            ContactTriggerHelper.setMarketingSiteInfo(Trigger.new, Trigger.oldMap, Trigger.isUpdate, Trigger.isInsert);
        }
        
        // SCDEV-3381 - Result Code Short Description
    if (Trigger.isUpdate && Trigger.isBefore) {
        Map<Id,Contact> oldMap = trigger.oldMap;
        //Map<String, Melissa_Data_Personator_Result_Code__mdt> mapresultCode = Melissa_Data_Personator_Result_Code__mdt.getAll();
                    
        for (Contact cont: Trigger.new) {
            String resultCodeDesc='';
            if(!String.isBlank(cont.Mailing_Address_Personator_Result_Codes__c) && cont.Mailing_Address_Personator_Result_Codes__c != oldMap.get(cont.Id).Mailing_Address_Personator_Result_Codes__c){ 
            
                String[] lstCodes = cont.Mailing_Address_Personator_Result_Codes__c.split(',');
                system.debug('lstCodes :'+lstCodes);
                for(String code: lstCodes){
                    resultCodeDesc += code +' - '+ addressValidationHelper.getResultCodeShortDescription(code) +'\n';
                }
                cont.Mailing_Address_Status_Message__c = resultCodeDesc;
            }
            if(!String.isBlank(cont.Other_Address_Personator_Result_Codes__c) && cont.Other_Address_Personator_Result_Codes__c != oldMap.get(cont.Id).Other_Address_Personator_Result_Codes__c){ 
            	resultCodeDesc = '';
                String[] lstCodes = cont.Other_Address_Personator_Result_Codes__c.split(',');
                system.debug('lstCodes :'+lstCodes);
                for(String code: lstCodes){
                    resultCodeDesc += code +' - '+ addressValidationHelper.getResultCodeShortDescription(code) +'\n';
                }
                cont.Other_Address_Status_Message__c = resultCodeDesc;
            }
        }
    }
    }
}