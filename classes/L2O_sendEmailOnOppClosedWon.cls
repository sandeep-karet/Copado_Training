/**
* Company : PwC.
* @description : L2O_sendEmailOnOppClosedWon will be executed from the L2O_OpportunityTriggerHelperService (sendEmailOnClosedWon method).
* *******************************************************************************************************************************************
* History : 
* @date 24/11/2022
* @author Neha Sheikh
*/
public without sharing class L2O_sendEmailOnOppClosedWon {
    // both HHS/USGH product involved field variables
    public static String strHHSandUSGH = 'both';
    
    /**
* @name sendEmailOnClosedWon
* @description To send email on International Opportunity closed won
* @param newOpportunities to pass the of new Opportunity records Id
* @param mapOldOpps  Map of new Opportunity records
**/
    public void sendEmailOnClosedWon(List<Opportunity> newOpportunities,Map<Id,Opportunity> mapOldOpps) {
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> closedWonOpportunityUSAList = new List<Opportunity>();
        List<Opportunity> closedWonOpportunityINTLList = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,List<String>> ccEmailMap = new Map<Id,List<String>>();
        EmailTemplate et= L2O_Utility.getClosedWonEmailTemplate();
        for(Opportunity tmpOpportunity : newOpportunities){
            if(tmpOpportunity.StageName != mapOldOpps.get(tmpOpportunity.id).StageName && tmpOpportunity.StageName == L2O_Constants.OPPTY_STAGE_CLOSED_OWN){
                if(tmpOpportunity.L2O_Business_Region__c != L2O_Constants.BUSSINESS_REGION_USA && tmpOpportunity.L2O_Business_Region__c != null){
                    closedWonOpportunityINTLList.add(tmpOpportunity);
                }else{
                    closedWonOpportunityUSAList.add(tmpOpportunity);
                }
                oppIdSet.add(tmpOpportunity.id);
            }
        }
        if(!oppIdSet.isEmpty()){
            ccEmailMap = getCcEmail(oppIdSet);
        }
       if(!closedWonOpportunityUSAList.isEmpty()){
            mailList.addAll(sendUSAEmailOnClosedWon(closedWonOpportunityUSAList,mapOldOpps,et.Id,ccEmailMap));
        }
        if(!closedWonOpportunityINTLList.isEmpty()){
            mailList.addAll(sendIntnlEmailOnClosedWon(closedWonOpportunityINTLList,mapOldOpps,et.Id,ccEmailMap));
        }
        if(!mailList.isEmpty() && mailList != null){
            Messaging.sendEmail(mailList);
        }
    }
    /**
* @name  sendUSAEmailOnClosedWon
* @description To send email for USA/Null Business Region
* @param closedWonOpportunityUSAList to set of new Opportunity records Id
* @param mapOldOpps  Map of new Opportunity records
* @param emailTempltId  email template
* @param ccEmailMap  contains all CCAddresses
* @return List<Messaging.SingleEmailMessage> List of mail which will send per closed Won opportunity
**/
    public List<Messaging.SingleEmailMessage> sendUSAEmailOnClosedWon(List<Opportunity> closedWonOpportunityUSAList, Map<Id,Opportunity> mapOldOpps,
                                                                      Id emailTempltId,Map<Id,List<String>> ccEmailMap){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,List<String>> oppTeamEmailMap = new Map<Id,List<String>>();
        Map<Id,String> oppLineItemMap = new Map<Id,String>();
        String[] toAddresses = new String[]{};
            String[] ccAddresses = new String[]{};
                
        oppTeamEmailMap = getOppTeamEmail(closedWonOpportunityUSAList);
        oppLineItemMap = getOppLineItemServicePlatform(closedWonOpportunityUSAList);
        
       for (Opportunity tmpOpportunity : closedWonOpportunityUSAList) {
            if(oppLineItemMap.get(tmpOpportunity.id) != null){
                if((oppLineItemMap.get(tmpOpportunity.id) == strHHSandUSGH || oppLineItemMap.get(tmpOpportunity.id) == L2O_Constants.BUSSINESS_TYPE_HHS) &&
                  L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_HHS).L2O_toAddresses__c !=null){
                    toAddresses.addAll(L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_HHS).L2O_toAddresses__c.split(','));
                }
                    if((oppLineItemMap.get(tmpOpportunity.id) == strHHSandUSGH || oppLineItemMap.get(tmpOpportunity.id) == L2O_Constants.BUSSINESS_TYPE_USGH) &&
                  L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_USGH).L2O_toAddresses__c !=null){
                        toAddresses.addAll(L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_USGH).L2O_toAddresses__c.split(','));  
                    }
               }
            
            if(oppTeamEmailMap.get(tmpOpportunity.id) != null){
                toAddresses.addAll(oppTeamEmailMap.get(tmpOpportunity.id));                
            }
            if(!ccEmailMap.isEmpty()){
                ccAddresses.addAll(ccEmailMap.get(tmpOpportunity.id));   
            }
            mailList.add(setEmailMessage(tmpOpportunity.id,emailTempltId,toAddresses,ccAddresses));
            toAddresses.clear();
            ccAddresses.clear();
        }
        return mailList;
    }
    /**
* @name  sendIntnlEmailOnClosedWon
* @description To send email for International Business Region
* @param closedWonOpportunityINTLList to set of new Opportunity records Id
* @param mapOldOpps  Map of new Opportunity records
* @param emailTempltId  email template
* @param ccEmailMap  contains all CCAddresses
* @return List<Messaging.SingleEmailMessage> List of mail which will send per closed Won opportunity
**/
    public List<Messaging.SingleEmailMessage> sendIntnlEmailOnClosedWon(List<Opportunity> closedWonOpportunityINTLList,Map<Id,Opportunity> mapOldOpps,
                                                                        Id emailTempltId, Map<Id,List<String>> ccEmailMap){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        String[] toAddresses = new String[]{};
            String[] ccAddresses = new String[]{};
              
        for(Opportunity tmpOpportunity : closedWonOpportunityINTLList){
            if(tmpOpportunity.L2O_Business_Region__c == L2O_Constants.BUSSINESS_REGION_CANADA &&
               L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_CANADA).L2O_toAddresses__c !=null){
                toAddresses.addAll(L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_CANADA).L2O_toAddresses__c.split(',')); 
                }
            if(tmpOpportunity.L2O_Business_Region__c != L2O_Constants.BUSSINESS_REGION_CANADA &&
               L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_NOT_CANADA).L2O_toAddresses__c !=null){
                toAddresses.addAll(L2O_Contract_Signed_Email_Addresses__mdt.getInstance(L2O_Constants.CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_NOT_CANADA).L2O_toAddresses__c.split(','));
            }
            if(!ccEmailMap.isEmpty()){
                ccAddresses.addAll(ccEmailMap.get(tmpOpportunity.id));   
            }
            mailList.add(setEmailMessage(tmpOpportunity.id,emailTempltId,toAddresses,ccAddresses));
            toAddresses.clear();
            ccAddresses.clear();
        }
        return mailList;
    }
    /**
* @name  getOppTeamEmail
* @description To send email on 
* @param closedWonOpportunityList to pass closed won opportunity
* @return Map<Id, List<String>> to string opportunity team email
**/
    public  Map<Id, List<String>> getOppTeamEmail(List<Opportunity> closedWonOpportunityList)  {
        Map<Id, List<String>> oppTeamListMap = new Map<Id, List<String>>();
        for(OpportunityTeamMember oppTeam : [SELECT id, UserId, User.Email, TeamMemberRole,OpportunityId
                                             FROM OpportunityTeamMember
                                             WHERE OpportunityId IN : closedWonOpportunityList  ORDER BY OpportunityId]){
                                                 if(oppTeamListMap.containsKey(oppTeam.OpportunityId)){
                                                     oppTeamListMap.get(oppTeam.OpportunityId).add(oppTeam.user.email);
                                                 }else{ 
                                                     oppTeamListMap.put(oppTeam.OpportunityId, new List<String> { oppTeam.user.email });
                                                 }
                                             }
        return oppTeamListMap;
    }
    /**
* @name  getCcEmail
* @description To send email on 
* @param oppIdSet to pass closed won opportunity Ids
* @return Map<Id, List<String>> to string opportunity team email
**/
    public  Map<Id, List<String>> getCcEmail(Set<Id> oppIdSet)  {
        Map<Id, List<String>> ccEmailMap = new Map<Id, List<String>>();
        for(SBQQ__Quote__c tmpQuote : [SELECT id, Owner.email,SBQQ__Opportunity2__c,SBQQ__Primary__c,SBQQ__Account__r.Owner.email
                                       FROM SBQQ__Quote__c 
                                       WHERE SBQQ__Primary__c = TRUE AND SBQQ__Opportunity2__c IN : oppIdSet ORDER BY SBQQ__Opportunity2__c]){
                                           if(ccEmailMap.containsKey(tmpQuote.SBQQ__Opportunity2__c)){
                                               ccEmailMap.get(tmpQuote.SBQQ__Opportunity2__c).add(tmpQuote.Owner.email);
                                               ccEmailMap.get(tmpQuote.SBQQ__Opportunity2__c).add(tmpQuote.SBQQ__Account__r.Owner.email);
                                           }else{ 
                                               ccEmailMap.put(tmpQuote.SBQQ__Opportunity2__c, new List<String> { tmpQuote.Owner.email ,tmpQuote.SBQQ__Account__r.Owner.email});
                                           }
                                       }
        return ccEmailMap;
    }
    /**
* @name  getOppLineItemServicePlatform
* @description To send email on 
* @param closedWonOpportunityList to pass closed won opportunity
* @return Map<Id, List<String>> to string opportunity team email
**/
    public  Map<Id, String> getOppLineItemServicePlatform(List<Opportunity> closedWonOpportunityList)  {
        Map<Id, String> oppLineMap = new Map<Id, String>();
        for(OpportunityLineItem tmpOppLine : [SELECT id, OpportunityId,L2O_Service_Platform__c
                                              FROM OpportunityLineItem 
                                              WHERE  OpportunityId IN : closedWonOpportunityList ORDER BY OpportunityId]){
                                                  String tmpvalue = null;
                                                  if(tmpOppLIne.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_LIV || tmpOppLIne.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_TDH){
                                                      tmpvalue ='USGH';
                                                  }
                                                  else{
                                                      tmpvalue ='HHS';
                                                  }
                                                  if(OppLineMap.containsKey(tmpOppLIne.OpportunityId) && OppLineMap.get(tmpOppLIne.OpportunityId) != tmpvalue && OppLineMap.get(tmpOppLIne.OpportunityId) != strHHSandUSGH){
                                                      OppLineMap.put(tmpOppLIne.OpportunityId,'both');      
                                                      
                                                  }else{ 
                                                      OppLineMap.put(tmpOppLIne.OpportunityId,tmpvalue);      
                                                  }
                                                  
                                              }
        return OppLineMap;
    }
    
    /**
* @name  setEmailMessage
* @description To set the Email data
* @param oppId store the current opportunity record id
* @param emailTempltId store the email template record id
* @param toAddresses array of toAddresses
* @param ccAddresses array of ccAddresses
* @return mail will reteun the mail set values
**/
    public Messaging.SingleEmailMessage setEmailMessage(Id oppId, Id emailTempltId, String[] toAddresses, String[] ccAddresses)  {
        Messaging.SingleEmailMessage mail =  Messaging.renderStoredEmailTemplate(emailTempltId, null, oppId);                   
        mail.setTemplateId (emailTempltId);
        mail.setWhatId(oppId);
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        
        return mail;
    }
    
}