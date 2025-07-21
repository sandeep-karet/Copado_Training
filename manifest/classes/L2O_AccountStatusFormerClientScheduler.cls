/** 
* Company : PwC.
* @description : Schedulable Class for L2O_AccountStatusFormerClientBatch Batch Class
* ************************************************************************************************************************************
* History : 
* @date 28/04/2022
* @author Aviral Dhodi
*/
public without sharing class L2O_AccountStatusFormerClientScheduler implements Schedulable {
    
    /**
	* @name  execute()
	* @description Runs Batch Class L2O_AccountStatusFormerClientBatch when called.
	* @param sc to pass SchedulableContext
	*/ 
 	public void execute(SchedulableContext sc) {
    L2O_AccountStatusFormerClientBatch batch = new L2O_AccountStatusFormerClientBatch() ;
	Database.executeBatch(batch) ;
	}
}