global with sharing class GCRM_Process_V3_Bch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private String orderMUID {get;set;}
    private Boolean isReprocessed{get; set;}
    global GCRM_Process_V3_Bch(String muid,Boolean reprocessed){
        orderMUID = muid;
        isReprocessed = reprocessed;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, MUID__c, Status__c,Processor__c from G2LCRM_Item__c where MUID__c = \'' + orderMUID + '\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<G2LCRM_Item__c> scope) {
        SBQQ.TriggerControl.disable();
        G2LCRM_Flow__c settings = G2LCRM_Flow__c.getInstance();
        
        Boolean ispresale = false;
        for(G2LCRM_Item__c g2lci : scope){
            g2lci.Status__c = 'Processing';
            if(g2lci.Processor__c == 'PreSale'){
                ispresale = true;
            }
        }
        update scope;
        ExceptionCustomLog.captureCustomException(orderMUID,'','', '', '', '', '','');
        if(!settings.G2LCRM_V4_Flow__c)
        {
            if(ispresale){
            	GCRM_Process_PreSales gcrmPre = new GCRM_Process_PreSales();
            	gcrmPre.ProcessPayload(orderMUID);
        	}
            else{
                GCRM_Ingest_OrderV3.ingestG2LByMUID(orderMUID);
            	GCRM_Process_OrderV3.ProcessOrderByMUID(orderMUID);
            }
            
        }
        else 
        {
            //GCRM_Process_Payload gpab = new GCRM_Process_Payload();
            GCRMProcess gpab = new GCRMProcess();
			gpab.ProcessOrderByMUID(orderMUID);
        }
        ExceptionCustomLog.saveResultsToG2LItemLog();
    }
    global void finish(Database.BatchableContext bc) {
        /*
        List<G2LCRM_Item__c> g2items = [Select Id, MUID__c from G2LCRM_Item__c where MUID__c = :orderMUID];
        for(G2LCRM_Item__c g2lci : g2items){
            g2lci.Status__c = 'Done';
        }
        update g2items;
        */
        List<G2LCRM_Item__c> g2items = [Select Id, Status__c, Processed__c, (Select Id from G2LItemLogs__r) from G2LCRM_Item__c where MUID__c = :orderMUID];
        for(G2LCRM_Item__c g2lci : g2items){
            g2lci.Processed__c = true;
            if(g2lci.G2LItemLogs__r.size()>0){
                g2lci.Status__c = 'Processed with Error';
            }else if(isReprocessed){
                g2lci.Status__c = 'Re-Processed';
            }else{
                g2lci.Status__c = 'Done';
            }
            
        }
        update g2items;
        G2LItemErrorReportEmail.sendErrorReport(orderMUID);
        SBQQ.TriggerControl.enable();
    }
}