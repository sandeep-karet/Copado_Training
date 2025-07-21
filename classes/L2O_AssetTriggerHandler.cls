/**
* Company : PwC.
* @description : L2O_AssetTriggerHandler will be executed from the L2O_AssetTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
public class L2O_AssetTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_AssetTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @param
	**/
    public override void beforeInsert() {
        try{
            L2O_AssetTriggerHelperService helper = new L2O_AssetTriggerHelperService();
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
	* @param
	**/
    
    public override void beforeUpdate() {
        try{
            L2O_AssetTriggerHelperService helper = new L2O_AssetTriggerHelperService();
            helper.setGUID(Trigger.new);
        }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
    }
    

}