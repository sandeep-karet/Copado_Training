trigger OpportunityTriggers on Opportunity (after insert, after update, before insert, before update, before delete) {
    // REFACTORED PB: 2018-10-28 - Calculate Days in Current Stage on Opportunity
    Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());
    List<Opportunity> oppStageChange = new List<Opportunity>();
    Set<Id> primaryCarrierList  = new  Set<Id>();
    Set<Id> addErrorPrimaryCarrierList  = new Set<Id>();
    List<SBQQ__Quote__c> quoStartDateUpdate = new List<SBQQ__Quote__c>();
    List<SBQQ__Quote__c> quoRecordTypeUpdate = new List<SBQQ__Quote__c>();
    List<Opportunity> oppUpdate = new List<Opportunity>();
    
    if (!DS.Disable_Triggers__c) {
        System.debug('Opp Trigger fired.');         
        if ((Trigger.isInsert ||Trigger.isUpdate) && Trigger.isBefore) {
            OpportunityTriggerHelper.setGUID(Trigger.new); 
        }    
        if (Trigger.isBefore && Trigger.isInsert) {
            OpportunityTriggerHelper.updateProbability(trigger.new, new Map<Id, Opportunity>());
            OpportunityTriggerHelper.autoPopulateAmendmentFields(Trigger.new);
            for (Opportunity tmp_opp : Trigger.new) {
                // Handle new stage
                if (tmp_opp.StageName != null)
                    tmp_opp.Stage_Changed_Date__c = Date.today();
            }      
        }
        
        List<Opportunity> oppStageChange = new List<Opportunity>();
        if (Trigger.isUpdate && Trigger.isBefore) {
            OpportunityTriggerHelper.checkAccountChange(trigger.new, trigger.oldMap);
            OpportunityTriggerHelper.updateProbability(trigger.new, trigger.oldMap);
            //For Creating Account Relation by Venu
            OpportunityTriggerHelper.createAcctRelation(trigger.new, trigger.oldMap); 
            
            Opp_RevFlagHelper.setFlag(trigger.newMap);   
            for (Opportunity tmp_opp : Trigger.new) {
                if (tmp_opp.StageName != Trigger.oldMap.get(tmp_opp.id).StageName)
                {
                    tmp_opp.Stage_Changed_Date__c = Date.today();
                    if( tmp_opp.RFP_Count__c > 0 &&  tmp_opp.StageName  == 'Closed Won' ){
                        tmp_opp.RFP_Finalist__c = true;
                    }else{
                        tmp_opp.RFP_Finalist__c = false;
                    }
                }
            }

            //validate the ProposalTemplate Value Only when PropsalTemplate is changed
            List<Opportunity> updatedTemplateOpp = new List<Opportunity>();
            for (Opportunity opp : Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (opp.Proposal_Template__c != oldOpp.Proposal_Template__c) {
                    updatedTemplateOpp.add(opp);
                }
            }
            if (updatedTemplateOpp != null && updatedTemplateOpp.size() > 0) {
                GlobalOppUtil.validProposalTemplate(updatedTemplateOpp, true);
            }

            //validate Contractee Relationship for StageChange on Opportunity to Contracting/Closed Won
            for (Opportunity opp : Trigger.new) {
                Opportunity oldstage = Trigger.oldMap.get(opp.Id);
                if (opp.StageName != oldstage.StageName || opp.SBQQ__Contracted__c != oldstage.SBQQ__Contracted__c) {
                    oppStageChange.add(opp);
                }
                
               // validation rule for Primary Carrier
                if (opp.StageName != oldstage.StageName && (opp.StageName == 'Closed Won' || opp.StageName == 'Contracting') ) {
                    primaryCarrierList.add(opp.Id);
                }


                // update quotas on opp
                if(opp.Quotas__c != oldstage.Quotas__c && oldstage.quotas__c != null) {
                    // update new quotas record's total AAR and IYR
                    if (opp.Quotas__c != null) {
                        Quotas__c newQuotas = [SELECT Id FROM Quotas__c WHERE Id =: opp.Quotas__c];   
                        List<AggregateResult> updateNewResult = [SELECT SUM(Ann_Rec_Rev__c) totalARR,SUM(In_Year_Rec_Rev__c) totalIYR 
                                                                 FROM Opportunity WHERE quotas__c =:opp.Quotas__c];
                        Decimal newQuotasAAR = (decimal)updateNewResult[0].get('totalARR') == null ? 0 : (decimal)updateNewResult[0].get('totalARR');
                        Decimal newQuotasIYR = (decimal)updateNewResult[0].get('totalIYR') == null ? 0 : (decimal)updateNewResult[0].get('totalIYR');
                        newQuotas.Current_Total_ARR__c = newQuotasAAR + opp.Ann_Rec_Rev__c;
                        newQuotas.Current_Total_IYR__c = newQuotasIYR + opp.In_Year_Rec_Rev__c;
                        update newQuotas; 
                        
                        // update old quotas record's total AAR and IYR
                        Quotas__c oldQuotas = [SELECT Id FROM Quotas__c WHERE Id =: oldstage.Quotas__c];   
                        List<AggregateResult> updateOldResult = [SELECT SUM(Ann_Rec_Rev__c) totalARR,SUM(In_Year_Rec_Rev__c) totalIYR 
                                                                 FROM Opportunity WHERE quotas__c =:oldstage.Quotas__c];
                        Decimal oldQuotasAAR = (decimal)updateOldResult[0].get('totalARR') == null ? 0 : (decimal)updateOldResult[0].get('totalARR');
                        Decimal oldQuotasIYR = (decimal)updateOldResult[0].get('totalIYR') == null ? 0 : (decimal)updateOldResult[0].get('totalIYR');
                        oldQuotas.Current_Total_ARR__c = oldQuotasAAR - opp.Ann_Rec_Rev__c;
                        oldQuotas.Current_Total_IYR__c = oldQuotasIYR - opp.In_Year_Rec_Rev__c;
                        update oldQuotas; 
                    } else {
                        //opp.addError('Associated Quotas can not be empty');
                    }
                }

                if(opp.StageName != oldstage.StageName && opp.StageName == 'Closed Won'){
                    User user = [SELECT UserRole.Name FROM User WHERE Id  =: opp.OwnerId ];
                    List<Quotas__c> quotasList = [SELECT Id FROM Quotas__c WHERE Quotas_Owner__c =: opp.OwnerId
                                                  AND Starting_Date__c <=: opp.Contracted_Date__c 
                                                  AND Ending_Date__c >=: opp.Contracted_Date__c
                                                  AND role__c =: user.userRole.Name];
                    if(quotasList.size() > 0) {
                        opp.Quotas__c = quotasList[0].Id;
                        List<AggregateResult> amountResult = [SELECT SUM(Ann_Rec_Rev__c) totalARR, SUM(In_Year_Rec_Rev__c) totalIYR 
                                                              FROM Opportunity WHERE quotas__c =:quotasList[0].Id AND Id !=: opp.Id];
                        Decimal AAR = (decimal)amountResult[0].get('totalARR') == null ? 0 : (decimal)amountResult[0].get('totalARR');
                        Decimal IYR = (decimal)amountResult[0].get('totalIYR') == null ? 0 : (decimal)amountResult[0].get('totalIYR');
                        quotasList[0].Current_Total_ARR__c = AAR + opp.Ann_Rec_Rev__c;
                        quotasList[0].Current_Total_IYR__c = IYR + opp.In_Year_Rec_Rev__c;
                        update quotasList[0];      
                    } else{
                        opp.Quotas__c = null;
                    }
                }
            }
            if (oppStageChange.size() > 0) {
                OpportunityValidator.validateStageChange(oppStageChange);
                OpportunityTriggerHelper.updateOppRecordType(oppStageChange);
                //OpportunityTriggerHelper.updateQuoteRecordType(oppStageChange);

            }
           
            if (primaryCarrierList.size() > 0) {
                 for(SBQQ__Quote__c quote: [SELECT Id, Sales_Channels__c, CPQ_Pricebook__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Primary_Carrier__c FROM SBQQ__Quote__c 
                                            WHERE SBQQ__Primary__c = TRUE 
                                            AND SBQQ__Opportunity2__c in :primaryCarrierList]) {
                    if(quote.SBQQ__Opportunity2__r.Primary_Carrier__c == null && 
                       (quote.Sales_Channels__c == 'US HealthPlan' || quote.CPQ_Pricebook__c == 'Carrier' || quote.CPQ_Pricebook__c == 'HealthPlan' || quote.CPQ_Pricebook__c == 'Complex Case Mgmt')) {
							addErrorPrimaryCarrierList.add(quote.SBQQ__Opportunity2__c);
                    }		
                }              
            }
            
            //Below values will be deprecated later for Contract Path LOB functionality
            /*if (addErrorPrimaryCarrierList.size() > 0) {
            for (Opportunity opp : Trigger.new) {
                if (addErrorPrimaryCarrierList.contains(opp.Id))
                    opp.addError('The Contract Path field is required for any health plan related opportunities.');
                }
            }*/

            //Validation rule for non-Contracting permission users on Contracting Opportunities
            
                       
            Id oppProviderRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Provider - Platform').getRecordTypeId();
            Id oppReadOnlyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Read Only').getRecordTypeId();
            
            for (Opportunity opp : Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (((opp.stageName == 'Closed Won' && oldopp.RecordTypeId != oppReadOnlyRecordType) || (oldOpp.SBQQ__Contracted__c == TRUE && oldopp.RecordTypeId == oppReadOnlyRecordType) || (opp.CPQ_Pricebook__c == 'Broker' && opp.StageName == 'Closed Won' && oldOpp.RecordTypeId != oppReadOnlyRecordType) || (opp.StageName == 'Closed Won' && oldOpp.RecordTypeId == oppProviderRecordType)) 
                    && (opp.StageName != oldOpp.StageName || oldOpp.CloseDate != opp.CloseDate || oldOpp.Name != opp.Name || oldOpp.Contracted_Date__c != opp.Contracted_Date__c || oldOpp.Contract_Service_Agreement_Status__c != opp.Contract_Service_Agreement_Status__c)) {
                   OpportunityValidator.validateContractingOtherOpp(opp, oldOpp);
                }

                //Validation rule for Contracting permission users on Contracting Opportunities
                if (oldOpp.StageName != 'Closed Won' && oldOpp.SBQQ__Contracted__c == TRUE && oldopp.RecordTypeId == oppReadOnlyRecordType && opp.StageName != 'Closed Won') {
                   OpportunityValidator.validateContractingOpp(opp, oldOpp);
                }

                //Validation rule for Non-system admins on Closed Won opportunity
                if (oldOpp.StageName == 'Closed Won' && (opp.StageName != oldOpp.StageName || oldOpp.CloseDate != opp.CloseDate || oldOpp.Name != opp.Name || oldOpp.Contracted_Date__c != opp.Contracted_Date__c)) {
                    OpportunityValidator.validateClosedWonOpp(opp);

                }

            }

        }

        if (Trigger.isUpdate && trigger.isAfter) {
            
            //handle account change for quote when opp account is changed
            Set<Id> oppIdsforDateChange = new Set<Id>();
            List<SBQQ__Quote__c> quoteStartDateChange = new List<SBQQ__Quote__c>();
            for(Opportunity opp: Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

                if(opp.CloseDate != oldOpp.CloseDate && (opp.stageName != 'Closed Won' && opp.closedate != Date.today()) ){
                    oppIdsforDateChange.add(opp.Id);
                }
            }
            
            if (oppIdsforDateChange.size() > 0){
                for(SBQQ__Quote__c quote: [SELECT id, SBQQ__StartDate__c, SBQQ__Opportunity2__r.CloseDate FROM SBQQ__Quote__c WHERE SBQQ__Quote__c.SBQQ__Opportunity2__c in :oppIdsforDateChange]) {
                    if(quote.SBQQ__StartDate__c != quote.SBQQ__Opportunity2__r.CloseDate) {
                        quote.SBQQ__StartDate__c = quote.SBQQ__Opportunity2__r.CloseDate;
                        quoteStartDateChange.add(quote);
                    }
                }              
                update quoteStartDateChange;
            }

            //handle Primary Quotelines NumberOfLives sync
            Set<Id> OppIdsforLivesChange = new Set<Id>();
            List<SBQQ__QuoteLine__c> quotelineLivesChange = new List<SBQQ__QuoteLine__c>();
            for(Opportunity opp: Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

                if(opp.Initial_of_Lives__c != oldOpp.Initial_of_Lives__c && opp.stageName != 'Closed Won'){
                    OppIdsforLivesChange.add(opp.Id);
                }
            }
            /*
             *  SCDEV-572 getting rid of it
            if(OppIdsforLivesChange.size() > 0){
                for(SBQQ__QuoteLine__c quoteline: [select id, SBQQ__Quantity__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Initial_of_Lives__c, 
                                                   SBQQ__Product__r.SBQQ__SubscriptionType__c, SBQQ__Quote__r.SBQQ__Primary__c 
                                                   from SBQQ__QuoteLine__c 
                                                   where (SBQQ__Product__r.family != 'Provider' and SBQQ__Product__r.family != 'Marketing')
                                                   and SBQQ__Quote__r.SBQQ__Primary__c = true and SBQQ__UpgradedSubscription__c = null 
                                                   and SBQQ__Quote__r.SBQQ__Opportunity2__c in :OppIdsforLivesChange]) {
                                                       
                                                       if(quoteline.SBQQ__Quantity__c != quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__r.Initial_of_Lives__c){
                                                           quoteline.SBQQ__Quantity__c = quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__r.Initial_of_Lives__c;
                                                           quotelineLivesChange.add(quoteline);
                                                       }
                                                   }
            }

            if(quotelineLivesChange.size() > 0)
                update quotelineLivesChange;
			*/
            List<SBQQ__Quote__c> quoteRecordTypeChange = new List<SBQQ__Quote__c>();
            for (SBQQ__Quote__c quo : [select id, RecordType.Name from SBQQ__Quote__c where SBQQ__Quote__c.SBQQ__Opportunity2__c in :oppStageChange]) {
                System.debug('Quote record type name *******' + RecordType.Name);
                if (quo.RecordType.DeveloperName != 'Read_Only') {
                    quoteRecordTypeChange.add(quo);
                }
            }
            if (quoteRecordTypeChange.size() > 0) {
                OpportunityTriggerHelper.updateQuoteRecordType(quoteRecordTypeChange);
                update quoteRecordTypeChange;
            }
            Set<Id> oppIds = new Set<Id>();
            Set<Id> oppRecIds = new Set<Id>();

            for (Opportunity opp : Trigger.new) {

                if (opp.CloseDate != Trigger.oldMap.get(opp.Id).CloseDate) {
                    oppIds.add(opp.Id);
                }
                if(opp.RecordType.DeveloperName == 'Read_Only' && opp.RecordTypeId != Trigger.oldMap.get(opp.Id).RecordTypeId) {
                    oppRecIds.add(opp.Id);
                }
            }
            RecordType quoReadOnlyRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c' AND Name = 'Read Only' LIMIT 1];
            if (oppIds.size() > 0) {
                for (SBQQ__Quote__c quo : [SELECT Id, SBQQ__StartDate__c, RecordTypeId, RecordType.Name,RecordType.DeveloperName,SBQQ__Opportunity2__r.RecordType.DeveloperName, SBQQ__Opportunity2__r.CloseDate from SBQQ__Quote__c WHERE SBQQ__Primary__c = TRUE AND SBQQ__Opportunity2__c in :oppIds]) {
                    if (quo.SBQQ__StartDate__c != quo.SBQQ__Opportunity2__r.CloseDate) {
                        quo.SBQQ__StartDate__c = quo.SBQQ__Opportunity2__r.CloseDate;
                        System.debug('Added quote to the list to update');
                        quoStartDateUpdate.add(quo);
                    }
                    if(quo.RecordType.DeveloperName != 'Read_Only' && quo.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Read_Only') {
                        quo.RecordTypeId = quoReadOnlyRecordType.Id;
                        quoRecordTypeUpdate.add(quo);
                    }
                }
            }
            
            if(OpportunityTriggerHelper.isFirstTime) {
                OpportunityTriggerHelper.isFirstTime = false;
                //Create Stage Metric custom Object record on Opportunity Stage change
                OpportunityTriggerHelper.createStageMetricObjRec(trigger.new, trigger.oldMap);
                
            }
        }
        
         if (Trigger.isInsert && trigger.isAfter) {
            //Create Stage Metric custom Object record on Opportunity Stage change
            OpportunityTriggerHelper.createStageMetricObjRec(trigger.new, null);
         }
        
        if (Message_Bus_Toggle__c.getOrgDefaults().Enable_MB__c) {
            /*if ((Trigger.isUpdate || Trigger.isInsert) && trigger.isBefore) {
                MB_OppTrgHelper.validateOppForBus(Trigger.New, Trigger.OldMap);
            } */
            if ((Trigger.isUpdate) && trigger.isBefore) {
                MB_OppTrgHelper.validateOppForBus(Trigger.New, Trigger.OldMap);
            }
            if ((Trigger.isBefore && Trigger.isDelete)) {
                MB_OppTrgHelper.deleteOpp(Trigger.Old);
            }
        }       
    }
}