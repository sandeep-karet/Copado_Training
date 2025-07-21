trigger Quotas_Before on Quotas__c (before insert, before update) {
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId()); 
    if (!DS.Disable_Triggers__c) {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                for(Quotas__c quotas: Trigger.new) {
                    // update role for quotas
                    quotas.role__c = [SELECT UserRole.Name FROM User WHERE Id  =: quotas.Quotas_Owner__c].UserRole.Name;
                    quotas.OwnerId = quotas.Quotas_Owner__c;
                    // check quotas period overlapping
                    List<Quotas__c> overlayRangeList = [SELECT Id FROM Quotas__c WHERE Quotas_Owner__c =: quotas.Quotas_Owner__c
                                                        AND Starting_Date__c <=: quotas.Ending_Date__c 
                                                        AND Ending_Date__c >=: quotas.Starting_Date__c
                                                        AND Role__c =: quotas.Role__c
                                                       ];
                    if (overlayRangeList.size() > 0) {
                        quotas.addError('Quoats Period is overalpping for the quotas owner with same role');
                    }
                    
                    // check if end date < start date
                    if (quotas.Starting_Date__c >= quotas.Ending_Date__c){ 
                        quotas.addError('End date must be greater than start date');
                        
                    }   
                }
            }
            if(Trigger.isUpdate){
                for(Quotas__c quotas: Trigger.new) {
                    quotas.OwnerId = quotas.Quotas_Owner__c;
                    quotas.role__c = [SELECT UserRole.Name FROM User WHERE Id  =: quotas.Quotas_Owner__c].UserRole.Name;
                    List<Quotas__c> overlayRangeList = [SELECT Id FROM Quotas__c WHERE Quotas_Owner__c =: quotas.Quotas_Owner__c
                                                        AND Starting_Date__c <=: quotas.Ending_Date__c 
                                                        AND Ending_Date__c >=: quotas.Starting_Date__c
                                                        AND Role__c =: quotas.Role__c
                                                        AND Id !=: quotas.Id
                                                       ];
                    if (overlayRangeList.size() > 0) {
                        quotas.addError('Quoats Period is overalpping for the quotas owner with same role');
                    }
                    if (quotas.Starting_Date__c >= quotas.Ending_Date__c){ 
                        quotas.addError('End date must be greater than start date');        
                    }  
                }
            }
        }  
    }
}