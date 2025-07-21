global class UmrUploadWebService {
  // Create items in queue to allow for future processing.  This overcomes response timeouts in webservice call
  webService static String PostData(
    string incomingData,
    string fieldDefaultData
  ) {
    String batchid = String.valueOf(DateTime.now().getTime());

    // Put data back into object form
    List<PostingData> tmpPostedData = (List<PostingData>) JSON.deserialize(
      incomingData,
      List<PostingData>.class
    );
    Map<String, String> mappedDefaults = null;
    if (!String.isBlank(fieldDefaultData))
      mappedDefaults = (Map<String, String>) JSON.deserialize(
        fieldDefaultData,
        Map<String, String>.class
      );

    List<AcctGrpConParsing_Item__c> queuedItems = new List<AcctGrpConParsing_Item__c>();
    for (PostingData tmpPd : tmpPostedData) {
      AcctGrpConParsing_Item__c tmpAGCPI = new AcctGrpConParsing_Item__c(
        source__c = 'UMR',
        batch_key__c = batchid,
        item_data__c = JSON.serialize(tmpPd),
        item_key__c = tmpPd.groupId,
        item_defaults__c = fieldDefaultData
      );
      queuedItems.add(tmpAGCPI);
    }
    insert queuedItems;
    UmrAcctGrpConParse_Bch uagcpb = new UmrAcctGrpConParse_Bch(null);
    System.scheduleBatch(uagcpb, 'UMR Batch Processing', 5, 1);
    return JSON.serialize(
      '[' + batchid + '] ' + queuedItems.size() + ' items have been queued.'
    );
  }
}