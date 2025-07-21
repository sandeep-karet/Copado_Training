/**
* Company : PwC.
* @description : L2O_ApprovalController will be executed from the L2O_ApprovalRejectionSummary.
* *******************************************************************************************************************************************
* History : 
* @date 13/04/2022
* @author Harshita Paliwal
*/
public with sharing class L2O_ApprovalController {

    /**
    * @name  quoteId
    * @description quote Id value.
    * @params  none
    **/
    public String quoteId{get;set;}
    /**
    * @name  quoteValues
    * @description quote value.
    * @params  none
    **/
    public SBQQ__Quote__c quoteValues{
        get {
          SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE id =: quoteId LIMIT 1];
          return quote; }
       set;
    }
    /**    
    * @name  lineItems
    * @description quote line items value.
    * @params  none
    **/
    public List<SBQQ__QuoteLine__c> lineItems{
        get{        
            List<SBQQ__QuoteLine__c> quoteList = [SELECT Name,SBQQ__ProductName__c,L2O_Parent_Product_Code__c,
                                                  SBQQ__Quantity__c,SBQQ__ListPrice__c,L2O_Per_Unit_Discount__c,
                                                  L2O_Membership_Fee__c,L2O_Consult_Fee__c,SBQQ__EffectiveStartDate__c,
                                                  SBQQ__Quote__r.L2O_ORG_LINK__c,SBQQ__NetTotal__c 
                                                  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quoteId];
            
            return quoteList;
        }
        set;
    }
    /**
    * @name  lastApprovedBy
    * @description last approver of approval record.
    * @params  none
    **/
    public String lastApprovedBy{get;set;}
    /**
    * @name  listofapprovalRecords
    * @description list of approval records.
    * @params  none
    **/
    public List<sbaa__Approval__c> listofapprovalRecords{
        
        get{     
            List<sbaa__Approval__c> listofapprovalRecords = new List<sbaa__Approval__c>();
            List<sbaa__Approval__c> approvalRecords = [SELECT Name,sbaa__ApprovalChain__r.Name,sbaa__CommentsLong__c,sbaa__Status__c,
                                                 LastModifiedDate,sbaa__ApprovedBy__r.Name,sbaa__Archived__c,sbaa__ApprovalStep__c,sbaa__Approver__r.Name 
                                                 FROM sbaa__Approval__c WHERE Quote__c=:quoteId ORDER BY LastModifiedDate];
            
            for(sbaa__Approval__c approval:approvalRecords){
                if(approval.sbaa__Status__c == L2O_Constants.APPROVAL_STATUS_APPROVED && approval.sbaa__Archived__c == false){
                    listofapprovalRecords.add(approval);
                }
            }   
            if(!listofapprovalRecords.isEmpty()){
             lastApprovedBy = listofapprovalRecords.get(listofapprovalRecords.size()-1).sbaa__Approver__r.Name;
            }
            return listofapprovalRecords;
        }
           
    }
    /**
    * @name  lastRejectedBy
    * @description last approver of rejected record.
    * @params  none
    **/
    public String lastRejectedBy{get;set;}
    /**
    * @name  listOfRejectionRecords
    * @description list of rejection records.
    * @params  none
    **/
    public List<sbaa__Approval__c> listOfRejectionRecords{
        get{        
            
            List<sbaa__Approval__c> listOfRejectionRecords = new List<sbaa__Approval__c>();
            List<sbaa__Approval__c> rejectionRecords = [SELECT Name,sbaa__ApprovalChain__r.Name,sbaa__CommentsLong__c,sbaa__Status__c,
                                                 sbaa__RejectedBy__r.Name,sbaa__Archived__c,sbaa__ApprovalStep__c,sbaa__Approver__r.Name
                                                 FROM sbaa__Approval__c WHERE Quote__c=:quoteId];
               
            for(sbaa__Approval__c rejection:rejectionRecords){

                     if(rejection.sbaa__Status__c == L2O_Constants.APPROVAL_STATUS_REJECTED && rejection.sbaa__Archived__c == false){
                    	listOfRejectionRecords.add(rejection);
                     }
            }
            
            if(!listOfRejectionRecords.isEmpty()){
                lastRejectedBy = listOfRejectionRecords.get(listOfRejectionRecords.size()-1).sbaa__Approver__r.Name;

            } 
            
            return listOfRejectionRecords;
        }
      
    }
   
}