// TDH SIDE
trigger MB_OppLineItem_Trg on OpportunityLineItem (after insert, after update, after delete) {
    if (Message_Bus_Toggle__c.getOrgDefaults().Enable_MB__c) {      
        Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
        if (!DS.Disable_Triggers__c) {
            List<String> queIdList = new List<String>();
            List<String> LvnProdList = new List<String>();
            List<Product2> prodList = [SELECT Id, ProductCode FROM Product2 where Family LIKE '%Livongo%'];
            for (Product2 prod: prodList) {
                LvnProdList.add(prod.ProductCode);
            } 
            Set<String> oppIdSet = new Set<String>();
            if (!Trigger.isDelete) {
                for (OpportunityLineItem oppli: Trigger.New) {
                    if (Trigger.isUpdate && MB_Recursive.isFirstUpdateOppli) {
                        MB_Recursive.isFirstUpdateOppli = false;
                        OpportunityLineItem oldOppli = Trigger.oldMap.get(oppli.Id);
                        if (oppli.Product_Family__c != null && oppli.Product_Family__c.Contains('Livongo')) {
                            oppIdSet.add(oppli.OpportunityId);
                        }
                    } else if (Trigger.isInsert && MB_Recursive.isFirstInsertOppli) {
                        MB_Recursive.isFirstInsertOppli = false;
                        if (oppli.Product_Family__c != null && oppli.Product_Family__c.Contains('Livongo')) {
                            oppIdSet.add(oppli.OpportunityId); 
                        }
                    }
                }
            }
            
            if (Trigger.isAfter && Trigger.isDelete) {
                for (OpportunityLineItem oppli: Trigger.Old) {
                    if (LvnProdList.contains(oppli.ProductCode)) {
                        oppIdSet.add(oppli.OpportunityId);
                    }
                } 
            }
            List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id in: oppIdSet And (StageName In ('Contracting', 'Closed Won', 'Closed Lost') OR isLvn__c = True)];
            oppIdSet.clear();
            for (Opportunity opp: oppList) {
                oppIdSet.add(opp.Id);
            }
            queIdList.addAll(oppIdSet);
            if (queIdList.size() > 0) {
                system.debug('how many time it hits');
               // Database.executeBatch(new MB_OppToQItemBatch(queIdList), 10);
            } 
        }
    }
}