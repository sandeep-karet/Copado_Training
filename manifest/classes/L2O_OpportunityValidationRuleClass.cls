/**
* Company : PwC.
* @description : L2O_OpportunityValidationRuleClass will be executed from the L2O_OpportunityHandler and will extend the L2O_TriggerHandler class.
* *******************************************************************************************************************************************
* History : 
* @date 29/03/2022
* @author Neha Sharma
*/
public without sharing class L2O_OpportunityValidationRuleClass {
    
  /**
  * @name  checkOpportunityStageValidations
  * @description checking validation on opportunity stage
  **/
  public void checkOpportunityStageValidations(){
      setExceptionVars('checkOpportunityStageValidations');
      List<Opportunity> newOpportunityList = Trigger.new;
      List<Opportunity> oppStageupdatedList = new List<Opportunity>();
      Map<Id,List<OpportunityContactRole>> oppContactListMap = new Map<Id,List<OpportunityContactRole>>();
      Map<Id,SBQQ__Quote__c> oppQuoteMap = new Map<Id,SBQQ__Quote__c>();
      
      Set<Id> newOppIdSet = new Set<Id>();
      Set<Id> oppIdSet = new Set<Id>();
      for(Opportunity oppor:newOpportunityList){
          newOppIdSet.add(oppor.id);
          Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(oppor.ID);
          if(oppor.StageName != oldOpp.StageName){
              oppIdSet.add(oppor.id);
              oppStageupdatedList.add(oppor);
          }  
      }
      //get contact role count on opportunity
      if(!newOppIdSet.isEmpty()){
      oppContactListMap = getOpportunityContactRoleCount(newOppIdSet);
      }
      if(!oppStageupdatedList.isEmpty()){
         oppQuoteMap =   getOppPrimaryQuoteStatus(oppIdSet);
          for(Opportunity opp: oppStageupdatedList){
            errorMessageCalculation(opp,oppQuoteMap,oppContactListMap);
          }
      }
      // #147033, #157455, #160408.
      checkOpportunityContactRoleBroke(newOpportunityList,oppContactListMap);
  }
  
  /**
  * @name  checkOpportunityContactRoleBroke
  * @description Check related Contact Role 
  * @param newOpportunityList List of opportunities
  * @param oppContactListMap Map of Opportunities and related Contact Role    
  */
  public void checkOpportunityContactRoleBroke(List<Opportunity> newOpportunityList,Map<Id,List<OpportunityContactRole>> oppContactListMap){
      setExceptionVars('checkOpportunityContactRoleBroke');
      for(Opportunity tempOpp : newOpportunityList){
          List<OpportunityContactRole> oppConRoleList = oppContactListMap.get(tempOpp.id);
          Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(tempOpp.ID);
          Boolean isBrokerContactRole = false;
          String errorMessage = null;
          if(tempOpp.L2O_Benefit_Consultant_Involved_in_Deal__c != null && !oppContactListMap.isEmpty() &&
             tempOpp.L2O_Benefit_Consultant_Involved_in_Deal__c != L2O_Constants.BENEFIT_CONSULTANT_NO_INVOLVEMENT){
                 for(OpportunityContactRole oppCon: oppConRoleList){
                     Boolean isBrokerRole = false;
                   if(oppCon.Role == L2O_Constants.OPPCON_ROLE_BROKER || oppCon.Role == L2O_Constants.OPPCON_ROLE_BENEFIT_CONSULTANT || oppCon.Role == L2O_Constants.OPPCON_ROLE_GENERAL_AGENCY)
                    {
                        isBrokerContactRole = true;
                    }
                    if(oppCon.Role == L2O_Constants.OPPCON_ROLE_BROKER  || oppCon.Role == L2O_Constants.OPPCON_ROLE_GENERAL_AGENCY)
                    {
                       isBrokerRole = true;
                    }
                     if(isBrokerRole && oppCon.L2O_Broker_Flat_Rate__c == null && oppCon.L2O_Broker_Percentage__c == null && 
                       oppCon.L2O_Chronic_Care_Flat_Rate__c == null && oppCon.L2O_Chronic_Care_Percentage__c == null){
                           errorMessage = System.Label.L2O_BenCon_ConRole;
                        }
              }
             }
          if(!String.isEmpty(errorMessage) && errorMessage != null){
               tempOpp.addError(errorMessage);
          }
          if(!isBrokerContactRole && tempOpp.L2O_Benefit_Consultant_Involved_in_Deal__c != L2O_Constants.BENEFIT_CONSULTANT_NO_INVOLVEMENT && 
            tempOpp.L2O_Benefit_Consultant_Involved_in_Deal__c != null && tempOpp.StageName != oldOpp.StageName){
              tempOpp.addError(System.Label.L2O_Benefifit_consultant_Error);
          }
      }
  }
  
  /**
  * @name  getOpportunityContactRoleCount
  * @description Getting contact roles of opportunity
  * @param  oppId set for opportunity id
  * @return Map<Id,Integer>
  **/
  public Map<Id,List<OpportunityContactRole>> getOpportunityContactRoleCount(Set<Id> oppId){
      Map<Id,List<OpportunityContactRole>> oppContactMap = new Map<Id,List<OpportunityContactRole>>();        
      List<OpportunityContactRole> oppContactRoleList = [SELECT Id,Role,OpportunityId,L2O_Broker_Flat_Rate__c,L2O_Broker_Percentage__c,
                                                         L2O_Chronic_Care_Flat_Rate__c,L2O_Chronic_Care_Percentage__c
                                                         FROM OpportunityContactRole 
                                                         WHERE OpportunityId IN :oppId];
      if(oppContactRoleList.size() > 0){
          for(OpportunityContactRole oppConRole: oppContactRoleList){
              if(!oppContactMap.containsKey(oppConRole.OpportunityId)){
                  oppContactMap.put(oppConRole.OpportunityId,new List<OpportunityContactRole>());  
              }
              oppContactMap.get(oppConRole.OpportunityId).add(oppConRole); 
          }
      }
      return oppContactMap;
  }

  /**
  * @name  getOppPrimaryQuoteStatus
  * @description Getting status of primary quote
  * @param  oppId set for opportunity id
  * @return Map<Id,SBQQ__Quote__c>
  **/
  public Map<Id,SBQQ__Quote__c> getOppPrimaryQuoteStatus(Set<Id> oppId){
      List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__Status__c,SBQQ__Opportunity2__c,L2O_Replacement_Quote__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :oppId AND SBQQ__Primary__c = TRUE];
      Map<Id,SBQQ__Quote__c> oppQuoteMap = new Map<Id,SBQQ__Quote__c>();
      
      if(quoteList.size() > 0){
          for(SBQQ__Quote__c quote: quoteList){
              oppQuoteMap.put(quote.SBQQ__Opportunity2__c,quote);            
          }
      }
      return oppQuoteMap;
  }

  /**
  * @name  checkIfDiscovery
  * @description Check validation if stage is discovery
  * @param  opp  opportunity to pass opportunity
  * @param  primaryQuoteStatus string to pass primary quote
  * @return errorMessage
  **/
  public String checkIfDiscovery(Opportunity opp,String primaryQuoteStatus){
      String errorMessage;
      if(opp.stageName == L2O_Constants.OPPTY_STAGE_DISCOVERY ){
          if(primaryQuoteStatus != null){
              
              errorMessage = System.Label.L2O_Discovery_Stage_Validation_From_Proposal;
          }
          //On moving to Discovery, Close Date <= TODAY + 365 #5391
          if(opp.CloseDate > System.Today().addMonths(12)){
              errorMessage = System.Label.L2O_DiscoveryStageErrorMessage_fromProspect;
          }
          if(opp.type != L2O_Constants.OPPTY_TYPE_EXISTINGBUSINESS && opp.type != L2O_Constants.OPPTY_TYPE_NEWBUSINESS){
              errorMessage = System.Label.L2O_Discovery_Validation_Error_for_Type_opportunity;                
              
          }
          /*if(opp.L2O_Benefit_Consultant_Involved_in_Deal__c != L2O_Constants.BENEFIT_CONSULTANT_NO_INVOLVEMENT && brokerConsultantContact == false){
              errorMessage = System.Label.L2O_Benefifit_consultant_Error;
          }*/
          
      }
      return errorMessage;
      
  }
  
  /**
  * @name  checkIfContracting
  * @description Check validation if stage is Contracting
  * @param  opp  opportunity to pass opportunity
  * @param  primaryQuoteStatus string to pass primary quote
  * @return String errorMessage
  **/
  public String checkIfContracting(Opportunity opp,String primaryQuoteStatus){
      String errorMessage;
      if(opp.stageName == L2O_Constants.OPPTY_STAGE_CONTRACTING && (opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_USA ||  opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_CANADA)){ 
          if(primaryQuoteStatus == null || (primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_APPROVED)){
              //169982 
              //&& primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_PRESENTED && primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_ACCEPTED && primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_REJECTED
              errorMessage = System.Label.L2O_Contracting_validation_error_message;
          }
      }
      return errorMessage;
  }

  /**
  * @name  checkIfClosedWon
  * @description Check validation if stage is ClosedWon
  * @param  opp  opportunity to pass opportunity
  * @param  primaryQuoteStatus string to pass primary quote
  * @param  replacementQuoteId get replacement quote Id
  * @return String errorMessage
  **/
  public String checkIfClosedWon(Opportunity opp,String primaryQuoteStatus,String replacementQuoteId){
      String errorMessage;
      if(opp.stageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN){ 
          System.debug('In closed won '+primaryQuoteStatus);
          if(primaryQuoteStatus == null || (primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_ACCEPTED)){
              errorMessage = System.Label.L2O_ClosedWon_validation_error_message;
          }
          if(replacementQuoteId !=null && !opp.L2O_Closed_By_Rip_And_Replace__c){
              errorMessage = System.Label.L2O_Rip_And_replace_opportunity_close_error;
              
              
          }
      } 
      
      return errorMessage;
      
  }

  /**
  * @name  checkIfProposal
  * @description Check validation if stage is Proposal
  * @param  opp  opportunity to pass opportunity
  * @param  primaryQuoteStatus string to pass primary quote
  * @param  contactRoleCount Integer to pass contact role count
  * @return String errorMessage
  **/
  public String checkIfProposal(Opportunity opp,String primaryQuoteStatus,Integer contactRoleCount){
      String errorMessage;
      if(opp.stageName == L2O_Constants.OPPTY_STAGE_PROPOSAL && (opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_USA ||  opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_CANADA)){ 
          if(primaryQuoteStatus == null || contactRoleCount <= 0 ||
             (primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_DRAFT && primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_IN_REVIEW &&
             primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_APPROVED && primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_REJECTED)
            ){ //169982
              errorMessage = System.Label.L2O_Proposal_validation_error_message;
          }
      } 
      return errorMessage;
      
  }

  /**
  * @name  checkIfReviewNegotiation
  * @description Check validation if stage is Negotiation
  * @param  opp  opportunity to pass opportunity
  * @param  primaryQuoteStatus string to pass primary quote
  * @return String errorMessage
  **/
  public String checkIfReviewNegotiation(Opportunity opp,String primaryQuoteStatus){
      String errorMessage;
      if(opp.stageName == L2O_Constants.OPPTY_STAGE_REVIEW_NEGOTIATION && (opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_USA ||  opp.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_CANADA)){ 
          if(primaryQuoteStatus == null || 
             (primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_IN_REVIEW && primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_REJECTED && 
             primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_APPROVED)){ //primaryQuoteStatus != L2O_Constants.QUOTE_STATUS_DENIED //169982
              errorMessage = System.Label.L2O_Review_negotiation_validation_error_message;
          }
      } 
      return errorMessage;
  }

  /**
  * @name  errorMessageCalculation
  * @description Check validation if stage is Negotiation
  * @param  opp  opportunity to pass opportunity
  * @param  oppQuoteMap Boolean to pass map opportunity quote Profile
  * @param  oppContactListMap Map to pass map opportunity quote Profile
  **/
  public void errorMessageCalculation(Opportunity opp,Map<Id,SBQQ__Quote__c> oppQuoteMap, Map<Id,List<OpportunityContactRole>> oppContactListMap){
      setExceptionVars('errorMessageCalculation');                                    
      String currentStage = opp.stageName;
      String errorMessage = null;
      Integer contactRoleCount = 0;                                     
      List<OpportunityContactRole> oppConRoleList = oppContactListMap.get(opp.id);                                    
      Map<String,String> stageProfileMap =  L2O_Utility.fetchOpportunityProfileStageValidationMetadata(); 
      String profileName = L2O_Utility.getUserProfileName();
      String stagesAllowed = (stageProfileMap.get(profileName));
      String replacementQuoteId = null;
      String primaryQuoteStatus = null;
      if(!oppContactListMap.isEmpty()){
          contactRoleCount = oppConRoleList.size();                            
      }                                                                     
      if(stageProfileMap.get(profileName) != null && stagesAllowed.containsIgnoreCase(currentStage) ){
          System.debug('Came here 1');
          if(oppQuoteMap.get(opp.id) != null){
              primaryQuoteStatus = oppQuoteMap.get(opp.id).SBQQ__Status__c;
          }
          
          switch on opp.stageName {
              when 'Discovery'{
                  errorMessage = checkIfDiscovery(opp,primaryQuoteStatus);
              }
              when 'Contracting'{
                  errorMessage = checkIfContracting(opp,primaryQuoteStatus);
              }
              when 'Closed Won'{
                  replacementQuoteId =  oppQuoteMap.get(opp.id).L2O_Replacement_Quote__c;
                  errorMessage = checkIfClosedWon(opp,primaryQuoteStatus,replacementQuoteId);
              }
              when 'Proposal'{
                  errorMessage = checkIfProposal(opp,primaryQuoteStatus,contactRoleCount);
              }
              when 'Review/Negotiation'{
                  errorMessage = checkIfReviewNegotiation(opp,primaryQuoteStatus);
              }
          }
      }
      else{
          
          errorMessage = System.Label.L2O_Profile_Access_To_Opportunity_Stage + ' ' + opp.stageName;
      }
      
      if(errorMessage !=null){
          opp.addError(errorMessage);
      }  
      
  }

  /**
  * @name  setExceptionVars
  * @description To update Exception log variables ClassName & MethodName
  * @param methodName To pass the current MethodName
  **/
  public void setExceptionVars(String methodName){
      If (methodName != null){
          L2O_OpportunityTriggerHandler.className = 'L2O_OpportunityValidationRuleClass';
          L2O_OpportunityTriggerHandler.methodName = methodName;
      }
  }
}