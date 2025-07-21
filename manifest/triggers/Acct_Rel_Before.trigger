trigger Acct_Rel_Before on Acct_Rel__c (before insert, before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {
        Id stdRtId = [select id from RecordType where sObjectType = 'Acct_Rel__c' limit 1].Id;
        List<Acct_Rel__c> missingRt = new List<Acct_Rel__c>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String,String> contactGUIDMap = new Map<String,String>();
        for(Acct_Rel__c tmpAr : trigger.new){
            if(tmpAr.Broker_Contact__c != NULL){
                contactIdSet.add(tmpAr.Broker_Contact__c);
            }
        }
        if(contactIdSet.size() > 0){
            List<Contact> contactList = [SELECT Id, Guid__c from contact where Id =: contactIdSet];
            for(Contact cont:contactList){
                contactGUIDMap.put(cont.Id, cont.GUID__c);
            }
        }
        
        for (Acct_Rel__c tmpAr : trigger.new) {
            // Calculate composite key
            try {
                if(tmpAR.RecordTypeId == null)
                    tmpAr.RecordTypeId = stdRtId;
                
                string date_string = tmpAr.Start_Date__c.year() + '-' + tmpAr.Start_Date__c.month() + '-' + tmpAr.Start_Date__c.day();
                string key_string = tmpAr.Svc_Acct__c + '_' + tmpAr.Benefit_Sponsor__c;
                key_string = key_string + '_' + tmpAr.Relationship_Type__c + '_' + tmpAr.Contract_Type__c + '_' + contactGUIDMap.get(tmpAr.Broker_Contact__c);
                //tmpAr.Composite_Key__c = key_string + '_' + date_string;
                // Add new md5 logic for composite key
                Blob requestBlob = Blob.valueOf(key_string + '_' + date_string);
                Blob hash = Crypto.generateDigest('MD5', requestBlob);
                //Need to convert into hex to generate the equivalent of md5(string) method of PHP.
                String requestSignature = EncodingUtil.convertToHex(hash);
                tmpAr.Composite_Key__c = requestSignature;
                system.debug('[COMPOSITE_KEY] = ' + tmpAr.Composite_Key__c);
                
            } catch (System.NullPointerException e) {
                
                string e1 = e.getStackTraceString(); // can be assigned to a variable to display a user-friendly error message
                system.debug(e1);
            }
        }
    }
}