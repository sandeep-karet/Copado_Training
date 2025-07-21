@RestResource(urlMapping='/UmrUpload/v2/*')
global with sharing class UmrUploadService {
  @HttpGet
  global static String fetchStatus() {
    return 'Still queued.';
  }
  @auraenabled
  @HttpPost
  global static string submitData(
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
    return JSON.serialize(tmpPostedData);
  }

  @auraenabled
  public static String umr_E2E() {
    Integer AGCPI_notProcessed = [
      SELECT COUNT()
      FROM AcctGrpConParsing_Item__c
      WHERE Source__c = 'UMR' AND Processed__c = FALSE
    ];
    String result = 'No Unprocessed UMR Record Found';
    if (AGCPI_notProcessed > 0) {
      List<String> statusList = new List<String>{
        'Queued',
        'Preparing',
        'Processing'
      };
      List<Asyncapexjob> batchJob = [
        SELECT
          Id,
          ApexClass.Name,
          status,
          JobItemsProcessed,
          TotalJobItems,
          Createddate
        FROM asyncapexjob
        WHERE
          jobtype = 'BatchApex'
          AND ApexClass.Name = 'UmrAcctGrpConParse_Bch'
          AND Status IN :statusList
        ORDER BY Createddate
      ];
      if (batchJob.size() == 0) {
        UmrAcctGrpConParse_Bch umrBch = new UmrAcctGrpConParse_Bch(null);
        string batchJobId = Database.executeBatch(umrBch, 1);
        Result = 'UMR Batch Job is Queued. JobId: ' + batchJobId;
      } else {
        Result = 'UMR Batch Job Is Already Running. JobId: ' + batchJob[0].Id;
      }
    }
    system.debug(Result);
    return Result;
  }
}