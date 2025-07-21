/**
 * Created by eugenemartinez on 11/2/17.
 */

global without sharing class UmrAcctGrpConParse_Bch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  private final String qString;

  global UmrAcctGrpConParse_Bch(String pQuery) {
    if (pQuery == null)
      qString = 'select id, batch_key__c, batch_time__c, item_data__c, item_defaults__c, item_key__c from acctgrpconparsing_item__c where source__c = \'UMR\' and processed__c = false';
    else
      qString = pQuery;
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(qString);
  }
  global void execute(
    Database.BatchableContext BC,
    List<acctgrpconparsing_item__c> scope
  ) {
    UmrAcctGrpConParser uagcp = new UmrAcctGrpConParser();
    for (AcctGrpConParsing_Item__c tmpAgcpi : scope) {
      uagcp.ProcessPostingEntries(
        new List<AcctGrpConParsing_Item__c>{ tmpAgcpi }
      );
      tmpAgcpi.Processed__c = true;
    }
    update scope;
  }
  global void finish(Database.BatchableContext BC) {
    String baseURL = URL.getOrgDomainUrl().toExternalForm();
    AsyncApexJob a = [
      SELECT Id, Status, TotalJobItems, CreatedBy.Email, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :BC.getJobId()
    ];
    if (a.NumberOfErrors == 0) {
      List<AcctGrpConParsing_Item__c> agcpiList = [
        SELECT Id, Item_Data__c, item_defaults__c
        FROM AcctGrpConParsing_Item__c
        WHERE Source__c = 'UMR' AND Processed__c = FALSE
      ];
      if (agcpiList.size() > 0) {
        UmrAcctGrpConParse_Bch umrbch = new UmrAcctGrpConParse_Bch(null);
        Database.executeBatch(umrbch, 1);
      } else {
        /*
                ApexPages.PageReference report = new ApexPages.PageReference('/00Of40000080w8h?csv=1');
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('report.csv');
                attachment.setBody(report.getContent());
                attachment.setContentType('text/csv');
                */
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ a.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        //mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('UMR Batch Job Completed: ' + a.Status);
        mail.setHtmlBody(
          'UMR Batch Process ID:<b> ' +
            a.Id +
            ' </b> \n <p>Total Group record processed:<b> ' +
            a.TotalJobItems +
            '</b> with <b>' +
            a.NumberOfErrors +
            '</b> failures.</p> \n <p>To view your UMR process report: <a href=' +
            baseURL +
            '/00Of40000080w8h> click here</a></p>'
        );
        if (!Test.isRunningTest()) {
          Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
      }
    }
  }
}