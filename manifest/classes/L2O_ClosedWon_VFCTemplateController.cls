/**
* Company : PwC.
* @description : L2O_ClosedWon_VFCTemplateController will be executed from the L2O_ClosedWon_VFCTemplate .
* *******************************************************************************************************************************************
* History : 
* @date 22/12/2022
* @author Neha Sheikh
*/
public without sharing class L2O_ClosedWon_VFCTemplateController {
    
    
    List<SBQQ__QuoteLine__c> quotLineItemLstINTL = new List<SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> quotLineItemLstUSGH = new List<SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> quotLineItemLstHHS = new List<SBQQ__QuoteLine__c>();

     /**
    * @name  oppId
    * @description opportunity Id value.
    * @params  none
    **/
    public String oppId{get;set;}
    
    /**
    * @name  getFields
    * @description fields in the L2O_ClosedWonEmailTemplateFieldSet field set.
    * @params  none
    * @return all the fields in the L2O_ClosedWonEmailTemplateFieldSet field set.
    **/
    List<Schema.FieldSetMember> getFields() {
        return SObjectType.Opportunity.FieldSets.L2O_ClosedWonEmailTemplateFieldSet.getFields();
    }
    /**
    * @name  oppRecord
    * @description opp value.
    * @params  none
    * @return opp record data.
    **/

    public Opportunity oppRecord{
        get {
        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldSet : this.getFields()) {
            query += fieldSet.getFieldPath() + ', '; 
        }
       return Database.query(String.escapeSingleQuotes(query)+
                                  'Id, Account.Owner.Name,SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__r.Email FROM Opportunity WHERE Id =\'' + 
                                  String.escapeSingleQuotes(oppId) + '\''+' LIMIT 1');
        
        }
        set;
    }
    /**
    * @name  isInternational
    * @description check if the opp is international or not.
    * @params  none
    * @return true if opp is international else false.
    **/
    public Boolean isInternational{
        get{
            if(oppRecord.L2O_Business_Region__c != L2O_Constants.BUSSINESS_REGION_USA && oppRecord.L2O_Business_Region__c != null){
                return true;
            }else{
                 return false;
            }
        }
        set;
    }
    /**    
    * @name  quoteLineItems
    * @description related Quote's Quote line items value.
    * @params  none
    * @return list of quoteLine's.
    **/
 
    List<SBQQ__QuoteLine__c> quoteLineItems{
        
        get{   
          List<SBQQ__QuoteLine__c> quotLineItemList = [SELECT SBQQ__ProductName__c,SBQQ__EffectiveQuantity__c,SBQQ__UnitCost__c,
                                                         SBQQ__Quote__r.SBQQ__StartDate__c,L2O_Case_Rate__c,SBQQ__NetTotal__c,
                                                         L2O_Membership_Fee__c,L2O_Per_Unit_Discount__c,SBQQ__ListPrice__c,L2O_Service_Platform__c,
                                                         L2O_Business_Region_rev__c,SBQQ__AdditionalDiscount__c
                                                         FROM SBQQ__QuoteLine__c 
                                                         WHERE SBQQ__Quote__c=:oppRecord.SBQQ__PrimaryQuote__c];
             return quotLineItemList;
        }
        set;
        
    }
    /**    
    * @name  quoteLineItemsforINTL
    * @description related Quote's Quote line for international.
    * @params  none
    * @return list of quoteLine's.
    **/
    public List<SBQQ__QuoteLine__c> quoteLineItemsforINTL{
        get{
            for(SBQQ__QuoteLine__c qliTemp : quoteLineItems){
                if(qliTemp.L2O_Business_Region_rev__c != L2O_Constants.BUSSINESS_REGION_USA && !quotLineItemLstINTL.contains(qliTemp)){
                    quotLineItemLstINTL.add(qliTemp);
                }
            }
            return quotLineItemLstINTL;
        }
         set;
    }
    /**    
    * @name  quoteLineItemsforUSGH
    * @description related Quote's Quote line for USGH.
    * @params  none
    * @return list of quoteLine's.
    **/
    public List<SBQQ__QuoteLine__c> quoteLineItemsforUSGH{
        get{
            for(SBQQ__QuoteLine__c qliTemp : quoteLineItems){
                if((qliTemp.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_LIV || qliTemp.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_TDH) &&
                    qliTemp.L2O_Business_Region_rev__c == L2O_Constants.BUSSINESS_REGION_USA && !quotLineItemLstUSGH.contains(qliTemp)){
                    quotLineItemLstUSGH.add(qliTemp);
                }
            }
            return quotLineItemLstUSGH;
        }
         set;
    }
    /**    
    * @name  quoteLineItemsforHHS
    * @description related Quote's Quote line for HHS.
    * @params  none
    * @return list of quoteLine's.
    **/
    public List<SBQQ__QuoteLine__c> quoteLineItemsforHHS{
        get{
            for(SBQQ__QuoteLine__c qliTemp : quoteLineItems){
                if((qliTemp.L2O_Service_Platform__c != L2O_Constants.BUSSINESS_TYPE_LIV && qliTemp.L2O_Service_Platform__c != L2O_Constants.BUSSINESS_TYPE_TDH) && 
                    qliTemp.L2O_Business_Region_rev__c == L2O_Constants.BUSSINESS_REGION_USA && !quotLineItemLstHHS.contains(qliTemp)){
                    quotLineItemLstHHS.add(qliTemp);
                }
            }
            return quotLineItemLstHHS;
        }
         set;
    }
    /**    
    * @name  setTablevisibility
    * @description to set the table visibility based on products.
    * @param  productType type of the region.
    * @return true/false based on given condtions.
    **/
    public Boolean setTablevisibility(String productType){
        for(SBQQ__QuoteLine__c qliTemp : quoteLineItems){
            if(qliTemp.L2O_Business_Region_rev__c != L2O_Constants.BUSSINESS_REGION_USA && productType == 'INTL'){
                return true;
            }
            else if((qliTemp.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_LIV || qliTemp.L2O_Service_Platform__c == L2O_Constants.BUSSINESS_TYPE_TDH) &&
                    qliTemp.L2O_Business_Region_rev__c == L2O_Constants.BUSSINESS_REGION_USA && productType == 'USGH'){ 
                         return true;
                    }
            else if((qliTemp.L2O_Service_Platform__c != L2O_Constants.BUSSINESS_TYPE_LIV && qliTemp.L2O_Service_Platform__c != L2O_Constants.BUSSINESS_TYPE_TDH) && 
                    qliTemp.L2O_Business_Region_rev__c == L2O_Constants.BUSSINESS_REGION_USA && productType == 'HHS'){
                         return true;
                    }
            
        }
         return false;
    }
    /**    
    * @name  isINTL
    * @description to show the table with international products.
    * @params  none
    * @return true/false based on given condtions.
    **/
    public Boolean isINTL{
        get{
            if(setTablevisibility('INTL')){
                return true;
            }
            return false;
        }set;
    }
    /**    
    * @name  isUSGH
    * @description to show the table with USGH products.
    * @params  none
    * @return true/false based on given condtions.
    **/
        public Boolean isUSGH{
        get{
            if(setTablevisibility('USGH')){
                return true;
            }
            return false;
        }set;
    }
    /**    
    * @name  isHHS
    * @description to show the table with HHS products.
    * @params  none
    * @return true/false based on given condtions.
    **/
        public Boolean isHHS{
        get{
            if(setTablevisibility('HHS')){
                return true;
            }
            return false;
        }set;
    }    
}