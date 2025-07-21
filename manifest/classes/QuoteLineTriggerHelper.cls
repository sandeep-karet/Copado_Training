public class QuoteLineTriggerHelper {
  public static boolean runAddMissingFeeProductsToAmendments = true;

  public static void addMissingFeeProductsToAmendments(
    Map<id, SBQQ__QuoteLine__c> quoteLinesMap
  ) {
    if (runAddMissingFeeProductsToAmendments) {
      runAddMissingFeeProductsToAmendments = false;
      // get quote lines list from quote line ids.
      List<SBQQ__QuoteLine__c> quoteLines = [
        SELECT
          id,
          SBQQ__RequiredBy__c,
          SBQQ__Quote__c,
          SBQQ__Number__c,
          SBQQ__Product__c,
          SBQQ__Quantity__c,
          SBQQ__EffectiveQuantity__c,
          Consult_Type__c
        FROM SBQQ__QuoteLine__c
        WHERE id IN :quoteLinesMap.keySet()
      ];

      // get quote/product ids from quote lines.
      Map<id, id> quoteIdsMap = new Map<id, id>();
      Map<id, id> productIdsMap = new Map<id, id>();
      Map<id, id> excludeQuoteLinesMap = new Map<id, id>();
      for (SBQQ__QuoteLine__c ql : quoteLines) {
        if (!quoteIdsMap.containsKey(ql.SBQQ__Quote__c)) {
          quoteIdsMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__c);
        }
        if (!productIdsMap.containsKey(ql.SBQQ__Product__c)) {
          productIdsMap.put(ql.SBQQ__Product__c, ql.SBQQ__Product__c);
        }
        if (
          ql.SBQQ__RequiredBy__c != null &&
          !excludeQuoteLinesMap.containsKey(ql.SBQQ__RequiredBy__c)
        ) {
          excludeQuoteLinesMap.put(
            ql.SBQQ__RequiredBy__c,
            ql.SBQQ__RequiredBy__c
          );
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
        SELECT
          id,
          SBQQ__OptionalSKU__c,
          SBQQ__ConfiguredSKU__c,
          SBQQ__Bundled__c
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
          'QuoteTriggerHelper.addMissingFeeProductsToAmendments(): quote: ' +
          q.id
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
            // if this quote line's quote matches this quote's id and it is nto part of the exclude list,
            if (
              ql.SBQQ__Quote__c == q.id &&
              !excludeQuoteLinesMap.containsKey(ql.id)
            ) {
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
        //insert quoteLinesToInsert;
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
  }
}