/**
* Company : PwC.
* @description : L2O_OrderItemTriggerHandler will be executed from the L2O_OrderItemTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Neha Sharma
*/

public class L2O_OrderItemTriggerHandler extends SDF_TGF_TriggerHandler {
    
    //Exception log variables
    public static String className = 'L2O_OrderItemTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeInsert() {
        try{
            L2O_OrderItemTriggerHelperService helper = new L2O_OrderItemTriggerHelperService();
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
            L2O_OrderItemTriggerHelperService helper = new L2O_OrderItemTriggerHelperService();
            // To validate and update GUID Field on Account
            helper.setGUID(Trigger.new);
           	helper.setContractAction(Trigger.new);
            }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }
 }