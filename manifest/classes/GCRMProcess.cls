public with sharing class GCRMProcess {
  String moduleName = 'GCRMProcessV4';
  String defaultSeverity = 'INFO';

  public void processOrderByMUID(String muid) {
    List<G2LCRM_Item__c> gitems = new List<G2LCRM_Item__c>();
    Map<String, List<Map<String, Object>>> recordsByProcess = new Map<String, List<Map<String, Object>>>();
    GCRMHelper.muid = muid;

    GCRMHelper helper = new GCRMHelper();
    gitems = helper.getG2LCRMItemRecords();
    helper.deleteG2ItemLogs();
    if (gitems != null && gitems.size() > 0) {
      recordsByProcess = helper.getRecordsByProcessors(gitems);
    }
    if (helper.validatePayload(recordsByProcess)) {
      helper.parseRecords(recordsByProcess);
      helper.setdefaultOwner();
      helper.recordstoCreate();
    }
    helper.updateReBroadcasted();
  }
}