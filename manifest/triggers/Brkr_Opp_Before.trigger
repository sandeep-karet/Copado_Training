trigger Brkr_Opp_Before on Broker_Opp_Rel__c (before insert, before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {   
        Map<Id, String> mappedSponsors = new Map<Id, String>();
        Set<Id> scopedAr = new Set<Id>();
        Set<Id> scopedAccts = new Set<Id>();
        Set<Id> scopedCons = new Set<Id>();
        Set<String> statusesToIgnore = new Set<String>{'Closed Won','Closed Lost'};
            
            for(Broker_Opp_Rel__c tmpBor : trigger.new){
                scopedAr.add(tmpBor.Broker_Rel__c);
                scopedCons.add(tmpBor.Broker_Contact__c);      
                if(statusesToIgnore.contains(tmpBor.Opportunity_Stage__c))
                    tmpBor.addError('update not allowed for opportunity in stage: ' + tmpBor.Opportunity_Stage__c);
            }
        //System.debug('scopedAr: ' + scopedAr);
        Map<Id,Acct_Rel__c> mappedAr = new Map<Id,Acct_Rel__c>([select id, Broker_Percentage__c, Broker_Flat_Rate__c, Chronic_Care_Broker_Flat_Rate__c, Chronic_Care_Broker_Percentage__c, Broker_Loc_Name__c
                                                                from Acct_Rel__c where id in :scopedAr]);
        for (Broker_Opp_Rel__c tmpBor : trigger.new) {
            // Calculate composite key
            try {
                
                string key_string = tmpBor.Opp_Broker__c + '_' + tmpBor.Broker_Rel__c + '_' + tmpBor.Broker_Contact__c;
                tmpBor.Composite_Key__c = key_string;
                
                if(!statusesToIgnore.contains(tmpBor.Opportunity_Stage__c)){
                    System.debug('mappedAr: ' + mappedAr.get(tmpBor.Broker_Rel__c));
                    if(trigger.isInsert){
                        tmpBor.Broker_Percentage__c = mappedAr.get(tmpBor.Broker_Rel__c).Broker_Percentage__c;
                        tmpBor.Broker_Flat_Rate__c = mappedAr.get(tmpBor.Broker_Rel__c).Broker_Flat_Rate__c;
                        tmpBor.Chronic_Care_Broker_Flat_Rate__c = mappedAr.get(tmpBor.Broker_Rel__c).Chronic_Care_Broker_Flat_Rate__c;
                        tmpBor.Chronic_Care_Broker_Percentage__c = mappedAr.get(tmpBor.Broker_Rel__c).Chronic_Care_Broker_Percentage__c;
                        
                    }
                    tmpBor.Location_of_Record__c = mappedAr.get(tmpBor.Broker_Rel__c).Broker_Loc_Name__c;
                    /*
                    * if(tmpBor.Broker_Contact__r.Location__c == NULL)
                        tmpBor.Location_of_Record__c = tmpBor.Broker_Contact__r.Account.Name;
                        else
                        tmpBor.Location_of_Record__c = tmpBor.Broker_Contact__r.Location__r.Name;
                    */
                } else {
                    System.debug('update ignored due to opportunity stage: ' + tmpBor.Opportunity_Stage__c);
                }
                
            } catch (System.NullPointerException e) {
                
                string e1 = e.getStackTraceString(); // can be assigned to a variable to display a user-friendly error message
                system.debug(e1);
            }
        }
    }
}