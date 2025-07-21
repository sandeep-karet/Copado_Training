public class QuoteTriggerHelper {
  public static void setAmendmentCPQPricebookAndCarrier(
    List<SBQQ__Quote__c> roQuotes
  ) {
    //Map<id, SBQQ__Quote__c> quotesMap = new Map<id, SBQQ__Quote__c>([select id, SBQQ__Type__c, CPQ_Pricebook__c, Opt_In__c, SBQQ__Opportunity2__c from SBQQ__Quote__c where id in :roQuotesMap.keySet()]);
    //System.debug('QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quotes size: '+quotesMap.size());

    Map<id, SBQQ__Quote__c> quotesToUpdateMap = new Map<id, SBQQ__Quote__c>();

    // get opp ids.
    List<id> oppIds = new List<id>();
    for (SBQQ__Quote__c q : roQuotes) {
      if (q.SBQQ__Opportunity2__c != null) {
        oppIds.add(q.SBQQ__Opportunity2__c);
      }
    }
    System.debug(
      'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): opp ids size: ' +
      oppIds.size()
    );

    // retrieve opp information needed to retrieve old CPQ Pricebook and Carrier.
    Map<id, Opportunity> oppsMap = new Map<id, Opportunity>(
      [
        SELECT
          id,
          SBQQ__AmendedContract__c,
          SBQQ__RenewedContract__c,
          SBQQ__PrimaryQuote__c
        FROM Opportunity
        WHERE id IN :oppIds
      ]
    );
    System.debug(
      'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): opps size: ' +
      oppsMap.size()
    );

    // fill amended and renewed Contract id lists.
    List<id> amendedContractIds = new List<id>();
    List<id> renewedContractIds = new List<id>();
    for (Opportunity o : oppsMap.values()) {
      if (o.SBQQ__AmendedContract__c != null) {
        amendedContractIds.add(o.SBQQ__AmendedContract__c);
      }

      if (o.SBQQ__RenewedContract__c != null) {
        renewedContractIds.add(o.SBQQ__RenewedContract__c);
      }
    }
    System.debug(
      'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): amended contract ids size: ' +
      amendedContractIds.size()
    );
    System.debug(
      'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): renewed contract ids size: ' +
      renewedContractIds.size()
    );

    // retrieve amended Contract information using the above list.
    List<Contract> amendedContracts = new List<Contract>();
    if (amendedContractIds.size() > 0) {
      amendedContracts = [
        SELECT
          id,
          CPQ_Pricebook__c,
          Sales_Channels__c,
          Carrier__c,
          Line_of_Business__c,
          opt_in__c,
          Pricing_Model__c,
          HealthPlan_Opt_In__c,
          Insurance_Company__c,
          Insurance_Policy__c,
          Quote_Record_Type_Id__c,
          Type_of_Provider_IDN__c,
          HHS_Staffed_Bed_Size__c,
          HHS_Employees__c,
          HHS_Total_Revenue__c,
          HHS_EBITDA__c,
          HHS_Outpatient_Visits__c,
          HHS_Discharges__c,
          Business_Region__c,
          Channel_Rate__c
        FROM Contract
        WHERE id IN :amendedContractIds
      ];
      System.debug(
        'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): amended contracts size: ' +
        amendedContracts.size()
      );

      // loop through Amended Contracts.
      for (Contract c : amendedContracts) {
        System.debug(
          'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract: ' +
          c.id
        );
        // loop through Opps.
        for (Opportunity o : oppsMap.values()) {
          System.debug(
            'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): opp: ' +
            o.id
          );
          System.debug(
            'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): opp amended contract: ' +
            o.SBQQ__AmendedContract__c
          );
          // if this Opp's Amended Contract matches this Amended Contract,
          if (o.SBQQ__AmendedContract__c == c.id) {
            // loop through Quotes.
            for (SBQQ__Quote__c q : roQuotes) {
              System.debug(
                'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote: ' +
                q.id
              );
              System.debug(
                'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): opp primary quote: ' +
                o.SBQQ__PrimaryQuote__c
              );
              // if this Opp's Primary Quote matches this Quote,
              if (o.id == q.SBQQ__Opportunity2__c) {
                boolean foundQuote = false;
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote cpq pricebook: ' +
                  q.CPQ_Pricebook__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract cpq pricebook: ' +
                  c.CPQ_Pricebook__c
                );
                // set the Quote's CPQ Pricebook and Carrier if they're null.
                if (q.CPQ_Pricebook__c == null || q.CPQ_Pricebook__c == '') {
                  q.CPQ_Pricebook__c = c.CPQ_Pricebook__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Sales Channels: ' +
                  q.Sales_Channels__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Sales Channels: ' +
                  c.Sales_Channels__c
                );
                // set the Quote's CPQ Pricebook, Sales Channels and Carrier if they're null.
                if (q.Sales_Channels__c == null || q.Sales_Channels__c == '') {
                  q.Sales_Channels__c = c.Sales_Channels__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Carrier__c: ' +
                  q.Carrier__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Carrier__c: ' +
                  c.Carrier__c
                );
                if (q.Carrier__c == null || q.Carrier__c == '') {
                  q.Carrier__c = c.Carrier__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Line_of_Business__c: ' +
                  q.Line_of_Business__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Line_of_Business__c: ' +
                  c.Line_of_Business__c
                );
                // set the Quote's Line of Bussiness if they're null.
                if (
                  q.Line_of_Business__c == null ||
                  q.Line_of_Business__c == ''
                ) {
                  q.Line_of_Business__c = c.Line_of_Business__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Opt_In__c: ' +
                  q.Opt_In__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Opt_In__c: ' +
                  c.Opt_In__c
                );
                // set the Quote's Opt In if they're null.
                if (q.Opt_In__c == null || q.Opt_In__c == '') {
                  q.Opt_In__c = c.Opt_In__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote HealthPlan_Opt_In__c: ' +
                  q.HealthPlan_Opt_In__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract HealthPlan_Opt_In__c: ' +
                  c.HealthPlan_Opt_In__c
                );
                // set the Quote's HealthPlan Opt In if they're null.
                if (
                  q.HealthPlan_Opt_In__c == null ||
                  q.HealthPlan_Opt_In__c == ''
                ) {
                  q.HealthPlan_Opt_In__c = c.HealthPlan_Opt_In__c;
                  foundQuote = true;
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Pricing_Model__c: ' +
                  q.Pricing_Model__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Pricing_Model__c: ' +
                  c.Pricing_Model__c
                );
                // set the Quote's Pricing Model if they're null.
                if (q.Pricing_Model__c == null || q.Pricing_Model__c == '') {
                  q.Pricing_Model__c = c.Pricing_Model__c;
                  foundQuote = true;
                }
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Insurance_Company__c: ' +
                  q.Insurance_Company__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Insurance_Company__c: ' +
                  c.Insurance_Company__c
                );
                // set the Quote's Insurance Company if they're null.
                if (
                  q.Insurance_Company__c == null ||
                  q.Insurance_Company__c == ''
                ) {
                  q.Insurance_Company__c = c.Insurance_Company__c;
                  foundQuote = true;
                }
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Insurance_Company__c: ' +
                  q.Insurance_Policy__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Insurance_Company__c: ' +
                  c.Insurance_Policy__c
                );
                // set the Quote's Insurance Policy if they're null.
                if (
                  q.Insurance_Policy__c == null ||
                  q.Insurance_Policy__c == ''
                ) {
                  q.Insurance_Policy__c = c.Insurance_Policy__c;
                  foundQuote = true;
                }
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote Business_Region__c: ' +
                  q.Business_Region__c
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Business_Region__c: ' +
                  c.Business_Region__c
                );
                // set the Quote's Insurance Policy if they're null.
                if (
                  q.Business_Region__c == null ||
                  q.Business_Region__c == ''
                ) {
                  q.Business_Region__c = c.Business_Region__c;
                  foundQuote = true;
                }

                // set the Channel Rate on quote
                if (c.Channel_Rate__c != null || c.Channel_Rate__c != '') {
                  q.Channel_Rate__c = c.Channel_Rate__c;
                  foundQuote = true;
                }
                //Use Direct pricebook for all Cross--sell opportunities on amendment
                if (q.CPQ_Pricebook__c == 'Cross-Sell') {
                  q.CPQ_Pricebook__c = 'Direct';
                }

                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): quote RecordTypeId: ' +
                  q.RecordTypeId
                );
                System.debug(
                  'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): contract Quote_Record_Type_Id__c: ' +
                  c.Quote_Record_Type_Id__c
                );
                // set the Quote's Record Type if they're null.
                if (
                  q.RecordType.Id == null ||
                  q.RecordType.Id == '' ||
                  q.RecordType.Id != c.Quote_Record_Type_Id__c
                ) {
                  q.RecordTypeId = c.Quote_Record_Type_Id__c;
                  foundQuote = true;
                }

                if (foundQuote && !quotesToUpdateMap.containsKey(q.id)) {
                  System.debug(
                    'QuoteTriggerHelper.setAmendmentCPQPricebookAndCarrier(): putting quote: ' +
                    q.id
                  );
                  quotesToUpdateMap.put(q.id, q);
                }
              }
            }
          }
        }
      }
    }

    // retrieve renewed Contract information using the above list.
    List<Contract> renewedContracts = new List<Contract>();
    if (renewedContractIds.size() > 0) {
      renewedContracts = [
        SELECT
          id,
          CPQ_Pricebook__c,
          Sales_Channels__c,
          Carrier__c,
          Line_of_Business__c,
          opt_in__c,
          Pricing_Model__c,
          HealthPlan_Opt_In__c,
          Insurance_Company__c,
          Insurance_Policy__c,
          Channel_Rate__c
        FROM Contract
        WHERE id IN :renewedContractIds
      ];

      // loop through Renewed Contracts.
      for (Contract c : renewedContracts) {
        // loop through Opps.
        for (Opportunity o : oppsMap.values()) {
          // if this Opp's Renewed Contract matches this Renewed Contract,
          if (o.SBQQ__RenewedContract__c == c.id) {
            // loop through Quotes.
            for (SBQQ__Quote__c q : roQuotes) {
              // if this Opp's Primary Quote matches this Quote,
              if (o.SBQQ__PrimaryQuote__c == q.id) {
                boolean foundQuote = false;
                // set the Quote's CPQ Pricebook and Carrier if they're null.
                if (q.CPQ_Pricebook__c == null || q.CPQ_Pricebook__c == '') {
                  q.CPQ_Pricebook__c = c.CPQ_Pricebook__c;
                  foundQuote = true;
                }

                // set the Quote's CPQ Pricebook if they're null.
                if (q.Sales_Channels__c == null || q.Sales_Channels__c == '') {
                  q.Sales_Channels__c = c.Sales_Channels__c;
                  foundQuote = true;
                }
                // set the Quote's Carrier if they're null.
                if (q.Carrier__c == null || q.Carrier__c == '') {
                  q.Carrier__c = c.Carrier__c;
                  foundQuote = true;
                }
                // set the Quote's Line of Bussines if they're null.
                if (
                  q.Line_of_Business__c == null ||
                  q.Line_of_Business__c == ''
                ) {
                  q.Line_of_Business__c = c.Line_of_Business__c;
                  foundQuote = true;
                }
                // set the Quote's Opt In if they're null.
                if (q.Opt_In__c == null || q.Opt_In__c == '') {
                  q.Opt_In__c = c.Opt_In__c;
                  foundQuote = true;
                }
                // set the Quote's HealthPlan Opt In if they're null.
                if (
                  q.HealthPlan_Opt_In__c == null ||
                  q.HealthPlan_Opt_In__c == ''
                ) {
                  q.HealthPlan_Opt_In__c = c.HealthPlan_Opt_In__c;
                  foundQuote = true;
                }
                // set the Quote's Pricing Model if they're null.
                if (q.Pricing_Model__c == null || q.Pricing_Model__c == '') {
                  q.Pricing_Model__c = c.Pricing_Model__c;
                  foundQuote = true;
                }
                // set the Quote's Insurance Company if they're null.
                if (
                  q.Insurance_Company__c == null ||
                  q.Insurance_Company__c == ''
                ) {
                  q.Insurance_Company__c = c.Insurance_Company__c;
                  foundQuote = true;
                }
                // set the Quote's Insurance Policy if they're null.
                if (
                  q.Insurance_Policy__c == null ||
                  q.Insurance_Policy__c == ''
                ) {
                  q.Insurance_Policy__c = c.Insurance_Policy__c;
                  foundQuote = true;
                }
                // set the Channel Rate on quote
                if (c.Channel_Rate__c != null || c.Channel_Rate__c != '') {
                  q.Channel_Rate__c = c.Channel_Rate__c;
                  foundQuote = true;
                }
                if (foundQuote && !quotesToUpdateMap.containsKey(q.id)) {
                  quotesToUpdateMap.put(q.id, q);
                }
              }
            }
          }
        }
      }
    }

    if (quotesToUpdateMap.size() > 0) {
      // commented out because this happens before insert.
      //update quotesToUpdateMap.values();
    }
  }

  public static void addMissingFeeProductsToAmendments(
    Map<id, SBQQ__QuoteLine__c> quoteLinesMap
  ) {
    // get quote lines list from quote line ids.
    List<SBQQ__QuoteLine__c> quoteLines = [
      SELECT
        id,
        SBQQ__Quote__c,
        SBQQ__Number__c,
        SBQQ__Product__c,
        SBQQ__Quantity__c,
        Consult_Type__c
      FROM SBQQ__QuoteLine__c
      WHERE id IN :quoteLinesMap.keySet()
    ];

    // get quote/product ids from quote lines.
    Map<id, id> quoteIdsMap = new Map<id, id>();
    Map<id, id> productIdsMap = new Map<id, id>();
    for (SBQQ__QuoteLine__c ql : quoteLines) {
      if (!quoteIdsMap.containsKey(ql.SBQQ__Quote__c)) {
        quoteIdsMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__c);
      }
      if (!productIdsMap.containsKey(ql.SBQQ__Product__c)) {
        productIdsMap.put(ql.SBQQ__Product__c, ql.SBQQ__Product__c);
      }
    }
    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote ids map size: ' +
      quoteIdsMap.size()
    );
    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): product ids map size: ' +
      productIdsMap.size()
    );

    // get quotes for these quote ids.
    List<SBQQ__Quote__c> quotes = [
      SELECT id, SBQQ__Type__c
      FROM SBQQ__Quote__c
      WHERE id IN :quoteIdsMap.values()
    ];
    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quotes size: ' +
      quotes.size()
    );

    // get product options from quote line products.
    List<SBQQ__ProductOption__c> productOptions = [
      SELECT id, SBQQ__OptionalSKU__c, SBQQ__ConfiguredSKU__c, SBQQ__Bundled__c
      FROM SBQQ__ProductOption__c
      WHERE SBQQ__ConfiguredSKU__c IN :productIdsMap.values()
    ];
    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): product options size: ' +
      productOptions.size()
    );

    // create quote lines to insert list.
    List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();

    // create quote lines to update list.
    List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

    // loop through quotes.
    for (SBQQ__Quote__c q : quotes) {
      System.debug(
        'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote: ' + q.id
      );
      // if this quote is an amendment,
      if (q.SBQQ__Type__c == 'Amendment') {
        // create quote number double.
        double quoteNumber = 1;

        // loop through quote lines.
        for (SBQQ__QuoteLine__c ql : quoteLines) {
          System.debug(
            'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote line: ' +
            ql.id
          );
          // if this quote line's quote matches this quote's id,
          if (ql.SBQQ__Quote__c == q.id) {
            // set number of quote line.
            ql.SBQQ__Number__c = quoteNumber;

            // add old quote line to quote lines to update list.
            quoteLinesToUpdate.add(ql);

            // increment quote number.
            quoteNumber++;

            // loop through product options.
            for (SBQQ__ProductOption__c po : productOptions) {
              // if this quote line's product matches this product option's configured sku,
              if (ql.SBQQ__Product__c == po.SBQQ__ConfiguredSKU__c) {
                // add new quote line with optional sku to quote.
                SBQQ__QuoteLine__c newQl = new SBQQ__QuoteLine__c();
                newQl.SBQQ__Quote__c = q.id;
                newQl.SBQQ__RequiredBy__c = ql.id;
                newQl.SBQQ__ProductOption__c = po.id;
                newQl.SBQQ__Product__c = po.SBQQ__OptionalSKU__c;
                newQl.SBQQ__Quantity__c = ql.SBQQ__Quantity__c;
                newQl.Consult_Type__c = ql.Consult_Type__c;

                // required fields to show hierarchy properly
                newQl.SBQQ__OptionType__c = 'Component';
                newQl.SBQQ__Number__c = quoteNumber;
                newQl.SBQQ__PriorQuantity__c = null;
                newQl.SBQQ__Bundled__c = po.SBQQ__Bundled__c;
                newQl.SBQQ__NonDiscountable__c = true;
                newQl.SBQQ__NonPartnerDiscountable__c = true;
                newQl.SBQQ__OptionLevel__c = 1;
                newQl.SBQQ__BundledQuantity__c = 1;

                // add new quote line to quote lines to insert list.
                quoteLinesToInsert.add(newQl);

                // increment quote number.
                quoteNumber++;
              }
            }
          }
        }
      }
    }

    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote lines to insert size: ' +
      quoteLinesToInsert.size()
    );
    // if we have quote lines to insert,
    if (quoteLinesToInsert.size() > 0) {
      // insert quote lines to insert.
      insert quoteLinesToInsert;
    }

    System.debug(
      'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote lines to update size: ' +
      quoteLinesToUpdate.size()
    );
    // if we have quote lines to update,
    if (quoteLinesToUpdate.size() > 0) {
      // update quote lines to update.
      update quoteLinesToUpdate;
    }
  }

  public static void QuoteUpdateOpp(
    List<SBQQ__Quote__c> roQuotes,
    Map<Id, SBQQ__Quote__c> oldQuoteMap
  ) {
    Set<ID> oppIds = new Set<Id>();
    for (SBQQ__Quote__c q : roQuotes) {
      oppIds.add(q.SBQQ__opportunity2__c);
    }

    Map<Id, opportunity> opp2update = new Map<Id, Opportunity>();

    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
      [SELECT id, CloseDate FROM Opportunity WHERE id IN :oppIds]
    );
	
    for (SBQQ__Quote__c q : roQuotes) {
      if (q.sbqq__startDate__c != oldQuoteMap.get(q.id).SBQQ__startDate__c) {
        Opportunity opp = opportunityMap.get(q.sbqq__opportunity2__c);
        if (q.Sbqq__startDate__c != null) {
          opp.CloseDate = q.Sbqq__startDate__c;
          opp2update.put(opp.id, opp);
        }
      }
    }
    if (opp2update != null && opp2update.size() > 0) {
      update opp2update.values();
    }
  }
}