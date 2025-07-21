global without sharing class MassPsfMig_Bch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Mbr_Group__c where status__c != 'TERMED']);
    }
    
    global void execute(Database.BatchableContext bc, List<Mbr_Group__c> scope) {
        for(Mbr_Group__c mg : scope){
            MassPsfMigration mpm = new MassPsfMigration();
            try {
                
                mpm.ProcessRecords(mg.Id);
            } catch(Exception ex){
                AcctGrpConParsing_Item__c newAgcpi = new AcctGrpConParsing_Item__c(Batch_Time__c = DateTime.now(),
                                                                                   Batch_Key__c = String.valueOf(DateTime.now().getTime()), Item_Key__c = mg.Id, Processed__c = true,
                                                                                   Source__c = 'PSFMIG');
                insert newAgcpi;
                createException(newAgcpi.Id, 'ERROR','Plan_Specific_Fees__c','BCH_ERROR',ex.getMessage().left(1024));            
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