/**
 * Name          : GCRM_Process_PreSales
 * Created Date  : 30-Aug-2023
 * Description   : Class to Process 'PreSales' payload from GCRM
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-4353    12-Dec-2023		Elambaruthi T		Setup Default Owner to Salesforce Support User
 */

public class GCRM_Process_PreSales {
  public Map<String, Object> accountRecord = new Map<String, Object>();
  public Map<String, Object> OpportunityRecord = new Map<String, Object>();
  public Map<String, Object> quoteRecord = new Map<String, Object>();
  public String oppCurrency;
  public String muid;
  public String oppGUID;
  public Boolean isLVN = false;
  /* SCDEV-4353 [Starts] */
  public String tdSFSupportUserId = '';
  /* SCDEV-4353 [Ends] */

  public void ProcessPayload(String muid) {
    this.muid = muid;
    /* SCDEV-4353 [Starts] */
    tdSFSupportUserId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
      UserInfo.getUserId()
    );
    /* SCDEV-4353 [Ends] */
    //Delete Old G2Item Logs
    List<G2LItemLog__c> muidLogs = [
      SELECT Id, MUID__c
      FROM G2LItemLog__c
      WHERE MUID__c = :muid
    ];
    delete muidLogs;

    //get g2lcrm item for the MUID
    List<G2LCRM_Item__c> gitems = [
      SELECT Id, Action__c, Body__c, CDM_Name__c, MUID__c, Status__c
      FROM G2LCRM_Item__c
      WHERE MUID__c = :muid AND CDM_Name__c = 'PreSale'
    ];

    Map<String, Object> masterPayload = new Map<String, object>();
    if (gitems.size() > 0) {
      masterPayload = (Map<String, Object>) ((Map<String, object>) JSON.deserializeUntyped(
          gitems[0].Body__c
        ))
        .get('body');
      accountRecord = (Map<String, object>) masterPayload.get('account');
      opportunityRecord = (Map<String, Object>) masterPayload.get(
        'opportunity'
      );
      oppCurrency = (String) opportunityRecord.get('currencyIsoCode');
      quoteRecord = (Map<String, Object>) masterPayload.get('quote');
    }
    GCRM_ProcessOrder_Utlity.InitUtil(oppCurrency);
    oppGUID = (String) opportunityRecord.get('opportunityGUID');
    if (OpportunityProcessed(oppGUID)) {
      GCRM_ProcessOrder_Utlity.deleteRecordsByMUID(oppGUID);
    }
    Map<String, Account> accountIDMap = new Map<String, Account>();
    Map<String, Opportunity> opportuntiyIDMap = new Map<String, Opportunity>();
    Map<String, SBQQ__Quote__c> quoteIdMap = new Map<String, SBQQ__Quote__c>();
    map<String, SBQQ__QuoteLine__c> quotelineMap = new Map<String, SBQQ__QuoteLine__c>();
    List<Contract> contractlist = new List<Contract>();
    Map<String, SBQQ__Subscription__c> subscriptionIDmap = new Map<String, SBQQ__Subscription__c>();
    String accountGUID = (String) (accountRecord?.get('accountGUID'));
    accountIDMap = accountExists(accountGUID);
    if (accountIDMap.size() == 0 && accountRecord.size() > 0)
      accountIDMap = createAccount();
    if (accountIDMap.size() > 0 && opportunityRecord.size() > 0)
      opportuntiyIDMap = createOpportunity(accountIDMap);
    if (quoteRecord.size() > 0)
      quoteIdMap = createQuote(accountIDMap, opportuntiyIDMap);
    List<Object> quoteLines = (List<Object>) quoteRecord.get('quoteLines');
    if (quoteLines != null && opportuntiyIDMap.size() > 0) {
      quotelineMap = createQuoteLines(quoteIdMap);
      mapQuoteLineHierarchy(quotelineMap);
      CreateOpportunityLineItem(opportuntiyIDMap, quotelineMap);
      contractlist = createcontracts(opportuntiyIDMap);
      subscriptionIDmap = createSubscriptions(quotelineMap, contractlist);
      createAssets(subscriptionIDmap, quoteIdMap, quotelineMap);
    }
    //Update Opportunity Stage
    for (Opportunity opp : opportuntiyIDMap.values()) {
      opp.StageName = 'Contracting';
      opp.isLVN__c = isLVN;
    }
    Set<Id> oppids = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      opportuntiyIDMap.values(),
      'update opp stage',
      'PreSales',
      'Upsert opp',
      Opportunity.Opp_GUID__c
    );
  }
  /*****************************************************
    /* Method Name        : OpportunityProcessed
    /* Method Description : checks if the Opportunity is already processed 
    /* Method Parameters  : accountGUID
    ******************************************************/
  public Boolean OpportunityProcessed(String oppGUID) {
    List<Opportunity> opp = [
      SELECT Id, Early_Implemented__c
      FROM Opportunity
      WHERE Opp_GUID__c = :oppGUID
    ];
    if (opp.size() > 0)
      return opp[0]?.Early_Implemented__c;
    return false;
  }
  /*****************************************************
    /* Method Name        : accountExists
    /* Method Description : checks if the account already exists 
    /* Method Parameters  : accountGUID
    ******************************************************/
  public Map<String, Account> accountExists(String accountGUID) {
    Map<String, Account> accountGUIDMap = new Map<String, Account>();
    List<Sobject> acctToUpsert = new List<SObject>();
    for (Account acct : [
      SELECT Id, GUID__c, GCRM_Account_ID__c
      FROM Account
      WHERE GUID__c = :accountGUID
    ]) {
      system.debug('accct' + accountRecord.keySet());
      accountGUIDMap.put((String) accountRecord.get('accountId'), acct);
      SObject acctRec = new Account();
      acctRec.put('GCRM_Account_ID__c', accountRecord.get('accountId'));
      acctRec.put('GUID__c', accountRecord.get('accountGUID'));
      acctToUpsert.add(acctRec);
    }
    Set<Id> accountIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      acctToUpsert,
      'CreateAccount',
      'PreSales',
      'Upsert Account',
      Account.GUID__c
    );
    return accountGUIDMap;
  }
  /*****************************************************
    /* Method Name        : createAccount
    /* Method Description : Create Account record from payload
    /* Method Parameters  : NA
    ******************************************************/
  public Map<String, Account> CreateAccount() {
    List<SObject> accountstoUpsert = new List<SObject>();
    Map<String, Account> accountidMap = new Map<String, Account>();
    Set<Id> accountIds = new Set<Id>();
    // SCDEV-4353 [Starts]
    Set<Id> existingOwnerIds = new Set<Id>();
    // SCDEV-4353 [Ends]
    try {
      //map fields on Account Payload from custom metadata
      List<Map<String, Object>> acctPayload = new List<Map<String, Object>>();
      acctPayload.add(accountRecord);
      accountstoUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'Account',
        'Account',
        acctPayload
      );

      /* SCDEV-4107 AccountType changes [Starts] */
      //Map Account Type
      Map<String, Map<String, String>> valueMapping = GCRM_ProcessOrder_Utlity.g2lcrmPickListMapping(
        'Account'
      );
      for (SObject acct : accountstoUpsert) {
        String accType = (String) acct.get('Account_Type__c');
        if (
          valueMapping.containsKey('Account_Type__c') &&
          valueMapping.get('Account_Type__c').containsKey(accType)
        ) {
          acct.put(
            'Account_Type__c',
            valueMapping.get('Account_Type__c').get(accType)
          );
        }
        /* G2LAccountType__c csG2LACType = G2LAccountType__c.getInstance((String)acct.get('Account_Type__c'));
                if(csG2LACType != null){
                    acct.put('Account_Type__c',csG2LACType.TD_Account_Type__c);
                } */
      }
      /* SCDEV-4107 AccountType changes [Ends] */
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'CreateAccount',
        'PreSales',
        'Account Field Mapping',
        '',
        e
      );
    }
    try {
      // SCDEV-4353 [Starts]
     /* existingOwnerIds = GCRM_ProcessOrder_Utlity.getExistingUsersIds(
        accountstoUpsert,
        'OwnerId'
      );*/
      // SCDEV-4353 [Ends]
      //Map other fields on Account like Addresses which need a criteria E.g Type = Billing
      for (SObject acct : accountstoUpsert) {
        // SCDEV-4353 [Starts]
        String ownerId = (String) acct.get('ownerId');
        //if (!existingOwnerIds.contains(ownerId)) {
          acct.put('OwnerId', tdSFSupportUserId);
        //}
        // SCDEV-4353 [Ends]
        List<Map<String, Object>> addresses = new List<Map<String, Object>>();
        if (accountRecord.containskey('addresses')) {
          for (Object addr : (List<Object>) accountRecord.get('addresses')) {
            addresses.add((Map<String, Object>) addr);
          }
          for (object addr : addresses) {
            String Objectname = 'Account.addresses';
            acct = GCRM_ProcessOrder_Utlity.ConditionalFieldMapping(
              Objectname,
              'Account',
              acct,
              addresses
            );
          }
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'CreateAccount',
        'PreSale',
        'Account Address Mapping',
        '',
        e
      );
    }
    accountIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      accountstoUpsert,
      'CreateAccount',
      'PreSales',
      'Upsert Account',
      Account.GUID__c
    );

    for (Account acct : [
      SELECT Id, GUID__c, GCRM_Account_ID__c
      FROM Account
      WHERE Id IN :accountIds
    ]) {
      accountidMap.put(acct.GCRM_Account_ID__c, acct);
    }
    return accountidMap;
  }
  /*****************************************************
    /* Method Name        : CreateOpportunity
    /* Method Description : Create Opportunity records from the payload
    /* Method Parameters  : NA
    ******************************************************/

  public Map<String, Opportunity> CreateOpportunity(
    Map<String, Account> accountIDMap
  ) {
    Map<String, Opportunity> OpportuntiyIDMap = new Map<String, Opportunity>();
    List<SObject> OpportunityToUpsert = new List<SObject>();
    List<Map<String, Object>> OppPayload = new List<Map<String, Object>>();
    // SCDEV-4353 [Starts]
    Set<Id> existingOwnerIds = new Set<Id>();
    // SCDEV-4353 [Ends]
    try {
      OppPayload.add(opportunityRecord);
      OpportunityToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'order.opportunities',
        'Opportunity',
        OppPayload
      );
      // SCDEV-4353 [Starts]
      /*existingOwnerIds = GCRM_ProcessOrder_Utlity.getExistingUsersIds(
        OpportunityToUpsert,
        'OwnerId'
      );*/
      // SCDEV-4353 [Ends]
      //Map Parent account for Opportunity
      for (SObject Opp : OpportunityToUpsert) {
        // SCDEV-4353 [Starts]
        String ownerId = (String) Opp.get('ownerId');
        //if (!existingOwnerIds.contains(ownerId)) {
          Opp.put('OwnerId', tdSFSupportUserId);
        //}
        // SCDEV-4353 [Ends]
        Opp.put(
          'AccountId',
          accountIDMap.get((String) this.OpportunityRecord.get('accountId'))?.Id
        );
        opp.put('Early_Implemented__c', true);
        opp.put('StageName', 'Discovery');
        if (Opp.get('currencyIsoCode') == 'CAD')
          Opp.put('pricebook2Id', GCRM_ProcessOrder_Utlity.cadPriceBookId);
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'CreateOpportunity',
        'PreSales',
        'Opportunity Field Mapping',
        '',
        e
      );
    }
    //Upsert the Opporutnities mapped
    Set<id> oppIds = new Set<Id>();
    oppIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      OpportunityToUpsert,
      'CreateOpportunity',
      'PreSales',
      'Upsert Opportunity',
      Opportunity.Opp_Guid__c
    );

    for (Opportunity Opp : [
      SELECT Id, Opp_Guid__c, GCRM_Source_Id__c, AccountId, Pricebook2Id
      FROM Opportunity
      WHERE Id IN :oppIds
    ]) {
      OpportuntiyIDMap.put(Opp.Opp_Guid__c, Opp);
    }
    return OpportuntiyIDMap;
  }
  /*****************************************************
    /* Method Name        : createQuote
    /* Method Description : Create CPQ Quote from payload
    /* Method Parameters  : NA
    ******************************************************/
  public Map<String, SBQQ__Quote__c> createQuote(
    Map<String, Account> accountidMap,
    Map<String, Opportunity> OpportunityIdMap
  ) {
    Map<String, SBQQ__Quote__c> quoteIDMap = new Map<String, SBQQ__Quote__c>();
    List<Map<String, Object>> quotepayload = new List<Map<String, Object>>();
    List<SBQQ__Quote__c> quoteToUpsert = new List<SBQQ__Quote__c>();
    // SCDEV-4353 [Starts]
    Set<Id> existingOwnerIds = new Set<Id>();
    // SCDEV-4353 [Ends]
    try {
      quotepayload.add(quoteRecord);
      quoteToUpsert = (List<SBQQ__Quote__c>) GCRM_ProcessOrder_Utlity.FieldMapping(
        'quote',
        'SBQQ__Quote__c',
        quotepayload,
        'preSale'
      );
      // SCDEV-4353 [Starts]
      /*existingOwnerIds = GCRM_ProcessOrder_Utlity.getExistingUsersIds(
        quoteToUpsert,
        'OwnerId'
      );*/
      // SCDEV-4353 [Ends]
      //Map Quote Account
      for (SObject quote : quoteToUpsert) {
        // SCDEV-4353 [Starts]
        String ownerId = (String) quote.get('ownerId');
        //if (!existingOwnerIds.contains(ownerId)) {
          quote.put('OwnerId', tdSFSupportUserId);
        //}
        // SCDEV-4353 [Ends]
        quote.put(
          'SBQQ__Account__c',
          accountidMap.get((String) quoteRecord.get('accountId'))?.Id
        );
        quote.put(
          'SBQQ__Opportunity2__c',
          OpportunityIdMap.get((String) quoteRecord.get('opportunityGUID'))?.Id
        );
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'createQuote',
        'PreSales',
        'Quote Field Mapping',
        '',
        e
      );
    }

    //upsert quote record
    Set<id> quoteIds = new Set<Id>();
    quoteIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      quoteToUpsert,
      'CreateQuote',
      'OrderV3',
      'Upsert Quote',
      SBQQ__Quote__c.GCRM_Quote_ID__c
    );

    for (SBQQ__Quote__c quote : [
      SELECT Id, GCRM_Quote_ID__c, SBQQ__Account__c
      FROM SBQQ__Quote__c
      WHERE Id IN :quoteIds
    ]) {
      quoteIDMap.put(quote.GCRM_Quote_ID__c, quote);
    }

    GCRM_ProcessOrder_Utlity.setPrimaryQuote(
      oppGUID,
      quoteIDMap.values()[0]?.Id
    );
    return quoteIDMap;
  }
  /*****************************************************
    /* Method Name        : CreateOpportunityLineItem
    /* Method Description : Create Opportunity Line Item records from the payload
    /* Method Parameters  : NA
    ******************************************************/
  public void CreateOpportunityLineItem(
    Map<String, Opportunity> OpportunityIDMap,
    Map<String, SBQQ__QuoteLine__c> quoteLineMap
  ) {
    List<SObject> oppLiToUpsert = new List<SObject>();
    List<Map<String, Object>> oppLiPayload = new List<map<String, Object>>();
    Map<String, OpportunityLineItem> oppliIDMap = new Map<String, OpportunityLineItem>();
    Map<String, Id> ProductIdMap = new Map<String, Id>();
    Map<String, Id> priceBookIdMap = new Map<String, Id>();
    Map<String, Decimal> totalPriceMap = new Map<String, Decimal>();

    try {
      for (Object oppli : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> oppliObj = (Map<String, Object>) oppli;
        if ((Decimal) oppliObj.get('effectiveQuantity') > 0) {
          oppLiPayload.add(oppliObj);
          PricebookEntry pbe = GCRM_ProcessOrder_Utlity.getProductId(oppliObj, oppCurrency);
          productIdMap.put(
            (String) oppliObj.get('quoteLineId'),
            pbe.Product2Id != NULL ? pbe.Product2Id : NULL
          );
          priceBookIdMap.put(
            (String) oppliObj.get('quoteLineId'),
            pbe != NULL ? pbe.Id : NULL
          );
          String Family = GCRM_ProcessOrder_Utlity.getProductFamily(
            oppliObj,
            oppCurrency
          );
          if (isLVN == false && Family?.containsIgnoreCase('livongo')) {
            isLVN = true;
          }
          totalPriceMap.put(
            (String) oppliObj.get('quoteLineId'),
            Decimal.valueOf(String.valueOf(oppliObj.get('listPrice'))) *
            Decimal.valueOf(String.valueof(oppliObj.get('effectiveQuantity')))
          );
        }
      }
      oppLiToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'quote.quoteLines',
        'OpportunityLineItem',
        oppLiPayload,
        'preSale'
      );
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'CreateOpportunityLineItem',
        'PreSales',
        'Opp LineItem Field mapping',
        '',
        e
      );
    }

    try {
      for (SObject oppli : oppLiToUpsert) {
        if (OpportunityIDMap.size() > 0)
          oppli.put('OpportunityId', OpportunityIDMap.values()[0].Id);
        oppli.put(
          'Product2Id',
          ProductIdMap.get((String) oppli.get('GCRM_Quote_Line_ID__c'))
        );
        oppli.put(
          'PricebookEntryId', 
          priceBookIdMap.get((String) oppli.get('GCRM_Quote_Line_ID__c'))
        );
        oppli.put(
          'TotalPrice',
          totalPriceMap.get((String) oppli.get('GCRM_Quote_Line_ID__c'))
        );
        oppli.put(
          'SBQQ__QuoteLine__c',
          quoteLineMap.get((String) oppli.get('GCRM_Quote_Line_ID__c'))?.Id
        );
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'CreateOpportunityLineItem',
        'PreSales',
        'Opp LineItem lookup Mapping',
        '',
        e
      );
    }
    //Upsert the Opp Line items mapped
    Set<id> oppliIds = new Set<Id>();
    oppliIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      oppLiToUpsert,
      'CreateOpportunityLineItem',
      'OrderV3',
      'Upsert Opportunity line',
      OpportunityLineItem.GCRM_Quote_Line_ID__c
    );
  }
  /*****************************************************
    /* Method Name        : mapQuoteLineHierarchy
    /* Method Description : Map requiredby fields on quote line
    /* Method Parameters  : NA
    ******************************************************/
  public void mapQuoteLineHierarchy(
    Map<String, SBQQ__QuoteLine__c> quoteLineMap
  ) {
    try {
      Map<String, String> qliParentMap = new Map<String, String>();
      for (Object qli : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> qliObj = (Map<String, Object>) qli;
        qliParentMap.put(
          (String) qliObj.get('quoteLineId'),
          (String) qliObj.get('requiredBy')
        );
      }
      for (SBQQ__QuoteLine__c qli : quoteLineMap.values()) {
        qli.SBQQ__RequiredBy__c = quoteLineMap.get(
            (String) qliParentMap.get((String) qli.get('GCRM_Quote_Line_Id__c'))
          )
          ?.Id;
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'mapQuoteLineHierarchy',
        'PreSales',
        'Update qli relationship',
        '',
        e
      );
    }
    Set<id> qliids = new Set<Id>();
    qliids = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      quoteLineMap.values(),
      'mapQuoteLineHierarchy',
      'OrderV3',
      'Upsert Quote line RequiredBy',
      SBQQ__QuoteLine__c.GCRM_Quote_Line_ID__c
    );
  }
  /*****************************************************
    /* Method Name        : createQuoteLines
    /* Method Description : Create CPQ Quote Lines from payload
    /* Method Parameters  : NA
    ******************************************************/
  public Map<String, SBQQ__QuoteLine__c> createQuoteLines(
    Map<String, SBQQ__Quote__c> quoteIDMap
  ) {
    Map<String, SBQQ__QuoteLine__c> quoteLineIDmap = new Map<String, SBQQ__QuoteLine__c>();
    List<SObject> qliToUpsert = new List<SObject>();
    List<Map<String, Object>> qliPayload = new List<Map<String, Object>>();
    Map<String, Id> ProductIdMap = new Map<String, Id>();
    try {
      for (Object qli : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> qliObj = (Map<String, object>) qli;
        if ((Decimal) qliObj.get('effectiveQuantity') > 0) {
          qliPayload.add(qliObj);
          PricebookEntry pbe = GCRM_ProcessOrder_Utlity.getProductId(qliObj, oppCurrency);
          productIdMap.put(
            (String) qliObj.get('quoteLineId'),
            pbe.Product2Id != NULL ? pbe.Product2Id : NULL
          );
        }
      }
      qliToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'quote.quoteLines',
        'SBQQ__QuoteLine__c',
        qliPayload,
        'PreSale'
      );
      for (SObject qli : qliToUpsert) {
        if (quoteIDMap.size() > 0)
          qli.put('SBQQ__Quote__c', quoteIDMap.values()[0].Id);
        qli.put(
          'SBQQ__Product__c',
          ProductIdMap.get((String) qli.get('GCRM_Quote_Line_ID__c'))
        );
         qli.put(
          'CurrencyIsoCode',oppCurrency);
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'createQuoteLines',
        'PreSales',
        'Qli Field Mapping',
        '',
        e
      );
    }
    //Upsert the Opp Line items mapped
    Set<id> qliids = new Set<Id>();
    qliids = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      qliToUpsert,
      'CreateQuoteLineItem',
      'OrderV3',
      'Upsert Quote line',
      SBQQ__QuoteLine__c.GCRM_Quote_Line_ID__c
    );
    for (SBQQ__QuoteLine__c qli : [
      SELECT
        Id,
        GCRM_Quote_Line_ID__c,
        SBQQ__Product__c,
        SBQQ__Quantity__c,
        SBQQ__ListPrice__c,
        SBQQ__Product__r.Name
      FROM SBQQ__QuoteLine__c
      WHERE Id IN :qliids
    ]) {
      quoteLineIDmap.put(qli.GCRM_Quote_Line_ID__c, qli);
    }
    return quoteLineIDmap;
  }
  /*****************************************************
    /* Method Name        : createContracts
    /* Method Description : Create Contract from payload
    /* Method Parameters  : NA
    ******************************************************/
  public List<Contract> createContracts(
    Map<String, Opportunity> OpportunityIDMap
  ) {
    List<Map<String, object>> contractPayload = new List<map<String, Object>>();
    List<SObject> contracttoUpsert = new List<Sobject>();
    contractPayload.add(opportunityRecord);
    try {
      //Commented since no values to map in payload
      /*contracttoUpsert = GCRM_ProcessOrder_Utlity.FieldMapping('Opportunity',
                                                                    'Contract',
                                                                    contractPayload,
                                                                    'PreSale');
            */
      Opportunity oppRec = OpportunityIDMap.values()[0];
      SObject ctr = new Contract();
      ctr.put('SBQQ__Opportunity__c', oppRec?.Id);
      ctr.put('AccountId', oppRec?.AccountId);
      ctr.put('Pricebook2Id', oppRec?.Pricebook2Id);
      if (quoteRecord.containsKey('subscriptionTerm')) {
        ctr.put(
          'ContractTerm',
          Integer.valueOf(
            String.valueOf((quoteRecord?.get('subscriptionTerm')))
          )
        );
      }
      ctr.put('ContractTerm', 12);
      String OppName = ((String) opportunityRecord?.get('opportunityName'));
      OppName = OppName.length() > 80 ? OppName.substring(0, 80) : OppName;
      ctr.put('Name', OppName);
      // SCDEV-4353 [Starts]
      ctr.put('OwnerId', tdSFSupportUserId);
      // SCDEV-4353 [Ends]
      contracttoUpsert.add(ctr);
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'createContracts',
        'PreSales',
        '',
        '',
        e
      );
    }
    Set<id> ctrIds = new Set<Id>();
    ctrIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      contracttoUpsert,
      'CreateContract',
      'preSale',
      'Upsert Contract',
      null
    );
    List<Contract> contractLst = new List<Contract>();
    for (Contract ctrs : [
      SELECT Id, AccountId
      FROM Contract
      WHERE Id IN :ctrIds
    ]) {
      contractLst.add(ctrs);
    }
    return contractLst;
  }
  /*****************************************************
    /* Method Name        : createSubscripotions
    /* Method Description : Create subscriptions from payload
    /* Method Parameters  : NA
    ******************************************************/
  public Map<String, SBQQ__Subscription__c> createSubscriptions(
    Map<String, SBQQ__QuoteLine__c> quoteLineIDMap,
    List<Contract> contractList
  ) {
    Map<String, SBQQ__Subscription__c> subscriptionIDMap = new Map<String, SBQQ__Subscription__c>();
    Map<String, SBQQ__Subscription__c> parentSubsMap = new Map<String, SBQQ__Subscription__c>();
    Map<String, SObject> SubscriptionMap = new Map<String, SObject>();
    List<Map<String, Object>> subsPayload = new List<map<String, Object>>();
    List<SObject> subsToUpsert = new List<SObject>();
    // SCDEV-4353 [Starts]
    Set<Id> existingOwnerIds = new Set<Id>();
    // SCDEV-4353 [Ends]
    try {
      for (Object subs : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> subObj = (Map<String, object>) subs;
        if (
          subObj.get('productCode') != 'VISITFEE' &&
          subObj.get('productSubscriptionType') != 'one-Time' &&
          (Decimal) subObj.get('effectiveQuantity') > 0
        ) {
          subsPayload.add(subObj);
        }
      }
      subsToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'quote.quoteLines',
        'SBQQ__Subscription__c',
        subsPayload,
        'PreSale'
      );
      // SCDEV-4353 [Starts]
      /*existingOwnerIds = GCRM_ProcessOrder_Utlity.getExistingUsersIds(
        subsToUpsert,
        'OwnerId'
      );*/
      // SCDEV-4353 [Ends]
      for (SObject sub : subsToUpsert) {
        // SCDEV-4353 [Starts]
        String ownerId = (String) sub.get('ownerId');
        //if (!existingOwnerIds.contains(ownerId)) {
          sub.put('OwnerId', tdSFSupportUserId);
        //}
        // SCDEV-4353 [Ends]
        if (quoteLineIDMap.size() > 0) {
          String Externalkey =
            (String) sub.get('GCRM_Quote_Line_ID__c') +
            '-' +
            String.valueOf(
              Date.valueOf(sub.get('SBQQ__SubscriptionStartDate__c'))
            );
          SBQQ__QuoteLine__c qliRec = quoteLineIDMap
            ?.get((String) sub?.get('GCRM_Quote_Line_ID__c'));
          sub.put('SBQQ__QuoteLine__c', qliRec?.Id);
          sub.put('SBQQ__Product__c', qliRec?.SBQQ__Product__c);
          sub.put('SBQQ__Account__c', contractList[0]?.AccountId);
          sub.put('SBQQ__Contract__c', contractList[0]?.Id);
          sub.put('External_Id__c', Externalkey);
          sub.put('CurrencyIsoCode',oppCurrency);
          SubscriptionMap.put(Externalkey, sub);
          parentSubsMap.put(
            (String) sub.get('GCRM_Quote_Line_ID__c'),
            (SBQQ__Subscription__c) sub
          );
        }
      }
      //check if the current payload is MDQ - chekcing if same visit fee product is present multiple times
      Boolean isMDQ = false;
      set<String> MDQkeySet = new Set<String>();
      for (Object vistifees : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> assObj = (Map<String, object>) vistifees;
        if (assObj.get('productCode') == 'VISITFEE') {
          if (
            MDQkeySet.contains(
              (String) assObj.get('feeCode') +
                '-' +
                (String) assObj.get('requiredBy')
            )
          ) {
            isMDQ = true;
            break;
          } else {
            MDQkeySet.add(
              (String) assObj.get('feeCode') +
                '-' +
                (String) assObj.get('requiredBy')
            );
          }
        }
      }
      //Create additional Subscriptions based on parent Subscription for MDQ Scenario
      if (isMDQ) {
        for (Object visitfees : (List<Object>) quoteRecord.get('quoteLines')) {
          Map<String, Object> assObj = (Map<String, object>) visitfees;
          String key =
            (String) assObj.get('requiredBy') +
            '-' +
            (String) assobj.get('effectiveStartDate');
          system.debug('key' + key + SubscriptionMap.get(key));
          if (
            (String) assObj.get('productCode') == 'VISITFEE' &&
            (Decimal) assObj.get('effectiveQuantity') > 0 &&
            SubscriptionMap.get(key) == null
          ) {
            SObject ParentSubscription = parentSubsMap.get(
              (String) assObj.get('requiredBy')
            );
            SObject DupSubs = ParentSubscription.clone();
            DupSubs
              ?.put(
                'SBQQ__SubscriptionStartDate__c',
                Date.valueOf(String.valueOf(assObj.get('effectiveStartDate')))
              );
            DupSubs
              ?.put(
                'GCRM_Quote_Line_Id__c',
                (String) assObj.get('quoteLineId')
              );
            DupSubs?.put('External_Id__c', key);
            // SCDEV-4353 [Starts]
            DupSubs?.put('OwnerId', tdSFSupportUserId);
            DupSubs?.put('CurrencyIsoCode', oppCurrency);
            // SCDEV-4353 [Ends]
            SubscriptionMap.put(key, DupSubs);
            subsToUpsert.add(DupSubs);
          }
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'createSubscriptions',
        'PreSales',
        'Parse Subscriptions',
        '',
        e
      );
    }
    //upsert all the subscription records
    Set<id> subIds = new Set<Id>();
    subIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      subsToUpsert,
      'createSubscriptions',
      'preSale',
      'Upsert Subscriptions',
      SBQQ__Subscription__c.External_Id__c
    );
    List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
    for (SBQQ__Subscription__c sub : [
      SELECT Id, External_Id__c
      FROM SBQQ__Subscription__c
      WHERE Id IN :subIds
    ]) {
      subscriptionIDMap.put(sub.External_Id__c, sub);
    }

    return subscriptionIDMap;
  }
  /*****************************************************
    /* Method Name        : createAssets
    /* Method Description : Create assets from payload
    /* Method Parameters  : NA
    ******************************************************/
  public void createAssets(
    Map<String, SBQQ__Subscription__c> subscriptionIdMap,
    Map<String, SBQQ__Quote__c> quoteIdMap,
    Map<String, SBQQ__QuoteLine__c> quoteLineMap
  ) {
    List<SObject> assetsToUpsert = new List<SObject>();
    List<map<String, Object>> assetPayload = new List<Map<String, Object>>();
    Map<String, String> subassetmap = new Map<String, String>();
    Map<String, String> assetAccountMap = new Map<String, String>();
    // SCDEV-4353 [Starts]
    Set<Id> existingOwnerIds = new Set<Id>();
    // SCDEV-4353 [Ends]
    try {
      for (Object asst : (List<Object>) quoteRecord.get('quoteLines')) {
        Map<String, Object> assObj = (Map<String, object>) asst;
        if (
          (assObj.get('productCode') == 'VISITFEE' ||
          assObj.get('productSubscriptionType') == 'One-Time') &&
          (Decimal) assObj.get('effectiveQuantity') > 0
        ) {
          String Key =
            (String) assObj.get('requiredBy') +
            '-' +
            (String) assObj.get('effectiveStartDate');
          assetPayload.add(assObj);
          String subscriptionId = subscriptionIdMap.get(Key)?.Id;
          String accountId = quoteIdMap.get((String) assObj.get('quoteId'))
            ?.SBQQ__Account__c;
          subassetmap.put((String) assObj.get('quoteLineId'), subscriptionId);
          assetAccountmap.put((String) assObj.get('quoteLineId'), accountId);
        }
      }

      assetsToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        'quote.quoteLines',
        'Asset',
        assetPayload,
        'PreSale'
      );
      // SCDEV-4353 [Starts]
      /*existingOwnerIds = GCRM_ProcessOrder_Utlity.getExistingUsersIds(
        assetsToUpsert,
        'OwnerId'
      );*/
      // SCDEV-4353 [Ends]
      //Map Parent subscription and Account for the asset
      for (SObject asst : assetsToUpsert) {
        // SCDEV-4353 [Starts]
        String ownerId = (String) asst.get('ownerId');
        if (!existingOwnerIds.contains(ownerId)) {
          asst.put('OwnerId', tdSFSupportUserId);
        }
        // SCDEV-4353 [Ends]
        asst.put(
          'SBQQ__RequiredBySubscription__c',
          (String) subassetmap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
        );
        asst.put(
          'AccountId',
          assetAccountmap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
        );
        asst.put(
          'product2Id',
          quoteLineMap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
            ?.SBQQ__Product__c
        );
        asst.put(
          'Name',
          quoteLineMap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
            ?.SBQQ__Product__r.Name
        );
        asst.put('CurrencyIsoCode',oppCurrency);
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        this.muid,
        'GCRM_Process_OrderV3',
        'createAssets',
        'PreSales',
        'Asset Field Mapping',
        '',
        e
      );
    }
    //upsert all Asset Records
    Set<Id> assetIds = new Set<Id>();
    assetIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
      this.muid,
      assetsToUpsert,
      'create Asset',
      'preSale',
      'Upsert Asset',
      Asset.GCRM_Quote_Line_ID__c
    );
  }
}