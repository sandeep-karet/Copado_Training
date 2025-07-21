public without sharing class GlobalOppUtil {
  /*
   * 1. TD Standard and EMS (Must have both GM* Standard* and BD. No HY or GM Included...)
   * 2. TD Included and EMS (Must have both GM* Standard* and BD. No HY or GM Included...)
   * 3. EMS Standalone (BD products ONLY)
   * 4. Telehealth Services - TD Standard Only (TD products with GM Standard Only)
   * 5. Telehealth Services - TD Included Only (TD products with GM Included Only)
   * 6. Telehealth Services - Both TD Standard & TD Included (Uses 2 Quotes in one proposal: 1 GM Standard and 1: GM Included)
   * 7. Teleheath HY Standard - Uses HY Product + BH (As optional)
   * 8. Telehealth HY Included - Uses HY Product + BH (As optional)
   * 9. Telehealth Combined HY Standard - HY product + BD Core bundle + BH (As optional)
   * 10. Telehealth combined HY Included - HY Product + BD Core bundle + BH (As optional)
   */
  public static String validProposalTemplate(
    List<Opportunity> opps,
    boolean isTrigger
  ) {
    String errorMsg = null;
    Map<Id, Integer> tdStandardCountMap = GlobalOppUtil.getTDStandardCountMap(
      opps
    );
    Map<Id, Integer> tdIncludedCountMap = GlobalOppUtil.getTDIncludedCountMap(
      opps
    );
    Map<Id, Integer> bdStandardCountMap = GlobalOppUtil.getBDStandardCountMap(
      opps
    );
    Map<Id, Integer> ems2StandardCountMap = GlobalOppUtil.getEMS2StandardCountMap(
      opps
    );
    Map<Id, Integer> ems2IncludedCountMap = GlobalOppUtil.getEMS2IncludedCountMap(
      opps
    );
    //Map<Id,Integer> hyCountMap = OpportunityTriggerHelper.getHYCountMap(opps);
    Map<Id, Integer> hyOnPrinaryCountMap = GlobalOppUtil.getHYonPrimayCountMap(
      opps
    );
    Map<Id, Integer> hyStandardCountMap = GlobalOppUtil.getHYStandardCountMap(
      opps
    );
    Map<Id, Integer> hyIncludedCountMap = GlobalOppUtil.getHYIncludedCountMap(
      opps
    );
    Map<Id, Integer> bhCustomCountMap = GlobalOppUtil.getBHCustomCountMap(opps);
    Map<Id, Integer> myStrengthCountMap = GlobalOppUtil.getMSCountMap(opps);
    Map<Id, Integer> backCareCountMap = GlobalOppUtil.getBackCareCountMap(opps);

    Map<Id, List<SBQQ__Quote__c>> oppQuoteMap = GlobalOppUtil.getOppQuoteMap(
      opps
    );

    List<SBQQ__Quote__c> IncInOctivList = new List<SBQQ__Quote__c>();
    list<SBQQ__Quote__c> ExcFromOctivList = new List<SBQQ__Quote__c>();
    Map<Id, SBQQ__Quote__c> updateList = new Map<Id, SBQQ__Quote__c>();

    for (Opportunity opp : opps) {
      if (opp.Proposal_Template__c != null) {
        List<SBQQ__Quote__c> primaryQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> tdStandardQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> tdIncludedQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> ems2StandardQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> ems2IncludedQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> CombinedStandardQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> CombinedIncludedQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> hyStandardQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> hyIncludedQuotes = new List<SBQQ__Quote__c>();
        //List<SBQQ__Quote__c> CombinedHYStandardQuotes = new List<SBQQ__Quote__c>();
        //List<SBQQ__Quote__c> CombinedHYIncludedQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> hyCompleteQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> hyComplete2Quotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> hyOnPrimaryQuotes = new List<SBQQ__Quote__c>();

        for (SBQQ__Quote__c quote : oppQuoteMap.get(opp.id)) {
          Integer tdStandardCount = tdStandardCountMap.get(quote.id);
          Integer tdIncludedCount = tdIncludedCountMap.get(quote.id);
          //Integer bdStandardCount = bdStandardCountMap.get(quote.id);
          Integer ems2StandardCount = ems2StandardCountMap.get(quote.id);
          Integer ems2IncludedCount = ems2IncludedCountMap.get(quote.id);
          // Integer hyCount = hyCountMap.get(quote.id);
          Integer hyOnPrimaryCount = hyOnPrinaryCountMap.get(quote.id);
          Integer hyStandardCount = hyStandardCountMap.get(quote.id);
          Integer hyIncludedCount = hyIncludedCountMap.get(quote.id);
          Integer bhCustomCount = bhCustomCountMap.get(quote.id);
          Integer backCareCount = backCareCountMap.get(quote.id);
          Integer myStrengthCount = myStrengthCountMap.get(quote.id);

          System.debug('tdStandardCount' + tdStandardCount);
          System.debug('tdIndlucedCount' + tdIncludedCount);
          System.debug('ems2StandardCount' + ems2StandardCount);
          System.debug('ems2IncludedCount' + ems2IncludedCount);
          System.debug('hyStandardCount' + hyStandardCount);
          System.debug('hyIncludedCount' + hyIncludedCount);
          System.debug('bhCustomCount' + bhCustomCount);
          System.debug('backCareCount' + backCareCount);
          System.debug('myStrengthCount' + myStrengthCount);

          if (quote.sbqq__primary__c == true) {
            primaryQuotes.add(quote);
          }
          if (
            tdStandardCount > 0 &&
            (tdIncludedCount == null &&
            ems2StandardCount == null &&
            ems2IncludedCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            tdStandardQuotes.add(quote);
          }
          if (
            tdIncludedCount > 0 &&
            (tdStandardCount == null &&
            ems2StandardCount == null &&
            ems2IncludedCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            tdIncludedQuotes.add(quote);
          }
          if (
            ems2StandardCount > 0 &&
            (tdIncludedCount == null &&
            tdStandardCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            ems2StandardQuotes.add(quote);
          }
          if (
            ems2IncludedCount > 0 &&
            (tdIncludedCount == null &&
            tdStandardCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            ems2IncludedQuotes.add(quote);
          }
          if (
            (tdStandardCount > 0 && ems2StandardCount > 0) &&
            (tdIncludedCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            CombinedStandardQuotes.add(quote);
          }
          if (
            (tdIncludedCount > 0 && ems2IncludedCount > 0) &&
            (tdStandardCount == null &&
            hyStandardCount == null &&
            hyIncludedCount == null)
          ) {
            CombinedIncludedQuotes.add(quote);
          }
          if (
            hyStandardCount > 0 &&
            (tdIncludedCount == null &&
            tdStandardCount == null &&
            hyIncludedCount == null)
          ) {
            hyStandardQuotes.add(quote);
          }
          if (
            hyIncludedCount > 0 &&
            (tdIncludedCount == null &&
            tdStandardCount == null &&
            hyStandardCount == null &&
            bhCustomCount == null &&
            backCareCount == null)
          ) {
            hyIncludedQuotes.add(quote);
          }
          if (
            hyIncludedCount > 0 &&
            ems2IncludedCount > 0 &&
            myStrengthCount > 0 &&
            backCareCount > 0 &&
            (tdIncludedCount == null &&
            tdStandardCount == null &&
            hyStandardCount == null)
          ) {
            hyComplete2Quotes.add(quote);
          }
          if (hyOnPrimaryCount > 0) {
            hyOnPrimaryQuotes.add(quote);
          }
        }

        System.debug('tdStandardQuotes Size' + tdStandardQuotes.size());
        System.debug('tdIncludedQuotes' + tdIncludedQuotes.size());
        System.debug('ems2StandardQuotes' + ems2StandardQuotes.size());
        System.debug('ems2IncludedQuotes' + ems2IncludedQuotes.size());
        System.debug('CombinedStandardQuotes' + CombinedStandardQuotes.size());
        System.debug('CombinedIncludedQuotes' + CombinedIncludedQuotes.size());
        System.debug('hyStandardQuotes' + hyStandardQuotes.size());
        System.debug('hyIncludedQuotes' + hyIncludedQuotes.size());
        System.debug('hyCompleteQuotes' + hyComplete2Quotes.size());

        if (opp.Proposal_Template__c == 'Dynamic Proposal on Primary Quote') {
          if (primaryQuotes != null && primaryQuotes.size() > 0) {
            //Added this condition to restrict Dynamic Proposal if there is EMS Standard is present on the Quote.
            // COP-1641
            if (
              ems2StandardQuotes.size() > 0 ||
              CombinedStandardQuotes.size() > 0 ||
              hyOnPrimaryQuotes.size() > 0
            ) {
              errorMsg = 'Dynamic Proposal NOT available for EMS Standard Consult and HY Products';
              if (isTrigger)
                opp.Proposal_Template__c.addError(
                  'Dynamic Proposal NOT available for EMS Standard Consult and HY Products'
                );
            } else {
              IncInOctivList.addAll(primaryQuotes);
              ExcFromOctivList.addAll(tdStandardQuotes);
              ExcFromOctivList.addAll(tdIncludedQuotes);
              ExcFromOctivList.addAll(ems2StandardQuotes);
              ExcFromOctivList.addAll(ems2IncludedQuotes);
              ExcFromOctivList.addAll(CombinedStandardQuotes);
              ExcFromOctivList.addAll(CombinedIncludedQuotes);
              ExcFromOctivList.addAll(hyStandardQuotes);
              ExcFromOctivList.addAll(hyIncludedQuotes);
              ExcFromOctivList.addAll(hyCompleteQuotes);
              ExcFromOctivList.addAll(hyComplete2Quotes);
            }
          } else {
            errorMsg = 'Invalid product data for Proposal Template';
            if (isTrigger)
              opp.Proposal_Template__c.addError('Error:Invalid data');
          }
        } else if (
          opp.Proposal_Template__c ==
          'Telehealth Services - Both TD Standard & TD Included'
        ) {
          if (
            (tdStandardQuotes != null && tdStandardQuotes.size() > 0) &&
            (tdIncludedQuotes != null &&
            tdIncludedQuotes.size() > 0)
          ) {
            // Mark Octiv Proposal checkbox
            IncInOctivList.addAll(tdIncludedQuotes);
            IncInOctivList.addAll(tdStandardQuotes);
            ExcFromOctivList.addAll(primaryQuotes);
            ExcFromOctivList.addAll(ems2StandardQuotes);
            ExcFromOctivList.addAll(ems2IncludedQuotes);
            ExcFromOctivList.addAll(CombinedStandardQuotes);
            ExcFromOctivList.addAll(CombinedIncludedQuotes);
            ExcFromOctivList.addAll(hyStandardQuotes);
            ExcFromOctivList.addAll(hyIncludedQuotes);
            ExcFromOctivList.addAll(hyCompleteQuotes);
            ExcFromOctivList.addAll(hyComplete2Quotes);
          } else {
            errorMsg = 'Invalid product data for Proposal Template';
            if (isTrigger)
              opp.Proposal_Template__c.addError('Error:Invalid data');
          }
        } else if (opp.Proposal_Template__c == 'HY Core Bundle Standard') {
          System.debug('HY Core Bundle Standard');
          if (hyStandardQuotes != null && hyStandardQuotes.size() > 0) {
            //Mark Octiv Proposal checkbox
            IncInOctivList.addAll(hyStandardQuotes);
            ExcFromOctivList.addAll(hyIncludedQuotes);
            ExcFromOctivList.addAll(tdStandardQuotes);
            ExcFromOctivList.addAll(tdIncludedQuotes);
            ExcFromOctivList.addAll(CombinedStandardQuotes);
            ExcFromOctivList.addAll(CombinedIncludedQuotes);
            ExcFromOctivList.addAll(hyCompleteQuotes);
            ExcFromOctivList.addAll(hyComplete2Quotes);
          } else {
            errorMsg = 'Invalid product data for Proposal Template';
            if (isTrigger)
              opp.Proposal_Template__c.addError('Error:Invalid data');
          }
        } else if (opp.Proposal_Template__c == 'HY Core Bundle Included') {
          System.debug('HY Core Bundle Included');
          if (hyIncludedQuotes != null && hyIncludedQuotes.size() > 0) {
            // Mark Octiv Proposal checkbox
            IncInOctivList.addAll(hyIncludedQuotes);
            ExcFromOctivList.addAll(hyStandardQuotes);
            ExcFromOctivList.addAll(tdStandardQuotes);
            ExcFromOctivList.addAll(tdIncludedQuotes);
            ExcFromOctivList.addAll(CombinedStandardQuotes);
            ExcFromOctivList.addAll(CombinedIncludedQuotes);
            ExcFromOctivList.addAll(hyCompleteQuotes);
            ExcFromOctivList.addAll(hyComplete2Quotes);
          } else {
            errorMsg = 'Invalid product data for Proposal Template';
            if (isTrigger)
              opp.Proposal_Template__c.addError('Error:Invalid data');
          }
        } else if (opp.Proposal_Template__c == 'HY Complete Bundle 3.0') {
          System.debug('HY Complete Bundle 3.0');
          if (hyComplete2Quotes != null && hyComplete2Quotes.size() > 0) {
            // Mark Octiv Proposal checkbox
            IncInOctivList.addAll(hyComplete2Quotes);
            ExcFromOctivList.addAll(hyCompleteQuotes);
            ExcFromOctivList.addAll(hyIncludedQuotes);
            ExcFromOctivList.addAll(hyStandardQuotes);
            ExcFromOctivList.addAll(tdStandardQuotes);
            ExcFromOctivList.addAll(tdIncludedQuotes);
            ExcFromOctivList.addAll(CombinedStandardQuotes);
            ExcFromOctivList.addAll(CombinedIncludedQuotes);
          } else {
            errorMsg = 'Invalid product data for Proposal Template';
            if (isTrigger)
              opp.Proposal_Template__c.addError('Error:Invalid data');
          }
        }
      }
    }

    System.debug('Exclude List ' + ExcFromOctivList);
    System.debug('Inlucde List ' + IncInOctivList);

    if (ExcFromOctivList != null && ExcFromOctivList.size() > 0) {
      for (SBQQ__Quote__c quote : ExcFromOctivList) {
        quote.Include_in_Octiv_Proposal__c = false;
        updateList.put(quote.Id, quote);
      }
    }
    if (IncInOctivList != null && IncInOctivList.size() > 0) {
      for (SBQQ__Quote__c quote : IncInOctivList) {
        quote.Include_in_Octiv_Proposal__c = true;
        updateList.put(quote.Id, quote);
      }
    }

    if (updateList != null & updateList.size() > 0) {
      update updateList.Values();
    }
    return errorMsg;
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

  public static Map<Id, Integer> getHYonPrimayCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        SBQQ__Quote__r.SBQQ__Primary__c = TRUE
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

  public static Map<Id, Integer> getMSCountMap(List<Opportunity> opps) {
    Map<Id, Integer> returnMap = new Map<Id, Integer>();
    for (AggregateResult aggr : [
      SELECT count(id) total, SBQQ__Quote__c quoteId
      FROM SBQQ__Quoteline__c
      WHERE
        SBQQ__ProductCode__c = 'MYSTR3'
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
}