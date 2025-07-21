trigger Acct_Rel_After on Acct_Rel__c (after insert, after update, after delete) {
	// Sponsor assignment on accounts
    Map<Id, String> mappedSponsors = new Map<Id, String>();

    // Gather svc_account ids and evaluate for flow
	Set<Id> dce_ids = new Set<Id>();

    // Take into account svc when deleting acct_rel__c
    if(Trigger.isDelete || Trigger.isUpdate){
        for(Acct_Rel__c tmpAr : Trigger.old){
            dce_ids.add(tmpAr.Svc_Acct__c);
        }
    }
    
    // Consider old/new accounts when reassigning svc_acct on acct_rel__c
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Acct_Rel__c tmpAr : Trigger.new){
            dce_ids.add(tmpAr.Svc_Acct__c);
            // Update broker info on benefit sponsor
            if (tmpAr.Relationship_Type__c == 'Broker'){
                if (tmpAr.Start_Date__c < Date.today() && (tmpAr.End_Date__c == NULL || tmpAr.End_Date__c > Date.today())) {
                    mappedSponsors.put(tmpAr.Benefit_Sponsor__c, tmpAr.Svc_Acct_Name__c);
                    // add to dce_ids for broker name update
                    dce_ids.add(tmpAr.Benefit_Sponsor__c);
                }
            }
        }
    }

    // Fetch all accounts to be reviewed for eithre Svc Account or Benefit Sponsor
    List<Account> target_accts = [select id, Account_Type__c, Allow_Flow__c, Broker_Account_Names__c from Account where id in :dce_ids];

    // Reassign broker names
    if (mappedSponsors.size() > 0) {
        for(Account tmpAcct : target_accts) {
            if(mappedSponsors.containsKey(tmpAcct.Id))
                tmpAcct.Broker_Account_Names__c = mappedSponsors.get(tmpAcct.Id);    
        }
    }

    System.debug('[Acct_Rel_After] Accounts targeted: ' + target_accts.size());
    Eval_Acct_For_Flow.Process(target_accts);

    // Fail quietly
    Database.SaveResult[] sr = Database.update(target_accts, false);
}