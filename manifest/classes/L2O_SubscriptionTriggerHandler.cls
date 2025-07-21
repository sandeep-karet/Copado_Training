/**
* Company : PwC.
* @description : L2O_SubscriptionTriggerHandler will be executed from the L2O_SubscriptionTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
public class L2O_SubscriptionTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_SubscriptionTriggerHandler';
    public static String methodName = '';
    public static String triggerConfigurationName = 'L2O_TriggerContextDataMigration';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @param
	**/
    public override void beforeInsert() {
        try{
            L2O_SubscriptionTriggerHelperService helper = new L2O_SubscriptionTriggerHelperService();
            // To validate and update GUID Field on Account
            If(SDF_TGF_Trigger_Config__mdt.getInstance(triggerConfigurationName).Enabled__c){
            helper.setGUID(Trigger.New);
            }
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        
    }
    
    /**
	* @name beforeUpdate
	* @description To override beforeUpdate
	* @param
	**/
    
    public override void beforeUpdate() {
        try{
            L2O_SubscriptionTriggerHelperService helper = new L2O_SubscriptionTriggerHelperService();
            // To validate and update GUID Field on Account
            If(SDF_TGF_Trigger_Config__mdt.getInstance(triggerConfigurationName).Enabled__c){
            helper.setGUID(Trigger.New);
            }
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }

    /**
	* @name afterInsert
	* @description To override afterInsert
	* @param
	**/
    
    public override void afterInsert() {
        try{
            L2O_SubscriptionTriggerHelperService helper = new L2O_SubscriptionTriggerHelperService();
            If(SDF_TGF_Trigger_Config__mdt.getInstance(triggerConfigurationName).Enabled__c){
            helper.updateContract();
            helper.updateSubscription(); //CON-162092
            }
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }

    /**
	* @name afterUpdate
	* @description To override afterUpdate
	* @param
	**/
    
    public override void afterUpdate() {
        try{
            L2O_SubscriptionTriggerHelperService helper = new L2O_SubscriptionTriggerHelperService();
            If(SDF_TGF_Trigger_Config__mdt.getInstance(triggerConfigurationName).Enabled__c){
            helper.updateContract();
            }
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }
    

}