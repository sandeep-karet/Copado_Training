trigger QuoteTriggers on SBQQ__Quote__c (before insert, before update, after insert, after update) {
    //SBQQ.TriggerControl.disable();
    RecordType rtReadOnlyOpp = [select id, developername 
                                from recordtype 
                                where sobjecttype = 'Opportunity' and developername = 'Read_Only' limit 1];
    Id profileId=userinfo.getProfileId();
    String profileName =[Select Id,Name from Profile where Id=:profileId].Name;
    
    // REFACTOR: 2018-10-26 - Use custom setting to disable trigger
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId()); 
    if (!DS.Disable_Triggers__c) {
        if (Trigger.isBefore) {
            // COP-742 - prevent quote from being edited if opportunity is set to Read_Only            
            Set<Id> targetOpps = new Set<Id>();
            for(SBQQ__Quote__c tmpCpqQuote: Trigger.new){
                targetOpps.add(tmpCpqQuote.SBQQ__Opportunity2__c);
            }
            system.debug('targetOpps:' + targetOpps);
            Map<Id,Opportunity> readOnlyOpps = new Map<Id,Opportunity>([select id from Opportunity 
                                                where id in :targetOpps
                                               and recordtype.developername = 'Read_Only']);

            system.debug('readonlyOpps:' + readOnlyOpps.keySet());
            for(SBQQ__Quote__c tmpCpqQuote: Trigger.new){
                system.debug('looking for opp:' + tmpCpqQuote.SBQQ__Opportunity2__c);
                if(readOnlyOpps.containsKey(tmpCpqQuote.SBQQ__Opportunity2__c) && !profileName.contains('System Administrator'))
                    tmpCpqQuote.addError('Cannot edit this record while associated OPPORTUNITY is read-only.');
            }
            if (Trigger.isInsert) {
                QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(Trigger.new);
            }
        } else if(Trigger.isAfter) {
            if (Trigger.isUpdate){
                QuoteTriggerHelper.QuoteUpdateOpp(Trigger.new, Trigger.oldMap);
            }           
        }
    }
    //SBQQ.TriggerControl.enable();
}