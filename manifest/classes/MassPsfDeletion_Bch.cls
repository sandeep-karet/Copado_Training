global without sharing class MassPsfDeletion_Bch implements Database.Batchable<sObject> {
    AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c(Batch_Key__c = String.valueOf(DateTime.now().getTime()), Item_Key__c = String.valueOf(DateTime.now().getTime()/1000), Processed__c = true, Batch_Time__c = DateTime.now(), Source__c = 'PSF_DELETION');
    global Database.QueryLocator start(Database.BatchableContext bc) {
        insert agcpi;
        return Database.getQueryLocator([SELECT Id FROM Plan_Specific_Fees__c WHERE Psf_ProductCode__c IN ('BH')]);
    }
    
    global void execute(Database.BatchableContext bc, List<Plan_Specific_Fees__c> scope) {
        Database.DeleteResult[] dr = Database.delete(scope, false);
        for (Database.DeleteResult rowSr : dr) {
            if (!rowSr.isSuccess()) {
                for (Database.Error rowError : rowSr.getErrors()) {
                    createException(agcpi.Id, 'PLAN_SPECIFIC_FEES__C', 'ERROR', 'PSF_DELETE_FAILED',
                                    rowError.getMessage());
                }
            }
        } 
    }
    global void finish(Database.BatchableContext bc) {
    }
    global void createException(Id sourceAgcpi, String exType, String sObjectName, String shortDesc, String fullDesc) {
        AcctGrpConParse_Exception__c tmpAgcpe = new AcctGrpConParse_Exception__c();
        tmpAgcpe.Agcpi__c = sourceAgcpi;
        tmpAgcpe.Exception_Type__c = exType.trim().toUpperCase();
        tmpAgcpe.sobject__c = sObjectName.trim().toUpperCase();
        tmpAgcpe.Short_Desc__c = shortDesc.left(64).trim().toUpperCase();
        if (fullDesc.length() > 255) {
            tmpAgcpe.Full_Desc__c = fullDesc.substring(0, 255);
        } else {
            tmpAgcpe.Full_Desc__c = fullDesc;
            
        }
        insert tmpAgcpe;
    }
}