// TDH SIDE
public class MB_OppTrgHelper {
  public static void validateOppForBus(
    List<Opportunity> oppList,
    Map<Id, Opportunity> oldOppMap
  ) {
    System.debug('In ValidateOppForBus Method');

    List<Id> queList = new List<Id>();
    List<String> queGuidList = new List<String>();
    List<Opportunity> newOppList = new List<Opportunity>();
    List<String> oppId = new List<String>();

    for (Opportunity opp : oppList) {
      System.debug('Opp Id, LVN FIRST :::' + opp.Id + ' - ' + opp.isLVN__c);
      if (
        opp.StageName == 'Contracting' ||
        opp.StageName == 'Closed Won' ||
        opp.StageName == 'Closed Lost' ||
        opp.isLVN__c
      ) {
        oppId.add(opp.Id);
        newOppList.add(opp);
      }
    }
    if (newOppList.size() > 0 && MB_Recursive.isFirstTimeOpp) {
      MB_Recursive.isFirstTimeOpp = false;
      List<OpportunityLineItem> oppliList = [
        SELECT Id, OpportunityId
        FROM OpportunityLineItem
        WHERE OpportunityId IN :oppId AND Product2.Family LIKE '%Livongo%'
      ];
      Set<Id> oppIdSet = new Set<Id>();
      for (OpportunityLineItem oppli : oppliList) {
        oppIdSet.add(oppli.OpportunityId);
      }

      Msg_Bus_Fields__mdt fields = [
        SELECT Opportunity_Fields__c
        FROM Msg_Bus_Fields__mdt
        WHERE Parser_Name__c = 'Opportunity_Parser'
        LIMIT 1
      ];
      List<String> oppFields = fields.Opportunity_Fields__c.replaceAll(
          '\\s+',
          ''
        )
        .split(',');

      for (Opportunity opp : newOppList) {
        Opportunity oldOpp = oldOppMap.get(opp.Id);
        System.debug('Opp.isLVN__c' + opp.isLVN__c);
        if (opp.isLVN__c) {
          /*  //Bypassing this condition to meet G2LCRM Requirements
                    if ((oldOpp.StageName != 'Contracting' && oldOpp.StageName != 'Closed Won' && oldOpp.StageName != 'Closed Lost') && opp.StageName == 'Closed Won') {
                    opp.addError('Cannot move an Opportunity directly to Closed Won (cannot skip Contracting) if a Livongo product is on the Quote or its a Livongo Opportunity.');
                    } 
                    if (String.isBlank(opp.Leadsource)) {
                    opp.addError('Lead Source and Estimated Contracted Date is required for LVN Opportunity');
                    } */

          Boolean isUpdate = false;
          List<String> byPassList = new List<String>{
            'Primary_Carrier__r.Svc_Acct__r.GUID__c',
            'Parent_Opportunity__r.Sub_Type__c',
            'Parent_Opportunity__r.AccountId'
          };

          for (String field : oppFields) {
            if (
              !byPassList.contains(field) && opp.get(field) != oldOpp.get(field)
            ) {
              isUpdate = true;
              break;
            }
          }
          if (isUpdate) {
            queList.add(opp.Id);
            queGuidList.add(opp.Opp_Guid__c);
          }
          if (!oppIdSet.contains(opp.Id)) {
            opp.isLVN__c = false;
          }
        } else {
          if (oppIdSet.contains(opp.Id)) {
            /* //Bypassing this condition to meet G2LCRM Requirements
                        if ((oldOpp.StageName != 'Contracting' && oldOpp.StageName != 'Closed Won' && oldOpp.StageName != 'Closed Lost') && opp.StageName == 'Closed Won') {
                        opp.addError('Cannot move an Opportunity directly to Closed Won (cannot skip Contracting) if a Livongo product is on the Quote or its a Livongo Opportunity.');
                        } 
                        if (String.isBlank(opp.Leadsource)) {
                        opp.addError('Lead Source and Estimated Contracted Date is required for LVN Opportunity');
                        } */
            opp.isLVN__c = true;
            /*if ((oldOpp.GCRM_Process_Completed__c == true && opp.GCRM_Process_Completed__c == true && opp.StageName == 'Closed Won' && opp.isLVN__c == true) ||
                             (opp.Msg_Bus_Manual_Trigger__c == true)) {
                           queList.add(opp.Id);
                           queGuidList.add(opp.Opp_Guid__c);
                        } */
          }
        }
      }
      /* Moved this condition to trigger the Message Bus to a Lightning Flow
                * System.debug('queList ' + queList);
                System.debug('queGuidList ' + queGuidList);
                if (queList.size() > 0) {
                System.debug('Calling MB_OppToQItemBatch executeBatch');
                
                MB_OppToQItemBatch msgBusBch = new MB_OppToQItemBatch(queList);
                database.executebatch(msgBusBch, 10);
                } */
    }
  }

  public static void deleteOpp(List<Opportunity> oppList) {
    List<String> deleteList = new List<String>();
    for (Opportunity opp : oppList) {
      if (opp.isLVN__c) {
        deleteList.add(opp.Opp_Guid__c);
      }
    }
    if (deleteList.size() > 0) {
      List<System.JSONGenerator> genlist = new List<System.JSONGenerator>();
      for (String guid : deleteList) {
        genlist.add(MB_OppJSONGenerator.generateDeleteJSON(guid));
      }
      System.debug(genlist);
      MB_QXfr.CreateAsyncQItem('LVN', 'TDH', 'Delete_Parser', genlist);
    }
  }
}