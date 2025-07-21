// CORE PROCESS CLASSES (MOST LIKELY BE LVN SIDE)
public class MB_QXfr_Process {
  public static Map<String, Object> processQ(Q_Item__c qItem) {
    System.debug('In MB_QXfr_Process.Process Q');
    Map<String, Object> results = new Map<String, Object>();
    switch on qItem.Parser_Name__c {
      when 'Opportunity_Parser' {
        QItem_Opp_Parser qitemp = new QItem_Opp_Parser();
        qitemp.Parse(qItem.Payload__c);
        //System.debug('qitemp after parse() ' +qitemp );
        //System.debug('qitemp after parse(LVGO__UnitPrice__c) ' +qitemp.QItemOppli.oppliList[0].LVGO__UnitPrice__c );
        // System.debug('qitemp after parse(LVGO__Product_Participants__c) ' +qitemp.QItemOppli.oppliList[0].LVGO__Product_Participants__c );

        results = OpportunityParserProcess(qitemp, qItem.Id);
      }
      when 'Delete_Parser' {
        QItem_Opp_Parser qitemp = new QItem_Opp_Parser();
        qitemp.Parse(qItem.Payload__c);
        results = deleteOpp(qitemp, qItem.Id);
      }
      when else {
      }
    }
    return results;
  }

  public static Map<String, Object> OpportunityParserProcess(
    QItem_Opp_Parser qitemp,
    String qItemId
  ) {
    Map<String, Object> results = new Map<String, Object>();
    results.put('parsing_errors', null);
    results.put('dml_errors', null);
    results.put('lvn_acct_url', '');
    results.put('tdh_acct_id', '');
    results.put('lvn_opp_id', '');
    results.put('tdh_opp_id', '');
    Map<String, String> parsingErrors = new Map<String, String>();
    List<Q_Item_Exception__c> oldQEx = [
      SELECT Id
      FROM Q_Item_Exception__c
      WHERE Q_Item__c = :qItemId
    ];
    delete oldQEx;
    if (qitemp.QItemAcct != null && qitemp.QItemAcct.parsingErrors.size() > 0) {
      for (String error : qitemp.QItemAcct.parsingErrors.keyset()) {
        parsingErrors.put(
          'ACCOUNT_LEVEL_BAD_DATA',
          error + ' : ' + qitemp.QItemAcct.parsingErrors.get(error)
        );
      }
    }
    if (qitemp.QItemOpp != null && qitemp.QItemOpp.parsingErrors.size() > 0) {
      for (String error : qitemp.QItemOpp.parsingErrors.keyset()) {
        parsingErrors.put(
          'OPPORTUNITY_LEVEL_BAD_DATA',
          error + ' : ' + qitemp.QItemOpp.parsingErrors.get(error)
        );
      }
    }

    if (
      qitemp.QItemCarrierAcct != null &&
      qitemp.QItemCarrierAcct.parsingErrors.size() > 0
    ) {
      for (String error : qitemp.QItemCarrierAcct.parsingErrors.keyset()) {
        parsingErrors.put(
          'PRIMARY_CARRIER_ACCOUNT_LEVEL_BAD_DATA',
          error + ' : ' + qitemp.QItemCarrierAcct.parsingErrors.get(error)
        );
      }
    }

    if (
      qitemp.QItemOppli != null &&
      qitemp.QItemOppli.parsingErrors.size() > 0
    ) {
      for (String error : qitemp.QItemOppli.parsingErrors.keyset()) {
        parsingErrors.put(
          'PRODUCT_LEVEL_BAD_DATA',
          error + ' : ' + qitemp.QItemOppli.parsingErrors.get(error)
        );
      }
    }

    if (qitemp.QItemAcct.TdhAcctId != null) {
      results.put('tdh_acct_id', qitemp.QItemAcct.TdhAcctId);
      System.debug('TDH AccountId ' + qitemp.QItemAcct.TdhAcctId);
    }

    if (qitemp.QItemOpp.TdhOppId != null) {
      results.put('tdh_opp_id', qitemp.QItemOpp.TdhOppId);
    }

    if (parsingErrors.size() == 0) {
      system.debug('venu --- qitem' + qitemp);
      MB_QxfrUtils.FetchExistingData(qitemp, qItemId);
      LVGO__Account__c acct = new LVGO__Account__c();
      LVGO__Opportunity__c opp = new LVGO__Opportunity__c();

      if (MB_QxfrUtils.existingAcct == null) {
        acct = qitemp.QItemAcct.Acct;
        acct.Id = null;
        acct.LVGO__Source__c = 'TD';
        if (qitemp.QItemAcct.RecordType == 'Downmarket Client') {
          acct.RecordTypeId = MB_QxfrUtils.DownMarketId;
        }
        try {
          insert acct;
          results.put(
            'lvn_acct_url',
            URL.getOrgDomainUrl().toExternalForm() + '/' + acct.Id
          );
        } catch (exception e) {
          MB_QxfrUtils.LogException(
            qItemId,
            'LVGO__ACCOUNT__C',
            'DML_ERROR',
            'CANNOT_CREATE_LVGO__ACCOUNT__C',
            e.getMessage()
          );
          acct = null;
        }
      } else {
        acct = MB_QxfrUtils.existingAcct;
        Boolean isUpdateAcct = Account_Parser.CalculateDelta(
          qitemp.QItemAcct.fieldDeltas,
          qitemp.QItemAcct.Acct,
          acct
        );
        results.put(
          'lvn_acct_url',
          URL.getOrgDomainUrl().toExternalForm() + '/' + acct.Id
        );
        if (isUpdateAcct) {
          try {
            update acct;
          } catch (exception e) {
            MB_QxfrUtils.LogException(
              qItemId,
              'LVGO__ACCOUNT__C',
              'DML_ERROR',
              'CANNOT_UPDATE_LVGO__ACCOUNT__C',
              e.getMessage()
            );
          }
        }
      }

      if (acct != null) {
        if (MB_QxfrUtils.existingOpp == null) {
          system.debug(Opp.LVGO__Source_ID__c);
          opp = qitemp.QItemOpp.Opp;
          String StageValue = opp.LVGO__StageName__c;
          String lostReason = opp.LVGO__Loss_Reason__c;
          opp.Id = null;
          opp.LVGO__Account__c = acct.Id;
          opp.LVGO__Source__c = 'TD';
          opp.LVGO__StageName__c = 'Prospect';
          opp.LVGO__Lost_Reason__c = null;
          opp.LVGO__Pricebook2__c = MB_QxfrUtils.LvnPriceBookId;
          if (MB_QxfrUtils.contractAcct != null) {
            opp.LVGO__Pre_Contracting_Contract_Paper__c = MB_QxfrUtils.contractAcct.Id;
            opp.LVGO__BillingPartner__c = MB_QxfrUtils.contractAcct.Id;
            opp.LVGO__Contract_Path__c = MB_QxfrUtils.contractAcct.Id;
          } else {
            opp.LVGO__Pre_Contracting_Contract_Paper__c = MB_QxfrUtils.LvnAcct.Id;
            opp.LVGO__BillingPartner__c = MB_QxfrUtils.LvnAcct.Id;
            opp.LVGO__Contract_Path__c = MB_QxfrUtils.LvnAcct.Id;
          }

          try {
            insert opp;
            results.put('lvn_opp_id', opp.Id);
          } catch (exception e) {
            MB_QxfrUtils.LogException(
              qItemId,
              'LVGO__Opportunity__c',
              'DML_ERROR',
              'CANNOT_CREATE_LVGO__OPPORTUNITY__C',
              e.getMessage()
            );
            opp = null;
          }
          if (opp != null) {
            List<LVGO__OpportunityLineItem__c> oppliList = new List<LVGO__OpportunityLineItem__c>();
            for (
              LVGO__OpportunityLineItem__c oppli : MB_QxfrUtils.newOppli.values()
            ) {
              oppli.LVGO__Opportunity__c = opp.Id;
              oppliList.add(oppli);
            }
            Database.SaveResult[] sr = Database.insert(oppliList, false);
            for (Database.SaveResult rowSr : sr) {
              if (!rowSr.isSuccess()) {
                for (Database.Error rowError : rowSr.getErrors()) {
                  MB_QxfrUtils.LogException(
                    qItemId,
                    'LVGO__OpportunityLineItem__c',
                    'ERROR',
                    'CANNOT_INSERT_LVGO__OPPORTUNITYLINEITEM__C',
                    rowError.getMessage()
                  );
                }
              }
            }
            opp.LVGO__StageName__c = StageValue;
            opp.LVGO__Lost_Reason__c = lostReason;
            try {
              update opp;
              results.put('lvn_opp_id', opp.Id);
            } catch (exception e) {
              MB_QxfrUtils.LogException(
                qItemId,
                'LVGO__OPPORTUNITY__C',
                'DML_ERROR',
                'CANNOT_UPDATE_LVGO__OPPORTUNITY__C',
                e.getMessage()
              );
              opp = null;
            }
          }
        } else {
          opp = MB_QxfrUtils.existingOpp;
          Boolean isUpdateOpp = Opportunity_Parser.CalculateDelta(
            qitemp.QItemOpp.fieldDeltas,
            qitemp.QItemOpp.Opp,
            opp,
            acct
          );
          opp.LVGO__Source__c = 'TD';
          if (MB_QxfrUtils.contractAcct != null) {
            if (
              opp.LVGO__Pre_Contracting_Contract_Paper__c !=
              MB_QxfrUtils.contractAcct.Id ||
              opp.LVGO__BillingPartner__c != MB_QxfrUtils.contractAcct.Id
            ) {
              opp.LVGO__Pre_Contracting_Contract_Paper__c = MB_QxfrUtils.contractAcct.Id;
              opp.LVGO__BillingPartner__c = MB_QxfrUtils.contractAcct.Id;
              opp.LVGO__Contract_Path__c = MB_QxfrUtils.contractAcct.Id;
              isUpdateOpp = true;
            }
          } else {
            if (opp.LVGO__Contract_Path__c != MB_QxfrUtils.LvnAcct.Id) {
              isUpdateOpp = true;
            }
            opp.LVGO__Pre_Contracting_Contract_Paper__c = MB_QxfrUtils.LvnAcct.Id;
            opp.LVGO__BillingPartner__c = MB_QxfrUtils.LvnAcct.Id;
            opp.LVGO__Contract_Path__c = MB_QxfrUtils.LvnAcct.Id;
          }

          Boolean noProd = MB_QxfrUtils.newOppli.isEmpty();

          if (MB_QxfrUtils.existingOppli != null) {
            for (String key : MB_QxfrUtils.newOppli.keySet()) {
              if (MB_QxfrUtils.existingOppli.containsKey(key)) {
                MB_QxfrUtils.newOppli.remove(key);
                MB_QxfrUtils.existingOppli.remove(key);
              }
            }
          }
          for (
            LVGO__OpportunityLineItem__c oppli : MB_QxfrUtils.newOppli.values()
          ) {
            oppli.LVGO__Opportunity__c = opp.Id;
          }

          Database.SaveResult[] sr = Database.insert(
            MB_QxfrUtils.newOppli.values(),
            false
          );
          for (Database.SaveResult rowSr : sr) {
            if (!rowSr.isSuccess()) {
              for (Database.Error rowError : rowSr.getErrors()) {
                MB_QxfrUtils.LogException(
                  qItemId,
                  'OPPORTUNITYLINEITEM',
                  'ERROR',
                  'CANNOT_INSERT_OPPORTUNITYLINEITEM',
                  rowError.getMessage()
                );
              }
            }
          }

          if (MB_QxfrUtils.existingOppli != null) {
            List<LVGO__OpportunityLineItem__c> deleteOppliList = new List<LVGO__OpportunityLineItem__c>();
            for (
              List<LVGO__OpportunityLineItem__c> oppList : MB_QxfrUtils.existingOppli.values()
            ) {
              deleteOppliList.addAll(oppList);
            }
            Database.DeleteResult[] dr = Database.delete(
              deleteOppliList,
              false
            );
            for (Database.DeleteResult rowSr : dr) {
              if (!rowSr.isSuccess()) {
                for (Database.Error rowError : rowSr.getErrors()) {
                  MB_QxfrUtils.LogException(
                    qItemId,
                    'OPPORTUNITYLINEITEM',
                    'ERROR',
                    'CANNOT_DELETE_OPPORTUNITYLINEITEM',
                    rowError.getMessage()
                  );
                }
              }
            }
          }

          if (isUpdateOpp) {
            try {
              if (opp.LVGO__StageName__c == 'Closed Won' && noProd) {
                opp.LVGO__StageName__c = 'Closed Lost';
                opp.LVGO__Lost_Reason__c = 'Other';
                opp.LVGO__Opportunity_Update_Next_Step__c = 'No LVN Program in TD Opportuntiy';
              }
              update opp;
              results.put('lvn_opp_id', opp.Id);
            } catch (exception e) {
              MB_QxfrUtils.LogException(
                qItemId,
                'OPPORTUNITY',
                'DML_ERROR',
                'CANNOT_UPDATE_OPPORTUNITY',
                e.getMessage()
              );
            }
          }
        }
      }
    }
    MB_QxfrUtils.CommitDelta();

    Map<Id, Q_Item_Exception__c> qException = new Map<Id, Q_Item_Exception__c>(
      [
        SELECT Exception_Type__c, Short_Desc__c, SObject__c, Full_Desc__c
        FROM Q_Item_Exception__c
        WHERE Q_Item__c = :qItemId
      ]
    );
    results.put('dml_errors', qException);
    results.put('parsing_errors', parsingErrors);
    System.debug('Parsing_errors ' + parsingErrors);
    System.debug('dml_errors ' + qException);
    return results;
  }

  public static Map<String, Object> deleteOpp(
    QItem_Opp_Parser qitemp,
    String qItemId
  ) {
    Map<String, Object> results = new Map<String, Object>();
    results.put('parsing_errors', null);
    results.put('dml_errors', null);
    results.put('lvn_acct_url', '');
    results.put('tdh_acct_id', '');
    results.put('lvn_opp_id', '');
    results.put('tdh_opp_id', '');
    Map<String, String> parsingErrors = new Map<String, String>();
    List<Q_Item_Exception__c> oldQEx = [
      SELECT Id
      FROM Q_Item_Exception__c
      WHERE Q_Item__c = :qItemId
    ];
    delete oldQEx;
    if (qitemp == null || qitemp.parsingErrors.size() > 0) {
      parsingErrors.put(
        'BAD_ITEM_DATA',
        'The payload provided for [' + qItemId + '] was invalid.'
      );
    } else {
      List<LVGO__Opportunity__c> opp = [
        SELECT Id, LVGO__Contract__c
        FROM LVGO__Opportunity__c
        WHERE LVGO__TD_Opp_Guid__c = :qitemp.QItemOpp.Opp.LVGO__TD_Opp_Guid__c
      ];
      if (!opp.isEmpty()) {
        /*
                List<Relationship__c> rList = [SELECT Id FROM Relationship__c WHERE Opportunity_Partnership__c =: opp[0].Id OR Opportunity_Competition__c =: opp[0].Id];
                try {
                    Delete rList;
                } catch (exception e) {
                    MB_QxfrUtils.LogException(qItemId, 'RELATIONSHIP', 'DML_ERROR', 'CANNOT_DELETE_RELATIONSHIP', e.getMessage());
                }
                List<Contract> clientContract = [SELECT Id FROM Contract WHERE Id =: opp[0].ContractId];
                if(!clientContract.isEmpty()) {
                    List<Contract> programContract = [SELECT Id FROM Contract WHERE Client_Overview__c =: clientContract[0].Id];
                    if(!programContract.isEmpty()) {
                        try {
                            Delete programContract;
                        } catch (exception e) {
                            MB_QxfrUtils.LogException(qItemId, 'PROGRAM CONTRACT', 'DML_ERROR', 'CANNOT_DELETE_PROGRAMCONTRACT', e.getMessage());
                        }
                    }
                    try {
                        Delete clientContract;
                    } catch (exception e) {
                        MB_QxfrUtils.LogException(qItemId, 'CLIENT CONTRACT', 'DML_ERROR', 'CANNOT_DELETE_CLIENTCONTRACT', e.getMessage());
                    }
                }*/
        try {
          delete opp;
        } catch (exception e) {
          MB_QxfrUtils.LogException(
            qItemId,
            'OPPORTUNITY',
            'DML_ERROR',
            'CANNOT_DELETE_OPPORTUNITY',
            e.getMessage()
          );
        }
      }
    }
    MB_QxfrUtils.CommitDelta();
    Map<Id, Q_Item_Exception__c> qException = new Map<Id, Q_Item_Exception__c>(
      [
        SELECT Exception_Type__c, Short_Desc__c, SObject__c, Full_Desc__c
        FROM Q_Item_Exception__c
        WHERE Q_Item__c = :qItemId
      ]
    );
    results.put('dml_errors', qException);
    results.put('parsing_errors', parsingErrors);
    return results;
  }
}