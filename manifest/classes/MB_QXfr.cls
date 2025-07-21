// CORE CLASS
/**
 * Name: MB_QXfr
 *
 * JIRA          CHANGED DATE     CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-3337    06-June-2023     Rajalakshmi R      Message Bus Functionality enabling
 */

public without sharing class MB_QXfr {
  public static void CreateAsyncQItem(
    String destination,
    String source,
    String parserName,
    List<JSONGenerator> payloadGenerator
  ) {
    List<Q_Item__c> qitemList = new List<Q_Item__c>();
    //SCDEV-3337 Changes Begin
    String LVNIldRecordTypeid = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
      .get('LV Island')
      .getRecordTypeId();
    String LVOrgRecordTypeid = Schema.SObjectType.Q_Item__c.getRecordTypeInfosByName()
      .get('LV Org')
      .getRecordTypeId();
    for (JSONGenerator json : payloadGenerator) {
      System.debug('json :::' + json);
      Q_Item__c qitem;
      Q_Item__c qitem1;
      QItem_Opp_Parser qitemp = new QItem_Opp_Parser();
      qitemp.Parse(json.getAsString());
      String OppId = qitemp.QItemOpp.TdhOppId;
      if (Message_Bus_Toggle__c.getOrgDefaults().Enable_MB_LV_Island__c) {
        qitem = new Q_Item__c(
          Payload__c = json.getAsString(),
          ItemKey__c = generateGuid(),
          Status__c = 'Pending',
          Src__c = source,
          Dst__c = 'LVNILD',
          Parser_Name__c = parserName,
          Type__c = 'Outgoing',
          RecordTypeId = LVNIldRecordTypeid,
          Opportunity__c = OppId
        );
      }
      if (
        destination == 'LVN' &&
        Message_Bus_Toggle__c.getOrgDefaults().Enable_MB_LV_Org__c
      ) {
        qitem1 = new Q_Item__c(
          Payload__c = json.getAsString(),
          ItemKey__c = generateGuid(),
          Status__c = 'Pending',
          Src__c = source,
          Dst__c = 'LVNORG',
          Parser_Name__c = parserName,
          Type__c = 'Outgoing',
          RecordTypeId = LVOrgRecordTypeid,
          Opportunity__c = OppId
        );
      }
      if (qitem != null)
        qitemList.add(qitem);
      if (qitem1 != null)
        qitemList.add(qitem1);
    }
    if (qitemList.size() > 0)
      insert qitemList;
  }

  @TestVisible
  public static String generateGuid() {
    Blob generatedBlob = Crypto.GenerateAESKey(128);
    String hex = EncodingUtil.ConvertTohex(generatedBlob);
    String guid =
      hex.substring(0, 8) +
      '-' +
      hex.substring(8, 12) +
      '-' +
      hex.substring(12, 16) +
      '-' +
      hex.substring(16, 20) +
      '-' +
      hex.substring(20);
    return guid.toUppercase();
  }

  public class responseWrapper {
    public Map<String, String> parsing_errors;
    public Map<Id, Q_Item_Exception__c> dml_errors;
  }

  @TestVisible
  private static Boolean isTesting = false;
}