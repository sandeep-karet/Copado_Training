/**
* Company : PwC.
* @description : L2O_LookupController will be used to handle lookup fields on Edit Order Products LWC.
* *******************************************************************************************************************************************
* History : 
* @date 11/24/2022
* @author Lakshitha Salian
*/

public without sharing class L2O_LookupController {
    
    //Exception log variables
    public static String className = 'L2O_LookupController';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;
    
    /**
    * @name  lookUp   
    * @description This method gives list valid search records
    * @param searchTerm for search term in the lookup
    * @param myObject for dynamic object
    * @param filter for filters to be set in the lookup
    * @return List of SObjects
    **/ 
	@AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, string myObject, String filter){
        String myQuery = null;
        List<sObject> lookUpList = new List<sObject>();
        String searchFor = String.escapeSingleQuotes(searchTerm);
        String obj = String.escapeSingleQuotes(myObject);
        String criteria = String.escapeSingleQuotes(filter);
        
        // Generate a query string 
        // Exception Handling
        try{
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
            if(filter != null && filter != ''){
                if(myObject == 'Contact'){
                    myQuery = 'Select Id, Name from Contact Where AccountId = \''+criteria+'\' ORDER BY LastViewedDate DESC LIMIT 5'; 
                }
                else{
                    myQuery = 'Select Id, Name from '+obj+' Where Name Like  \'%' + searchFor + '%\' LIMIT 5'; 
                }
            }
            else {
                if(searchTerm == null || searchTerm == ''){
                   	myQuery = 'Select Id, Name from '+obj+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5'; 
                }
                else {
                    myQuery = 'Select Id, Name from '+obj+' Where Name Like  \'%' + searchFor + '%\' LIMIT 5';
                }
            }
            
            lookUpList = database.query(myQuery);
            
    	}catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        // Return list of valid search records
        return lookUpList;
    }
    
}