trigger G2LCRM_Item_After on G2LCRM_Item__c (after insert, after undelete) {
  for(G2LCRM_Item__c tmpItem : trigger.new){
    if (tmpItem.Processor__c == 'orderV3' || tmpItem.Processor__c == 'PreSale'){
      DateTime dtCurrentTime = System.now().addminutes(2);

      String sHour = '', sMinute='', sDayOfMonth='', sMonth='', sYear='';

      sMinute = String.ValueOf(dtCurrentTime.minute());
      sHour = String.ValueOf(dtCurrentTime.hour());
      sDayOfMonth = String.ValueOf(dtCurrentTime.day());
      sMonth = String.ValueOf(dtCurrentTime.month());
      sYear = String.ValueOf(dtCurrentTime.year());

      String cronTriggerId = System.schedule('[' + tmpItem.MUID__c + '] : scheduled to process at ' + dtCurrentTime
          , '0 '+sMinute+' '+sHour+' '+sDayOfMonth+' '+sMonth+' ?'+' '+sYear
          , new GCRM_Process_OrderV3_Sch(tmpItem.MUID__c));
      System.debug('GCRM_Process_OrderV3_Sch Cron trigger ID: ' + cronTriggerId);
    }
  }
}