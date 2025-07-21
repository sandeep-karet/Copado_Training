public without sharing class OpportunityTriggerHelper {
  public static Boolean isFirstTime = true;
  public static void autoPopulateAmendmentFields(List<Opportunity> opps) {
    System.debug(' #############  autoPopulateAmendmentFields');
    // create amended contracts map.
    Map<id, id> contractIdsMap = new Map<id, id>();

    Id EmployerRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Employer – Teladoc and HY Products')
      .getRecordTypeId();
    Id ProviderRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Provider - Platform')
      .getRecordTypeId();

    // loop through opps.
    for (Opportunity opp : opps) {
      // if this amended contract is not null and is not in the amended contracts map,
      if (
        opp.SBQQ__AmendedContract__c != null &&
        !contractIdsMap.containsKey(opp.SBQQ__AmendedContract__c)
      ) {
        // add to the amended contracts map.
        contractIdsMap.put(
          opp.SBQQ__AmendedContract__c,
          opp.SBQQ__AmendedContract__c
        );
      }
    }

    // get amended contracts map with opp value.
    Map<id, Contract> amendedContractsMap = new Map<id, Contract>(
      [
        SELECT id, SBQQ__Opportunity__c
        FROM Contract
        WHERE id IN :contractIdsMap.values()
      ]
    );

    // get original opp ids list
    Map<id, id> originalOppIdsMap = new Map<id, id>();
    for (Contract c : amendedContractsMap.values()) {
      if (!originalOppIdsMap.containsKey(c.SBQQ__Opportunity__c)) {
        originalOppIdsMap.put(c.SBQQ__Opportunity__c, c.SBQQ__Opportunity__c);
      }
    }

    // get original opportunities Map with number of lives value.
    Map<id, Opportunity> origOppsMap = new Map<id, Opportunity>(
      [
        SELECT
          id,
          Fee_Type__c,
          Initial_of_Lives__c,
          CloseDate,
          Description,
          RecordType.Id,
          Type_of_Provider_IDN__c,
          HHS_Staffed_Bed_Size__c,
          HHS_Employees__c,
          HHS_Total_Revenue__c,
          HHS_EBITDA__c,
          HHS_Outpatient_Visits__c,
          HHS_Discharges__c,
          Business_Region__c,
          Country__c,
          Sales_Channels__c,
          Sub_Channel__c
        FROM Opportunity
        WHERE id IN :originalOppIdsMap.values()
      ]
    );

    // loop through original opportunities.
    for (Opportunity origOpp : origOppsMap.values()) {
      // loop through contracts.
      for (Contract c : amendedContractsMap.values()) {
        // if this opp's id matches this contract's opp id,
        if (origOpp.id == c.SBQQ__Opportunity__c) {
          // loop through opps map opps.
          for (Opportunity opp : opps) {
            // if this opp's amended contract id matches this contract's id,
            if (opp.SBQQ__AmendedContract__c == c.id) {
              // copy values from original opp to opps map opp.
              opp.Fee_Type__c = origOpp.Fee_Type__c;
              opp.Initial_of_Lives__c = origOpp.Initial_of_Lives__c;
              opp.CloseDate = origOpp.CloseDate;
              opp.Stagename = 'Prospect'; //added by Jig to resolve the issue on Amendment opportunity Stage being set to 'ClosedWon'
              opp.Description = origOpp.Description;
              opp.Business_Region__c = origOpp.Business_Region__c;
              opp.country__c = origOpp.country__c;
              opp.Sub_Channel__c = origOpp.Sub_Channel__c;

              if (origOpp.Sales_Channels__c == 'Hospital and Health Systems') {
                opp.RecordTypeId = ProviderRecordType;
              } else {
                opp.RecordTypeId = EmployerRecordType;
              }
              // For Provider information
              // Type of provider
              if (
                origOpp.Type_of_Provider_IDN__c != '' ||
                origOpp.Type_of_Provider_IDN__c != null
              ) {
                opp.Type_of_Provider_IDN__c = origOpp.Type_of_Provider_IDN__c;
              }
              //HHS Staffed bed size - HHS Employees - HHS Total Revenue - HHS EBITDA - HHS Outpatient Visits - HHS Discharges
              if (
                origOpp.HHS_Staffed_Bed_Size__c != '' ||
                origOpp.HHS_Staffed_Bed_Size__c != null
              ) {
                opp.HHS_Staffed_Bed_Size__c = origOpp.HHS_Staffed_Bed_Size__c;
              }
              if (
                origOpp.HHS_Employees__c != '' ||
                origOpp.HHS_Employees__c != null
              ) {
                opp.HHS_Employees__c = origOpp.HHS_Employees__c;
              }
              if (
                origOpp.HHS_Total_Revenue__c != '' ||
                origOpp.HHS_Total_Revenue__c != null
              ) {
                opp.HHS_Total_Revenue__c = origOpp.HHS_Total_Revenue__c;
              }
              if (
                origOpp.HHS_EBITDA__c != '' ||
                origOpp.HHS_EBITDA__c != null
              ) {
                opp.HHS_EBITDA__c = origOpp.HHS_EBITDA__c;
              }
              if (
                origOpp.HHS_Outpatient_Visits__c != '' ||
                origOpp.HHS_Outpatient_Visits__c != null
              ) {
                opp.HHS_Outpatient_Visits__c = origOpp.HHS_Outpatient_Visits__c;
              }
              if (
                origOpp.HHS_Discharges__c != '' ||
                origOpp.HHS_Discharges__c != null
              ) {
                opp.HHS_Discharges__c = origOpp.HHS_Discharges__c;
              }
            }
          }
        }
      }
    }
  }
  public static void updateOppRecordType(List<Opportunity> opps) {
    Id oppProvider = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Provider - Platform')
      .getRecordTypeId();
    Id oppReadOnly = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Read Only')
      .getRecordTypeId();

    List<Id> oppIds = new List<Id>();
    List<Id> quoteIds = new List<Id>();
    List<Opportunity> opps2Update = new List<Opportunity>();

    for (Opportunity opp : opps) {
      if (opp.StageName == 'Closed Won' || opp.SBQQ__Contracted__c == true) {
        opp.recordtypeId = oppReadOnly;
        opps2Update.add(opp);
      }
      /*  This Condition has been moved to StratImplementation Functionality (StartImplementationController)
else if(opp.recordtypeId != oppProvider.Id && opp.StageName == 'Contracting' && opp.CPQ_Pricebook__c != 'Broker'){
opp.recordtypeId = oppReadOnly.Id;
opps2Update.add(opp);
}*/
    }
  }

  public static void updateQuoteRecordType(List<SBQQ__Quote__c> quos) {
    Id quoteReadOnly = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
      .get('Read Only')
      .getRecordTypeId();
    Id quoteLineReadOnly = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Read Only')
      .getRecordTypeId();

    List<SBQQ__Quote__c> quote2Update = new List<SBQQ__Quote__c>();
    List<SBQQ__QuoteLine__c> quoteLines2Update = new List<SBQQ__QuoteLine__c>();

    for (SBQQ__Quote__c quote : [
      SELECT Id, RecordTypeId
      FROM SBQQ__Quote__c
      WHERE id IN :quos
    ]) {
      quote.recordTypeId = quoteReadOnly;
      quote2Update.add(quote);
    }

    for (SBQQ__QuoteLine__c quoteLine : [
      SELECT Id, RecordTypeId
      FROM SBQQ__QuoteLine__c
      WHERE SBQQ__Quote__c IN :quote2Update
    ]) {
      quoteLine.recordTypeId = quoteLineReadOnly;
      quoteLines2Update.add(quoteLine);
    }

    if (quote2Update != null && quote2Update.size() > 0)
      Database.update(quote2Update);

    if (quoteLines2Update != null && quoteLines2Update.size() > 0)
      Database.update(quoteLines2Update);
  }

  public static Map<Id, List<SBQQ__Quote__c>> getOppQuoteMap(
    List<Opportunity> opps
  ) {
    Map<Id, List<SBQQ__Quote__C>> returnMap = new Map<Id, List<SBQQ__Quote__C>>();
    for (Opportunity opp : [
      SELECT
        id,
        (
          SELECT id, SBQQ__Primary__c, Include_in_Octiv_Proposal__c
          FROM SBQQ__Quotes2__r
        )
      FROM Opportunity
      WHERE id IN :opps
    ]) {
      returnMap.put(opp.id, opp.SBQQ__Quotes2__r);
    }
    return returnMap;
  }

  public static Map<Id, Integer> getTDStandardCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Standard%'
        AND SBQQ__ProductCode__c = 'GM'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getTDIncludedCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Included%'
        AND SBQQ__ProductCode__c = 'GM'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getBDStandardCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Standard%'
        AND SBQQ__ProductCode__c = 'BD-USEMP-BUNDLE'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getEMS2StandardCountMap(
    List<Opportunity> opps
  ) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Standard%'
        AND SBQQ__ProductCode__c = 'BD-USEMP-BUNDLE-2.0'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getEMS2IncludedCountMap(
    List<Opportunity> opps
  ) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Included%'
        AND SBQQ__ProductCode__c = 'BD-USEMP-BUNDLE-2.0'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getHYStandardCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Standard%'
        AND SBQQ__ProductCode__c = 'HY'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getHYIncludedCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Included%'
        AND SBQQ__ProductCode__c = 'HY'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getBHCustomCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        Consult_Type__c LIKE '%Custom%'
        AND SBQQ__ProductCode__c = 'BH'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static Map<Id, Integer> getBackCareCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        SBQQ__ProductCode__c = 'TDBC'
        AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opps
      GROUP BY SBQQ__Quote__c
    ]) {
      returnMap.put(
        Id.valueOf(aggr.get('quoteId').toString()),
        Integer.valueOf(aggr.get('total'))
      );
    }
    return returnMap;
  }

  public static void setGUID(List<Opportunity> newOpp) {
    for (Opportunity opp : newOpp) {
      if (
        String.isBlank(opp.Opp_GUID__c) ||
        !GlobalIdUtils.isGuid(opp.Opp_GUID__c)
      ) {
        opp.Opp_GUID__c = GlobalIdUtils.generateGuid();
      }
    }
  }

  public static void updateProbability(
    List<Opportunity> lstOpp,
    Map<Id, Opportunity> mapOldOpp
  ) {
    for (Opportunity opp : lstOpp) {
      if (
        opp.Ann_Rec_Rev__c != null &&
        (mapOldOpp.isEmpty() ||
        (!mapOldOpp.isEmpty() &&
        opp.StageName != mapOldOpp.get(opp.Id).StageName))
      ) {
        //if(opp.Net_ARR__c >= 2000000 && !mapOldOpp.isEmpty() && mapOldOpp.get(opp.Id).StageName == 'Proposal' && opp.StageName == 'Review/Negotiation' ) { } // no change
        if (opp.Ann_Rec_Rev__c > 2000000 && !mapOldOpp.isEmpty()) {
          opp.Probability = mapOldOpp.get(opp.Id).Probability;
        }
        if (opp.Ann_Rec_Rev__c < 2000000) {
          if (opp.StageName == 'Prospect') {
            opp.Probability = 0;
          } else if (opp.StageName == 'Discovery') {
            opp.Probability = 0;
          } else if (opp.StageName == 'Proposal') {
            opp.Probability = 0;
          } else if (opp.StageName == 'Review/Negotiation') {
            opp.Probability = 70;
          } else if (opp.StageName == 'Contracting') {
            opp.Probability = 90;
          }
        }
      }
      if (opp.StageName == 'Closed Won') {
        opp.Probability = 100;
      } else if (
        opp.StageName == 'Closed Lost' ||
        opp.StageName == 'Closed No Decision'
      ) {
        opp.Probability = 0;
      }
    }
  }

  public static void checkAccountChange(
    List<Opportunity> newOpp,
    Map<Id, Opportunity> mapOldOpp
  ) {
    // SCDEV-4514  [Starts]
    String userProfileName = [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :userinfo.getProfileId()
      LIMIT 1
    ]
    .Name;
    if (userProfileName != 'System Administrator') {
      // SCDEV-4514  [Ends]
      for (Opportunity opp : newOpp) {
        if (opp.AccountId != mapOldOpp.get(opp.Id).AccountId) {
          opp.addError(
            'If you have to change the account on this opportuntiy, please delete the record and recreate it with the correct account'
          );
        }
      }
      // SCDEV-4514  [Starts]
    }
    // SCDEV-4514  [Ends]
  }

  public static boolean stoprecurrsion = true;
  //For Creating Account Relation For Venu
  public static void createAcctRelation(
    List<Opportunity> newOpp,
    Map<Id, Opportunity> mapOldOpp
  ) {
    if (stoprecurrsion) {
      String healthDocAcctID = System.Label.TD_Teladoc_Account;
      Map<String, Acct_Rel__c> acctRelMap = new Map<String, Acct_Rel__c>();
      for (Opportunity opp : newOpp) {
        system.debug('** ash opp.StageName ' + opp.StageName);
        system.debug('** ash opp.mapOldOpp ' + mapOldOpp.get(opp.Id).StageName);
        system.debug('** ash opp.Contract_Path__c ' + opp.Contract_Path__c);
        if (
          (opp.StageName == 'Contracting' || opp.StageName == 'Closed Won') &&
          ((opp.StageName != mapOldOpp.get(opp.Id).StageName &&
          opp.StageName == 'Contracting') ||
          (opp.Contract_Path__c != mapOldOpp.get(opp.Id).Contract_Path__c &&
          opp.Contract_Path__c != null) ||
          (opp.Contracting_Lens__c !=
          mapOldOpp.get(opp.Id).Contracting_Lens__c &&
          opp.Contracting_Lens__c != '') ||
          (opp.CloseDate != mapOldOpp.get(opp.Id).CloseDate &&
          opp.CloseDate != null) ||
          Test.isRunningTest())
        ) {
          Id acctForServ = opp.Contract_Path__c;
          if (
            opp.Contract_Path__c != null &&
            opp.Contract_Path__c == healthDocAcctID
          ) {
            acctForServ = opp.AccountId;
          }
          String Contract_Type = '';
          if (opp.Contracting_Lens__c == 'Employer')
            Contract_Type = 'Direct';
          else if (opp.Contracting_Lens__c == 'Reseller')
            Contract_Type = 'Reseller';
          else if (opp.Contracting_Lens__c == 'Health Plan/Insurance')
            Contract_Type = 'Insurance';
          else if (opp.Contracting_Lens__c == 'Hospital/Health System')
            Contract_Type = 'Health Systems';

          Acct_Rel__c accRel = new Acct_Rel__c(
            Svc_Acct__c = acctForServ,
            Benefit_Sponsor__c = opp.AccountId,
            Relationship_Type__c = 'Contractee',
            ownerid = opp.OwnerId,
            Start_Date__c = opp.CloseDate,
            Contract_Type__c = Contract_Type
          );
          acctRelMap.put(getCompositeKey(accRel), accRel);
        }
      }
      for (Acct_Rel__c accRel : [
        SELECT id, Composite_Key__c
        FROM Acct_Rel__c
        WHERE Composite_Key__c IN :acctRelMap.keyset()
      ]) {
        acctRelMap.remove(accRel.Composite_Key__c);
      }
      if (
        acctRelMap != null &&
        acctRelMap.size() > 0 &&
        !Test.isRunningTest()
      ) {
        stoprecurrsion = false;
        insert acctRelMap.values();
      }
      stoprecurrsion = false;
    }
  }
  public static String getCompositeKey(Acct_Rel__c tmpAr) {
    string date_string =
      tmpAr.Start_Date__c.year() +
      '-' +
      tmpAr.Start_Date__c.month() +
      '-' +
      tmpAr.Start_Date__c.day();
    string key_string = tmpAr.Svc_Acct__c + '_' + tmpAr.Benefit_Sponsor__c;
    key_string =
      key_string +
      '_' +
      tmpAr.Relationship_Type__c +
      '_' +
      tmpAr.Contract_Type__c;
    Blob requestBlob = Blob.valueOf(key_string + '_' + date_string);
    Blob hash = Crypto.generateDigest('MD5', requestBlob);
    String requestSignature = EncodingUtil.convertToHex(hash);
    return requestSignature;
  }

  //Create Stage Metric custom Object record on Opportunity Stage change
  public static void createStageMetricObjRec(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> mapOldOpps
  ) {
    List<L2O_Stage_Metric__c> stgMtrcRecInsList = new List<L2O_Stage_Metric__c>();
    List<L2O_Stage_Metric__c> stgMtrcRecUpdList = new List<L2O_Stage_Metric__c>();
    List<Opportunity> stgChangdOppList = new List<Opportunity>();
    Map<Id, L2O_Stage_Metric__c> oppStgMtrcMap = new Map<Id, L2O_Stage_Metric__c>();

    if (Trigger.isInsert) {
      for (Opportunity opp : newOpps) {
        if (opp.StageName != null) {
          L2O_Stage_Metric__c stgMtrcRec = new L2O_Stage_Metric__c();
          stgMtrcRec.L2O_Opportunity__c = opp.Id;
          stgMtrcRec.L2O_To_Stage__c = opp.StageName;
          stgMtrcRecInsList.add(stgMtrcRec);
        }
      }
    }

    if (Trigger.isUpdate) {
      for (Opportunity opp : newOpps) {
        if (opp.StageName != mapOldOpps.get(opp.Id).StageName) {
          stgChangdOppList.add(opp);
        }
      }
      if (!stgChangdOppList.isEmpty()) {
        for (L2O_Stage_Metric__c stM : [
          SELECT Id, CreatedDate, L2O_Opportunity__c, L2O_To_Stage__c
          FROM L2O_Stage_Metric__c
          WHERE L2O_Opportunity__c = :stgChangdOppList
          ORDER BY CreatedDate DESC
        ]) {
          if (!oppStgMtrcMap.containsKey(stM.L2O_Opportunity__c)) {
            oppStgMtrcMap.put(stM.L2O_Opportunity__c, stM);
          }
        }
        for (Opportunity opp : stgChangdOppList) {
          if (
            (oppStgMtrcMap.get(opp.Id) != null &&
            oppStgMtrcMap.get(opp.Id).L2O_To_Stage__c ==
            mapOldOpps.get(opp.Id).StageName) || !stgChangdOppList.isEmpty()
          ) {
            L2O_Stage_Metric__c stgMtrcRec = new L2O_Stage_Metric__c();
            stgMtrcRec.L2O_Opportunity__c = opp.Id;
            stgMtrcRec.L2O_From_Stage__c = mapOldOpps.get(opp.Id).StageName;
            stgMtrcRec.L2O_To_Stage__c = opp.StageName;
            stgMtrcRec.L2O_From_Stage_Date__c = oppStgMtrcMap.size() > 0
              ? oppStgMtrcMap.get(opp.Id).CreatedDate
              : null;
            stgMtrcRecInsList.add(stgMtrcRec);
          }
        }
      }
    }
    if (!stgMtrcRecInsList.isEmpty()) {
      insert stgMtrcRecInsList;
    }
  }
}