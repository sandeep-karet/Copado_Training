/**
* Company : PwC.
* @description : L2O_AgreementTriggerHandler will be executed from the L2O_AgreementTrigger and will extend the SDF_TGF_TriggerHandler.
* ************************************************************************************************************************************
* History : 
* @date 07/07/2022
* @author Aviral Dhodi
*/
public class L2O_AgreementTriggerHandler extends SDF_TGF_TriggerHandler{
    
    //Exception log variables
    public static String className = 'L2O_AgreementTriggerHandler';
    public static String methodName = '';
    
 	/**
	* @name  beforeInsert
	* @description To override beforeInsert
	* @params  none
	**/
    public override void beforeInsert() {
        try{
            L2O_AgreementTriggerHelperService helper = new L2O_AgreementTriggerHelperService();
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
            L2O_AgreementTriggerHelperService helper = new L2O_AgreementTriggerHelperService();
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