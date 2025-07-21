@RestResource(urlMapping='/Flow1be2e/*')
global with sharing class Flow1b_E2E {
  public class resultWrapper {
    public String JobId { get; set; }
    public String BatchId { get; set; }
    public resultWrapper(String JobId, String BatchId) {
      this.JobId = JobId;
      this.BatchId = BatchId;
    }
  }

  @HttpPost
  global static String Flow1b_E2E(String jobId) {
    Integer AGCPI_notProcessed = [
      SELECT COUNT()
      FROM AcctGrpConParsing_Item__c
      WHERE Source__c = 'Flow1b' AND Processed__c = FALSE
    ];
    resultWrapper resultWrapper = new resultWrapper(jobId, 'NO_RECORDS_FOUND');
    String Result = JSON.serialize(resultWrapper);
    if (AGCPI_notProcessed > 0) {
      List<String> statusList = new List<String>{
        'Queued',
        'Preparing',
        'Processing',
        'Holding'
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
        WHERE ApexClass.Name = 'Flow1b_Bch' AND Status IN :statusList
        ORDER BY Createddate
      ];
      if (batchJob.size() == 0) {
        Flow1b_Bch Flow1b = new Flow1b_Bch();
        string batchJobId = Database.executeBatch(Flow1b, 1);
        resultWrapper batchWrapper = new resultWrapper(jobId, batchJobId);
        Result = JSON.serialize(batchWrapper);
      } else {
        resultWrapper batchWrapper = new resultWrapper(jobId, batchJob[0].Id);
        Result = JSON.serialize(batchWrapper);
      }
    }
    system.debug(Result);
    return Result;
  }
}