trigger AccountTriggers on Account (before insert, before update, after update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    if (!DS.Disable_Triggers__c) {   
        if(!Recursive.isAccountWorking()){
            System.debug(LoggingLevel.FINE,'First interation in Account');
            Recursive.setAccountWorking();
            
            // Evaluate accounts for Allow Flow
            Eval_Acct_For_Flow.Process(trigger.new);
            
            for (Account tmp_acct : Trigger.new) {
                // Check for attempt to flag ALLOW_FLOW and confirm it is not missing required Admin fields
                if(tmp_acct.Allow_Flow__c == TRUE && tmp_acct.Missing_Flow_Fields__c == TRUE){
                    //tmp_acct.addError('ALLOW_FLOW cannot be set while required Admin fields are missing.');
                }
                System.debug(LoggingLevel.FINE,'Setting source__c to HUB: ' + tmp_acct.Source__c);
                if(tmp_acct.Source__c == null || String.isBlank(tmp_acct.Source__c)){
                    tmp_acct.Source__c = 'HUB';
                }
                if (String.isBlank(tmp_acct.Business_Region__c)) {
                    tmp_acct.Business_Region__c = 'USA';
                    tmp_acct.Language__c = 'English';
                    tmp_acct.CurrencyIsoCode = 'USD';
                }
            }
            AccountTriggerHelper.setGUID(Trigger.new);   
        } else {
            System.debug(LoggingLevel.FINE,'Recursion is occurring in Account');
        }
        
        if (Trigger.isUpdate && Trigger.isAfter) {
            List<String> oppAcctList = new List<String>();
            for (Account acct: Trigger.new) {
                Account oldAcct = Trigger.oldMap.get(acct.Id);
                if(acct.Rev_Synergy__c != oldAcct.Rev_Synergy__c) {
                    oppAcctList.add(acct.Id);
                }
            }
  
            if (!oppAcctList.isEmpty()) {
            List<Opportunity> oppUpdateList = [SELECT Id FROM Opportunity WHERE AccountId IN: oppAcctList];         
                if (!oppUpdateList.isEmpty()) {               
            		update oppUpdateList;
                }
            List<OpportunityLineItem> oppliList = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.AccountId IN: oppAcctList];         	 
                if (!oppliList.isEmpty()) {
            		update oppliList;
           			 }
              }
       }

        
        // SCDEV-3381 - Result Code Short Description
        if (Trigger.isUpdate && Trigger.isBefore) {
            Map<Id,Account> oldMap = trigger.oldMap;
                        
            for (Account acct: Trigger.new) {
                String resultCodeDesc='';
                if(!String.isBlank(acct.Billing_Address_Personator_Result_Codes__c) && acct.Billing_Address_Personator_Result_Codes__c != oldMap.get(acct.Id).Billing_Address_Personator_Result_Codes__c){ 
                
                    String[] lstCodes = acct.Billing_Address_Personator_Result_Codes__c.split(',');
                    for(String code: lstCodes){
                        resultCodeDesc += code +' - '+ addressValidationHelper.getResultCodeShortDescription(code) +'\n';
                    }
                    acct.Billing_Address_Status_Message__c = resultCodeDesc;
                }
                
            }
        }
    }
    
}