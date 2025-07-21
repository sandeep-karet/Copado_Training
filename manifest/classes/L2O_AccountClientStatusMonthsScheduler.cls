/** 
* Company : PwC.
* @description : Schedulable Class for L2O_AccountClientStatusMonthsScheduler Batch Class
* ************************************************************************************************************************************
* History : 
* @date 30/09/2022
* @author Neha Sharma
*/
public without sharing class L2O_AccountClientStatusMonthsScheduler {
     
    /**
	* @name  execute()
	* @description Runs Batch Class L2O_AccountStatusFormerClientBatch when called.
	* @param sc to pass SchedulableContext
	*/ 
 	public void execute(SchedulableContext sc) {
    L2O_AccountClientStatusMonthsBatch batch = new L2O_AccountClientStatusMonthsBatch() ;
	Database.executeBatch(batch) ;
	}

}