/**
* Company : PwC.
* @description : L2O_OpportunityTriggerHelperService will be executed from the L2O_OpportunityTriggerHandler and will contain all the Opportunity logic.
* **********************************************************************************************************************************
* History : 
* @date 29/03/2022
* @author Neha Sharma
*/

@SuppressWarnings('PMD.StdCyclomaticComplexity , PMD.NcssMethodCount,PMD.OperationWithLimitsInLoop,PMD.UnusedLocalVariable,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount')
public without sharing class L2O_OpportunityTriggerHelperService{
    //Exception log variables
    public static String className = '';
    public static String methodName = '';
    /**
* @name  updateOpportunity
* @description To update the Opportunity fields with automated values only Before Update context.
* @params  none
**/
    public void updateOpportunity(){ 
        
        //Set Exception Log MethodName
        setExceptionVars('updateOpportunity');
        
        List<Opportunity> newOpps = Trigger.new;
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        Map<Id,Opportunity> mapOppSalesTypeUpdate = new Map<Id,Opportunity>();
        
        for(Opportunity  opp: newOpps){
            
            //Update the Contracted field to True. #5625
            if( mapOldOpps!=null && !mapOldOpps.isEmpty() && (opp.stageName != mapOldOpps.get(opp.Id).stageName)
               && opp.stageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN && opp.SBQQ__Contracted__c == FALSE && !opp.Name.CONTAINS(L2O_Constants.RIP_REPLACE_OPPTY_PREFIX_NAME)){
                   opp.SBQQ__Contracted__c = TRUE;
               }
            
            //Update the Sales Type from Primary Quote's Sales Type. #15270
            if( mapOldOpps!=null && !mapOldOpps.isEmpty() && 
               (opp.Type == L2O_Constants.OPPTY_TYPE_EXISTINGBUSINESS || opp.Type == L2O_Constants.OPPTY_TYPE_RESIGNBUSINESS) ){
                   //system.debug('check primary quotes sales type'+opp.SBQQ__PrimaryQuote__r.L2O_Sales_Type__c);//shows Null value
                   mapOppSalesTypeUpdate.put(opp.Id,opp);
               }
            If(opp.Type == L2O_Constants.RENEWAL_OPPTY_TYPE && opp.L2O_Subtype__c == L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_RENEWAL){
                opp.L2O_Prior_ARR_value__c = 0;
                opp.L2O_Prior_Bookings_Total_Value__c = 0;
                opp.L2O_Prior_Est_One_Time_Revenue__c = 0;
                opp.L2O_Prior_Net_ARR__c = 0;
                opp.L2O_Prior_TCV_Value__c = 0; 
                opp.L2O_Prior_Est_First_Year_Revenue__c = 0;
                opp.L2O_Prior_Est_In_Year_Revenue__c = 0;
                opp.L2O_Prior_Net_ARR_w_PG__c = 0; 
            }
        } 
        
        if(!mapOppSalesTypeUpdate.isEmpty()){
            Map<Id,SBQQ__Quote__c> mapPrimaryQuoteToSalesType = new Map<Id,SBQQ__Quote__c>([SELECT ID,L2O_Sales_Type__c FROM SBQQ__Quote__c 
                                                                                            WHERE SBQQ__Primary__c = TRUE AND SBQQ__Opportunity2__c =: mapOppSalesTypeUpdate.keySet()]);
            for(Opportunity  opp: mapOppSalesTypeUpdate.values()){
                //Update the Primary Quote's Sales Type onto the Opp Sales Type.
                if(mapPrimaryQuoteToSalesType.containsKey(opp.SBQQ__PrimaryQuote__c)){
                    opp.L2O_Sales_Type__c = mapPrimaryQuoteToSalesType.get(opp.SBQQ__PrimaryQuote__c).L2O_Sales_Type__c;
                }                
            }
        }
    }
    
    /**
* @name  updateOpportunityStageOnInsert
* @description To update opportunity stage with prospect as default
* @params  none
**/
    public void updateOpportunityStageOnInsert(){
        //Set Exception Log MethodName
        setExceptionVars('updateOpportunityStageOnInsert');
        List<Opportunity> newOpps = Trigger.new;
        //Id stdPricebookId = [SELECT Id, Name, IsActive FROM PriceBook2 WHERE IsStandard=True LIMIT 1].Id;
        Map<Id,Opportunity> mapAccIdToOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapContractIdToOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapContractIdToOppRenewal = new Map<Id,Opportunity>();
        for(Opportunity  opp: newOpps){
            // null duplicate GUID in Trigger Context 
            if(!String.isEmpty(opp.L2O_GUID__c) && SDF_TGF_Trigger_Config__mdt.getInstance('L2O_TriggerContextDataMigration').Enabled__c){ 
                opp.L2O_GUID__c = null;
            }
            //Fetch Opp List if user did not populate Business Region. #5844
            If(opp.L2O_Business_Region__c == null && opp.AccountId != null){
                mapAccIdToOpp.put(opp.AccountId,opp);
            }
            //Update the stage to business if opportunity type is new.
            If(opp.type == L2O_Constants.OPPTY_TYPE_NEWBUSINESS && SDF_TGF_Trigger_Config__mdt.getInstance('L2O_TriggerContextDataMigration').Enabled__c){
                opp.stageName = L2O_Constants.OPPTY_STAGE_PROSPECT;
            }
            //Update the Type to Existing Business if Opp is Amendment Opp. #5634
            If(opp.SBQQ__AmendedContract__c != null){
                mapContractIdToOpp.put(opp.SBQQ__AmendedContract__c,opp);
                opp.type = L2O_Constants.OPPTY_TYPE_EXISTINGBUSINESS;
            } 
            //Update the Type & Sub Type of Renewal Opportunity 
            If(opp.SBQQ__RenewedContract__c != null){ 
                mapContractIdToOppRenewal.put(opp.SBQQ__RenewedContract__c,opp);
                opp.type = L2O_Constants.RENEWAL_OPPTY_TYPE;
                opp.L2O_Subtype__c = L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_RENEWAL;
            } 
            //Update the Type, Flag when Amend Opp created from Account without contract and filtering out only assets amendment
            If(opp.Name.CONTAINS(System.Label.L2O_AmendOppDefaultName) && opp.L2O_Subtype__c == null){ //&& opp.SBQQ__RenewedContract__c == null 
                opp.type = L2O_Constants.OPPTY_TYPE_EXISTINGBUSINESS;
                opp.L2O_IsAccountAmendAssets__c = TRUE;
            }
        }
        updateAmendOpptyFrmContract(mapContractIdToOpp); // to update the Amnedment Opportunity
        updateRenewalOpptyFrmOriginalOppty(mapContractIdToOppRenewal); //to update Renewal Opportunity
        updateOpptyFromAccount(mapAccIdToOpp); //To update Opportunity from Parent Account
    }
     /**
* @name  updateOpptyFromAccount
* @description To update Opportunity from Parent Account
* @param  mapAccIdToOpp Map of Opportunity record
**/
    public void updateOpptyFromAccount(Map<Id,Opportunity> mapAccIdToOpp){
        
        //Set Exception Log MethodName
        setExceptionVars('updateOpptyFromAccount');
        
        If(!mapAccIdToOpp.isEmpty() && mapAccIdToOpp!=null){
            Map<ID, Account> mapAccountInfo = new Map<ID, Account>([SELECT Id, L2O_Business_Region__c,L2O_Invoicing_Country__c,
                                                                    L2O_Amendment_Opportunity_SubType__c,Name,
                                                                    (SELECT L2O_Initial_of_Lives__c,Pricebook2Id,
                                                                     L2O_Contract_Path__c,L2O_Channel_Segment__c,L2O_Sub_Channel_Segment__c,
                                                                     L2O_GUID__c,//L2O_Healthplan_Subtype__c,L2O_Plan_Administration__c,
                                                                     L2O_Benefit_Consultant_Involved_in_Deal__c
                                                                     FROM Opportunities
                                                                     WHERE Type =: L2O_Constants.OPPTY_TYPE_NEWBUSINESS //'New Business' 
                                                                     AND StageName !=: L2O_Constants.OPPTY_STAGE_CLOSED_LOST //'Closed Lost'
                                                                     ORDER BY CreatedDate DESC Limit 1),
                                                                    (SELECT Quantity FROM Assets 
                                                                     WHERE Quantity != NULL 
                                                                     ORDER BY Quantity DESC Limit 1)
                                                                    FROM Account WHERE Id IN:mapAccIdToOpp.keySet()]);
            for(Opportunity opp : mapAccIdToOpp.values()){
                if(mapAccountInfo.get(opp.AccountId).L2O_Business_Region__c != null){
                    opp.L2O_Invoicing_Country__c = mapAccountInfo.get(opp.AccountId).L2O_Invoicing_Country__c;
                    opp.L2O_Business_Region__c = mapAccountInfo.get(opp.AccountId).L2O_Business_Region__c;
                }
                //Update the Name when Amend Opp created from Account Amend Assets button
                If(opp.L2O_IsAccountAmendAssets__c == TRUE){
                    // update Amendment oppirtunity Name based on with and without contract. #28211 (CR)
                    opp.Name = mapAccountInfo.get(opp.AccountId).Name+ L2O_Constants.NAME_CONTRACT_AMENDMENT +Date.today().format();
                    opp.L2O_Subtype__c = mapAccountInfo.get(opp.AccountId).L2O_Amendment_Opportunity_SubType__c;
                    }
                
                //Default Number of Lives as the Max Qty of related Assets on Amend Oppty ONLY ASSETS #5364
               If(opp.L2O_IsAccountAmendAssets__c == TRUE && !mapAccountInfo.get(opp.AccountId).Assets.isEmpty()){
                    opp.L2O_Initial_of_Lives__c = opp.L2O_Initial_of_Lives__c != null ? opp.L2O_Initial_of_Lives__c : mapAccountInfo.get(opp.AccountId).Assets[0].Quantity;
                   }
                //Default required fields from Orig Opp on Amend Oppty ONLY ASSETS #5364
               If(opp.L2O_IsAccountAmendAssets__c == TRUE && !mapAccountInfo.get(opp.AccountId).Opportunities.isEmpty() &&
                   SDF_TGF_Trigger_Config__mdt.getInstance('L2O_TriggerContextDataMigration').Enabled__c){
                       opp.Pricebook2Id = mapAccountInfo.get(opp.AccountId).Opportunities[0].Pricebook2Id;
                       opp.L2O_Contract_Path__c = mapAccountInfo.get(opp.AccountId).Opportunities[0].L2O_Contract_Path__c;
                       opp.L2O_Channel_Segment__c = mapAccountInfo.get(opp.AccountId).Opportunities[0].L2O_Channel_Segment__c;
                       opp.L2O_Sub_Channel_Segment__c = mapAccountInfo.get(opp.AccountId).Opportunities[0].L2O_Sub_Channel_Segment__c;
                    
                        //Populate the New Business opportunity's GUID #152471
                        opp.L2O_InitialOpportunityGUID__c = mapAccountInfo.get(opp.AccountId).Opportunities[0].L2O_GUID__c;
                       // Populate the Benefit Consultant Involved in Deal #169948
                      opp.L2O_Benefit_Consultant_Involved_in_Deal__c = mapAccountInfo.get(opp.AccountId).Opportunities[0].L2O_Benefit_Consultant_Involved_in_Deal__c;
                    }
            }
        }
    }
    
    /**
* @name  updatePrimaryQuote
* @description To update Primary Quote with Opp Business Region
**/
    public void updatePrimaryQuote(){
        
        //Set Exception Log MethodName
        setExceptionVars('updatePrimaryQuote');
        
        List<Opportunity> newOpps = Trigger.new;
        Set<Id> setOppRegionChanged = new Set<Id>();
        
        Map<Id,Opportunity> mapNewOpps = (Map<Id,Opportunity>)Trigger.newMap;
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        List<SBQQ__Quote__c> lstPrimaryQuotes = new List<SBQQ__Quote__c>();
        
        for(Opportunity  opp: newOpps){
            
            //To check if Opp Business Region or Fee Type Changed
            If( mapOldOpps!=null && !mapOldOpps.isEmpty() && (opp.L2O_Business_Region__c != mapOldOpps.get(opp.Id).L2O_Business_Region__c && opp.L2O_Business_Region__c != null) || 
               												 (opp.L2O_Fee_Type__c != mapOldOpps.get(opp.Id).L2O_Fee_Type__c && opp.L2O_Fee_Type__c != null)){
                                                                 setOppRegionChanged.add(opp.Id);}
            if((opp.L2O_Contracting_Account__c != mapOldOpps.get(opp.Id).L2O_Contracting_Account__c)){
                setOppRegionChanged.add(opp.Id);
            }
           
        }
        
        If(!setOppRegionChanged.isEmpty()){
            
            lstPrimaryQuotes = [SELECT Id,SBQQ__Opportunity2__c,L2O_Business_Region__c,L2O_Fee_Type__c,L2O_Contracting_Account__c,SBQQ__Account__c,SBQQ__PriceBook__c
                                FROM SBQQ__Quote__c  
                                WHERE SBQQ__Primary__c = TRUE
                                AND SBQQ__Opportunity2__c IN :setOppRegionChanged];
        }
          
        If(!lstPrimaryQuotes.isEmpty()){
            // update Quote record
            for(SBQQ__Quote__c quote: lstPrimaryQuotes){
                if(quote.L2O_Contracting_Account__c != mapNewOpps.get(quote.SBQQ__Opportunity2__c).L2O_Contracting_Account__c){
                    
                    quote.L2O_Contracting_Account__c =mapNewOpps.get(quote.SBQQ__Opportunity2__c).L2O_Contracting_Account__c;
                	
                }
                quote.L2O_Business_Region__c = mapNewOpps.get(quote.SBQQ__Opportunity2__c).L2O_Business_Region__c;
                quote.L2O_Fee_Type__c = mapNewOpps.get(quote.SBQQ__Opportunity2__c).L2O_Fee_Type__c;
            
            }
            update lstPrimaryQuotes;
            
            
        }
        }
  /**
* @name  updateAccountIdOnQuote
* @description To all related Quotes with changed AccountId
* @params  none
**/
    public void updateAccountIdOnQuote()
    {
        Map<Id,Opportunity> mapNewOpps = (Map<Id,Opportunity>)Trigger.newMap;
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        Map<Id,Id> accountchangemap=new Map<Id,Id>(); 
        for(Id oppid:mapNewOpps.keySet())
        {
            if(mapNewOpps.get(oppid).AccountId!=mapOldOpps.get(oppid).AccountId)
            {
                accountchangemap.put(oppid,mapNewOpps.get(oppid).AccountId);
            }
            
        }
        List<SBQQ__Quote__c> updateQuoteList=new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoterec:[Select Id,SBQQ__Account__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN :accountchangemap.keySet()])
        {
            if(accountchangemap.containsKey(quoterec.SBQQ__Opportunity2__c))
            {
                quoterec.SBQQ__Account__c=accountchangemap.get(quoterec.SBQQ__Opportunity2__c);
                updateQuoteList.add(quoteRec);
            }
        }
        
        update updateQuoteList; 
    }

    
    /**
* @name  updateAmendOpptyFrmContract
* @description To update Amend Opp from Contract values
* @param mapContractIdToOpp To pass the map of ContractId to Opportunities
**/
    public void updateAmendOpptyFrmContract( Map<Id,Opportunity> mapContractIdToOpp){
        //Set Exception Log MethodName
        setExceptionVars('updateAmendOpptyFrmContract');
        If(mapContractIdToOpp!=null && !mapContractIdToOpp.isEmpty()){
            Map<ID, Contract> mapContractInfo = new Map<ID, Contract>([SELECT Id,SBQQ__AmendmentOpportunityStage__c,ContractNumber,L2O_Amendment_Opportunity_SubType__c,
                                                                       SBQQ__Opportunity__r.L2O_Initial_of_Lives__c,SBQQ__Opportunity__r.L2O_Benefit_Consultant_Involved_in_Deal__c,
                                                                       SBQQ__Opportunity__r.Account.Name,SBQQ__Opportunity__r.L2O_GUID__c,
                                                                       (Select L2O_Initial_of_Lives__c
                                                                        From SBQQ__AmendmentOpportunities__r
                                                                        ORDER BY CreatedDate DESC Limit 1)
                                                                       FROM Contract WHERE Id IN:mapContractIdToOpp.keySet()]);
            for(Opportunity opptyRec :  mapContractIdToOpp.Values()){
                opptyRec.L2O_Subtype__c = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).L2O_Amendment_Opportunity_SubType__c;
                // Populate the Benefit Consultant Involved in Deal #169948
                opptyRec.L2O_Benefit_Consultant_Involved_in_Deal__c = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__Opportunity__r.L2O_Benefit_Consultant_Involved_in_Deal__c;
                
                // Populate the New Business GUID #152471
                 opptyRec.L2O_InitialOpportunityGUID__c = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__Opportunity__r.L2O_GUID__c;
                
                // update Amendment oppirtunity Name based on with and without contract. #28211 (CR)
                opptyRec.Name = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__Opportunity__r.Account.Name+ L2O_Constants.NAME_CONTRACT +mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).ContractNumber+ L2O_Constants.NAME_AMENDMENT +Date.today().format();
                //To default the Number of Lives on Amend Oppty #5364
                if(!mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__AmendmentOpportunities__r.isEmpty()){
                    Decimal numberOfLives = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__AmendmentOpportunities__r[0].L2O_Initial_of_Lives__c;
                    opptyRec.L2O_Initial_of_Lives__c = numberOfLives;
                }
                else{
                    opptyRec.L2O_Initial_of_Lives__c = mapContractInfo.get(opptyRec.SBQQ__AmendedContract__c).SBQQ__Opportunity__r.L2O_Initial_of_Lives__c;
                }
            } 
        }
    }
    
    /**
* @name  updateRenewalOpptyFrmOriginalOppty #5677
* @description To update Renewal Oppty from Original Oppty values
* @param mapContractIdToOppRenewal To pass the map of ContractId to Opportunities
**/
    public void updateRenewalOpptyFrmOriginalOppty( Map<Id,Opportunity> mapContractIdToOppRenewal){
        
        //Set Exception Log MethodName
        setExceptionVars('updateRenewalOpptyFrmOriginalOppty');
        
        If(mapContractIdToOppRenewal!=null && !mapContractIdToOppRenewal.isEmpty()){
            
            Map<ID, Contract> mapContractInfo = new Map<ID, Contract>([SELECT Id,contractNumber,SBQQ__Opportunity__r.L2O_Subtype__c,
                                                                       SBQQ__Opportunity__r.OwnerId,SBQQ__Opportunity__r.L2O_GUID__c,
                                                                       SBQQ__Opportunity__r.L2O_Initial_of_Lives__c,
                                                                       SBQQ__Opportunity__r.L2O_Benefit_Consultant_Involved_in_Deal__c
                                                                       FROM Contract WHERE Id IN:mapContractIdToOppRenewal.keySet()]);
            
            for(Opportunity opptyRec :  mapContractIdToOppRenewal.Values()){
                // update Renewal opportunity
                opptyRec.name = 'Contract #'+mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).contractNumber+'-'+opptyRec.Name+'-'+Date.today();
                opptyRec.OwnerId = mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.OwnerId;
                
                 // Populate the New Business opportunity's GUID #152471
                 opptyRec.L2O_InitialOpportunityGUID__c = mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.L2O_GUID__c;
                
                if(mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.L2O_Subtype__c == L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_PILOT){
                    opptyRec.L2O_Subtype__c = L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_PILOT_EXT;
                }
                
                //To default the Number of Lives on Renewal Oppty #5364
                opptyRec.L2O_Initial_of_Lives__c = mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.L2O_Initial_of_Lives__c;
                // Populate the Benefit Consultant Involved in Deal #CON0000681-169948
                opptyRec.L2O_Benefit_Consultant_Involved_in_Deal__c = mapContractInfo.get(opptyRec.SBQQ__RenewedContract__c).SBQQ__Opportunity__r.L2O_Benefit_Consultant_Involved_in_Deal__c;
            }
        }
    }
    
    /**
* @name  updateRipOpptyToContracted
* @description This method is used to contracted the Rip & Replace Oppty  
**/ 
    public void updateRipOpptyToContracted(){
        setExceptionVars('updateRipOpptyToContracted');
        List<Opportunity> lstOpptyRecs = Trigger.new;
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        for(Opportunity currentOpptyRec : lstOpptyRecs){
            // Check if the current opportunity stage is 'Closed Won'
            if(currentOpptyRec.StageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN 
               && mapOldOpps.get(currentOpptyRec.id).StageName != currentOpptyRec.StageName 
               && currentOpptyRec.Name.CONTAINS(L2O_Constants.RIP_REPLACE_OPPTY_PREFIX_NAME)){ 
                   currentOpptyRec.SBQQ__Contracted__c =true;
                   currentOpptyRec.L2O_Closed_By_Rip_And_Replace__c = TRUE;
                   }
        }
    }
    /**
* @name  updateCancelRipOpptyToContracted
* @description This method is used to closed own and contracted the Cancel Amend Oppty
* @params  none
**/
    public void updateCancelRipOpptyToContracted(){
        setExceptionVars('updateCancelRipOpptyToContracted');
        List<Opportunity> lstOpptyRecs = Trigger.new;
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        List<Id> lstRipAndReplaceQuoteId = new List<Id>();
        List<Opportunity> lstOpptyToUpdate = new List<Opportunity>();
        for(Opportunity currentOpptyRec : lstOpptyRecs){
            // Check if the current opportunity stage is 'Closed Won' 
            if(currentOpptyRec.StageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN 
               && mapOldOpps.get(currentOpptyRec.id).StageName != currentOpptyRec.StageName 
               && currentOpptyRec.Name.CONTAINS(L2O_Constants.RIP_REPLACE_OPPTY_PREFIX_NAME)){ 
                   lstRipAndReplaceQuoteId.add(currentOpptyRec.SBQQ__PrimaryQuote__c);
                   }
        }
        if(!lstRipAndReplaceQuoteId.isEmpty())   { 
            for(Opportunity cancelledOpportunity : [SELECT Id,SBQQ__Contracted__c,StageName
                                                    FROM Opportunity 
                                                    WHERE SBQQ__PrimaryQuote__r.L2O_Replacement_Quote__c =: lstRipAndReplaceQuoteId]){
                                                        cancelledOpportunity.SBQQ__Contracted__c =true;
                                                        cancelledOpportunity.StageName = L2O_Constants.OPPTY_STAGE_CLOSED_OWN;
                                                        cancelledOpportunity.L2O_Closed_By_Rip_And_Replace__c = TRUE;
                                                        lstOpptyToUpdate.add(cancelledOpportunity);
                                                    }
            // update opportunity record
            if(!lstOpptyToUpdate.isEmpty()){
                update lstOpptyToUpdate;
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
            L2O_OpportunityTriggerHandler.className = 'L2O_OpportunityTriggerHelperService';
            L2O_OpportunityTriggerHandler.methodName = methodName;
        }
    }
    
    /**
* @name  setDefaultPriceBook
* @description To set PriceBook Field on new Opportunity 
* @params none
**/
    public void setDefaultPriceBook() {
         setExceptionVars('setDefaultPriceBook');
        List<Opportunity> newOpptys = Trigger.new;
        Map<String, String> contractPriceBookMap = new Map<String, Id>();
        // get all L2O_Contract_Path_Price_Book_Mapping__mdt custom metadata records
        List<L2O_Contract_Path_Price_Book_Mapping__mdt> contractPriceBookList = L2O_Contract_Path_Price_Book_Mapping__mdt.getAll().values();
        Map<String,Id> pricebookIdMap = new Map<String,Id>();
        // to fetch Price book
        for(Pricebook2 systemPriceBook : [SELECT Id, Name FROM Pricebook2 WHERE IsActive = TRUE]) {
            pricebookIdMap.put(systemPriceBook.Name,systemPriceBook.Id);
        }
        // L2O_Contract_Path_Price_Book_Mapping__mdt Custom metadata for mapping Contract Path with Price book
        for(L2O_Contract_Path_Price_Book_Mapping__mdt contractPriceBookRecord : contractPriceBookList) {
            contractPriceBookMap.put(contractPriceBookRecord.MasterLabel,pricebookIdMap.get(contractPriceBookRecord.PriceBook__c));
        }
       
        for(Opportunity newOppty : newOpptys) {
            if((newOppty.type != L2O_Constants.RENEWAL_OPPTY_TYPE && 
                newOppty.L2O_Subtype__c != L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_RENEWAL) && (newOppty.Pricebook2Id == null || newOppty.L2O_Subtype__c == 'Contract Path Change')){
                    if( newOppty.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_USA || newOppty.L2O_Business_Region__c == null ){
                        //newOppty.Pricebook2Id = contractPriceBookMap.get(newOppty.L2O_Contract_Path__c);
                        //CON0000681-149465-
                        newOppty.Pricebook2Id = contractPriceBookMap.get(newOppty.L2O_Sub_Channel_Segment__c) !=null ? contractPriceBookMap.get(newOppty.L2O_Sub_Channel_Segment__c) : contractPriceBookMap.get(newOppty.L2O_Contract_Path__c);            
                    }
                    else{
                        newOppty.Pricebook2Id = pricebookIdMap.get(L2O_Constants.PRICEBOOK_INTL);
                    }
                }
        }
    }
    
    /**
* @name  setUserRoleBasedOppChannelAndSubchannel
* @description To set Channel Segment and Sub-Channel Segment Field on new Opportunity
* @params none
**/
    public void setUserRoleBasedOppChannelAndSubchannel() {
        setExceptionVars('setUserRoleBasedOppChannelAndSubchannel');
        List<Opportunity> newOpptys = Trigger.new;
        Set<Id> ownerIds = new Set<Id>();
        List<User> userList = new List<User>();
        List<L2O_UserRole_OpportunityChannel_Mapping__mdt> mdtWithDefaultCurrencyList = new List<L2O_UserRole_OpportunityChannel_Mapping__mdt>();
        List<L2O_UserRole_OpportunityChannel_Mapping__mdt> mdtWithoutDefaultCurrencyList = new List<L2O_UserRole_OpportunityChannel_Mapping__mdt>();
        // L2O_UserRole_OpportunityChannel_Mapping__mdt custom metadata for mapping opportunity Channel and sub- channel with User role
        Map<String, L2O_UserRole_OpportunityChannel_Mapping__mdt> oppUsrRolMdtMap = new Map<String, L2O_UserRole_OpportunityChannel_Mapping__mdt>();
        for(Opportunity opp : newOpptys){
            ownerIds.add(opp.OwnerId);
        }
        for(L2O_UserRole_OpportunityChannel_Mapping__mdt mdt : [SELECT L2O_User_Role__c,L2O_Opportunity_Channel_Segment__c,
                                                                L2O_Opportunity_Sub_Channel_Segment__c,L2O_DefaultUserCurrency__c,DeveloperName
                                                                FROM L2O_UserRole_OpportunityChannel_Mapping__mdt
                                                                WHERE L2O_Opportunity_Channel_Segment__c != Null]){
                                                                    if(mdt.L2O_DefaultUserCurrency__c != Null){
                                                                        mdtWithDefaultCurrencyList.add(mdt);
                                                                    }
                                                                    else{
                                                                        mdtWithoutDefaultCurrencyList.add(mdt);  
                                                                    }
                                                                }
        for(User usr : [SELECT Id, UserRole.Name,DefaultCurrencyIsoCode FROM User WHERE Id =: ownerIds]){
            if(usr.UserRole.Name == null){
                continue; 
            }
            for(L2O_UserRole_OpportunityChannel_Mapping__mdt mdt : mdtWithDefaultCurrencyList){
                if(mdt.L2O_User_Role__c.split(',').contains(usr.UserRole.Name) && 
                   mdt.L2O_DefaultUserCurrency__c.contains(usr.DefaultCurrencyIsoCode)){
                       oppUsrRolMdtMap.put(usr.Id, mdt);
                   }
            }
            if(!oppUsrRolMdtMap.containsKey(usr.Id)){
                userList.add(usr); 
            }
        }
        for(User usr : userList){
            for(L2O_UserRole_OpportunityChannel_Mapping__mdt mdt : mdtWithoutDefaultCurrencyList){
                if(mdt.L2O_User_Role__c.split(',').contains(usr.UserRole.Name)){
                    oppUsrRolMdtMap.put(usr.Id, mdt); 
                }
            }
        }
        if(!oppUsrRolMdtMap.isEmpty()){
            for(Opportunity opp : newOpptys){
                // update channel segment/sub- channel segemnt if a user contains role
                if(oppUsrRolMdtMap.containsKey(opp.OwnerId)){
                    opp.L2O_Channel_Segment__c = oppUsrRolMdtMap.get(opp.OwnerId).L2O_Opportunity_Channel_Segment__c;
                    opp.L2O_Sub_Channel_Segment__c = oppUsrRolMdtMap.get(opp.OwnerId).L2O_Opportunity_Sub_Channel_Segment__c;
                }
            }
        }
    }
    
    /**
* @name  setGUID
* @description To validate and update GUID Field on Opportunity # 14583
* @param newOpportunities To pass the current List of opportunites record
**/
    public void setGUID(List<Opportunity> newOpportunities) {
        
        Set<String> allGuids = new Set<String>();
        for (Opportunity tmpOpportunity : newOpportunities) {
            
            // Create new GUID if account is new or has invalid GUID
            if (String.isBlank(tmpOpportunity.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tmpOpportunity.L2O_GUID__c)) {
                // To generate GUID
                tmpOpportunity.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tmpOpportunity.L2O_GUID__c);
            }
            else{
                allGuids.add(tmpOpportunity.L2O_GUID__c);
            }
        }
    } 
    
    /**
* @name  sendEmailOnClosedWon
* @description To send email on Opportunity stage change to 'Closed Won' 
* @params none
**/
    public void sendEmailOnClosedWon() {
        setExceptionVars('sendEmailOnClosedWon');
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        List<Opportunity> newOpportunities = Trigger.new;
        
         // To check if the 'L2O_sendEmailOnOppClosedWon' needs to execute or not
        if(!SDF_TGF_Trigger_Config__mdt.getInstance('L2O_sendEmailOnOppClosedWon').Enabled__c){
            return;
        } 
        // L2O_sendEmailOnOppClosedWon is a helper class, handling the logic for email send
        L2O_sendEmailOnOppClosedWon helperMthd = new L2O_sendEmailOnOppClosedWon();
        helperMthd.sendEmailOnClosedWon(newOpportunities,mapOldOpps);
    }
    
    /**
* @name  createStageMetricObjRec
* @description To Create Stage Metric custom Object record on Opportunity Stage change
**/
    public void createStageMetricObjRec()  {
         setExceptionVars('createStageMetricObjRec');
        List<Opportunity> newOpps = Trigger.new;
        List<L2O_Stage_Metric__c> stgMtrcRecInsList = new List<L2O_Stage_Metric__c>();
        List<L2O_Stage_Metric__c> stgMtrcRecUpdList = new List<L2O_Stage_Metric__c>();
        List<Opportunity> stgChangdOppList = new List<Opportunity>();
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        Map<Id,L2O_Stage_Metric__c> oppStgMtrcMap = new Map<Id,L2O_Stage_Metric__c>();
        
        // To Create 1st Stage Metric record on Opportunity Insert
        if(Trigger.isInsert){
            for(Opportunity opp : newOpps){
                if(opp.StageName != null){
                    L2O_Stage_Metric__c stgMtrcRec = new L2O_Stage_Metric__c();
                    stgMtrcRec.L2O_Opportunity__c = opp.Id;
                    stgMtrcRec.L2O_To_Stage__c = opp.StageName;
                    stgMtrcRec.L2O_Sequence_Number__c = 1;
                    stgMtrcRecInsList.add(stgMtrcRec); 
                }
            }
        }
        // To create the stage metric record if the opportunity's stage change
        if(Trigger.isUpdate){
            for(Opportunity opp : newOpps){
                if(opp.StageName != mapOldOpps.get(opp.Id).StageName){
                    stgChangdOppList.add(opp);
                }
            }
            if(!stgChangdOppList.isEmpty()){
                // To get the latest stage metric record from opportunity
                for(L2O_Stage_Metric__c stM : [SELECT Id,CreatedDate, L2O_Opportunity__c, L2O_To_Stage__c,L2O_Sequence_Number__c  
                                               FROM L2O_Stage_Metric__c 
                                               WHERE L2O_Opportunity__c =:stgChangdOppList 
                                               ORDER BY CreatedDate DESC]){
                                                   if(!oppStgMtrcMap.containsKey(stM.L2O_Opportunity__c)){
                                                       oppStgMtrcMap.put(stM.L2O_Opportunity__c, stM);
                                                   }
                                               } 
                for(Opportunity opp : stgChangdOppList){
                    if(oppStgMtrcMap.get(opp.Id) != null &&
                       oppStgMtrcMap.get(opp.Id).L2O_To_Stage__c == mapOldOpps.get(opp.Id).StageName){
                           L2O_Stage_Metric__c stgMtrcRec = new L2O_Stage_Metric__c();
                           stgMtrcRec.L2O_Opportunity__c = opp.Id;
                           stgMtrcRec.L2O_From_Stage__c = mapOldOpps.get(opp.Id).StageName;
                           stgMtrcRec.L2O_To_Stage__c = opp.StageName;
                           stgMtrcRec.L2O_From_Stage_Date__c = oppStgMtrcMap.get(opp.Id).CreatedDate;
                           stgMtrcRec.L2O_Sequence_Number__c = opp.L2O_Stage_Metric_Count__c + 1;
                           stgMtrcRecInsList.add(stgMtrcRec);
                       } 
                }
            }
        }
        // Insert Stage metric record if stgMtrcRecInsList is not empty
        if(!stgMtrcRecInsList.isEmpty()){ 
            Insert stgMtrcRecInsList;
        }
    }
    
    /**
* @name  populateContractPriorFields
* @description to populate the prior contract fields 
* @params none
**/
    public void populateContractPriorFields()  {
        List<Opportunity> newOpps = Trigger.new;
        Set<Id> contractIdSet = new Set<Id>();
        List<Contract> oppToUpdateList = new List<Contract>();
        Map<Id,Opportunity> mapOldOpps = (Map<Id,Opportunity>)Trigger.oldMap;
        for(Opportunity opp : newOpps){
            // Check if the opportunity is Amendment opportunity
            If(opp.SBQQ__AmendedContract__c != null && !opp.Name.CONTAINS(System.Label.L2O_AmendOppDefaultName) && opp.StageName != mapOldOpps.get(opp.id).StageName  && opp.StageName == 'Closed Won'){
                contractIdSet.add(opp.SBQQ__AmendedContract__c);
            } 
        }
        if(contractIdSet.size() > 0){
            // fetch the Contract record
            Map<ID, Contract> mapContractInfo = new Map<ID, Contract>([SELECT Id,L2O_Prior_TCV_value__c,L2O_Prior_ARR_value__c,L2O_Prior_Bookings_Total_Value__c,
                                                                       L2O_Prior_Est_One_Time_Revenue__c,L2O_Prior_Net_ARR__c,L2O_Prior_Est_First_Year_Revenue__c,
                                                                       L2O_Prior_Est_In_Year_Revenue__c,L2O_Prior_Net_ARR_w_PG__c
                                                                       FROM Contract WHERE Id IN :contractIdSet]);
            
            
            for(Opportunity opp : newOpps){
                Boolean isUpdateFlag = false;
                // update values on opportunity change to 'Closed Won'
                if(opp.StageName != mapOldOpps.get(opp.id).StageName  && opp.StageName == 'Closed Won'){
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_TCV_value__c = opp.L2O_TCV__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_ARR_value__c = opp.L2O_ARR__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Bookings_Total_Value__c = opp.L2O_Bookings_Total__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Est_One_Time_Revenue__c = opp.L2O_Est_One_Time_Revenue__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Net_ARR__c = opp.L2O_Net_ARR__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Est_First_Year_Revenue__c = opp.L2O_Prior_Est_First_Year_Revenue__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Est_In_Year_Revenue__c = opp.L2O_Prior_Est_In_Year_Revenue__c;
                    mapContractInfo.get(opp.SBQQ__AmendedContract__c).L2O_Prior_Net_ARR_w_PG__c = opp.L2O_Prior_Net_ARR_w_PG__c;
                    isUpdateFlag = true;
                }
                // update record if isUpdateFlag is true
                if(isUpdateFlag){
                    oppToUpdateList.add( mapContractInfo.get(opp.SBQQ__AmendedContract__c));
                } 
            }
        }
        // update contract list 
        if(oppToUpdateList.size() > 0){
            update oppToUpdateList;
        }
    }
    
    /**
    * @name  setLeadID
    * @description setLeadID
    * @param  newOpportunities for trigger.new Opportunity
    **/
    public void setLeadID(List<Opportunity> newOpportunities) {
        //Get Opportunity records
        List<Opportunity> updteOppList = new List<Opportunity>();
        List<Opportunity> updOpp = [SELECT Id,Name,L2O_Lead_Id__c FROM Opportunity WHERE Id IN: newOpportunities];
        //Update Opportunity record
        for (Opportunity tempOpportunity : updOpp) {
            tempOpportunity.L2O_Lead__c=updOpp[0].L2O_Lead_Id__c;
            updteOppList.add(tempOpportunity);
        }
        if(!updteOppList.isEmpty()){
            update updteOppList;
        }  
    }
    
    /**
    * @name publishPreSaleBroadcastEvent
    * @description Publishing the PreSale Broadcast Platform Event
    * @param newOpportunities for trigger.new Opportunity
    * @param oldOpportunitiesMap for trigger.oldMap Opportunities
    **/
    public void publishPreSaleBroadcastEvent(List<Opportunity> newOpportunities, Map<Id,sObject> oldOpportunitiesMap) {
        Set<Id> oppIdSet = new Set<Id>();
        List<String> resultGuidList = new List<String>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        String platformEventName = System.Label.PreSale_Broadcast_Platform_Event_Name;
        String objectName = 'Opportunity';
        
        // Calling L2O_PlatformEvent_MetadataHandler class to check if the Platform Event is Active
        L2O_PlatformEvent_MetadataHandler getmethodIns = new L2O_PlatformEvent_MetadataHandler();
        if (!getmethodIns.getMetadataPlatformEvents(platformEventName)) {
            return;
        }
        
        for (Opportunity opp :newOpportunities) {
            if (opp.Early_Implementation__c && opp.Pricing_and_Product_Lock__c && 
                opp.Pricing_and_Product_Lock__c != oldOpportunitiesMap.get(opp.Id).get('Pricing_and_Product_Lock__c')) {
                    oppIdSet.add(opp.Id);
                }
        }
        if (!oppIdSet.IsEmpty()) {
            resultGuidList = platformEventHelper(oppIdSet);
        }
        if(resultGuidList.size()>0){
                for(Opportunity tempOpp : [SELECT Id, L2O_Last_Integration_Date__c FROM Opportunity WHERE L2O_GUID__c =: resultGuidList]){
                    tempOpp.L2O_Last_Integration_Date__c = DateTime.now();
                    oppUpdateList.add(tempOpp);
                }
            }
            if(!oppUpdateList.isEmpty()){
                update oppUpdateList;
            }
    }
    
    /**
    * @name platformEventHelper
    * @description helper method for publishing platform event
    * @param  oppIdSet for getting the set of opp Ids
    * @return guidList retruns the list of opp guids
    **/
    public List<String> platformEventHelper(Set<Id> oppIdSet) {
        List<String> guidList = new List<String>();
        List<PreSale_Broadcast__e> preSaleBroadcastEventList = new List<PreSale_Broadcast__e>();
        List<L2O_Platform_Event_Published__c> publishEventsPublishedList = new List<L2O_Platform_Event_Published__c>();
        List<Opportunity> oppList = [SELECT Id, Name, L2O_GUID__c, Payload_Action__c, L2O_Account_GUID__c, AccountId, Account.Name, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.Name FROM Opportunity WHERE Id IN :oppIdSet];
        
        for (Opportunity opp :oppList) {
            PreSale_Broadcast__e pb = new PreSale_Broadcast__e();
            pb.Opportunity_Id__c = opp.Id;
            pb.Opportunity_Name__c = opp.Name;
            pb.Opportunity_GUID__c = opp.L2O_GUID__c;
            pb.Payload_Action__c = opp.Payload_Action__c;
            pb.Account_Id__c = opp.AccountId;
            pb.Account_Name__c = opp.Account.Name;
            pb.Account_GUID__c = opp.L2O_Account_GUID__c;
            pb.Quote_Id__c = opp.SBQQ__PrimaryQuote__c;
            pb.Quote_Name__c = opp.SBQQ__PrimaryQuote__r.Name;
            preSaleBroadcastEventList.add(pb);
        }

        if (!preSaleBroadcastEventList.IsEmpty()){
            List<Database.SaveResult> results = EventBus.publish(preSaleBroadcastEventList);               
                Integer tempCount = 0;
                for (Database.SaveResult sr : results) {
                    L2O_Platform_Event_Published__c platformeventObject = new L2O_Platform_Event_Published__c();
                    PreSale_Broadcast__e obj = preSaleBroadcastEventList[tempCount];
                    platformeventObject.L2O_Object__c = 'Opportunity';
                    platformeventObject.L2O_Platform_event_Name__c = 'PreSale_Broadcast__e';
                    platformeventObject.L2O_Object_Id__c = obj.Opportunity_GUID__c;
                    if (sr.isSuccess()) {
                        if(!guidList.contains(obj.Opportunity_GUID__c)){
                            guidList.add(String.valueOf(obj.Opportunity_GUID__c)); 
                        }
                        platformeventObject.L2O_Status__c = 'Success';
                    } else {                      
                        platformeventObject.L2O_Status__c = 'Errored';
                        platformeventObject.L2O_Error_Message__c = String.valueOf(sr.getErrors()[0]);
                        SDF_LGR_LoggerManager.DBufLogger.error(String.valueOf(sr),className,methodName);
                    }
                    publishEventsPublishedList.add(platformeventObject);
                    tempCount++;
                }
                if(publishEventsPublishedList.size() > 0){
                    insert publishEventsPublishedList;
                }
        }
        return guidList;
    }
    
    /**
    * @name  setINTLContractPathValues
    * @description set INTL ContractPathValues
    * @param  newOpportunities for trigger.new Opportunity
    **/
    public void setINTLContractPathValues(List<Opportunity> newOpportunities)
    {
        L2O_ContractPathUpdate__mdt conPathRec = L2O_ContractPathController.getMetaDataSettings()[0];
        Set<String> nonINTLRegset=new Set<String>();
		nonINTLRegset.addAll(System.Label.NonINTL_Regions.split(','));
        List<Opportunity> oppUpdList=new List<Opportunity>();
        Map<Id,Opportunity> oldOppMap=(Map<Id,Opportunity>)Trigger.oldMap;
        String teladocAccId=L2O_ContractPathController.findTeladocAccount();
        for(Opportunity opprec:newOpportunities)
        {
            if( !nonINTLRegset.contains(opprec.L2O_Business_Region__c) && String.isNotBlank(conPathRec.L2O_DirectContYes_EmpBsnYes__c) &&
            (Trigger.isInsert || (Trigger.isUpdate && opprec.L2O_Business_Region__c != oldOppMap.get(opprec.Id).L2O_Business_Region__c)) 
            )
            {
                
                Opportunity op=new Opportunity();
                op.Id = opprec.Id;
                op.L2O_DirectTDHContract__c = 'YES';
                op.L2O_DirectEmployerBusiness__c = 'YES';
                op.L2O_Contracting_Account__c = teladocAccId;
                op.L2O_Contract_Path__c = conPathRec.L2O_DirectContYes_EmpBsnYes__c.replaceAll('\'','');
                oppupdlist.add(op);
            }
          
        }
        if(!oppupdlist.isEmpty()){
            update oppupdlist;  
        }
    }
}