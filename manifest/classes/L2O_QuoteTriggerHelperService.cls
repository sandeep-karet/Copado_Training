/**
* Company : PwC.
* @description : L2O_QuoteTriggerHelperService will be executed from the L2O_QuoteTriggerHandler and will contain all the CPQ Quote logic.
* **********************************************************************************************************************************
* History : 
* @date 14/03/2022
* @author Lakshitha Salian
*/
@SuppressWarnings ('PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount')
public without sharing class L2O_QuoteTriggerHelperService {
    
    /**
* @name  mapApprovalStatusToQuoteStatus
* @description Update the Quote Status as per the Approval Status mapping from Metadata
* @params  none
**/
    public void mapApprovalStatusToQuoteStatus(){
       //Set Exception Log MethodName
        setExceptionVars('mapApprovalStatusToQuoteStatus');
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        List<SBQQ__Quote__c> lstUpdateQuoteStatus = new List<SBQQ__Quote__c>();
        
        //Check if Approval Status changed.
        for(SBQQ__Quote__c  quote: newQuotes){
            SBQQ__Quote__c oldQuote = (SBQQ__Quote__c)Trigger.oldMap.get(quote.ID);
            //Approval Status changed.
            if(quote.ApprovalStatus__c != oldQuote.ApprovalStatus__c){
                lstUpdateQuoteStatus.add(quote);
            } 
        }
        //Fetch Approval Status to Quote Status Mapping metadata.
        if(!lstUpdateQuoteStatus.isEmpty()){
            //Prepare map of Approval Status to Quote Status.
            List<L2O_QuoteApprovalStatus__mdt> lstApprovalToQuoteStatus = [SELECT Id,Label,L2O_Quote_Status__c 
                                                                        FROM L2O_QuoteApprovalStatus__mdt 
                                                                        WHERE L2O_Quote_Status__c != null
                                                                        LIMIT 100];
            Map<String,String> mapApprovalToQuoteStatus = new Map<String,String>();
            for (L2O_QuoteApprovalStatus__mdt mapStatus : lstApprovalToQuoteStatus){
                mapApprovalToQuoteStatus.put(mapStatus.Label,mapStatus.L2O_Quote_Status__c);
            }            
            //Update respective Quote status as per map.
            for(SBQQ__Quote__c  quote: lstUpdateQuoteStatus){
                if(mapApprovalToQuoteStatus.containsKey(quote.ApprovalStatus__c) && quote.L2O_Replacement_Quote__c == null && (quote.L2O_Business_Region__c == 'Canada' || quote.L2O_Business_Region__c == 'USA')){
                    quote.SBQQ__Status__c = mapApprovalToQuoteStatus.get(quote.ApprovalStatus__c);
                }
                if(quote.ApprovalStatus__c == 'Approved' && (quote.L2O_Business_Region__c != 'Canada' && quote.L2O_Business_Region__c != 'USA') && quote.L2O_Replacement_Quote__c == null){
                    quote.SBQQ__Status__c = 'Accepted';
                }
            }
        }
        
    }
    
    /**
* @name  updateQuote
* @description To update the Quote fields with automated values.
* @param mapOppInfo Map of related Opportunities
**/
    public void updateQuote(Map<Id,Opportunity> mapOppInfo){
        
        //Set Exception Log MethodName
        setExceptionVars('updateQuote');
        
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        Map<Id,SBQQ__Quote__c> mapOldQuotes = (Map<Id,SBQQ__Quote__c>)Trigger.oldMap;
        for(SBQQ__Quote__c  quote: newQuotes){
            // check if Business Region is null
            if(quote.L2O_Business_Region__c == null){
                quote.L2O_Business_Region__c = mapOppInfo.get(quote.SBQQ__Opportunity2__c).L2O_Business_Region__c;
            }
            
            //Default the End Date to Start Date + Subscription Term months.
            if( ( quote.SBQQ__EndDate__c == null || 
                 (mapOldQuotes!=null && !mapOldQuotes.isEmpty() && 
                  ((quote.SBQQ__StartDate__c != mapOldQuotes.get(quote.Id).SBQQ__StartDate__c)
                   || (quote.SBQQ__SubscriptionTerm__c != mapOldQuotes.get(quote.Id).SBQQ__SubscriptionTerm__c)
                   || (quote.SBQQ__EndDate__c != mapOldQuotes.get(quote.Id).SBQQ__EndDate__c))) ) ){
                       if(quote.SBQQ__StartDate__c!= null && quote.SBQQ__SubscriptionTerm__c!= null){
                           Integer months = (Integer)quote.SBQQ__SubscriptionTerm__c;
                           quote.SBQQ__EndDate__c = quote.SBQQ__StartDate__c.addMonths(months) - 1;
                       }
                       
                   } 
            
            //Update field Primary to True when Status is Approved.
            //if(quote.SBQQ__Status__c == 'Approved' && quote.SBQQ__Primary__c == False){
            // quote.SBQQ__Primary__c = True;
        }
        
    }
    
    /**
* @name  shareQuote
* @description To share the Quote record with owner's Manager and owner's Manager's Manager.
* @params  none
**/
    public void shareQuote(){
        
        //Set Exception Log MethodName
        setExceptionVars('shareQuote');
        
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        Map<Id,SBQQ__Quote__c> mapOldQuotes = (Map<Id,SBQQ__Quote__c>)Trigger.oldMap;
        List<SBQQ__Quote__Share> lstQuoteShare = new List<SBQQ__Quote__Share>();
        
        for(SBQQ__Quote__c  quote: newQuotes){
            
            if(Trigger.isInsert || (Trigger.isUpdate && quote.OwnerId != mapOldQuotes.get(quote.Id).OwnerId)){
                // Create quote share rows for manager and manager's manager sharing
                lstQuoteShare.add(createQuoteShare(quote.Id,quote.L2O_Owners_Manager__c));
                lstQuoteShare.add(createQuoteShare(quote.Id,quote.L2O_Owners_Managers_Manager__c));
            }
        }
        
        if(!lstQuoteShare.isEmpty()){
            // The false parameter allows for partial processing if multiple records
            Database.insert(lstQuoteShare,false);
        }
        
    }
    
    /**
* @name  shareQuote
* @description To share the Quote record with owner's Manager and owner's Manager's Manager.
* @param quoteId To pass the current QuoteId
* @param shareUser To pass the share to userId
* @return Quote Share row
**/
    public SBQQ__Quote__Share createQuoteShare(Id quoteId, String shareUser){
        
        //Set Exception Log MethodName
        setExceptionVars('createQuoteShare');
        
        SBQQ__Quote__Share newQuoteShare = new SBQQ__Quote__Share();
        newQuoteShare.ParentId = quoteId;
        newQuoteShare.UserOrGroupId = shareUser;
        newQuoteShare.AccessLevel = 'Edit';
        newQuoteShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;
        
        return newQuoteShare;
        
    }  
    
    /**
* @name  checkIfOpportunityHasContactRole
* @description to check if opportunity do have the contact before creation of new quote.
* @params none
**/
    public void checkIfOpportunityHasContactRole(){
        
        //Set Exception Log MethodName
        setExceptionVars('checkIfOpportunityHasContactRole');
        Set<Id> oppId = new Set<Id>();
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        for(SBQQ__Quote__c quote:newQuotes){
            OppId.add(quote.SBQQ__Opportunity2__c); 
            
        }
        Map<Id,List<OpportunityContactRole>> oppConMap = new Map<Id,List<OpportunityContactRole>>();
        L2O_OpportunityValidationRuleClass oppConMethod = new L2O_OpportunityValidationRuleClass();
        if(!OppId.isEmpty()){
            oppConMap = oppConMethod.getOpportunityContactRoleCount(OppId);
            for(SBQQ__Quote__c quote:newQuotes){
                if(oppConMap.isEmpty() || !oppConMap.containsKey(quote.SBQQ__Opportunity2__c)){
                    quote.addError(System.Label.L2O_opportunity_does_have_Contact_before_new_Quote);
                    
                }
                
            }
        }
        
    }
    
    /**
* @name  assignNewQuoteAsPrimary
* @description To only make the latest quote as primary quote
* @params none
**/
    public void assignNewQuoteAsPrimary(){
        //Set Exception Log MethodName
        setExceptionVars('assignNewQuoteAsPrimary');
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        Map<Id,Opportunity> mapOpportunitiesInfo = new Map<Id,Opportunity>();
        Map<Id,SBQQ__Quote__c> oldQuotesMap = (Map<Id,SBQQ__Quote__c>)Trigger.oldMap;
        Map<Id,SBQQ__Quote__c> oppQuoteMap = new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> statusChangedQuotes = new List<SBQQ__Quote__c>();
        Set<Id> oppIdsSet = new Set<Id>();
        Set<Id> oppId = new Set<Id>();
        Set<Id> quoteId = new Set<Id>();
        for(SBQQ__Quote__c quote:newQuotes){
            oppIdsSet.add(quote.SBQQ__Opportunity2__c);
            if(Trigger.isInsert || (quote.SBQQ__Status__c != oldQuotesMap.get(quote.id).SBQQ__Status__c)){
                OppId.add(quote.SBQQ__Opportunity2__c); 
                quoteId.add(quote.id);
                statusChangedQuotes.add(quote);                
            }
        }
        if(!oppIdsSet.isEmpty() && oppIdsSet != null){
            for(Opportunity opp : [SELECT Id,SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.SBQQ__Quote__r.L2O_Sales_Type__c,SBQQ__AmendedContract__c,
                                   SBQQ__AmendedContract__r.SBQQ__Quote__r.L2O_Sales_Type__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.L2O_Carrier__c,
                                   SBQQ__RenewedContract__r.SBQQ__Quote__r.L2O_Carrier__c,L2O_Carrier__c,L2O_Contracting_Account__c,
                                   SBQQ__AmendedContract__r.SBQQ__Quote__r.L2O_Contracting_Account__c,SBQQ__RenewedContract__r.SBQQ__Quote__r.L2O_Contracting_Account__c,
                                   Name,L2O_Business_Region__c,SBQQ__RenewedContract__r.L2O_AutoRenew__c,SBQQ__RenewedContract__r.EndDate,OwnerId,
                                   SBQQ__PrimaryQuote__r.L2O_Auto_Approve__c,
                                   (SELECT id,SBQQ__Primary__c,SBQQ__Status__c 
                                    FROM SBQQ__Quotes2__r 
                                    WHERE (SBQQ__Status__c = 'Approved' OR SBQQ__Status__c = 'Accepted' OR SBQQ__Status__c = 'Presented')
                                    AND SBQQ__Primary__c = TRUE AND ID NOT IN :quoteId LIMIT 1)
                                   FROM Opportunity
                                   WHERE ID IN :oppIdsSet]){
                                       if(opp.SBQQ__Quotes2__r.size() > 0 && OppId.contains(opp.Id)){
                                           oppQuoteMap.put(opp.id,opp.SBQQ__Quotes2__r[0]);
                                       }
                                       mapOpportunitiesInfo.put(opp.Id,opp);
                                   }
            
            for(SBQQ__Quote__c quote:statusChangedQuotes){
                if( quote.SBQQ__Status__c == L2O_Constants.QUOTE_STATUS_APPROVED ) {                                        
                    if(quote.SBQQ__Primary__c == FALSE && (oppQuoteMap.get(quote.SBQQ__Opportunity2__c) == null || (oppQuoteMap.get(quote.SBQQ__Opportunity2__c).SBQQ__Status__c != L2O_Constants.QUOTE_STATUS_PRESENTED &&  oppQuoteMap.get(quote.SBQQ__Opportunity2__c).SBQQ__Status__c != L2O_Constants.QUOTE_STATUS_ACCEPTED))){
                        quote.SBQQ__Primary__c = TRUE;                                                   
                    }
                }
                else{
                    if(oppQuoteMap.get(quote.SBQQ__Opportunity2__c) != null ){
                        quote.SBQQ__Primary__c = FALSE;
                    }
                }
            }
            if(Trigger.isInsert && !mapOpportunitiesInfo.isEmpty()){
                assignQuoteDefaultValues(mapOpportunitiesInfo);
            }
            if(!mapOpportunitiesInfo.isEmpty()){
                updateQuote(mapOpportunitiesInfo);
            }
        }
    }
    
    /**
* @name  stopUserTochangePrimaryQuotePresented
* @description To only make the latest quote as primary quote
* @params none
**/
    public void stopUserTochangePrimaryQuotePresented(){  
        //Set Exception Log MethodName
        setExceptionVars('stopUserTochangePrimaryQuotePresented');
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        Map<Id,SBQQ__Quote__c> oldQuotesMap = (Map<Id,SBQQ__Quote__c>)Trigger.oldMap;
        List<SBQQ__Quote__c> statusChangedQuotes = new List<SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> oppQuoteMap = new Map<Id,SBQQ__Quote__c>();       
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setQuoteId = new Set<Id>();
        for(SBQQ__Quote__c quote:newQuotes){            
            if((quote.SBQQ__Primary__c != oldQuotesMap.get(quote.id).SBQQ__Primary__c)){               
                setOppId.add(quote.SBQQ__Opportunity2__c); 
                setQuoteId.add(quote.id);
                statusChangedQuotes.add(quote);
            }
            //To update Quote End Date to null for Renewal Quote #15235 CR
            if(quote.L2O_Disable_Renewal_Co_Term__c != oldQuotesMap.get(quote.Id).L2O_Disable_Renewal_Co_Term__c &&
               quote.L2O_Disable_Renewal_Co_Term__c && quote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_RENEWAL){
                   quote.SBQQ__EndDate__c = null;
               }
        }
        if(!statusChangedQuotes.isEmpty() && statusChangedQuotes != null){
            List<SBQQ__Quote__c> quoteList = [SELECT id,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Opportunity2__c
                                              FROM SBQQ__Quote__c 
                                              WHERE (SBQQ__Status__c = 'Accepted' OR SBQQ__Status__c = 'Presented') 
                                              AND SBQQ__Primary__c = TRUE 
                                              AND ID NOT IN :setQuoteId 
                                              AND SBQQ__Opportunity2__c IN :setOppId];
            for(SBQQ__Quote__c tempQuote : quoteList){
                oppQuoteMap.put(tempQuote.SBQQ__Opportunity2__c,tempQuote);
            }
            for(SBQQ__Quote__c quote:statusChangedQuotes){
                
                if(oppQuoteMap.get(quote.SBQQ__Opportunity2__c) != null && (oppQuoteMap.get(quote.SBQQ__Opportunity2__c).SBQQ__Status__c == L2O_Constants.QUOTE_STATUS_PRESENTED ||  oppQuoteMap.get(quote.SBQQ__Opportunity2__c).SBQQ__Status__c == L2O_Constants.QUOTE_STATUS_ACCEPTED) &&
                   quote.SBQQ__Primary__c == TRUE){
                       
                       quote.addError(System.Label.L2O_Already_accepted_Primary_quote_exist);
                       
                   }                
            }
        }    	
    }
    
    /**
* @name  setExceptionVars
* @description To update Exception log variables ClassName & MethodName
* @param methodName To pass the current MethodName
**/
    public void setExceptionVars(String methodName){
        If (methodName != null){
            L2O_OpportunityTriggerHandler.className = 'L2O_QuoteTriggerHelperService';
            L2O_OpportunityTriggerHandler.methodName = methodName;
        }
    }
    
    /**
* @name updateQuoteSalesTypeOnOpp 
* @description To update Sales Type from Quotes onto Opportunity #15270
* @params  none
**/
    public void updateQuoteSalesTypeOnOpp(){
        
        //Set Exception Log MethodName
        setExceptionVars('updateQuoteSalesTypeOnOpp');
        
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        Map<Id,String> oppIdToSalesType = new Map<Id,String>();
        
        for(SBQQ__Quote__c newQuote: newQuotes){ //Trigger.new
            //On Update
            if(Trigger.isUpdate && newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_QUOTE){
                SBQQ__Quote__c oldQuote = (SBQQ__Quote__c)Trigger.oldMap.get(newQuote.ID);
                if(newQuote.SBQQ__Primary__c == true && oldQuote.L2O_Sales_Type__c != newQuote.L2O_Sales_Type__c){
                    oppIdToSalesType.put(newQuote.SBQQ__Opportunity2__c,newQuote.L2O_Sales_Type__c);
                } 
            }
        }
        
        //update opportunity list
        if(oppIdToSalesType.size() > 0){
            List<Opportunity> updateOppList = new List<Opportunity>();
            for(Id oppId: oppIdToSalesType.keySet()){
                updateOppList.add(new Opportunity(Id=oppId,L2O_Sales_Type__c=oppIdToSalesType.get(oppId)));  
            }
            if(updateOppList.size() > 0){
                update(updateOppList);
            }
        }
        
    }
    
    /**
* @name assignQuoteDefaultValues 
* @description To update Quote default values #15270
* @param mapOppInfo map of related opportunities 
**/
    public void assignQuoteDefaultValues(Map<Id,Opportunity> mapOppInfo){
        
        //Set Exception Log MethodName
        setExceptionVars('assignQuoteDefaultValues');
        
        List<SBQQ__Quote__c> newQuotes = Trigger.new;
        for(SBQQ__Quote__c newQuote: newQuotes){ //Trigger.new
            if(newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_AMENDMENT || newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_RENEWAL || newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_QUOTE){
                if(newQuote.L2O_Contracting_Account__c == null &&  newQuote.SBQQ__Opportunity2__c != null){
                    newQuote.L2O_Contracting_Account__c = mapOppInfo.get(newQuote.SBQQ__Opportunity2__c).L2O_Contracting_Account__c;
                    
                }
                //For Amendment Quotes	
                if(newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_AMENDMENT){
                    newQuote.L2O_Sales_Type__c = mapOppInfo.get(newQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.L2O_Sales_Type__c;
                    newQuote.L2O_Contracting_Account__c = mapOppInfo.get(newQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.L2O_Contracting_Account__c;
                    
                }
                //For Renewal Quotes	
                if(newQuote.SBQQ__Type__c == L2O_Constants.QUOTE_TYPE_RENEWAL){
                    newQuote.L2O_Sales_Type__c = mapOppInfo.get(newQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.SBQQ__Quote__r.L2O_Sales_Type__c;
                    newQuote.L2O_Contracting_Account__c = mapOppInfo.get(newQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.SBQQ__Quote__r.L2O_Contracting_Account__c;
                }                                
            }
        }
    }
    /*************************************************************************     
    * @description This class is used for setting Launch Status of Quotelines
    * @param newquotes newly updated quotes
    * @Author InfoSys Developer
    **************************************************************************/   
    @future
    public static void updateLaunchStatusField(List<Id> newquotes) {
            
            Map<String, SBQQ__QuoteLine__c> upgradedQuoteLinesMap = new Map<String, SBQQ__QuoteLine__c>();
            Map<String, SBQQ__QuoteLine__c> newQuoteLinesMap = new Map<String, SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
            Map<Id, SBQQ__QuoteLine__c> quoteLineMapParent = new Map<Id,SBQQ__QuoteLine__c>();
                                             
                                                for (SBQQ__QuoteLine__c quoteLine :[SELECT Id, Launch_Status__c, SBQQ__ProductCode__c,Did_Not_Launch_Date__c, SBQQ__Quantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, 
                                                                                    SBQQ__UpgradedSubscription__c, SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c,SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,Delayed_Launch_Date__c, L2O_Contract_Action__c,SBQQ__RequiredBy__c,SBQQ__Quote__c  FROM SBQQ__QuoteLine__c 
                                                                                    WHERE SBQQ__Quote__c IN :newquotes AND SBQQ__RequiredBy__c = null AND L2O_Contract_Action__c != 'Price Change' Order By SBQQ__EffectiveStartDate__c DESC]) {
                                                    if (quoteLine.SBQQ__UpgradedSubscription__c != null && quoteLine.SBQQ__Quantity__c == 0) {
                                                        upgradedQuoteLinesMap.put(quoteLine.SBQQ__ProductCode__c, quoteLine);
                                                    }
                                                    else {
                                                        newQuoteLinesMap.put(quoteLine.SBQQ__ProductCode__c, quoteLine);
                                                    }
                                                }   
                                               
                                            if (!upgradedQuoteLinesMap.values().isEmpty()) {
                                                
                                                for (SBQQ__QuoteLine__c upgradedQuoteLine :upgradedQuoteLinesMap.values()) {
                                                    SBQQ__QuoteLine__c newQuoteLine = newQuoteLinesMap.get(upgradedQuoteLine.SBQQ__ProductCode__c) != null ? newQuoteLinesMap.get(upgradedQuoteLine.SBQQ__ProductCode__c) : null;
                                                    SBQQ__QuoteLine__c oldQuoteLine = new SBQQ__QuoteLine__c(Id=upgradedQuoteLine.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c,SBQQ__Quote__c=upgradedQuoteLine.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c) ;
                
                                                    if (upgradedQuoteLine.SBQQ__Quantity__c == 0 && newQuoteLine != null && newQuoteLine.L2O_Contract_Action__c != 'Price Change' 
                                                        && newQuoteLine.SBQQ__EffectiveStartDate__c > upgradedQuoteLine.SBQQ__EffectiveStartDate__c) {
                                                        upgradedQuoteLine.Launch_Status__c = 'Delayed Launch';
                                                        oldQuoteLine.Launch_Status__c = 'Delayed Launch';
                                                        upgradedQuoteLine.Delayed_Launch_Date__c=newQuoteLine.SBQQ__EffectiveStartDate__c;
                                                        oldQuoteLine.Delayed_Launch_Date__c=newQuoteLine.SBQQ__EffectiveStartDate__c;
                                                        
                                                    }
                                                    else if (upgradedQuoteLine.SBQQ__Quantity__c == 0) {
                                                        upgradedQuoteLine.Launch_Status__c = 'Did not Launch';
                                                        upgradedQuoteLine.Did_Not_Launch_Date__c = System.Today(); //Setting the Did not Launch Date
                                                        oldQuoteLine.Launch_Status__c = 'Did not Launch';
                                                        oldQuoteLine.Did_Not_Launch_Date__c = System.Today();  //Setting the Did not Launch Date
                                                        upgradedQuoteLine.Delayed_Launch_Date__c=null;
                                                         oldQuoteLine.Delayed_Launch_Date__c=null;
                                                    }
                                                  
                                                    quoteLinesToUpdate.add(upgradedQuoteLine);    
                                                    quoteLinesToUpdate.add(oldQuoteLine);
                                                    quoteLineMapParent.put(oldQuoteLine.Id,oldQuoteLine);
                                                    
                                                    quoteLineMapParent.put(upgradedQuoteLine.Id,upgradedQuoteLine);
                                                    
                                              }   
                                                
                                            } 
                                            //child quoteline logic
                                            Set<Id> updatedQuoteIds=new Set<Id>();
                                            for(Id chre:quoteLineMapParent.keySet())
                                            {
                                                updatedQuoteIds.add(quoteLineMapParent.get(chre).SBQQ__Quote__c);
                                            }
                                            for(SBQQ__QuoteLine__c childQuoteLine:[SELECT Id, Launch_Status__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, 
                                            SBQQ__UpgradedSubscription__c,SBQQ__Quote__c,SBQQ__RequiredBy__c,SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c, L2O_Contract_Action__c,Delayed_Launch_Date__c, Did_Not_Launch_Date__c
                                                                                   FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :updatedQuoteIds AND  SBQQ__RequiredBy__c!=null Order By Name ASC])
                                            {
                                                if(quoteLineMapParent.containsKey(childQuoteLine.SBQQ__RequiredBy__c))
                                                {
                                                    SBQQ__QuoteLine__c chqlrec=new SBQQ__QuoteLine__c();
                                                    chqlrec.Id=childQuoteLine.Id;
                                                    chqlrec.Launch_Status__c=quoteLineMapParent.get(childQuoteLine.SBQQ__RequiredBy__c).Launch_Status__c;
                                                    chqlrec.Delayed_Launch_Date__c=quoteLineMapParent.get(childQuoteLine.SBQQ__RequiredBy__c).Delayed_Launch_Date__c;
                                                    chqlrec.Did_Not_Launch_Date__c =quoteLineMapParent.get(childQuoteLine.SBQQ__RequiredBy__c).Did_Not_Launch_Date__c;
                                                    quoteLineMapParent.put(chqlrec.Id,chqlrec);
                                                    quoteLinesToUpdate.add(chqlrec);
                                                }
                                            }
                                            if (!quoteLinesToUpdate.isEmpty()) {
                                                
                                                update quoteLinesToUpdate;
                                            }                             
    }
   
    
}