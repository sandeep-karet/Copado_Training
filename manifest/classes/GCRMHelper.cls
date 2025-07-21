public class GCRMHelper {
  public static boolean earlyImplementation = false;
  public Boolean isLVN = false;
  public static String tdSFSupportUserId;
  public static String muid;
  public static String oppCurrency;
  public static String oppGUID;
  public static String accGUID;
  public static String oGUID;
  public static String orderEffectiveDate;
  public static List<Map<String, Object>> accountRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> contactRecords = new List<map<String, Object>>();
  public static List<Map<String, Object>> oppRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> quoteRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> qliRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> contractRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> visitfeeRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> subscriptionRecords = new List<Map<String, Object>>();
  public static List<Map<String, Object>> assetRecords = new List<Map<String, Object>>();
  public static Map<String,Object> orderSubscriptionMap = new Map<String,Object>();
  public static Map<String,Object> subscriptionOrderMap = new Map<String,Object>();
  public static Map<String, String> contactAccountMap = new Map<String, String>();
  public static Map<String, String> quoteOrderMap = new Map<String, String>();
  public static Map<String, String> orderItemIdmap = new Map<String, String>();
  public static Map<String, String> subQliMap = new Map<String, String>();
  public static Map<String, String> revSubMap = new Map<String, String>();
  public static Map<String, String> recordIdMap = new Map<String, String>();

  @AuraEnabled
  public static List<AsyncApexJob> getJobDetails(String jobId) {
    try {
      List<AsyncApexJob> asyncJobList = [
        SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
        FROM AsyncApexJob
        WHERE Id = :jobId
        WITH SECURITY_ENFORCED
      ];
      return asyncJobList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string executeBatch(String thisMUID) {
    try {
      GCRM_Process_V3_Bch gpab = new GCRM_Process_V3_Bch(thisMUID, true);
      Id batchJobId = Database.executeBatch(gpab);
      return batchJobId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public list<G2LCRM_Item__c> getG2LCRMItemRecords() {
    List<G2LCRM_Item__c> gitems = new List<G2LCRM_Item__c>();
    gitems = [
      SELECT
        Id,
        Action__c,
        Body__c,
        CDM_Name__c,
        MUID__c,
        Status__c,
        Processor__c
      FROM G2LCRM_Item__c
      WHERE MUID__c = :muid
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate ASC
    ];
    return gitems;
  }

  public void deleteG2ItemLogs() {
    List<G2LItemLog__c> muidLogs = [
      SELECT Id, MUID__c
      FROM G2LItemLog__c
      WHERE MUID__c = :muid
      WITH SECURITY_ENFORCED
    ];
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      muidLogs
    );
    delete decision.getRecords();
  }

  public Map<String, List<Map<String, Object>>> getRecordsByProcessors(
    List<G2LCRM_Item__c> gitems
  ) {
    Map<String, List<Map<String, Object>>> recordsByProcess = new Map<String, List<Map<String, Object>>>();
    earlyImplementation = false;
    for (G2LCRM_Item__c gitem : gitems) {
      //Get body from the payload
      //muid = gitem.MUID__c;
      Map<String, Object> body = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped(
          gitem.Body__c
        ))
        .get('body');
      if (gitem.processor__c == 'accountV3') {
        if (body?.get('account') != null) {
          Map<String, Object> accountRecord = (Map<String, Object>) body.get(
            'account'
          );
          accGUID = (String) accountRecord.get('accountGUID') != NULL ? (String) accountRecord.get('accountGUID') : NULL;
          if (!recordsByProcess.containsKey('account')) {
            recordsByProcess.put(
              'account',
              new List<Map<String, Object>>{ accountRecord }
            );
          } else {
            recordsByProcess.get('account').add(accountRecord);
          }
          recordIdMap.put(accGUID, gitem.Id);
        }
      } else if (gitem.processor__c == 'orderv3') {
        if (body?.get('order') != null) {
          Map<String, Object> orderRecord = (Map<String, Object>) body
            ?.get('order');
          oGUID = (String) orderRecord.get('orderGUID') != NULL ? (String) orderRecord.get('orderGUID') : NULL;
          oppGUID = (List<Object>) orderRecord.get('opportunities') != NULL && ((List<Object>) orderRecord.get('opportunities')).size() >0
              			? ((Map<String, Object>) ((List<Object>) orderRecord.get('opportunities'))[0]).get('opportunityGUID') != NULL
              				? (String) ((Map<String, Object>) ((List<Object>) orderRecord.get('opportunities'))[0]).get('opportunityGUID')
              				: NULL
                        :NULL;
          if (!recordsByProcess.containsKey('order')) {
            recordsByProcess.put(
              'order',
              new List<Map<String, Object>>{ orderRecord }
            );
          } else {
            recordsByProcess.get('order').add(orderRecord);
          }
          recordIdMap.put(oGUID, gitem.Id);
        }
      } else if (gitem.processor__c == 'orderitemv3') {
        List<Object> orderItems = (List<object>) ((Map<String, Object>) body
            ?.get('order'))
          ?.get('orderItems');
        if (orderItems != null) {
          for (Object oitem : orderItems) {
            Map<String, Object> oitemRecord = (Map<String, Object>) oitem;
            if (!recordsByProcess.containsKey('orderitems')) {
              recordsByProcess.put(
                'orderitems',
                new List<Map<String, Object>>{ oitemRecord }
              );
            } else {
              recordsByProcess.get('orderitems').add(oitemRecord);
            }
            recordIdMap.put((String) oitemRecord.get('orderItemGUID'),gitem.Id);
          }
        }
      } else if (gitem.processor__c == 'PreSale') {
        earlyImplementation = true;
        if (!recordsByProcess.containsKey(gitem.processor__c)) {
          recordsByProcess.put(
            gitem.processor__c,
            new List<Map<String, Object>>{ body }
          );
        } else {
          recordsByProcess.get(gitem.processor__c).add(body);
        }
      }
    }
    return recordsByProcess;
  }

  public Boolean validatePayload(
    Map<String, List<Map<String, Object>>> recordsByProcess
  ) {
    Boolean isPassedValidation = true;
    //muid = muid;
    if (!earlyImplementation) {
      //Account Validations
      if (
        recordsByProcess.get('account') != null &&
        recordsByProcess.get('account').size() > 0
      ) {
        for (Map<String, Object> acct : recordsByProcess.get('account')) {
          if (
            acct.get('accountGUID') == null ||
            acct.get('accountName') == null ||
            acct.get('currencyIsoCode') == null
          ) {
            isPassedValidation = false;
            String errMsg = 'Failed: Account is missing mandatory Fields';
            String errDetail = 'Please verify the Account GUID , Name and Currency details in the request';
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) acct.get('accountGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'accountV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
        }
      } else {
        isPassedValidation = false;
        String errMsg = 'Failed: There is no records to process';
        String errDetail =
          'There is no records found under the muid:' +
          muid +
          ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV4';
        ExceptionCustomLog.captureCustomException(
          muid,
          'GCRM_Process_OrderV4',
          'ValidatePayload',
          'accountV3',
          '',
          '',
          errMsg,
          errDetail
        );
      }
      //Order Validations
      if (
        recordsByProcess.get('order') != null &&
        recordsByProcess.get('order').size() > 0
      ) {
        for (Map<String, Object> order : recordsByProcess.get('order')) {
          if (
            order?.get('accountGUID') == null ||
            order?.get('orderGUID') == null
          ) {
            isPassedValidation = false;
            String errMsg = 'Failed: Order is missing mandatory Fields';
            String errDetail = 'Please verify the Account and Order GUID in the request';
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) order.get('orderGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'orderV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
          List<Object> opp = (List<Object>) order.get('opportunities');
          if (opp == null || opp.size() == 0) {
            isPassedValidation = false;
            String errMsg = 'Failed: Order is missing opportunity Details';
            String errDetail = 'Please verify the Opportunity Details in the request';
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) order.get('orderGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'orderV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
          if (opp != null && opp.size() > 1) {
            isPassedValidation = false;
            String errMsg = 'Failed: Request contains multiple Opportunities';
            String errDetail = 'Order can have only one Opportunity per request. Please verify';
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) order.get('orderGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'orderV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
        }
      } else {
        isPassedValidation = false;
        String errMsg = 'Failed: There is no order record to process';
        String errDetail =
          'There is no order record found under the muid:' +
          muid +
          ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV4';
        ExceptionCustomLog.captureCustomException(
          muid,
          'GCRM_Process_OrderV4',
          'ValidatePayload',
          'orderV3',
          '',
          '',
          errMsg,
          errDetail
        );
      }
      //Order Item validations
      if (
        recordsByProcess.get('orderitems') != null &&
        recordsByProcess.get('orderitems').size() > 0
      ) {
        for (Map<String, Object> oitem : recordsByProcess.get('orderitems')) {
          if (
            oitem.get('productCode') == null ||
            oitem.get('orderItemGUID') == null
          ) {
            isPassedValidation = false;
            String errMsg = 'Failed: Mandatory fields missing for Order items';
            String errDetail =
              'Please verify the product Code and GUID details for the order item ' +
              oitem.get('orderItemGUID');
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) oitem.get('orderItemGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'orderItemV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
          if (
            oitem.get('assets') == null &&
            oitem.get('subscriptions') == null
          ) {
            isPassedValidation = false;
            String errMsg = 'Failed: No Subscriptions or Assets defined for Order Item';
            String errDetail =
              'There is no subcsription or asset defined for the order Item. Either subscription or an Asset is required to process the order item ' +
              oitem.get('orderItemGUID');
            ExceptionCustomLog.captureCustomExceptionV4(
              recordIdMap.get((String) oitem.get('orderItemGUID')),
              'GCRM_Process_OrderV4',
              'ValidatePayload',
              'orderItemV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
          List<Object> subscriptions = (List<Object>) oitem.get(
            'subscriptions'
          );
          if (subscriptions != null) {
            if (subscriptions.size() > 1) {
              isPassedValidation = false;
              String errMsg = 'Failed: Multiple subscriptions defined for Order Item';
              String errDetail =
                'There are multiple subscriptions defined for the order item. There can only be one subscription per order item ' +
                oitem.get('orderItemGUID');
              ExceptionCustomLog.captureCustomExceptionV4(
                recordIdMap.get((String) oitem.get('orderItemGUID')),
                'GCRM_Process_OrderV4',
                'ValidatePayload',
                'orderItemV3',
                '',
                '',
                errMsg,
                errDetail
              );
            }
            for (Object sub : subscriptions) {
              Map<String, object> subRecord = (Map<String, Object>) sub;
              if (
                oitem.get('productCode') == 'VISITFEE' &&
                subRecord.get('LCRMVisitFeeCode') == null
              ) {
                isPassedValidation = false;
                String errMsg = 'Failed: Visit fee products require FEE Code value';
                String errDetail = 'Fee Code details are missing for the visit fee products ';
                ExceptionCustomLog.captureCustomExceptionV4(
                  recordIdMap.get((String) oitem.get('orderItemGUID')),
                  'GCRM_Process_OrderV4',
                  'ValidatePayload',
                  'orderItemV3',
                  '',
                  '',
                  errMsg,
                  errDetail
                );
              }
            }
          }
        }
      } else {
        isPassedValidation = false;
        String errMsg = 'Failed: There are no order item record to process';
        String errDetail =
          'There is no order item record found under the muid:' +
          muid +
          ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV4';
        ExceptionCustomLog.captureCustomException(
          muid,
          'GCRM_Process_OrderV4',
          'ValidatePayload',
          'orderItemV3',
          '',
          '',
          errMsg,
          errDetail
        );
      }
    }
    return isPassedValidation;
  }

  public void parseRecords(
    Map<String, List<Map<String, Object>>> recordsByProcess
  ) {
    Map<String, Object> aRecord = new Map<String, Object>();
    Map<String, Object> oRecord = new Map<String, Object>();
    Map<String, Object> qRecord = new Map<String, Object>();
    Set<String> accGUIDSet = new Set<String>();

    for (String obj : recordsByProcess.KeySet()) {
      if (obj == 'account') {
        for (Map<String, Object> acc : recordsByProcess.get(obj)) {
          //accGUID = (String) acc.get('accountGUID');
          if (!accGUIDSet.contains(accGUID)) {
            accountRecords.add(acc);
            accGUIDSet.add(accGUID);
          }
        }
      } else if (obj == 'order') {
        for (Map<String, Object> order : recordsByProcess.get(obj)) {
          orderEffectiveDate = (String) order.get('effectiveDate');
          List<Object> oppRec = (List<Object>) order.get('opportunities');
          Map<String, Object> opp = (Map<String, Object>) oppRec[0];
          List<Object> oppContacts = (List<Object>) opp.get('contacts');
          oppCurrency = (String) opp.get('currencyIsoCode');
          //oGUID = (String) order.get('orderGUID');
          //oppGUID = (String) opp.get('opportunityGUID');
          oppRecords.add(opp);
          quoteRecords.add((Map<String, Object>) order.get('quote'));
          quoteOrderMap.put(
            (String) ((Map<String, Object>) order.get('quote'))
              ?.get('quoteId'), 
            (String) (order?.get('orderGUID')));
          contractRecords.add((Map<String, Object>) order.get('contract'));
          if (oppContacts != null) {
            for (Object contct : oppContacts) {
              Map<String, Object> contactObj = (Map<String, Object>) contct;
              String oppContactAccountGUID = (String) ((Map<String, Object>) contactObj
                  ?.get('contactAccount'))
                ?.get('accountGUID');
              if (!accGUIDSet.contains(oppContactAccountGUID)) {
                accountRecords.add(
                  (Map<String, Object>) contactObj?.get('contactAccount')
                );
                accGUIDSet.add(oppContactAccountGUID);
              }
              contactAccountMap.put(
                (String) contactObj?.get('contactGUID'),
                oppContactAccountGUID
              );
              contactRecords.add(contactObj);
            }
          }
        }
      } else if (obj == 'orderitems') {
        for (Map<String, Object> orderitem : recordsByProcess.get(obj)) {
          qliRecords.add(orderitem);
          if (orderitem.get('subscriptions') != null) {
            for (Object sub : (List<Object>) orderitem.get('subscriptions')) {
              Map<String, object> subObj = (Map<String, Object>) sub;
              if (orderitem.get('productCode') == 'VISITFEE') {
                visitFeeRecords.add(subObj);
              } else {
                subscriptionRecords.add(subObj);
              }
              if (subObj.get('revisedSubscription') != null) {
                RevSubMap.put(
                  (String) subObj.get('revisedSubscription'),
                  (String) subObj.get('subscriptionId')
                );
              }
              String quotelineId = (String) subObj.get('quoteLineId') != null
                ? (String) subObj.get('quoteLineId')
                : (string) subObj.get('originalQuoteLineId');
              orderItemIdmap.put(
                (String) orderitem.get('orderItemId'),
                quotelineId
              );
              subQliMap.put((String) subObj.get('subscriptionId'), quotelineId);
              if ((String) orderitem.get('orderItemGUID') != null) {
                orderSubscriptionMap.put((String) orderitem.get('orderItemId'),subObj);
              }
              if (quotelineId != null) {
                subscriptionOrderMap.put(quotelineId,orderitem);
              }
            }
          }
          if (orderitem.get('assets') != null) {
            List<Object> assObj = (List<object>) orderitem.get('assets');
            for (Object asst : assObj) {
              Map<String, Object> assetRec = (Map<String, object>) asst;
              assetRecords.add(assetRec);
              orderItemIdmap.put(
                (String) orderitem.get('orderItemId'),
                (string) assetRec.get('latestQuoteLineId')
              );
            }
          }
        }
      } else if (obj == 'Presale') {
        for (Map<String, Object> masterPayload : recordsByProcess.get(obj)) {
          if (masterPayload.get('account') != null) {
            aRecord = (Map<String, Object>) masterPayload.get('account');
            accGUID = (String) aRecord.get('accountGUID');
            accountRecords.add(aRecord);
          }
          if (masterPayload.get('opportunity') != null) {
            oRecord = (Map<String, Object>) masterPayload.get('opportunity');
            oppRecords.add(oRecord);
            oppGUID = (String) oRecord.get('opportunityGUID');
            oppCurrency = (String) oRecord.get('currencyIsoCode');
          }
          if (masterPayload.get('quote') != null) {
            qRecord = (Map<String, Object>) masterPayload.get('quote');
            quoteRecords.add(qRecord);
            if (qRecord.get('quoteLines') != null) {
              for (Object qLine : (List<Object>) qRecord.get('quoteLines')) {
                qliRecords.add((Map<String, Object>) qLine);
              }
            }
          }
        }
      }
    }
    if (earlyImplementation && opportunityProcessed(oppGUID)) {
      GCRM_ProcessOrder_Utlity.deleteRecordsByMUID(oppGUID);
    }
    GCRM_ProcessOrder_Utlity.initUtil(GCRMHelper.oppCurrency);
  }

  public static Boolean opportunityProcessed(String oppGUID) {
    List<Opportunity> opp = [
      SELECT Id, Early_Implemented__c
      FROM Opportunity
      WHERE Opp_GUID__c = :oppGUID
      WITH SECURITY_ENFORCED
    ];
    if (opp.size() > 0) {
      return opp[0].Early_Implemented__c;
    }
    return false;
  }

  public void setdefaultOwner() {
    String defaultOwnerEmail = System.Label.Default_LV_Owner;
    tdSFSupportUserId = [
      SELECT Id
      FROM User
      WHERE Username = :defaultOwnerEmail AND IsActive = TRUE
      WITH SECURITY_ENFORCED
      LIMIT 1
    ]
    ?.Id;
  }

  public void recordstoCreate() {
    Map<String, Account> accountGUIDMap = new Map<String, Account>();
    Map<String, Contact> contactGUIDMap = new Map<String, Contact>();
    Map<String, Opportunity> opportunityGUIDMap = new Map<String, Opportunity>();
    Map<String, SBQQ__Quote__c> quoteGUIDMap = new Map<String, SBQQ__Quote__c>();
    Map<String, SBQQ__QuoteLine__c> quoteLineIdMap = new Map<String, SBQQ__QuoteLine__c>();
    Map<String, Contract> contractmap = new Map<String, Contract>();
    Map<String, SBQQ__Subscription__c> subscriptionGUIDMap = new Map<String, SBQQ__Subscription__c>();

    accountGUIDMap = createAccount();
    contactGUIDMap = createContact(accountGUIDMap);
    opportunityGUIDMap = createOpportunity(accountGUIDMap);
    createOpportunityCtRole(contactGUIDMap, opportunityGUIDMap);
    quoteGUIDMap = createQuote(opportunityGUIDMap);
    quoteLineIdMap = createQuoteLine(quoteGUIDMap);
    CreateOpportunityLineItem(opportunityGUIDMap, quoteLineIdMap);
    contractmap = createContract(opportunityGUIDMap);
    subscriptionGUIDMap = createSubscriptions(quoteLineIdMap, contractmap);
    createAssets(subscriptionGUIDMap, quoteGUIDMap, quoteLineIdMap);
  }

  public Map<String, Account> createAccount() {
    Set<Id> accountIds = new Set<Id>();
    List<SObject> accountsMapped = new List<SObject>();
    List<SObject> accountstoUpsert = new List<SObject>();
    Map<String, Account> accountguidMap = new Map<String, Account>();
    Map<String, String> accountExistsMap = new Map<String, String>();
    Map<String, Map<String, Object>> acctRecMap = new Map<String, map<String, Object>>();
    try {
      //map fields on Account Payload from custom metadata
      for (Map<String, Object> acctRec : accountRecords) {
        acctRecMap.put((String) acctRec.get('accountGUID'), acctRec);
      }
      if (acctRecMap != NULL){
        accountExistsMap = GCRM_ProcessOrder_Utlity.isExistingAccountV4(acctRecMap.keySet());
        accountsMapped = GCRM_ProcessOrder_Utlity.FieldMapping(
          'Account',
          'Account',
          accountRecords
        );
        for (SObject acct : accountsMapped) {
          if(accountExistsMap.get((String) acct.get('GUID__c')) == NULL){
            acct.put('ownerId', tdSFSupportUserId);
            Map<String, Object> accntPayload = acctRecMap.get(
              (String) acct.get('GUID__c')
            );
            List<Map<String, Object>> addresses = new List<Map<String, Object>>();
            if (accntPayload.containskey('addresses')) {
              for (Object addr : (List<Object>) accntPayload.get('addresses')) {
                addresses.add((Map<String, Object>) addr);
              }
              acct = GCRM_ProcessOrder_Utlity.ConditionalFieldMapping(
                'Account.addresses',
                'Account',
                acct,
                addresses
              );
            }
            String picklistValue = GCRM_ProcessOrder_Utlity.getPicklistMappingValue(
              'Account',
              'Account_Type__c',
              (String) acct.get('Account_Type__c')
            );
            acct.put('Account_Type__c', picklistValue);
            acct.put('Source__c','GCRM');
			accountstoUpsert.add(acct);            
          }
        }
        if (accountstoUpsert != null) {
          accountIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
            muid,
            accountstoUpsert,
            'createAccount',
            earlyImplementation ? 'Presale' : 'accountv3',
            'Upsert Account',
            Account.GUID__c
          );
        }
      }
      if ((accountIds != null && accountIds.size() > 0) || accountExistsMap.size() > 0) {
        for (Account acct : [
          SELECT Id, GUID__c, OwnerId
          FROM Account
                    WHERE Id IN :accountIds OR GUID__c IN :accountExistsMap.KeySet()
          WITH SECURITY_ENFORCED
        ]) {
          accountguidMap.put(acct.GUID__c.toUpperCase(), acct);
        }
      }
    } catch (Exception e) {
          ExceptionCustomLog.captureException(
              muid,
              'GCRM_Process_OrderV4',
              'createAccount',
              earlyImplementation ? 'Presale' : 'accountv3',
              'Account Parsing',
              '',
              e
          );
    }
    return accountguidMap;
  }

  public Map<String, Contact> createContact(
    Map<String, Account> accountGUIDMap
  ) {
    List<Contact> contactsToUpsert = new List<Contact>();
    Set<Id> contactIds = new Set<id>();
    Map<String, Contact> contactGUIDMap = new Map<String, Contact>();
    try {
      if (contactRecords != null && contactRecords.size() > 0) {
        contactsToUpsert = (List<Contact>) GCRM_ProcessOrder_Utlity.FieldMapping(
          'order.contacts',
          'Contact',
          contactRecords,
          'orderV3'
        );
        for (SObject contct : contactsToUpsert) {
          contct.put(
            'AccountId',
            getValueIgnoreCase(accountGUIDMap, contactAccountMap.get(String.valueOf(contct.get('GUID__c'))))?.Id
            
          );
          contct.put('ownerId', tdSFSupportUserId);
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'CreateContact',
        'orderV3',
        'Order Contact Parsing',
        '',
        e
      );
    }
    if (contactsToUpsert != null) {
      contactIds = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        contactsToUpsert,
        'CreateContact',
        'orderV3',
        'Upsert Contact',
        Contact.Source_Id__c
      );
    }
    if (contactIds != null && contactIds.size() > 0) {
      for (Contact contct : [
        SELECT Id, GUID__c, Source_Id__c
        FROM Contact
        WHERE Id IN :contactIds
        WITH SECURITY_ENFORCED
      ]) {
        contactGUIDMap.put(contct.GUID__c.toUpperCase(), contct);
      }
    }
    return contactGUIDMap;
  }

  public Map<String, Opportunity> createOpportunity(
    Map<String, Account> accountGUIDMap
  ) {
    Set<id> oppIds = new Set<Id>();
    Set<String> oppGUIDs = new Set<String>();
    List<SObject> opportunityToUpsert = new List<SObject>();
    Map<String, String> oppAccountMap = new Map<String, String>();
    Map<String, Opportunity> opportunityGUIDMap = new Map<String, Opportunity>();
    for (Map<String, Object> oppRec : oppRecords) {
      oppGUIDs.add((String) oppRec.get('opportunityGUID'));
    }
    List<Opportunity> targetOpportunities = [
      SELECT
        Id,
        Name,
        Opp_Guid__c,
        Amount,
        StageName,
        AccountId,
        Early_Implemented__c,
        Source__c,
        Initial_of_Lives__c,
        CloseDate,
        CreatedDate,
        Pricebook2Id
      FROM Opportunity
      WHERE Opp_Guid__c = :oppGUIDs
      WITH SECURITY_ENFORCED
    ];
    if (!targetOpportunities.isEmpty()) {
      SOBject opp = (SObject) targetOpportunities[0];
      opp.put('StageName', 'Discovery');
      opportunityToUpsert.add(opp);
    } else {
      try {
        for (Map<String, Object> oppRecs : oppRecords) {
          oppAccountMap.put(
            (String) oppRecs.get('opportunityGUID'),
            (String) oppRecs.get('accountGUID')
          );
        }
        opportunityToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
          'order.opportunities',
          'Opportunity',
          oppRecords
        );
        //Map Parent account for Opportunity
        for (SObject opp : opportunityToUpsert) {
          opp.put(
            'AccountId',
            getValueIgnoreCase(accountGUIDMap,oppAccountMap.get(String.valueOf(opp.get('Opp_Guid__c')))) ?.Id
          );
          opp.put('ownerId', tdSFSupportUserId);
          opp.put(
            'PriceBook2Id',
            GCRM_ProcessOrder_Utlity.mappedPbe.values()[0].Pricebook2Id
          );
          opp.put('StageName', 'Discovery');
          opp.put('Source__c','GCRM');
          if (!earlyImplementation){
              opp.put('CloseDate',Date.valueOf(orderEffectiveDate));
          } if (earlyImplementation) {
            opp.put('Early_Implemented__c', earlyImplementation); //Early implementation will be true only for Presale payload
          }
        }
      } catch (Exception e) {
        ExceptionCustomLog.captureException(
          muid,
          'GCRM_Process_OrderV4',
          'createOpportunity',
          earlyImplementation ? 'Presale' : 'orderv3',
          'Opportunity Parsing',
          '',
          e
        );
      }
    }
    //Upsert the Opporutnities mapped
    if (opportunityToUpsert != null) {
      oppIds = GCRM_ProcessOrder_Utlity.UpsertRecords(
        muid,
        opportunityToUpsert,
        'createOpportunity',
        earlyImplementation ? 'Presale' : 'orderv3',
        'Upsert Opportunity',
        Opportunity.Opp_Guid__c
      );
    }
    if (oppIds != null && oppIds.size() > 0) {
      for (Opportunity opp : [
        SELECT Id, Opp_Guid__c, AccountId, Pricebook2Id, Early_Implemented__c
        FROM Opportunity
        WHERE Id IN :oppIds
        WITH SECURITY_ENFORCED
      ]) {
        opportunityGUIDMap.put(opp.Opp_Guid__c.toUpperCase(), opp);
      }
    }
    return opportunityGUIDMap;
  }

  public void createOpportunityCtRole(
    Map<String, Contact> contactGUIDMap,
    Map<String, Opportunity> opportunityGUIDMap
  ) {
    List<Map<String, Object>> oppContacts = new List<Map<String, Object>>();
    Map<String, OpportunityContactRole> oppctRoleMap = new Map<String, OpportunityContactRole>();
    List<OpportunityContactRole> ctRoleToUpsert = new List<opportunityContactRole>();
    Set<id> ctroleids = new Set<Id>();
    String oppId;
    try {
      if (contactGUIDMap != null) {
        oppId = opportunityGUIDMap.values()[0].Id;
        for (OpportunityContactRole ctRole : [
          SELECT Id, ContactId, OpportunityId
          FROM OpportunityContactRole
          WHERE OpportunityId = :oppId
          WITH SECURITY_ENFORCED
        ]) {
          oppctRoleMap.put(
            String.valueOf(ctRole.ContactId) +
            String.valueOf(ctRole.OpportunityId),
            ctRole
          );
        }
        ctRoleToUpsert = (List<OpportunityContactRole>) GCRM_ProcessOrder_Utlity.FieldMapping(
          'order.opportunities.contacts.contactrole',
          'OpportunityContactRole',
          contactRecords,
          'orderV3'
        );
        for (OpportunityContactRole ctrole : ctRoleToUpsert) {
          ctrole.put(
            'ContactId',
            getValueIgnoreCase(contactGUIDMap,String.valueOf(ctrole.get('Contact_GUID__c')))?.Id
          );
          ctrole.put('OpportunityId', opportunityGUIDMap.values()[0].Id);
          if (
            oppctRoleMap.get(
              getValueIgnoreCase(contactGUIDMap,String.valueOf(ctrole.get('Contact_GUID__c')))?.Id +
              oppId
            ) != null
          ) {
            ctrole.put(
              'Id',
              oppctRoleMap.get(
                  getValueIgnoreCase(contactGUIDMap, String.valueOf(ctrole.get('Contact_GUID__c')))
                    ?.Id + oppId
                )
                ?.Id
            );
          }
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createOpportunityCtRole',
        'orderV3',
        'Opportunity Contact parsing',
        '',
        e
      );
    }

    //Upsert the opp Line items mapped
    if (ctRoleToUpsert != null) {
      ctroleids = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        ctRoleToUpsert,
        'CreateOpportunityCtRole',
        'orderV3',
        'Upsert Opportunity Contact Role',
        null
      );
    }
  }

  public Map<String, SBQQ__Quote__c> createQuote(
    Map<String, Opportunity> opportunityGUIDMap
  ) {
    Map<String, SBQQ__Quote__c> quoteGUIDMap = new Map<String, SBQQ__Quote__c>();
    Map<String, String> quoteOppMap = new Map<String, String>();
    List<SBQQ__Quote__c> quotesToUpsert = new List<SBQQ__Quote__c>();
    Set<id> quoteIds = new Set<Id>();
    String primaryOppGUID;
    String objectName;
    try {
      //populate quotOppMap for mapping opportunities
      Integer iteration = 0;
      for (Map<String, Object> quoteRec : quoteRecords) {
        String oppGUID = oppRecords.isEmpty()
          ? (String) quoteRec.get('opportunityGUID')
          : (String) ((Map<String, Object>) oppRecords[0])
              .get('opportunityGUID');
        String gcrmQuoteId = quoteRec.get('quote') != null
          ? (String) (((Map<String, Object>) quoteRec.get('quote'))
              ?.get('quoteId'))
          : (String) quoteRec.get('quoteId');
        quoteOppMap.put(gcrmQuoteId, oppGUID);
        primaryOppGUID = iteration == 0 ? oppGUID : primaryOppGUID; //Get the first opportunity and make it as primary Opportunity
        iteration++;
      }
      // Basic Field Mapping pass quotePayload parameter as is
      quotesToUpsert = (List<SBQQ__Quote__c>) GCRM_ProcessOrder_Utlity.FieldMapping(
        earlyImplementation ? 'quote' : 'order',
        'SBQQ__Quote__c',
        quoteRecords,
        earlyImplementation ? 'PreSale' : 'orderV3'
      );
       System.debug('In create quote quotesToUpsert');
       System.debug(quotesToUpsert);
      for (SObject quote : quotesToUpsert) {
        if(!earlyImplementation){
        	quote.put('External_Id__c',(String) quoteOrderMap.get((String) quote.get('GCRM_Quote_ID__c')));
            quote.put('SBQQ__Primary__c', true);
        }
        String key = (String) quote.get('GCRM_Quote_ID__c');
        quote.put(
          'SBQQ__Opportunity2__c',
          getValueIgnoreCase(opportunityGUIDMap,quoteOppMap.get(key))?.Id
        );
        quote.put(
          'SBQQ__Account__c',
          getValueIgnoreCase(opportunityGUIDMap,quoteOppMap.get(key))?.get('AccountId')
        );
        quote.put('ownerId', tdSFSupportUserId);
      }
       System.debug('In create quote quotesToUpsert again');
       System.debug(quotesToUpsert);
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createQuote',
        earlyImplementation ? 'PreSale' : 'orderv3',
        'CPQ Quote Field Mapping',
        '',
        e
      );
    }
    //Upsert Logic
    if (quotesToUpsert != null && quotesToUpsert.size() > 0) {
      quoteIds = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        quotesToUpsert,
        'createQuote',
        earlyImplementation ? 'PreSale' : 'orderv3',
        'Upsert Quote',
        SBQQ__Quote__c.GCRM_Quote_ID__c
      );
    }
    //Query Logic
    if (quoteIds != null && quoteIds.size() > 0) {
      for (SBQQ__Quote__c quote : [
        SELECT Id, GCRM_Quote_ID__c, External_Id__c, SBQQ__Account__c
        FROM SBQQ__Quote__c
        WHERE Id IN :quoteIds
        WITH SECURITY_ENFORCED
      ]) {
        quoteGUIDMap.put(
          (earlyImplementation)
            ? quote.GCRM_Quote_ID__c //Presale payload
            : quote.External_Id__c, //Postsale payload
          quote
        );
      }
    }
    //Enabling the primary checkbox in SBQQ__Quote.
    if (earlyImplementation) {
      System.debug('In create quote quoteGUIDMap'+quoteGUIDMap);
      GCRM_ProcessOrder_Utlity.setPrimaryQuote(
        primaryOppGUID,
        quoteGUIDMap.values()[0]?.Id
      );
    }
    return quoteGUIDMap;
  }

  public Map<String, SBQQ__QuoteLine__c> createQuoteLine(
    Map<String, SBQQ__Quote__c> quoteMap
  ) {
    Set<id> qliids = new Set<Id>();
    List<SObject> qliToUpsert = new List<SObject>();
    List<SBQQ__QuoteLine__c> quoteLinestoUpdate = new List<SBQQ__QuoteLine__c>();
    Map<String, SBQQ__QuoteLine__c> quoteLinemap = new Map<String, SBQQ__QuoteLine__c>();
    Map<String, SBQQ__QuoteLine__c> quoteLineExternalIdMap = new Map<String, SBQQ__QuoteLine__c>();
    Map<String, String> requiredByMap = new Map<String, String>();
    Map<String, Id> productIdMap = new Map<String, Id>();
    String jsonObjectName;
    try {
      for (Map<String, object> qli : qliRecords) {
        String productMapKey = (String) qli.get('orderItemId') != null
          ? (String) qli.get('orderItemId')
          : (String) qli.get('quoteLineId');
        if(earlyImplementation){
           requiredByMap.put((String) qli.get('quoteLineId'), (String) qli.get('requiredBy'));
        } else {
           requiredByMap.put((String) qli.get('orderItemId'), (String) qli.get('requiredBy'));
        }
        PricebookEntry pbe = GCRM_ProcessOrder_Utlity.getProductId(qli, oppCurrency);
        productIdMap.put(
          productMapKey,
          pbe.Product2Id != NULL ? pbe.Product2Id : NULL
        );
      }

      jsonObjectName = earlyImplementation
        ? 'quote.quoteLines'
        : 'order.orderitem';
      qliToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        jsonObjectName,
        'SBQQ__QuoteLine__c',
        qliRecords,
        earlyImplementation ? 'Presale' : 'orderItemV3'
      );

      for (SObject qli : qliToUpsert) {
        if (quoteMap.size() > 0) {
          qli.put('SBQQ__Quote__c', (quoteMap.values())[0].Id);
        }
        qli.put(
          'SBQQ__Product__c',
          qli.get('External_Id__c') != null
            ? productIdMap.get((String) qli.get('External_Id__c')) //Postsale payload
            : productIdMap.get((String) qli.get('GCRM_Quote_Line_ID__c')) //Presale payload
        );
		
        //Custom mappings for field values from subscription section
        if(!earlyImplementation
           && (String) qli.get('External_Id__c') != null){
            if(orderSubscriptionMap.get((String) qli.get('External_Id__c')) != null){
                Map<string,object> sub = (Map<string,object>) orderSubscriptionMap.get((String) qli.get('External_Id__c'));
                qli.put('Anchor__c', (Boolean) sub.get('isAnchor'));
                qli.put('Bundle_Type__c', (String) sub.get('bundleType'));
                qli.put('Consult_Type__c', (String) sub.get('consultType'));
                qli.put('SBQQ__StartDate__c', Date.valueOf(String.valueOf(sub.get('subscriptionStartDate'))));
                qli.put('Participant_Quantity__c', (Decimal) sub.get('quoteLineParticipantQuantity'));
				qli.put('Vendor_Partner__c', (String) sub.get('vendorPartner')); // Added for SCDEV-5357
            }  
        }
        String gcrmQuoteLineId = !(orderItemIdmap.isEmpty())
          ? orderItemIdmap.get((String) qli.get('External_Id__c')) //Postsale payload
          : (String) qli.get('GCRM_Quote_Line_ID__c'); //Presale payload
		qli.put('GCRM_Quote_Line_ID__c', gcrmQuoteLineId);
        qli.put('CurrencyIsoCode',oppCurrency);
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createQuoteLines',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'CPQ Quote Lines Field Mapping',
        '',
        e
      );
    }

    //Upsert the Quote Line items mapped
    if (qliToUpsert != null && qliToUpsert.size() > 0) {
      qliids = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        qliToUpsert,
        'CreateQuoteLineItem',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Upsert Quote line',
        SBQQ__QuoteLine__c.GCRM_Quote_Line_ID__c
      );
    }

    if (qliids != null && qliids.size() > 0) {
      List<SBQQ__QuoteLine__c> qliList = [
        SELECT
          Id,
          External_Id__c,
          GCRM_Quote_Line_ID__c,
          SBQQ__Quote__r.SBQQ__Account__c,
          SBQQ__Product__c,
          SBQQ__RequiredBy__c,
          SBQQ__Product__r.Name
        FROM SBQQ__QuoteLine__c
        WHERE Id IN :qliids
        WITH SECURITY_ENFORCED
      ];
      for (SBQQ__QuoteLine__c qli : qliList) {
        if(earlyImplementation){
            quoteLineExternalIdMap.put(qli.GCRM_Quote_Line_Id__c, qli);	//Presale
        } else{
            quoteLineExternalIdMap.put(qli.External_Id__c, qli);	//PostSale
        }
        quoteLinemap.put(qli.GCRM_Quote_Line_ID__c, qli);
      }
      for(SBQQ__QuoteLine__c qliUpdate : qliList){
          if (requiredByMap.get(qliUpdate.External_Id__c) != null) {	//PostSale
              qliUpdate.put('SBQQ__RequiredBy__c',quoteLineExternalIdMap.get(
                  requiredByMap.get(qliUpdate.External_Id__c)
              )
              .id);
          } else if (requiredByMap.get(qliUpdate.GCRM_Quote_Line_Id__c) != null){	//Presale
              qliUpdate.put('SBQQ__RequiredBy__c',quoteLineExternalIdMap.get(
                  requiredByMap.get(qliUpdate.GCRM_Quote_Line_Id__c)
              )
              .id);
          }
          quoteLinestoUpdate.add(qliUpdate);   
       }
    }
    if (quoteLinestoUpdate != null && quoteLinestoUpdate.size() > 0) {
      GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        quoteLinestoUpdate,
        'CreateQuoteLineItem',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Upsert Quote line',
        SBQQ__QuoteLine__c.GCRM_Quote_Line_ID__c
      );
    }
    return quoteLinemap;
  }
    
  public void createOpportunityLineItem(
    Map<String, Opportunity> opportunityMap,
    Map<String, SBQQ__QuoteLine__c> quoteLineMap
  ) {
    Set<id> oppliIds = new Set<Id>();
    List<Map<String, Object>> oppLiPayload = new List<map<String, Object>>();
    List<SObject> oppLiToUpsert = new List<SObject>();
    Map<String, Id> productIdMap = new Map<String, Id>();
    Map<String, Id> priceBookIdMap = new Map<String, Id>();
    Map<String, Decimal> totalPriceMap = new Map<String, Decimal>();
    String jsonObjectName;
    try {
      for (Object oppli : qliRecords) {
        Map<String, Object> oppliObj = (Map<String, Object>) oppli;
        if ((earlyImplementation && (Decimal) oppliObj.get('effectiveQuantity') > 0)
            || !earlyImplementation){
        oppLiPayload.add(oppliObj);
        String mapKey = (String) oppliObj.get('orderItemGUID') != null
          ? (String) oppliObj.get('orderItemGUID') //Postsale payload
          : (String) oppliObj.get('quoteLineId'); //Presale Payload
            PricebookEntry pbe = GCRM_ProcessOrder_Utlity.getProductId(oppliObj, oppCurrency);
        productIdMap.put(
          mapKey,
              pbe.Product2Id != NULL ? pbe.Product2Id : NULL
        );
            priceBookIdMap.put(
              mapKey,
              pbe != NULL ? pbe.Id : NULL
            );
            if (earlyImplementation) {
        //Calculation of Total price for Presale payload. For Postsale, it's mapped via fieldmapping
        if (
          oppliObj.get('listPrice') != null &&
          oppliObj.get('effectiveQuantity') != null
        ) {
          totalPriceMap.put(
            mapKey,
            Decimal.valueOf(String.valueOf(oppliObj.get('listPrice'))) *
            Decimal.valueOf(String.valueof(oppliObj.get('effectiveQuantity')))
          );
        }
          //Presale
          String family = GCRM_ProcessOrder_Utlity.getProductFamily(
            oppliObj,
            oppCurrency
          );
          if (isLVN == false && family?.containsIgnoreCase('livongo')) {
            isLVN = true;
          }
        }
      }
      }
      jsonObjectName = earlyImplementation
        ? 'quote.quoteLines'
        : 'order.orderitem';
      oppLiToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        jsonObjectName,
        'OpportunityLineItem',
        oppLiPayload,
        earlyImplementation ? 'Presale' : 'orderItemV3'
      );

      for (SObject oppli : oppLiToUpsert) {
        if (OpportunityMap.size() > 0) {
          String gcrmQuoteLineId = orderItemIdmap.get(
              (String) oppli.get('Source_Id__c')
            ) != null
            ? orderItemIdmap.get((String) oppli.get('Source_Id__c')) //Postsale payload
            : (String) oppli.get('GCRM_Quote_Line_ID__c'); //Presale payload;
          String productId = (String) oppli.get('GUID__c') != null
            ? (String) oppli.get('GUID__c')
            : (String) oppli.get('GCRM_Quote_Line_ID__c');
          oppli.put('OpportunityId', OpportunityMap.values()[0].Id);
          oppli.put('Product2Id', productIdMap.get(productId));
          oppli.put('PricebookEntryId', priceBookIdMap.get(productId));
          oppli.put('GCRM_Quote_Line_ID__c', gcrmQuoteLineId);
          oppli.put(
            'SBQQ__QuoteLine__c',
            quoteLineMap.get(gcrmQuoteLineId)?.Id
          );
          oppli.put(
            'TotalPrice',
            oppli.get('TotalPrice') == null
              ? totalPriceMap.get((String) oppli.get('GCRM_Quote_Line_ID__c')) //Presale payload
              : oppli.get('TotalPrice') //Postsale payload
          );
          //Custom mappings for field values from subscription section
          if(!earlyImplementation
           && (String) oppli.get('Source_Id__c') != null){
            if(orderSubscriptionMap.get((String) oppli.get('Source_Id__c')) != null){
                Map<string,object> sub = (Map<string,object>) orderSubscriptionMap.get((String) oppli.get('Source_Id__c'));
                oppli.put('Anchor__c', (Boolean) sub.get('isAnchor'));
                oppli.put('Bundle_Type__c', (String) sub.get('bundleType'));
                oppli.put('Consult_Fees__c', (Decimal) sub.get('consultFee'));
				oppli.put('Vendor_Partner__c', (String) sub.get('vendorPartner')); // Added for SCDEV-5357
            }  
          }
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createOpportunityLineItem',
        earlyImplementation ? 'Presale' : 'orderitemv3',
        'Opportunity Line Item Field Mapping',
        '',
        e
      );
    }

    //Upsert the opp Line items mapped
    if (oppLiToUpsert != null) {
      oppliIds = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        oppLiToUpsert,
        'createOpportunityLineItem',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Upsert Opportunity line',
        OpportunityLineItem.GCRM_Quote_Line_ID__c
      );
    }
  }

  public Map<String, Contract> createContract(
    Map<String, Opportunity> opportunityGUIDMap
  ) {
    String accountId;
    Opportunity targetOpp = new Opportunity();
    Set<id> ctrids = new Set<Id>();
    List<SObject> contractToUpsert = new List<SObject>();
    Map<String, Contract> contractMap = new Map<String, Contract>();
    try {
      targetOpp = opportunityGUIDMap?.values()[0];
      accountId = targetOpp?.accountId;
      if (targetOpp?.Early_Implemented__c && !(contractRecords.isEmpty())) {
        for (Contract ctr : [
          SELECT
            Id,
            Name,
            ContractTerm,
            SBQQ__Opportunity__c,
            Pricebook2Id,
            AccountId,
            External_Id__c
          FROM Contract
          WHERE SBQQ__Opportunity__c = :targetOpp.Id AND AccountId = :accountId
          WITH SECURITY_ENFORCED
        ]) {
          contractMap.put(ctr.External_Id__c, ctr);
        }
      } else if (!(contractRecords.isEmpty())) {
        for (Contract ctr : [
          SELECT
            Id,
            Name,
            ContractTerm,
            SBQQ__Opportunity__c,
            Pricebook2Id,
            AccountId,
            External_Id__c
          FROM Contract
          WHERE
            External_Id__c = :(String) ((Map<String, Object>) contractRecords[0])
              .get('contractId')
            AND SBQQ__Opportunity__c = :targetOpp.Id
            AND AccountId = :accountId
          WITH SECURITY_ENFORCED
        ]) {
          contractMap.put(ctr.External_Id__c, ctr);
        }
      }
      if (contractMap != null && contractMap.size() > 0) {
        System.debug('In helper(createContract) Contract already exists');
        System.debug(contractMap);
        return contractMap;
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createContract',
        earlyImplementation ? 'Presale' : 'orderv3',
        'Existing Contract return',
        '',
        e
      );
    }
    try {
      //Postsale payload
      if (contractRecords.size() > 0) {
        contractToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
          'order.contract',
          'Contract',
          contractRecords
        );
      }
      //Presale payload
      else {
        SObject ctr = new Contract();
        contractToUpsert.add(ctr);
      }
      for (SObject ctr : contractToUpsert) {
        ctr.put('SBQQ__Opportunity__c', targetOpp.Id);
        ctr.put('Pricebook2Id', targetOpp.Pricebook2Id);
        ctr.put('AccountId', accountId);
        ctr.put('OwnerId', tdSFSupportUserId);
        //Presale payload
        if (earlyImplementation) {
          if (
            (Boolean) ((Map<String, Object>) quoteRecords[0])
              .containsKey('subscriptionTerm')
          ) {
            ctr.put(
              'ContractTerm',
              Integer.valueOf(
                String.valueOf(
                  ((Map<String, Object>) quoteRecords[0])
                    ?.get('subscriptionTerm')
                )
              )
            );
          }
          //Presale payload
          ctr.put('ContractTerm', 12);
          String oppName = ((String) ((Map<String, Object>) oppRecords[0])
            ?.get('opportunityName'));
          OppName = OppName.length() > 80 ? OppName.substring(0, 80) : OppName;
          ctr.put('Name', OppName);
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createContract',
        earlyImplementation ? 'Presale' : 'orderV3',
        'Contract Field Mapping',
        '',
        e
      );
    }
    if (contractToUpsert != null && contractToUpsert.size() > 0) {
      ctrids = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        contractToUpsert,
        'createContract',
        earlyImplementation ? 'Presale' : 'orderV3',
        'Upsert Contract',
        !earlyImplementation ? Contract.External_Id__c : null
      );
    }
    if (ctrids != null && ctrids.size() > 0) {
      for (Contract ctr : [
        SELECT Id, External_Id__c, AccountId
        FROM Contract
        WHERE Id IN :ctrids
        WITH SECURITY_ENFORCED
      ]) {
        contractMap.put(
          ctr.External_Id__c != null ? ctr.External_Id__c : ctr.Id,
          ctr
        );
      }
    }
    return contractMap;
  }

  public Map<String, SBQQ__Subscription__c> createSubscriptions(
    Map<String, SBQQ__QuoteLine__c> quoteLineGUIDMap,
    Map<String, Contract> contractmap
  ) {
    Set<id> subIds = new Set<Id>();
    set<String> mdqKeyset = new Set<String>();
    List<Map<String, Object>> subsPayloadConditional;
    List<Map<String, Object>> subsPayload = new List<map<String, Object>>();
    List<SObject> subsToUpsert = new List<SObject>();
    Map<String, SBQQ__Subscription__c> subIdMap = new Map<String, SBQQ__Subscription__c>();
    Map<String, SBQQ__Subscription__c> parentSubsMap = new Map<String, SBQQ__Subscription__c>();
    Map<String, SObject> suscriptionMap = new Map<String, SObject>();
    String jsonObjectName;

    try {
      if (subscriptionRecords != null && subscriptionRecords.size() > 0) {
        //Postsale
        subscriptionRecords = subscriptionRecords;
      } else if (earlyImplementation) {
        //Presale
        if (qliRecords != null && qliRecords.size() > 0) {
          subscriptionRecords = qliRecords;
        }
      }
      for (Map<String, Object> subs : subscriptionRecords) {
        if (earlyImplementation) {
          if (
            subs.get('productCode') != 'VISITFEE' &&
            subs.get('productSubscriptionType') != 'one-Time' &&
            (Decimal) subs.get('effectiveQuantity') > 0
          ) {
            subsPayload.add(subs); //Presale
          }
        } else {
          subsPayload.add(subs); //Postsale
        }
      }
      jsonObjectName = earlyImplementation
        ? 'quote.quoteLines'
        : 'order.orderitem';
      subsToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
        jsonObjectName,
        'SBQQ__Subscription__c',
        subsPayload,
        earlyImplementation ? 'Presale' : 'orderItemV3'
      );
      for (SObject sub : subsToUpsert) {
        if (sub?.get('GCRM_Quote_Line_ID__c') == null) {
          subsPayloadConditional = new List<Map<String, Object>>();
          subsPayloadConditional.add(sub.getPopulatedFieldsAsMap());
          sub = GCRM_ProcessOrder_Utlity.ConditionalFieldMapping(
            jsonObjectName,
            'SBQQ__Subscription__c',
            sub,
            subsPayloadConditional
          );
        }
        if (quoteLineGUIDMap.size() > 0) {
          String externalkey =
            (String) sub.get('GCRM_Quote_Line_ID__c') +
            '-' +
            String.valueOf(
              Date.valueOf(sub.get('SBQQ__SubscriptionStartDate__c'))
            );
          SBQQ__QuoteLine__c qliRec = quoteLineGUIDMap?.get((String) sub?.get('GCRM_Quote_Line_ID__c'));
          sub.put('SBQQ__QuoteLine__c', qliRec?.Id);
          sub.put('SBQQ__Product__c', qliRec?.SBQQ__Product__c);
          if (contractmap != null && contractmap.size() > 0) {
            sub.put('SBQQ__Account__c', contractmap.values()[0].AccountId);
            sub.put('SBQQ__Contract__c', contractmap.values()[0].Id);
          }
          //Custom mappings for field values from order item section
          if(!earlyImplementation
             && subscriptionOrderMap.get((String) sub.get('GCRM_Quote_Line_ID__c')) != NULL){
             Map<String, object> oItem = (Map<String,Object>) subscriptionOrderMap.get((String) sub.get('GCRM_Quote_Line_ID__c'));
             sub.put('Current_Membership_Fee__c', oItem.get('membershipFee')); 
          }
          sub.put('External_Id__c', externalkey);
          sub.put('OwnerId', tdSFSupportUserId);
          sub.put('CurrencyIsoCode',oppCurrency);
          suscriptionMap.put(externalkey, sub);
          parentSubsMap.put(
            (String) sub.get('GCRM_Quote_Line_ID__c'),
            (SBQQ__Subscription__c) sub
          );
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createSubscriptions',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Subscription Field Mapping',
        '',
        e
      );
    }
    try {
      //check if the current payload is MDQ - chekcing if same visit fee product is present multiple times
      Boolean isMDQ = false;
      if (visitFeeRecords != null && visitFeeRecords.size() > 0) {
        visitFeeRecords = visitFeeRecords; //Postsale
      } else if (earlyImplementation) {
        if (qliRecords != null && qliRecords.size() > 0) {
          //Presale
          visitFeeRecords = qliRecords;
        }
      }
      for (Map<String, Object> visitfees : visitFeeRecords) {
        if (earlyImplementation) {
          //Presale
          if (visitfees.get('productCode') == 'VISITFEE') {
            if (
              mdqKeyset.contains(
                (String) visitfees.get('feeCode') +
                  '-' +
                  (String) visitfees.get('requiredById')
              )
            ) {
              isMDQ = true;
              break;
            } else {
              mdqKeyset.add(
                (String) visitfees.get('feeCode') +
                  '-' +
                  (String) visitfees.get('requiredById')
              );
            }
          }
        } else {
          //Postsale
          if (
            mdqKeyset.contains(
              (String) visitfees.get('LCRMVisitFeeCode') +
                '-' +
                (String) visitfees.get('requiredById')
            )
          ) {
            isMDQ = true;
            break;
          } else {
            mdqKeyset.add(
              (String) visitfees.get('LCRMVisitFeeCode') +
                '-' +
                (String) visitfees.get('requiredById')
            );
          }
        }
      }

      //Create additional Subscriptions based on parent Subscription for MDQ Scenario
      if (isMDQ) {
        System.debug('In helper(createSubscriptionV4) MDQ');
        for (Map<String, Object> assObj : visitFeeRecords) {
          String key;
          String gcrmQliId;
          if (earlyImplementation) {
            //Presale
            key =
              (String) assObj.get('requiredBy') +
              '-' +
              (String) assobj.get('effectiveStartDate');
          } else {
            //Postsale
            gcrmQliId = subQliMap.get(
                RevSubMap.get((String) assObj.get('requiredById'))
              ) != null
              ? subQliMap.get(
                  RevSubMap.get((String) assObj.get('requiredById'))
                )
              : subQliMap.get((String) assObj.get('requiredById'));
            key =
              gcrmQliId +
              '-' +
              (String) assobj.get('subscriptionStartDate');
          }
          if (suscriptionMap.get(key) == null) {
            SObject parentSubscription = (earlyImplementation &&
              (String) assObj.get('productCode') == 'VISITFEE' &&
              (Decimal) assObj.get('effectiveQuantity') > 0)
              ? parentSubsMap.get((String) assObj.get('requiredBy'))
              : parentSubsMap.get(gcrmQliId);
            if (parentSubscription != null) {
              SObject dupSubs = parentSubscription.clone();
              dupSubs
                ?.put(
                  'SBQQ__SubscriptionStartDate__c',
                  earlyImplementation
                    ? Date.valueOf(
                        String.valueOf(assObj.get('effectiveStartDate'))
                      ) //Presale
                    : Date.valueOf(
                        String.valueOf(assObj.get('subscriptionStartDate'))
                      )
                ); //Postsale
              dupSubs
                ?.put(
                  'GCRM_Quote_Line_Id__c',
                  (String) assObj.get('quoteLineId')
                );
              dupSubs?.put('External_Id__c', key);
              dupSubs?.put('OwnerId', tdSFSupportUserId);
              dupSubs?.put('CurrencyIsoCode', oppCurrency);
              suscriptionMap.put(key, dupSubs);
              subsToUpsert.add(dupSubs);
            }
          }
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createSubscriptions',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'MDQ Subscription Creation',
        '',
        e
      );
    }
    //upsert all the subscription records
    if (subsToUpsert != null && subsToUpsert.size() > 0) {
      subIds = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        subsToUpsert,
        'createSubscriptions',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Upsert Subscriptions',
        SBQQ__Subscription__c.External_Id__c
      );
    }
    if (subIds != null && subIds.size() > 0) {
      for (SBQQ__Subscription__c subs : [
        SELECT Id, External_Id__c
        FROM SBQQ__Subscription__c
        WHERE Id IN :subIds
        WITH SECURITY_ENFORCED
      ]) {
        subIdMap.put(subs.External_Id__c, subs);
      }
    }
    return subIdMap;
  }

  public void createAssets(
    Map<String, SBQQ__Subscription__c> subscriptionIdMap,
    Map<String, SBQQ__Quote__c> quoteIdMap,
    Map<String, SBQQ__QuoteLine__c> quoteLineMap
  ) {
    Set<Id> assetIds = new Set<Id>();
    List<SObject> assetsToUpsert = new List<SObject>();
    List<map<String, Object>> assetPayload = new List<Map<String, Object>>();
    List<Map<String, Object>> assetPayloadFieldMap = new List<Map<String, Object>>();
    Map<String, String> subassetmap = new Map<String, String>();
    Map<String, String> assetAccountMap = new Map<String, String>();
    SObject asstObj;
    try {
      if (earlyImplementation) {
        //Presale
        if (qliRecords != null && qliRecords.size() > 0) {
          assetPayload = qliRecords;
        }
      } else {
        //Postsale
        for (Map<String, Object> assObj : visitFeeRecords) {
          assetPayload.add(assObj);
        }
        for (Map<String, Object> assObj : assetRecords) {
          assetPayload.add(assObj);
        }
      }

      //Map Parent subscription and Account for the asset
      for (Map<String, Object> asst : assetPayload) {
        String gcrmQliId;
        String key;
        String accountId;
        List<Map<String, Object>> asstpayload = new List<Map<String, Object>>();
        if (earlyImplementation) {
          //Presale
          if (
            (asst.get('productCode') == 'VISITFEE' ||
            asst.get('productSubscriptionType') == 'one-Time') &&
            (Decimal) asst.get('effectiveQuantity') > 0
          ) {
            key =
              (String) asst.get('requiredBy') +
              '-' +
              (String) asst.get('effectiveStartDate');
            accountId = quoteIdMap.get((String) asst.get('quoteId'))
              ?.SBQQ__Account__c;
            assetAccountmap.put((String) asst.get('quoteLineId'), accountId);
            String subscriptionId = subscriptionIdMap.get(Key)?.Id;
            subassetmap.put((String) asst.get('quoteLineId'), subscriptionId);
            assetPayloadFieldMap.add(asst);
          }
        } else {
          //Postsale
          gcrmQliId = subQliMap.get(
              RevSubMap.get((String) asst.get('requiredById'))
            ) != null
            ? subQliMap.get(RevSubMap.get((String) asst.get('requiredById')))
            : subQliMap.get((String) asst.get('requiredById'));
          key = gcrmQliId + '-' + (String) asst.get('subscriptionStartDate');
          String subscriptionId = subscriptionIdMap.get(Key)?.Id;
          subassetmap.put(Key, subscriptionId);
          asstpayload.add(asst);
          SObject assObj = GCRM_ProcessOrder_Utlity.conditionalFieldMapping(
            'order.orderitem',
            'Asset',
            null,
            asstpayload
          );
          assObj.put(
            'SBQQ__RequiredBySubscription__c',
            (String) subassetmap.get(key)
          );

          assetsToUpsert.add(assObj);
          } 
        }
      
      if (earlyImplementation) {
        //Presale
        if (assetPayload != null && assetPayload.size() > 0) {
          assetsToUpsert = GCRM_ProcessOrder_Utlity.FieldMapping(
            'quote.quoteLines',
            'Asset',
            assetPayloadFieldMap,
            earlyImplementation ? 'Presale' : 'orderItemV3'
          );
        }
      }
      //Map Parent subscription and Account for the asset
      if (assetsToUpsert != null) {
        for (SObject asst : assetsToUpsert) {
          asst.put('OwnerId', tdSFSupportUserId);
          if (earlyImplementation) {
            //Presale
            asst.put(
              'SBQQ__RequiredBySubscription__c',
              (String) subassetmap.get(
                (String) asst.get('GCRM_Quote_Line_ID__c')
              )
            );
            asst.put(
              'AccountId',
              assetAccountmap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
            );
            asst.put(
            'Name',
            quoteLineMap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
              ?.SBQQ__Product__r.Name
            );
          } else {
            //Postsale
            asst.put(
              'AccountId',
              quoteLineMap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
                ?.SBQQ__Quote__r.SBQQ__Account__c
            );
          }
          asst.put(
            'product2Id',
            quoteLineMap.get((String) asst.get('GCRM_Quote_Line_ID__c'))
              ?.SBQQ__Product__c
          );
          asst.put('CurrencyIsoCode',oppCurrency);
        }
      }
    } catch (Exception e) {
      ExceptionCustomLog.captureException(
        muid,
        'GCRM_Process_OrderV4',
        'createAssets',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Asset Field Mapping',
        '',
        e
      );
    }
    //upsert all Asset Records
    if (assetsToUpsert != null && assetsToUpsert.size() > 0) {
      assetIds = GCRM_ProcessOrder_Utlity.upsertRecords(
        muid,
        assetsToUpsert,
        'create Asset',
        earlyImplementation ? 'Presale' : 'orderItemV3',
        'Upsert Asset',
        Asset.GCRM_Quote_Line_ID__c
      );
    }
  }

  public void updateReBroadcasted() {
    GCRM_ProcessOrder_Utlity.updateOppStageNew(
      oppGUID,
      earlyImplementation,
      isLVN
    );
    List<G2LCRM_item__c> gitems = [
      SELECT Id, Status__c, MUID__c
      FROM G2LCRM_item__c
      WHERE
        (Account_GUID__c = :accGUID
        AND Opp_GUId__c = :oppGUID)
        OR MUID__c = :muid
      WITH SECURITY_ENFORCED
    ];
    for (G2LCRM_Item__c gitem : gitems) {
      if (gitem.MUID__c == muid) {
        gitem.Account_GUID__c = accGUID;
        gitem.Opp_GUId__c = oppGUID;
        gitem.Order_GUID__c = oGUID;
      } else {
        if (
          ExceptionCustomLog.exceptionsFound != null &&
          ExceptionCustomLog.exceptionsFound.size() == 1
        ) {
          gitem.Status__c = 'Re-Broadcasted';
        }
      }
    }
    Database.saveResult[] srRes = Database.update(gitems, false);
  }

  public static SObject getValueIgnoreCase(Map<String, SObject> GUIDMap, String Key ) 
  {
    for(String str : GUIDMap.keyset() )
    {
      if( str.equalsIgnoreCase(Key) )
      {
        return GUIDMap.get(str);
      }
    }
    return null;
  }

}