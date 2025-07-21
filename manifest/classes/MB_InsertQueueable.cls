// CORE CLASS
/**
 * Name: MB_InsertQueueable
 *
 * JIRA          CHANGED DATE     CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-3337    06-June-2023     Rajalakshmi R      Message Bus Functionality enabling
 */
public class MB_InsertQueueable implements Queueable, Database.AllowsCallouts {
  @testVisible
  private static Boolean doChainJob = true;

  private Q_Item__c QItem;
  private String Dest;
  public MB_InsertQueueable(Q_Item__c QItem, String Dest) {
    this.QItem = QItem;
    this.Dest = Dest;
  }

  public void execute(System.QueueableContext qc) {
    // Transfer MB start
    Map<String, String> nameCredMap = new Map<String, String>();
    /*nameCredMap.put('LVN_Org', 'https://livongohealth2ndorg.my.salesforce.com');
        nameCredMap.put('TDH_Org', 'https://teladochealth.my.salesforce.com/');
        nameCredMap.put('ITH_Org', 'https://intouchhealth.my.salesforce.com/');
        System.debug('In MB_InsertQueueable execute ()'); */
    String LVNRecordTypeid = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
      .get('LV Island')
      .getRecordTypeId();
    String LVIslandRecordTypeid = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
      .get('LV Org')
      .getRecordTypeId();
    if (QItem.RecordTypeId == LVNRecordTypeid) {
      system.debug('Venu --nextQItem[0]' + QItem);

      Map<String, Object> results = MB_QXfr_Process.processQ(QItem);
      System.debug('MB_InsertQueueable :: results ::' + results);
      System.debug('results.get(dml_errors) ::' + results.get('dml_errors'));
      System.debug(
        'JSON.serialize(results.get(dml_errors)).length() ::' +
        JSON.serialize(results.get('dml_errors')).length()
      );
      if (
        JSON.serialize(results.get('dml_errors')).length() > 2 ||
        JSON.serialize(results.get('parsing_errors')).length() > 2
      ) {
        Map<String, Object> finalResult = new Map<String, Object>();
        finalResult.put('DML_Errors', results.get('dml_errors'));
        finalResult.put('Parsing_Errors', results.get('parsing_errors'));
        QItem.Status__c = 'Processed with error';
        QItem.Result__c = JSON.serializePretty(finalResult);
      } else {
        QItem.Status__c = 'Processed without error';
        QItem.Result__c = 'No Error';
      }
      QItem.Processed__c = true;
      QItem.Livongo_Account_Id__c = (JSON.serialize(
          results.get('lvn_acct_url')
        ))
        .replace('"', '');
      QItem.Teladoc_Account_Id__c = (JSON.serialize(results.get('tdh_acct_id')))
        .replace('"', '');
      QItem.Livongo_Opp_Id__c = (JSON.serialize(results.get('lvn_opp_id')))
        .replace('"', '');
      QItem.Teladoc_Opp_Id__c = (JSON.serialize(results.get('tdh_opp_id')))
        .replace('"', '');
      System.debug('QItem = ' + QItem);
      if (
        QItem.Teladoc_Opp_Id__c != '' &&
        MB_QxfrUtils.checkOppId(QItem.Teladoc_Opp_Id__c)
      ) {
        qItem.Opportunity__c = QItem.Teladoc_Opp_Id__c;
      }
      qItem.Teladoc_Account_Id__c = QItem.Teladoc_Account_Id__c;
      if (
        QItem.Livongo_Account_Id__c != null &&
        QItem.Livongo_Account_Id__c != ''
      ) {
        MB_QxfrUtils.updateLvnAcctId(
          QItem.Livongo_Account_Id__c,
          QItem.Teladoc_Account_Id__c,
          'LVILD'
        );
      }
      if (QItem.Livongo_Opp_Id__c != null && QItem.Livongo_Opp_Id__c != '') {
        MB_QxfrUtils.updateSourceId(
          QItem.Livongo_Opp_Id__c,
          QItem.Teladoc_Opp_Id__c,
          'LVILD'
        );
      }
      if (QItem.status__c == 'Processed with error') {
        qItem.Error__c = MB_QxfrUtils.parseError(QItem.Result__c);
      }
      update QItem;
    }
    //SCDEV-3337 Changes Begin
    else {
      Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]
      .IsSandbox;
      this.Dest = this.Dest.contains('LVN') ? 'LVN' : this.Dest;
      String nameCred = this.Dest + '_Org';
      String endPoint;
      try {
        endPoint = [
          SELECT Endpoint
          FROM NamedCredential
          WHERE DeveloperName = :nameCred
        ]
        .Endpoint;
        System.debug('Endpoint' + endPoint);
      } catch (exception e) {
        endPoint = null;
      }
      if (isSandbox && !endpoint.containsIgnoreCase('sandbox')) {
        QItem.Result__c = 'NO ACCESS TO PRODUCTION FROM SANDBOX';
        QItem.Processed__c = true;
        Qitem.Status__c = 'Processed with Error';
        update Qitem;
      } else {
        System.debug('Type = ' + QItem.Type__c);
        String jsonstr = JSON.serialize(QItem);
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint(
          'callout:' + this.Dest + '_Org/services/apexrest/msgqitembus/'
        );
        req1.setMethod('POST');
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('accept', 'application/json');
        req1.setBody(jsonstr);
        System.debug('JSON String' + jsonstr);
        Http http = new Http();
        System.debug('Sending the request out ' + req1);
        HttpResponse res1 = http.send(req1);
        system.debug('res1.getStatusCode() :' + res1.getStatusCode());
        while (res1.getStatusCode() == 302) {
          req1.setEndpoint(res1.getHeader('Location'));
          res1 = new Http().send(req1);
        }

        if (res1.getStatusCode() != 200) {
          QItem.Result__c =
            'Callout_Status: ' +
            res1.getStatusCode() +
            ' body: ' +
            res1.getBody();
        } else {
          String result = (String) JSON.deserialize(
            res1.getBody(),
            String.class
          );
          QItem.Result__c = result;
          QItem.Processed__c = true;
          if (result.contains('Insert failed')) {
            Qitem.Status__c = 'Processed with error ';
          } else {
            Qitem.Status__c = 'Processed without error';
          }
        }
        system.debug(QItem.Result__c);
        system.debug(QItem.Status__c);
        system.debug(QItem.Processed__c);

        update QItem;
      }
    }

    //SCDEV-3337 Changes End

    List<Q_Item__c> nextQItem = [
      SELECT
        Payload__c,
        ItemKey__c,
        RecordTypeId,
        Type__c,
        Result__c,
        Processed__c,
        Src__c,
        Dst__c,
        Parser_Name__c,
        Parser_Version__c,
        Livongo_Account_Id__c,
        Teladoc_Account_Id__c
      FROM Q_Item__c
      WHERE Processed__c = FALSE AND Type__c = 'Outgoing' AND IsSync__c = FALSE
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];
    if (nextQItem.size() != 0 && doChainJob) {
      System.enqueueJob(
        new MB_InsertQueueable(nextQItem[0], nextQItem[0].Dst__c)
      );
    }
  }
}