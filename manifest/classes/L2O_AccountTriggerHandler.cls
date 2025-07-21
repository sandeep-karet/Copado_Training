/**
* Company : PwC.
* @description : L2O_AccountTriggerHandler will be executed from the L2O_AccountTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/
public class L2O_AccountTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_AccountTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeInsert() {
        try{
            L2O_AccountTriggerHelperService helper = new L2O_AccountTriggerHelperService();
            // To validate and update GUID Field on Account
            helper.setGUID(Trigger.new);
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
	* @params  none
	**/
    public override void beforeUpdate() {
        try{
            L2O_AccountTriggerHelperService helper = new L2O_AccountTriggerHelperService();
            // To validate and update GUID Field on Account
            helper.setGUID(Trigger.new);
            helper.updateClientStatusDate(Trigger.new, Trigger.oldMap);
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
	* @params  none
	**/
    
    public override void afterInsert() {
        try{
            L2O_AccountTriggerHelperService helper = new L2O_AccountTriggerHelperService();
            // To set LeadId field on Account,Opportunity and Contact
            helper.setLeadID(Trigger.new);
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
	* @params  none
	**/
    
    public override void afterUpdate() {
        try{
            L2O_AccountTriggerHelperService helper = new L2O_AccountTriggerHelperService();
            helper.publishClientBroadcastPlatformEvent(Trigger.new,Trigger.oldMap);
            //SCDEV-4598 starts
            helper.keepAccountTeamMembers(Trigger.new,Trigger.oldMap);
            //SCDEV-4598 ends
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }
}