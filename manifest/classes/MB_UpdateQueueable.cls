/**
 * Name: MB_UpdateQueueable
 *
 * JIRA          CHANGED DATE     CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-3337    06-June-2023     Rajalakshmi R      Message Bus Functionality enabling
 */
public class MB_UpdateQueueable implements Queueable, Database.AllowsCallouts {
  @testVisible
  private static Boolean doChainJob = true;

  private Q_Item__c QItem;
  public MB_UpdateQueueable(Q_Item__c QItem) {
    this.QItem = QItem;
  }

  public void execute(System.QueueableContext qc) {
    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    String nameCred = QItem.Src__c + '_Org';
    String endPoint;
    try {
      endPoint = [
        SELECT Endpoint
        FROM NamedCredential
        WHERE DeveloperName = :nameCred
      ]
      .Endpoint;
    } catch (exception e) {
      endPoint = null;
    }

    if (
      isSandbox &&
      endPoint != null &&
      !endPoint.containsIgnoreCase('sandbox')
    ) {
      system.debug('NO ACCESS TO PRODUCTION FROM SANDBOX');
      QItem.Result__c = 'NO ACCESS TO PRODUCTION FROM SANDBOX';
      QItem.Processed__c = true;
      Qitem.Status__c = 'Processed with Error';
      update Qitem;
    } else {
      String jsonstr = JSON.serialize(QItem);
      HttpRequest req1 = new HttpRequest();
      req1.setEndpoint('callout:' + QItem.Src__c + '_Org/services/apexrest//');
      req1.setMethod('POST');
      req1.setHeader('Content-Type', 'application/json');
      req1.setHeader('accept', 'application/json');
      req1.setBody(jsonstr);
      Http http = new Http();
      HttpResponse res1 = http.send(req1);
      while (res1.getStatusCode() == 302) {
        req1.setEndpoint(res1.getHeader('Location'));
        res1 = new Http().send(req1);
      }
      if (res1.getStatusCode() != 200) {
        QItem.Result__c = 'Callout_Status: ' + res1.getStatusCode();
      } else {
        String result = (String) JSON.deserialize(res1.getBody(), String.class);
        QItem.Result__c = result;
        QItem.isSync__c = true;
      }
      system.debug(QItem.Result__c);
      update QItem;
      List<Q_Item__c> nextQItem = [
        SELECT
          Payload__c,
          Type__c,
          RecordTypeId,
          ItemKey__c,
          Result__c,
          Processed__c,
          Src__c,
          Dst__c,
          Parser_Name__c,
          Parser_Version__c,
          Status__c,
          Livongo_Account_Id__c,
          Teladoc_Account_Id__c
        FROM Q_Item__c
        WHERE Processed__c = TRUE AND isSync__c = FALSE AND Type__c = 'Incoming'
        ORDER BY CreatedDate ASC
        LIMIT 1
      ];

      if (nextQItem.size() != 0 && doChainJob) {
        System.enqueueJob(new MB_UpdateQueueable(nextQItem[0]));
      }
    }
  }
}