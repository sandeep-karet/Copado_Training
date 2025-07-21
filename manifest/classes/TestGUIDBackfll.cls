public class TestGUIDBackfll {
  @future
  public static void GUIDBackFillMethod() {
    Map<String, List<G2LCRM_Item__c>> g2lcrmitemMap = new Map<String, List<G2lcrm_Item__c>>();
    List<G2LCRM_Item__c> gitems = new List<G2LCRM_Item__c>();
    List<G2LCRM_Item__c> updategitems = new List<G2LCRM_Item__c>();
    if (Test.isRunningTest()) {
      gitems = [
        SELECT id, MUID__C, Processor__c, Body__c
        FROM G2LCRM_item__c
        LIMIT 10
      ];
    } else {
      gitems = [
        SELECT id, MUID__C, Processor__c, Body__c
        FROM G2LCRM_item__c
      ];
    }
    for (G2LCRM_Item__c gitem : gitems) {
      if (g2lcrmitemMap.get(gitem.MUID__c) == null)
        g2lcrmitemMap.put(gitem.MUID__c, new List<G2LCRM_Item__c>{ gitem });
      else
        g2lcrmitemMap.get(gitem.MUID__c).add(gitem);
    }
    for (String muid : g2lcrmitemMap.Keyset()) {
      String accGUID;
      String oppGUID;
      String orderGUID;
      for (g2lcrm_Item__c gitem : g2lcrmitemMap.get(muid)) {
        Map<String, Object> body = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped(
            gitem.Body__c
          ))
          .get('body');
        if (body != null) {
          switch on gitem.Processor__c {
            when 'PreSale' {
              Map<String, Object> masterPayload = new Map<String, Object>();
              Map<String, Object> accountRecord = new Map<String, Object>();
              Map<String, Object> OpportunityRecord = new Map<String, Object>();
              masterPayload = (Map<String, Object>) ((Map<String, object>) JSON.deserializeUntyped(
                  gitem.Body__c
                ))
                .get('body');
              accountRecord = (Map<String, object>) masterPayload.get(
                'account'
              );
              opportunityRecord = (Map<String, Object>) masterPayload.get(
                'opportunity'
              );
              oppGUID = (String) opportunityRecord.get('opportunityGUID');
              accGUID = (String) accountRecord.get('accountGUID');
            }
            when 'accountV3' {
              Map<String, Object> accobj = new Map<String, Object>();
              accobj = (Map<String, Object>) body.get('account');
              accGUID = (String) accobj.get('accountGUID');
            }
            when 'orderV3' {
              Map<String, Object> untypedOrderRecords = new Map<String, Object>();
              untypedOrderRecords = (Map<String, Object>) body.get('order');
              Map<String, Object> quoteRec = (Map<String, Object>) untypedOrderRecords.get(
                'quote'
              );
              orderGUID = (String) untypedOrderRecords.get('orderGUID');
              List<Object> oppRecs = (List<Object>) untypedOrderRecords.get(
                'opportunities'
              );
              if (oppRecs != null && oppRecs.size() > 0) {
                Map<String, Object> oppObj = (Map<String, Object>) oppRecs[0];
                oppGUID = (String) oppObj.get('opportunityGUID');
              }
            }
          }
        }
      }
      for (g2lcrm_Item__c gitem2 : g2lcrmitemMap.get(muid)) {
        gitem2.Account_GUID__c = accGUID;
        gitem2.Order_GUID__c = orderGUID;
        gitem2.Opp_GUId__c = oppGUID;
      }
    }
    updategitems.addAll(gitems);
    update updategitems;
  }
}