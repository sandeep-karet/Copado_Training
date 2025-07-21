/************************
  In order to view the error (AGCPE) got created by the sciprt, run the following SOQL:

  SELECT Id, Processed__c, (SELECT Id, SObject__c, Exception_Type__c, Short_Desc__c, Full_Desc__c FROM AcctGrpConParse_Exceptions__r) FROM AcctGrpConParsing_Item__c WHERE Source__c = 'LVN_DATA_MIGRATION' ORDER BY Createddate DESC

*************************/
public class OppDataMigration {
  public static void createQuote(
    Map<Opportunity, List<OpportunityLineItem>> dataMap,
    String agcpiId
  ) {
    system.debug(agcpiId);
    /************************ 
            agcpeList       => List of AGCPE record to store in AGPCI(create in batch class)
            prodList        => List of product that are bundle    
            oppQuoteIdMap   => Map of opportunity Id and Quote record
            quoteList       => List of quote record we going to insert
            parentQL        => List of Parent quoteline record for bundle product
            qlList          => List of quoteline record (include standalone and parents quoteline) we going to insert
            childQLList     => List of child quote line record from bundle product
            carrierData     => Custom metadata type for carrier pricing mapping between pricing structure(LV) and line of business(TD)
            carrierMap      => Map of pricebook name(LV) + '_' + pricing structure(LV) and line of business(TD)
            prodMap         => Map of product name and product id
        *************************/
    List<AcctGrpConParse_Exception__c> agcpeList = new List<AcctGrpConParse_Exception__c>();
    List<Product2> prodList = [
      SELECT Name, Id
      FROM Product2
      WHERE
        Name IN (
          'Heart Failure',
          'Livongo BH 2.0',
          'MyStrength Complete',
          'Diabetes',
          'Hypertension',
          'Weight Management',
          'Chronic Kidney Disease',
          'Diabetes Prevention',
          'Psychiatry Initial Visit Fee',
          'Psychiatry Ongoing Visit Fee',
          'Therapy Ongoing Visit Fee'
        )
    ];
    Map<String, SBQQ__Quote__c> oppQuoteIdMap = new Map<String, SBQQ__Quote__c>();
    List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    List<SBQQ__QuoteLine__c> parentQL = new List<SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> childQLList = new List<SBQQ__QuoteLine__c>();
    List<Carrier_Pricing_Mapping__mdt> carrierData = [
      SELECT Carrier__c, LVN_Price_Structure__c, TDH_LOB__c
      FROM Carrier_Pricing_Mapping__mdt
    ];
    Map<String, String> carrierMap = new Map<String, String>();
    Map<String, String> prodMap = new Map<String, String>();
    List<String> lvnDirectList = new List<String>{ 'TPA', 'Payer/ASO', 'PBM' };
    List<String> lvnHpList = new List<String>{ 'Payer/ASO', 'PBM' };

    /************************
            1) Generate prodMap: Store product name and product Id
            2) Generate carrierMap: Store carrier pricing metadata to carrierMap        
        *************************/
    for (Product2 prod : prodList) {
      prodMap.put(prod.Name, prod.Id);
    }
    for (Carrier_Pricing_Mapping__mdt carrier : carrierData) {
      if (carrier.Carrier__c == 'Highmark') {
        carrierMap.put(
          'Highmark BCBS_' + carrier.LVN_Price_Structure__c,
          carrier.TDH_LOB__c
        );
      } else if (carrier.Carrier__c == 'Premera BCBS') {
        carrierMap.put(
          'Premera Blue Cross_' + carrier.LVN_Price_Structure__c,
          carrier.TDH_LOB__c
        );
      } else {
        carrierMap.put(
          carrier.Carrier__c + '_' + carrier.LVN_Price_Structure__c,
          carrier.TDH_LOB__c
        );
      }
    }

    /************************
            1) Create quote based info from opportunity
            2) Assigning sales channel, cpq pricebook and line of business(if needed) for quote record
            3) Quote logic table please see the email and attachment I sent.        
        *************************/
    for (Opportunity opp : dataMap.keySet()) {
      if (opp.LVN_Pricebook__c != null) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
          .get('Teladoc')
          .getRecordTypeId();
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.DM_Disable_BH__c = opp.DM_Disable_BH__c;
        quote.SBQQ__PricebookId__c = opp.Pricebook2Id;
        if (opp.LVN_Pricebook__c == 'Livongo') {
          if (
            (opp.StageName == 'Closed Won' &&
            opp.LVN_Contract_Path__c == 'Livongo') ||
            opp.StageName != 'Closed Won' ||
            (opp.StageName == 'Closed Won' &&
            opp.LVN_Contract_Path__c != 'Livongo' &&
            !lvnDirectList.Contains(opp.LVN_Contract_Path_Account_Type__c))
          ) {
            quote.Sales_Channels__c = 'US Employer';
            quote.CPQ_Pricebook__c = 'Direct';
          } else if (
            opp.StageName == 'Closed Won' &&
            opp.LVN_Contract_Path__c != 'Livongo' &&
            lvnHpList.Contains(opp.LVN_Contract_Path_Account_Type__c)
          ) {
            quote.Sales_Channels__c = 'US HealthPlan';
            quote.CPQ_Pricebook__c = 'HealthPlan';
            quote.Pricing_Model__c = 'Custom';
            if (
              opp.LVN_Pricing_Structure__c != null &&
              opp.LVN_Pricing_Structure__c.Contains('ASO Opt IN')
            ) {
              quote.HealthPlan_Opt_In__c = 'Yes';
            } else {
              quote.HealthPlan_Opt_In__c = 'No';
            }
          } else if (
            opp.StageName == 'Closed Won' &&
            opp.LVN_Contract_Path__c != 'Livongo' &&
            opp.LVN_Contract_Path_Account_Type__c == 'TPA'
          ) {
            quote.Sales_Channels__c = 'Reseller';
            quote.CPQ_Pricebook__c = 'Reseller';
          }
        } else {
          if (opp.LVN_Pricebook__c != null) {
            switch on opp.LVN_Pricebook_Type__c {
              when 'Broker' {
                quote.Sales_Channels__c = 'US Employer';
                quote.CPQ_Pricebook__c = 'Broker';
              }
              when 'Reseller' {
                quote.Sales_Channels__c = 'Reseller';
                quote.CPQ_Pricebook__c = 'Reseller';
              }
              when 'Healthplan' {
                String carrierStructure =
                  opp.LVN_Pricebook__c +
                  '_' +
                  opp.LVN_Pricing_Structure__c;
                if (carrierMap.containsKey(carrierStructure)) {
                  quote.Sales_Channels__c = 'US HealthPlan';
                  quote.CPQ_Pricebook__c = 'Carrier';
                  if (opp.LVN_Pricebook__c == 'Highmark BCBS') {
                    quote.Carrier__c = 'Highmark';
                  } else if (opp.LVN_Pricebook__c == 'Premera Blue Cross') {
                    quote.Carrier__c = 'Premera BCBS';
                  } else {
                    quote.Carrier__c = opp.LVN_Pricebook__c;
                  }
                  quote.Line_of_Business__c = carrierMap.get(carrierStructure);
                }
              }
              when 'Other' {
                quote.Sales_Channels__c = 'US Employer';
                quote.CPQ_Pricebook__c = 'Direct';
              }
              when else {
                if (
                  opp.Sub_Channel__c != null &&
                  opp.Sub_Channel__c.Contains('Broker')
                ) {
                  quote.Sales_Channels__c = 'US Employer';
                  quote.CPQ_Pricebook__c = 'Broker';
                }
              }
            }
          }
        }
        oppQuoteIdMap.put(opp.Id, quote);
        quoteList.add(quote);
      }
    }

    /************************
            1) Error Handling
            2) Insert failure will generate a new AGCPE record to store under the AGCPI
            3) Error message should provide parent opportuntiy Id and the reason it fail(no more than 255 characters)       
        *************************/
    Database.SaveResult[] sr = Database.insert(quoteList, false);
    for (Integer i = 0; i < quoteList.size(); i++) {
      Database.SaveResult s = sr[i];
      SBQQ__Quote__c quote = quoteList[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          quote.SBQQ__Opportunity2__c +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              quote.SBQQ__Opportunity2__c +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = 'DML_ERROR: QUOTE',
            Short_Desc__c = quote.SBQQ__Opportunity2__c,
            SObject__c = 'SBQQ__Quote__c',
            Full_Desc__c = fullDesc
          );
          agcpeList.add(agcpe);
        }
      }
    }
    /************************
            1) Create quoteline based info from opportunitylineitem
            2) Only create standalone and parent quoteline first 
            3) All field mapping please refer to the data migration mapping.csv
            4) Switch case are for differnet bundle product; please reach out to jig if question regarding MyStrength Complete child products
        *************************/
    List<Opportunity> lstOpportunity = new List<Opportunity>();
    for (Opportunity opp : dataMap.keySet()) {
      if (oppQuoteIdMap.get(opp.Id) != null) {
        opp.SBQQ__PrimaryQuote__c = oppQuoteIdMap.get(opp.Id).Id;
        opp.Contract_Term__c = 12;
        lstOpportunity.add(opp);
        for (OpportunityLineItem oppli : opp.opportunityLineItems) {
          SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
          ql.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
            .get('Standard')
            .getRecordTypeId();
          ql.SBQQ__Quote__c = oppQuoteIdMap.get(opp.Id).Id;
          ql.Fee_Type__c = oppli.DM_Fee_Type__c == null
            ? 'PPPM'
            : oppli.DM_Fee_Type__c;
          ql.QL_Enrollment_Percentage__c = oppli.DM_Enrollment_Percentage__c ==
            null
            ? 100
            : oppli.DM_Enrollment_Percentage__c;
          ql.QL_Participation_Percentage__c = oppli.DM_Participation_Percentage__c ==
            null
            ? 100
            : oppli.DM_Participation_Percentage__c;
          ql.SBQQ__Quantity__c = oppli.Quantity;
          ql.SBQQ__Product__c = oppli.Product2Id;
          ql.Disable_Teletherapy__c = oppli.DM_Disable_Teletherapy__c == 'TRUE'
            ? 'YES'
            : 'NO';
          ql.Disable_Coaching__c = oppli.DM_Disable_Coaching__c == 'TRUE'
            ? 'YES'
            : 'NO';
          ql.Participant_Quantity__c = oppli.DM_Participant_Quantity__c;
          ql.CurrencyIsoCode = 'USD';
          ql.DM_Original_Oppli_Id__c = oppli.DM_LVN_Program_Id__c;
          ql.DM_Disable_BH__c = oppQuoteIdMap.get(opp.Id).DM_Disable_BH__c;
          ql.DM_Create_MSC__c = oppli.DM_Create_MSC__c; // if this is true => create MSC instead of lV BH2.0
          ql.SBQQ__DefaultSubscriptionTerm__c = 1;
          ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
          ql.DM_Gross_Program_ARR__c = oppli.DM_Gross_Program_ARR__c;
          ql.DM_Net_Program_ARR__c = oppli.DM_Net_Program_ARR__c;
          switch on oppli.Product__c {
            when 'CV Solution',
              'DM Solution',
              'CKD Solution',
              'DP Solution',
              'HF Solution' {
              ql.DM_Admin_Fee__c = oppli.DM_Admin_Fee__c;
              ql.DM_At_Risk_PPPM__c = oppli.DM_At_Risk_Fee__c;
              ql.DM_Up_Front_Fee__c = oppli.DM_Up_Front_Fee__c;
              ql.DM_Net_Price__c = oppli.UnitPrice;
              ql.DM_Product_Name__c = oppli.Product__c;
              parentQL.add(ql);
            }
            when 'MyStrength Complete' {
              ql.Admin_Fee__c = oppli.DM_Admin_Fee__c;
              ql.At_Risk_PPPM__c = oppli.DM_At_Risk_Fee__c;
              ql.Up_Front_Fee__c = oppli.DM_Up_Front_Fee__c;
              ql.SBQQ__ListPrice__c = oppli.UnitPrice;
              ql.DM_Product_Name__c = oppli.Product__c;
              parentQL.add(ql);
            }
            when else {
              ql.Admin_Fee__c = oppli.DM_Admin_Fee__c;
              ql.At_Risk_PPPM__c = oppli.DM_At_Risk_Fee__c;
              ql.Up_Front_Fee__c = oppli.DM_Up_Front_Fee__c;
              ql.SBQQ__ListPrice__c = oppli.UnitPrice;
              if (
                (oppli.DM_PMPM__c != null &&
                oppli.DM_PMPM__c != 0) &&
                oppli.Quantity != 1 &&
                oppli.UnitPrice != 0
              ) {
                SBQQ__QuoteLine__c addQL = new SBQQ__QuoteLine__c();
                addQL.RecordTypeId = ql.RecordTypeId;
                addQL.SBQQ__Quote__c = ql.SBQQ__Quote__c;
                addQL.Fee_Type__c = ql.Fee_Type__c;
                addQL.QL_Enrollment_Percentage__c = 1;
                addQL.QL_Participation_Percentage__c = 100;
                addQL.SBQQ__Quantity__c = ql.SBQQ__Quantity__c;
                addQL.SBQQ__Product__c = ql.SBQQ__Product__c;
                addQL.Disable_Teletherapy__c = ql.Disable_Teletherapy__c;
                addQL.Disable_Coaching__c = ql.Disable_Coaching__c;
                addQL.Participant_Quantity__c = ql.Participant_Quantity__c;
                addQL.CurrencyIsoCode = 'USD';
                addQL.DM_Disable_BH__c = ql.DM_Disable_BH__c;
                addQL.SBQQ__DefaultSubscriptionTerm__c = 1;
                addQL.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                addQL.Admin_Fee__c = 0;
                addQL.At_Risk_PPPM__c = 0;
                addQL.Up_Front_Fee__c = 0;
                addQL.SBQQ__ListPrice__c = oppli.DM_PMPM__c;
                addQL.SBQQ__Description__c = 'Work Around to handle PMPM Value for LV Opps';
                qlList.add(addQL);
              }
            }
          }
          qlList.add(ql);
        }
      }
    }

    /************************
            1) Error Handling
            2) Insert failure will generate a new AGCPE record to store under the AGCPI
            3) Error message should provide parent opportuntiy Id, parent quote Id(if quote got created correctly) and the reason it fail(no more than 255 characters)      
        *************************/
    Database.SaveResult[] qlSaveResult = Database.insert(qlList, false);
    for (Integer i = 0; i < qlList.size(); i++) {
      Database.SaveResult s = qlSaveResult[i];
      SBQQ__QuoteLine__c ql = qlList[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
          ', ' +
          'QuoteId: ' +
          ql.SBQQ__Quote__c +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
              ', ' +
              'QuoteId: ' +
              ql.SBQQ__Quote__c +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = 'DML_ERROR: QL_PARENTS',
            Short_Desc__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__c,
            SObject__c = 'SBQQ__QuoteLine__c',
            Full_Desc__c = fullDesc
          );
          agcpeList.add(agcpe);
        }
      }
    }

    /************************
            1) Error Handling
            2) Insert failure will generate a new AGCPE record to store under the AGCPI
            3) Error message should provide parent opportuntiy Id, primary quote Id(if opportunity got updated correctly) and the reason it fail(no more than 255 characters)       
        *************************/
    Database.SaveResult[] oLSaveResult = Database.update(lstOpportunity, false);
    for (Integer i = 0; i < lstOpportunity.size(); i++) {
      Database.SaveResult s = oLSaveResult[i];
      Opportunity o = lstOpportunity[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          o.Id +
          ', ' +
          'QuoteId: ' +
          oppQuoteIdMap.get(o.Id).Id +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              o.Id +
              ', ' +
              'QuoteId: ' +
              oppQuoteIdMap.get(o.Id).Id +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = 'DML_ERROR',
            Short_Desc__c = String.valueOf(rowError.getStatusCode()),
            SObject__c = 'Opportunity',
            Full_Desc__c = fullDesc
          );
          agcpeList.add(agcpe);
        }
      }
    }

    /************************
            1) Create parent quoteline for MSC under WP based info from opportunitylineitem
            2) All field mapping please refer to the data migration mapping.csv
        *************************/

    Map<String, SBQQ__QuoteLine__c> mscMap = new Map<String, SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> parentMSC = new List<SBQQ__QuoteLine__c>();
    for (SBQQ__QuoteLine__c ql : parentQL) {
      if (
        (ql.DM_Create_MSC__c || ql.DM_Product_Name__c == 'HF Solution') &&
        ql.Disable_Teletherapy__c == 'NO'
      ) {
        SBQQ__QuoteLine__c MSC = createQuoteLine(
          ql,
          'MyStrength Complete',
          prodMap,
          false,
          false,
          true,
          false
        );
        parentMSC.add(MSC);
      }
    }

    Database.SaveResult[] parentMSCSaveResult = Database.insert(
      parentMSC,
      false
    );
    for (Integer i = 0; i < parentMSC.size(); i++) {
      Database.SaveResult s = parentMSCSaveResult[i];
      SBQQ__QuoteLine__c ql = parentMSC[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
          ', ' +
          'QuoteId: ' +
          ql.SBQQ__Quote__c +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
              ', ' +
              'QuoteId: ' +
              ql.SBQQ__Quote__c +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = 'DML_ERROR: MSC_PARENTS',
            Short_Desc__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__c,
            SObject__c = 'SBQQ__QuoteLine__c',
            Full_Desc__c = fullDesc
          );
          agcpeList.add(agcpe);
        }
      }
    }

    for (SBQQ__QuoteLine__c ql : parentMSC) {
      mscMap.put(ql.SBQQ__RequiredBy__c, ql);
    }

    /************************
            1) Create child quoteline based info from opportunitylineitem
            2) All fee fields are only apply to anchor product
            3) All field mapping please refer to the data migration mapping.csv
            4) Switch case are for differnet bundle product; please reach out to jig if question regarding MyStrength Complete child products
        *************************/

    for (SBQQ__QuoteLine__c ql : parentQL) {
      switch on ql.DM_Product_Name__c {
        when 'CV Solution' {
          system.debug(ql.SBQQ__Quote__c);
          SBQQ__QuoteLine__c hypertension = createQuoteLine(
            ql,
            'Hypertension',
            prodMap,
            true,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c weightMg = createQuoteLine(
            ql,
            'Weight Management',
            prodMap,
            false,
            false,
            false,
            false
          );
          if (ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'NO') {
            List<SBQQ__QuoteLine__c> MSCorBHList = createMSCorBH(
              mscMap.get(ql.Id),
              mscMap,
              prodMap
            );
            childQLList.addAll(MSCorBHList);
          } else if (
            ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'YES'
          ) {
            SBQQ__QuoteLine__c MSC = createQuoteLine(
              ql,
              'MyStrength Complete',
              prodMap,
              false,
              false,
              true,
              false
            );
            childQLList.add(MSC);
          } else if (!ql.DM_Create_MSC__c && !ql.DM_Disable_BH__c) {
            SBQQ__QuoteLine__c lvnBH = createQuoteLine(
              ql,
              'Livongo BH 2.0',
              prodMap,
              false,
              false,
              false,
              true
            );
            childQLList.add(lvnBH);
          }
          childQLList.add(hypertension);
          childQLList.add(weightMg);
        }
        when 'DM Solution' {
          SBQQ__QuoteLine__c diabetes = createQuoteLine(
            ql,
            'Diabetes',
            prodMap,
            true,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c hypertension = createQuoteLine(
            ql,
            'Hypertension',
            prodMap,
            false,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c weightMg = createQuoteLine(
            ql,
            'Weight Management',
            prodMap,
            false,
            false,
            false,
            false
          );
          if (ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'NO') {
            List<SBQQ__QuoteLine__c> MSCorBHList = createMSCorBH(
              mscMap.get(ql.Id),
              mscMap,
              prodMap
            );
            childQLList.addAll(MSCorBHList);
          } else if (
            ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'YES'
          ) {
            SBQQ__QuoteLine__c MSC = createQuoteLine(
              ql,
              'MyStrength Complete',
              prodMap,
              false,
              false,
              true,
              false
            );
            childQLList.add(MSC);
          } else if (!ql.DM_Create_MSC__c && !ql.DM_Disable_BH__c) {
            SBQQ__QuoteLine__c lvnBH = createQuoteLine(
              ql,
              'Livongo BH 2.0',
              prodMap,
              false,
              false,
              false,
              true
            );
            childQLList.add(lvnBH);
          }
          childQLList.add(diabetes);
          childQLList.add(hypertension);
          childQLList.add(weightMg);
        }
        when 'DP Solution' {
          SBQQ__QuoteLine__c diabetesPrevent = createQuoteLine(
            ql,
            'Diabetes Prevention',
            prodMap,
            true,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c hypertension = createQuoteLine(
            ql,
            'Hypertension',
            prodMap,
            false,
            false,
            false,
            false
          );
          if (ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'NO') {
            List<SBQQ__QuoteLine__c> MSCorBHList = createMSCorBH(
              mscMap.get(ql.Id),
              mscMap,
              prodMap
            );
            childQLList.addAll(MSCorBHList);
          } else if (
            ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'YES'
          ) {
            SBQQ__QuoteLine__c MSC = createQuoteLine(
              ql,
              'MyStrength Complete',
              prodMap,
              false,
              false,
              true,
              false
            );
            childQLList.add(MSC);
          } else if (!ql.DM_Create_MSC__c && !ql.DM_Disable_BH__c) {
            SBQQ__QuoteLine__c lvnBH = createQuoteLine(
              ql,
              'Livongo BH 2.0',
              prodMap,
              false,
              false,
              false,
              true
            );
            childQLList.add(lvnBH);
          }
          childQLList.add(diabetesPrevent);
          childQLList.add(hypertension);
        }
        when 'CKD Solution' {
          SBQQ__QuoteLine__c CKD = createQuoteLine(
            ql,
            'Chronic Kidney Disease',
            prodMap,
            true,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c diabetes = createQuoteLine(
            ql,
            'Diabetes',
            prodMap,
            false,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c hypertension = createQuoteLine(
            ql,
            'Hypertension',
            prodMap,
            false,
            false,
            false,
            false
          );
          if (ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'NO') {
            List<SBQQ__QuoteLine__c> MSCorBHList = createMSCorBH(
              mscMap.get(ql.Id),
              mscMap,
              prodMap
            );
            childQLList.addAll(MSCorBHList);
          } else if (
            ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'YES'
          ) {
            SBQQ__QuoteLine__c MSC = createQuoteLine(
              ql,
              'MyStrength Complete',
              prodMap,
              false,
              false,
              true,
              false
            );
            childQLList.add(MSC);
          } else if (!ql.DM_Create_MSC__c && !ql.DM_Disable_BH__c) {
            SBQQ__QuoteLine__c lvnBH = createQuoteLine(
              ql,
              'Livongo BH 2.0',
              prodMap,
              false,
              false,
              false,
              true
            );
            childQLList.add(lvnBH);
          }
          childQLList.add(diabetes);
          childQLList.add(hypertension);
          childQLList.add(CKD);
        }
        when 'HF Solution' {
          SBQQ__QuoteLine__c heartFailure = createQuoteLine(
            ql,
            'Heart Failure',
            prodMap,
            true,
            false,
            false,
            false
          );
          SBQQ__QuoteLine__c diabetes = createQuoteLine(
            ql,
            'Diabetes',
            prodMap,
            false,
            false,
            false,
            false
          );
          if (ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'NO') {
            List<SBQQ__QuoteLine__c> MSCorBHList = createMSCorBH(
              mscMap.get(ql.Id),
              mscMap,
              prodMap
            );
            childQLList.addAll(MSCorBHList);
          } else if (
            ql.DM_Create_MSC__c && ql.Disable_Teletherapy__c == 'YES'
          ) {
            SBQQ__QuoteLine__c MSC = createQuoteLine(
              ql,
              'MyStrength Complete',
              prodMap,
              false,
              false,
              true,
              false
            );
            childQLList.add(MSC);
          }
          childQLList.add(diabetes);
          childQLList.add(heartFailure);
        }
        when 'MyStrength Complete' {
          if (ql.Disable_Teletherapy__c == 'NO') {
            SBQQ__QuoteLine__c BHP1T = createQuoteLine(
              ql,
              'Psychiatry Initial Visit Fee',
              prodMap,
              false,
              true,
              false,
              false
            );
            SBQQ__QuoteLine__c BHPOT = createQuoteLine(
              ql,
              'Psychiatry Ongoing Visit Fee',
              prodMap,
              false,
              true,
              false,
              false
            );
            SBQQ__QuoteLine__c BHNPT = createQuoteLine(
              ql,
              'Therapy Ongoing Visit Fee',
              prodMap,
              false,
              true,
              false,
              false
            );
            childQLList.add(BHP1T);
            childQLList.add(BHPOT);
            childQLList.add(BHNPT);
          }
        }
      }
    }

    /************************
            1) Error Handling
            2) Insert failure will generate a new AGCPE record to store under the AGCPI
            3) Error message should provide parent opportuntiy Id, parent quote Id(if quote got created correctly) and the reason it fail(no more than 255 characters)      
        *************************/
    Database.SaveResult[] childQlSaveResult = Database.insert(
      childQLList,
      false
    );
    for (Integer i = 0; i < childQLList.size(); i++) {
      Database.SaveResult s = childQlSaveResult[i];
      SBQQ__QuoteLine__c ql = childQLList[i];
      if (!s.isSuccess()) {
        for (Database.Error rowError : s.getErrors()) {
          String fullDesc = ('OppId: ' +
          ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
          ', ' +
          'QuoteId: ' +
          ql.SBQQ__Quote__c +
          ', ' +
          rowError.getMessage());
          if (fullDesc.length() > 255) {
            fullDesc = ('OppId: ' +
              ql.SBQQ__Quote__r.SBQQ__Opportunity2__c +
              ', ' +
              'QuoteId: ' +
              ql.SBQQ__Quote__c +
              ', ' +
              rowError.getMessage())
              .substring(0, 255);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = 'DML_ERROR: QL_CHILD',
            Short_Desc__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__c,
            SObject__c = 'SBQQ__QuoteLine__c',
            Full_Desc__c = fullDesc
          );
          agcpeList.add(agcpe);
        }
      }
    }

    system.debug(agcpeList.size());
    Database.insert(agcpeList, false);
  }

  public static SBQQ__QuoteLine__c createQuoteLine(
    SBQQ__QuoteLine__c parentQL,
    String prodName,
    Map<String, String> prodMap,
    Boolean isAnchor,
    Boolean isAsset,
    Boolean isMSC,
    Boolean isBH
  ) {
    SBQQ__QuoteLine__c childQL = new SBQQ__QuoteLine__c();
    childQL.RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    childQL.SBQQ__Quote__c = parentQL.SBQQ__Quote__c;
    childQL.Participant_Quantity__c = parentQL.Participant_Quantity__c;
    childQL.Fee_Type__c = parentQL.Fee_Type__c;
    childQL.QL_Enrollment_Percentage__c = parentQL.QL_Enrollment_Percentage__c;
    childQL.QL_Participation_Percentage__c = parentQL.QL_Participation_Percentage__c;
    childQL.SBQQ__Quantity__c = parentQL.SBQQ__Quantity__c;
    childQL.SBQQ__Product__c = prodMap.get(prodName);
    childQL.DM_Create_MSC__c = parentQL.DM_Create_MSC__c;
    if (isMSC) {
      childQL.Disable_Teletherapy__c = parentQL.Disable_Teletherapy__c;
    } else {
      childQL.Disable_Teletherapy__c = 'NO';
    }
    if (isBH) {
      childQL.Disable_Coaching__c = parentQL.Disable_Coaching__c;
    } else {
      childQL.Disable_Coaching__c = 'NO';
    }
    childQL.SBQQ__RequiredBy__c = parentQL.Id;
    childQL.SBQQ__DefaultSubscriptionTerm__c = 1;
    childQL.CurrencyIsoCode = 'USD';
    if (isAnchor) {
      childQL.Admin_Fee__c = parentQL.DM_Admin_Fee__c;
      childQL.At_Risk_PPPM__c = parentQL.DM_At_Risk_PPPM__c;
      childQL.Up_Front_Fee__c = parentQL.DM_Up_Front_Fee__c;
      childQL.SBQQ__ListPrice__c = parentQL.DM_Net_Price__c;
      childQL.Anchor__c = true;
      childQL.DM_Gross_Program_ARR__c = parentQL.DM_Gross_Program_ARR__c;
      childQL.DM_Net_Program_ARR__c = parentQL.DM_Net_Program_ARR__c;
    }
    if (!isAsset) {
      childQL.SBQQ__SubscriptionPricing__c = 'Fixed Price';
    }
    return childQL;
  }

  public static List<SBQQ__QuoteLine__c> createMSCorBH(
    SBQQ__QuoteLine__c parentQL,
    Map<String, SBQQ__QuoteLine__c> mscMap,
    Map<String, String> prodMap
  ) {
    List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
    if (parentQL.Disable_Teletherapy__c == 'NO') {
      SBQQ__QuoteLine__c BHP1T = createQuoteLine(
        parentQL,
        'Psychiatry Initial Visit Fee',
        prodMap,
        false,
        true,
        false,
        false
      );
      SBQQ__QuoteLine__c BHPOT = createQuoteLine(
        parentQL,
        'Psychiatry Ongoing Visit Fee',
        prodMap,
        false,
        true,
        false,
        false
      );
      SBQQ__QuoteLine__c BHNPT = createQuoteLine(
        parentQL,
        'Therapy Ongoing Visit Fee',
        prodMap,
        false,
        true,
        false,
        false
      );
      qlList.add(BHP1T);
      qlList.add(BHPOT);
      qlList.add(BHNPT);
    }
    return qlList;
  }
}