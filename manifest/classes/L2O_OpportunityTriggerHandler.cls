/**
* Company : PwC.
* @description : L2O_OpportunityTriggerHandler will be executed from the L2O_OpportunityTrigger and will extend the L2O_TriggerHandler class.
* *******************************************************************************************************************************************
* History : 
* @date 29/03/2022
* @author Neha Sharma
*/
public class L2O_OpportunityTriggerHandler extends SDF_TGF_TriggerHandler{ 
    
    //Exception log variables
    public static String className = '';
    public static String methodName = ''; 
    
    /**
    * @name  beforeInsert
    * @description overriding beforeInsert
    * @params  none
    **/
    public override void beforeInsert() {
        try{
            L2O_OpportunityTriggerHelperService helper = new L2O_OpportunityTriggerHelperService();
             helper.updateOpportunityStageOnInsert();
            // To validate and update GUID Field on Opportunity # 14583
            helper.setGUID(Trigger.New);
           helper.setUserRoleBasedOppChannelAndSubchannel();
            // This method should call in last as it depends on qother fields values
            helper.setDefaultPriceBook();
             //L2O_OpportunityValidationRuleClass validatorClass = new L2O_OpportunityValidationRuleClass();
            
            //Validate stage change    
         //   validatorClass.checkOpportunityStageValidations();
            
            
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

    @SuppressWarnings('PMD.UnusedLocalVariable')
    public override void beforeUpdate() {
      try{
          	L2O_OpportunityValidationRuleClass validatorClass = new L2O_OpportunityValidationRuleClass();
            
            //Validate stage change    
            validatorClass.checkOpportunityStageValidations();
            
            L2O_OpportunityTriggerHelperService helper = new L2O_OpportunityTriggerHelperService();
            helper.setDefaultPriceBook();
            //Update Opportunity field Contracted to True. #5625   
            helper.updateOpportunity();
            helper.updateRipOpptyToContracted();
           
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
            L2O_OpportunityTriggerHelperService helper = new L2O_OpportunityTriggerHelperService();
            helper.updatePrimaryQuote();
            helper.updateCancelRipOpptyToContracted();
            helper.sendEmailOnClosedWon();
            helper.createStageMetricObjRec();
            helper.populateContractPriorFields();
            helper.publishPreSaleBroadcastEvent(trigger.new, Trigger.oldMap);
            helper.updateAccountIdOnQuote();
            helper.setINTLContractPathValues(Trigger.new);
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
            L2O_OperationOnAmmendedOpportunity opportunityAmmend = new L2O_OperationOnAmmendedOpportunity();
            opportunityAmmend.createContactRoleOnAmmendedOpportunity();
            L2O_OpportunityTriggerHelperService helper = new L2O_OpportunityTriggerHelperService();
            helper.createStageMetricObjRec();
            helper.setINTLContractPathValues(Trigger.new);
            helper.setLeadID(Trigger.new);
            
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        
    }
   
}