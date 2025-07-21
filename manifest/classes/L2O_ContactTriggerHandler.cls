/**
* Company : PwC.
* @description : L2O_ContactTriggerHandler will be executed from the L2O_AccountTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/
public class L2O_ContactTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_ContactTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeInsert() {
        try{
            L2O_ContactTriggerHelperService helper = new L2O_ContactTriggerHelperService();
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
            L2O_ContactTriggerHelperService helper = new L2O_ContactTriggerHelperService();
            helper.setGUID(Trigger.new);
            Map<Id,Contact> oldMap = (Map<Id,Contact>)Trigger.oldMap;
            helper.preventUpdateifRoleExists(Trigger.new, oldMap);
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
	* @description To override afterInsert
	* @params  none
	**/
    public override void afterInsert() {
        try{
            L2O_ContactTriggerHelperService helper = new L2O_ContactTriggerHelperService();
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
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeDelete() {
        try{
            L2O_ContactTriggerHelperService helper = new L2O_ContactTriggerHelperService();
            helper.preventUpdateifRoleExists(Trigger.old, null);
            }
        catch(Exception ex){
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        
    }
    

}