/**
* Company : PwC.
* @description : L2O_OrderTriggerHandler will be executed from the L2O_OrderTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
public class L2O_OrderTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_OrderTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeInsert() {
        try{
            L2O_OrderTriggerHelperService helper = new L2O_OrderTriggerHelperService();
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
            L2O_OrderTriggerHelperService helper = new L2O_OrderTriggerHelperService();
            // To validate and update GUID Field on Account   
            helper.setGUID(Trigger.new);
            helper.activateOrder(Trigger.new,Trigger.oldMap);
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
            L2O_OrderTriggerHelperService helper = new L2O_OrderTriggerHelperService();
            helper.holdOrderCheckMethod(Trigger.new,Trigger.oldMap);
            helper.publishPostSaleBroadcastPlatformEvent(Trigger.new,Trigger.oldMap);
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    } 
    

}