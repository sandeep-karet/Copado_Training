/**
 * Name: MsgQItemBus
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-3337    13-Jul-2023		Rajalakshmi R       LV Org Msg Bus fix
 */

@RestResource(urlMapping='/msgqitembus/*')
global with sharing class MsgQItemBus {
  @HttpPost
  global static String processQ() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Q_Item__c incomingQ = (Q_Item__c) JSON.deserialize(
      req.requestBody.toString(),
      Q_Item__c.class
    );
    if (incomingQ.Type__c == 'Incoming') {
      system.debug(incomingQ.Teladoc_Opp_Id__c);
      Q_Item__c qItem = [
        SELECT Id
        FROM Q_Item__c
        WHERE ItemKey__c = :incomingQ.ItemKey__c
      ];
      qItem.Status__c = incomingQ.Status__c;
      qItem.isSync__c = true;
      qItem.Result__c = incomingQ.Result__c;
      //SCDEV-3337 Changes Begin
      qItem.Teladoc_Opp_Id__c = incomingQ.Teladoc_Opp_Id__c;
      qItem.Livongo_Account_Id__c = incomingQ.Livongo_Account_Id__c;
      qItem.Livongo_Opp_Id__c = incomingQ.Livongo_Opp_Id__c;
      if (
        incomingQ.Teladoc_Opp_Id__c != '' &&
        MB_QxfrUtils.checkOppId(incomingQ.Teladoc_Opp_Id__c)
      ) {
        qItem.Opportunity__c = incomingQ.Teladoc_Opp_Id__c;
      }
      qItem.Teladoc_Account_Id__c = incomingQ.Teladoc_Account_Id__c;
      if (
        incomingQ.Livongo_Account_Id__c != null &&
        incomingQ.Livongo_Account_Id__c != ''
      ) {
        MB_QxfrUtils.updateLvnAcctId(
          incomingQ.Livongo_Account_Id__c,
          incomingQ.Teladoc_Account_Id__c,
          'LVNORG'
        );
      }
      if (
        incomingQ.Livongo_Opp_Id__c != null &&
        incomingQ.Livongo_Opp_Id__c != ''
      ) {
        MB_QxfrUtils.updateSourceId(
          incomingQ.Livongo_Opp_Id__c,
          incomingQ.Teladoc_Opp_Id__c,
          'LVNORG'
        );
      }
      //SCDEV-3337 changes End
      if (incomingQ.status__c == 'Processed with error') {
        qItem.Error__c = MB_QxfrUtils.parseError(incomingQ.Result__c);
      }
      try {
        update qItem;
        resultWrapper syncWrapper = new resultWrapper('Success', 'None');
        return JSON.serializePretty(syncWrapper);
      } catch (exception e) {
        resultWrapper syncWrapper = new resultWrapper('Failed', e.getMessage());
        return JSON.serializePretty(syncWrapper);
      }
    } else {
      incomingQ.Id = null;
      incomingQ.Type__c = 'Incoming';
      List<Q_Item__c> qList = new List<Q_Item__c>();
      qList.add(incomingQ);
      try {
        insert qList;
        outgoingWrapper qItemWrapper = new outgoingWrapper('True', 'None');
        return JSON.serializePretty(qItemWrapper);
      } catch (exception e) {
        outgoingWrapper qItemWrapper = new outgoingWrapper(
          'False',
          e.getMessage()
        );
        return JSON.serializePretty(qItemWrapper);
      }
    }
  }

  public class resultWrapper {
    public String syncResult { get; set; }
    public String syncError { get; set; }
    public resultWrapper(String syncResult, String syncError) {
      this.syncResult = syncResult;
      this.syncError = syncError;
    }
  }

  public class outgoingWrapper {
    public String isCreated { get; set; }
    public String qItemError { get; set; }
    public outgoingWrapper(String isCreated, String qItemError) {
      this.isCreated = isCreated;
      this.qItemError = qItemError;
    }
  }
}