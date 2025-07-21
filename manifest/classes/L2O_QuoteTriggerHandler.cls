/**
* Company : PwC.
* @description : L2O_QuoteTriggerHandler will be executed from the L2O_QuoteTrigger and will extend the L2O_TriggerHandler class .
* ************************************************************************************************************************************
* History : 
* @date 25/02/2022
* @author Lakshitha Salian
*/

public class L2O_QuoteTriggerHandler extends SDF_TGF_TriggerHandler{ 
    
    //Exception log variables
    public static String className = 'L2O_QuoteTriggerHandler';
    public static String methodName = '';
    
	/**
    * @name  beforeInsert
    * @description overriding beforeInsert
    * @params  none
    **/
    public override void beforeInsert() {
       try{
			
            L2O_QuoteTriggerHelperService helper = new L2O_QuoteTriggerHelperService();
             //Check if Opportunity of the quote do have the contact role?
           helper.checkIfOpportunityHasContactRole();   
           helper.assignNewQuoteAsPrimary(); 
           //helper.assignQuoteDefaultValues(); 
            //Update End Date to Start Date + Subscription Term months #5357
            //Update Business Region from Opp Business Region #5634
          // helper.updateQuote();
       	}
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        
    }
    
    /**
    * @name  afterInsert
    * @description overriding afterInsert
    * @params  none
    **/
    public override void afterInsert() {
        try{
            L2O_QuoteTriggerHelperService helper = new L2O_QuoteTriggerHelperService();
                
            //To share the Quote record with owner's Manager and owner's Manager's Manager. #6226
            helper.shareQuote();
            }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }

    }
    
    /**
    * @name  beforeUpdate
    * @description overriding beforeUpdate
    * @params  none
    **/
    public override void beforeUpdate() {
        try{
            
            L2O_QuoteTriggerHelperService helper = new L2O_QuoteTriggerHelperService();
            
            //Update Quote Status per Approval Status mapping. #5372    
            helper.mapApprovalStatusToQuoteStatus();
            helper.stopUserTochangePrimaryQuotePresented();
            helper.assignNewQuoteAsPrimary(); 
            //Default the Primary to True when Status is Approved #5357
            //helper.updateQuote();
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        
    }
    
    /**
    * @name  afterUpdate
    * @description overriding afterUpdate
    * @params  none
    **/
     public override void afterUpdate() {
        try{
            L2O_QuoteTriggerHelperService helper = new L2O_QuoteTriggerHelperService();
            Map<Id,SBQQ__Quote__c> olddata=(Map<Id,SBQQ__Quote__c>)Trigger.oldMap;
            Map<Id,SBQQ__Quote__c> newdata=(Map<Id,SBQQ__Quote__c>)Trigger.newMap;
            //To share the Quote record with owner's Manager and owner's Manager's Manager. #6226
            helper.shareQuote();
            helper.updateQuoteSalesTypeOnOpp(); //#15270
            //3385
            List<Id> newquoteids=new List<Id>();
            for(Id qrec:newdata.keySet())
            {
              if(newdata.get(qrec).SBQQ__Status__c=='Accepted' && olddata.get(qrec).SBQQ__Status__c!='Accepted')
                {
                newquoteids.add(qrec);    
                }
                  
            }
            if(newquoteids.size()>0)
            {
            L2O_QuoteTriggerHelperService.updateLaunchStatusField(newquoteids);
            }
            //3385
            }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }
}