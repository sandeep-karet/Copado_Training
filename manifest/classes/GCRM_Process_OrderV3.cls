/**
 * Name: GCRM_Process_OrderV3
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-2944    09-May-2023     Rajalakshmi R       Map Broker Commision fields to Opportunity Contact role
 * SCDEV-3194    09-May-2023     Rajalakshmi.R       Create contact records from Payload
 * SCDEV-3316/17 17-May-2023     Rajalakshmi.R       Visit Fee Opportunity Line Item creation fix
 * SCDEV-3371    31-May-2023     Rajalakshmi.R       ContactAccount Creation Fix
 * SCDEV-3327    12-Jun-2023     Rajalakshmi.R       BD-CANADA-BUNDLE Product Remapping fix
 * SCDEV-3475    19-Jun-2023     Rajalakshmi.R       Incorrect Program Type given Sub Bundle Type fix
 * SCDEV-3393    29-Jun-2023     Rajalakshmi.R       MDQ Products fix
 * SCDEV-3759    05-Jul-2023     Rajalakshmi.R       Preventing creation of Duplicate subuscription on reprocess
 * SCDEV-3798    21-Jul-2023     Rajalakshmi.R       Asset creation for non visit fee products
 * SCDEV-3915    11-Aug-2023     Rajalakshmi.R       Non visit fee subscription mapping
 * SCDEV-4018    06-Sep-2023     Elambaruthi T      LCRM: Modify G2LCRM(Current) Process to accept the "PreSale" payload.
 * SCDEV-4083    11-Dec-2023     Rajalakshmi.R       Upsert Contact roles on re-process of payload
 * SCDEV-4437    19-Dec-2023     Rajalakshmi.R       Re-Process G2LCRM items
 * SCDEV-4353    12-Dec-2023     Elambaruthi T       Setup Default Owner to Salesforce Support User
 * SCDEV-4702    04-Jan-2024     Rajalakshmi.R       Exception handling for common error scenarios
 * SCDEV-4704    16-Jan-2024     Rajalakshmi.R       ReBroadcasted Payload changes
 * SCDEV-4859    19-Feb-2024     Rajalakshmi.R       Map Opportunity Sub Type and Sub Type Detail
 */
public with sharing class GCRM_Process_OrderV3 {
  static String moduleName = 'GCRM_Process_OrderV3';
  static String defaultSeverity = 'INFO';
  static Boolean isEarlyImplemented = false;
  static String tdSFSupportUserId = '';
  static String thisMUID = '';
  static String oppGUID = '';
  static String orderGUID = '';
  static String accGUID = '';

  static List<G2LItemLog__c> allLogs = new List<G2LItemLog__c>();
  static Map<String, String> assetQLIMap = new Map<String, String>();
  static Map<String, String> subQlimap = new Map<String, String>();
  static Map<String, String> RevSubMap = new Map<String, String>();
  static Map<String, OpportunityContactRole> OppContactRoleMap = new Map<String, OpportunityContactRole>();
  static Map<String, priceBookEntry> mappedPbe = new Map<String, PriceBookEntry>();

  @AuraEnabled
  public static List<AsyncApexJob> getJobDetails(String jobId) {
    try {
      List<AsyncApexJob> asyncJobList = [
        SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
        FROM AsyncApexJob
        WHERE Id = :jobId
      ];
      return asyncJobList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string executeBatch(String MUID) {
    try {
      GCRM_Process_V3_Bch gpab = new GCRM_Process_V3_Bch(MUID, true);
      Id batchJobId = Database.executeBatch(gpab);
      return batchJobId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static void ProcessOrderByMUID(String MUID) {
    try {
      thisMUID = MUID;
      tdSFSupportUserId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
        UserInfo.getUserId()
      );

      List<DOI__c> doisByMUID = [
        SELECT
          Id,
          Name,
          CreatedDate,
          GUID__c,
          MD5Hash__c,
          ObjectName__c,
          ParentId__c,
          Payload__c,
          Processor__c,
          SourceId__c,
          Action__c,
          MUID__c
        FROM DOI__c
        WHERE MUID__c = :MUID
        ORDER BY CreatedDate ASC
      ];

      if (doisByMUID.isEmpty()) {
        String errMsg = 'NO_DOI_RECORD_AVAILABLE';
        String errDetail =
          'There is no DOI record found under the MUID:' +
          MUID +
          '\n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV3';
        ExceptionCustomLog.captureCustomException(
          MUID,
          'GCRM_Process_OrderV3',
          'ProcessOrderByMUID',
          '',
          '',
          '',
          errMsg,
          errDetail
        );
        return;
      }

      List<INT175_AccountV3.Account> accountRecords = new List<INT175_AccountV3.Account>();
      List<INT175_OrderV3.Order> orderRecords = new List<INT175_OrderV3.Order>();
      List<INT175_OrderItemV3.OrderItems> orderItemRecords = new List<INT175_OrderItemV3.OrderItems>();
      List<INT175_OrderItemV3.Subscriptions> subscriptionRecords = new List<INT175_OrderItemV3.Subscriptions>();
      List<INT175_OrderItemV3.Subscriptions> assetRecords = new List<INT175_OrderItemV3.Subscriptions>();
      List<INT175_OrderItemV3.Assets> NonVisitFeeAssets = new List<INT175_orderItemV3.Assets>();
      Map<String, Object> untypedOrderRecords = new Map<String, Object>();

      for (DOI__c currentDoi : doisByMUID) {
        switch on currentDoi.ObjectName__c {
          when 'account' {
            INT175_AccountV3.Account parsedAccount = (INT175_AccountV3.Account) JSON.deserialize(
              currentDoi.Payload__c,
              INT175_AccountV3.Account.class
            );
            accountRecords.add(parsedAccount);
            accGUID = parsedAccount.accountGUID;
          }
          when 'order' {
            INT175_OrderV3.Order parsedOrder = (INT175_OrderV3.Order) JSON.deserialize(
              currentDoi.Payload__c,
              INT175_OrderV3.Order.class
            );
            untypedOrderRecords = (Map<String, Object>) JSON.deserializeUntyped(
              currentDoi.Payload__c
            );
            orderRecords.add(parsedOrder);
            orderGUID = parsedOrder.orderGUID;
            oppGUID = parsedOrder.opportunities[0]?.opportunityGUID;
          }
          when 'orderitem' {
            INT175_OrderItemV3.OrderItems parsedOrderItems = (INT175_OrderItemV3.OrderItems) JSON.deserialize(
              currentDoi.Payload__c,
              INT175_OrderItemV3.OrderItems.class
            );
            orderItemRecords.add(parsedOrderItems);
          }
          when 'subscription' {
            INT175_OrderItemV3.Subscriptions parsedSubscriptions = (INT175_OrderItemV3.Subscriptions) JSON.deserialize(
              currentDoi.Payload__c,
              INT175_OrderItemV3.Subscriptions.class
            );
            subscriptionRecords.add(parsedSubscriptions);
          }
          when 'asset' {
            if (!currentDoi.ParentId__c.startswith('02i')) {
              INT175_OrderItemV3.Subscriptions parsedAssets = (INT175_OrderItemV3.Subscriptions) JSON.deserialize(
                currentDoi.Payload__c,
                INT175_OrderItemV3.Subscriptions.class
              );
              assetRecords.add(parsedAssets);
            } else {
              INT175_OrderItemV3.Assets parsedAssets = (INT175_OrderItemV3.Assets) JSON.deserialize(
                currentDoi.Payload__c,
                INT175_OrderItemV3.Assets.class
              );
              NonVisitFeeAssets.add(parsedAssets);
            }
          }
        }
      }

      String currencyCode = orderRecords[0]?.opportunities[0]?.currencyISOCode;
      
      mappedPbe = gatherPbe(currencyCode);
      if (
        validatePayload(
          accountRecords,
          orderRecords,
          orderItemRecords,
          subscriptionRecords,
          assetRecords,
          NonVisitFeeAssets
        )
      ) {
        Account candidateAccount = new Account();
        if (accountRecords != null && accountRecords.size() > 0) {
          candidateAccount = CreateAccount(accountRecords);
          system.debug('candidate Account:: ' + candidateAccount);
        }
        if (orderRecords != null && orderRecords.size() > 0) {
          CreateOrder(
            orderRecords,
            orderItemRecords,
            subscriptionRecords,
            assetRecords,
            candidateAccount,
            untypedOrderRecords,
            NonVisitFeeAssets
          );
        }
        /*if (
          (accountRecords == null || accountRecords.size() <= 0) &&
          (orderRecords == null ||
          orderRecords.size() <= 0)
        ) {
          String errMsg = 'Failed: There is no records to process';
          String errDetail =
            'There is no records found under the MUID:' +
            thisMUID +
            ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV3';
          ExceptionCustomLog.captureCustomException(
            MUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            '',
            '',
            '',
            errMsg,
            errDetail
          );
        } */
      }
      updateReBroadcasted(accGUId, oppGUID, orderGUID);
    } catch (Exception ex) {
      system.debug('Exception::: ' + ex.getMessage());
      ExceptionCustomLog.captureException(
        MUID,
        'GCRM_Process_OrderV3',
        'ProcessOrderByMUID',
        '',
        '',
        '',
        ex
      );
    }
  }

  //SCDEV-4702 Changes Start
  public static Boolean validatePayload(
    List<INT175_AccountV3.Account> accountRecords,
    List<INT175_OrderV3.Order> orderRecords,
    List<INT175_OrderItemV3.OrderItems> orderItemRecords,
    List<INT175_OrderItemV3.Subscriptions> subscriptionRecords,
    List<INT175_OrderItemV3.Subscriptions> assetRecords,
    List<INT175_OrderItemV3.Assets> NonVisitFeeAssets
  ) {
    Boolean isPassedValidation = true;
    //Account Validations
    if (accountRecords != null && accountRecords.size() > 0) {
      for (INT175_AccountV3.Account acct : accountRecords) {
        if (
          acct.accountGUID == null ||
          acct.accountName == null ||
          acct.currencyIsoCode == null
        ) {
          isPassedValidation = false;
          String errMsg = 'Failed: Account is missing mandatory Fields';
          String errDetail = 'Please verify the Account GUID , Name and Currency details in the request';
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
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
        'There is no records found under the MUID:' +
        thisMUID +
        ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV3';
      ExceptionCustomLog.captureCustomException(
        thisMUID,
        'GCRM_Process_OrderV3',
        'ProcessOrderByMUID',
        'accountV3',
        '',
        '',
        errMsg,
        errDetail
      );
    }
    //Opportunity Validations
    if (orderRecords != null && orderRecords.size() > 0) {
      for (INT175_OrderV3.Order ord : orderRecords) {
        if (ord.accountGUID == null || ord.orderGUID == null) {
          isPassedValidation = false;
          String errMsg = 'Failed: Order is missing mandatory Fields';
          String errDetail = 'Please verify the Account and Order GUID in the request';
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
        /*if (ord.opportunities == null) {
          isPassedValidation = false;
          String errMsg = 'Failed: Order is missing opportunity Details';
          String errDetail = 'Please verify the Opportunity Details in the request';
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }*/
        if (ord.opportunities.size() > 1) {
          isPassedValidation = false;
          String errMsg = 'Failed: Request contains multiple Opportunities';
          String errDetail = 'Order can have only one Opportunity per request. Please verify';
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
      }
    } else {
      /* isPassedValidation = false;
      String errMsg = 'Failed: There is no order record to process';
      String errDetail =
        'There is no order record found under the MUID:' +
        thisMUID +
        ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV3';
      ExceptionCustomLog.captureCustomException(
        thisMUID,
        'GCRM_Process_OrderV3',
        'ProcessOrderByMUID',
        'orderV3',
        '',
        '',
        errMsg,
        errDetail
      );*/
    }
    //Order Item validations
    if (orderItemRecords != null && orderItemRecords.size() > 0) {
      for (INT175_OrderItemV3.OrderItems oitem : orderItemRecords) {
        if (oitem.assets == null && oitem.subscriptions == null) {
          isPassedValidation = false;
          String errMsg = 'Failed: No Subscriptions or Assets defined for Order Item';
          String errDetail =
            'There is no subcsription or asset defined for the order Item. Either subscription or an Asset is required to process the order item ' +
            oitem.orderItemGUID;
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderItemV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
        if (oitem.subscriptions != null && oitem.subscriptions.size() > 1) {
          isPassedValidation = false;
          String errMsg = 'Failed: Multiple subscriptions defined for Order Item';
          String errDetail =
            'There are multiple subscriptions defined for the order item. There can only be one subscription per order item ' +
            oitem.orderItemGUID;
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderItemV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
        if (oitem.productCode == null || oitem.orderItemGUID == null) {
          isPassedValidation = false;
          String errMsg = 'Failed: Mandatory fields missing for Order items';
          String errDetail =
            'Please verify the product Code and GUID details for the order item ' +
            oitem.orderItemGUID;
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'ProcessOrderByMUID',
            'orderItemV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
      }
      if (assetRecords != null && assetRecords.size() > 0) {
        for (INT175_OrderItemV3.Subscriptions assets : assetRecords) {
          if (assets.lcrmVisitFeeCode == null) {
            isPassedValidation = false;
            String errMsg = 'Failed: Visit fee products require FEE Code value';
            String errDetail = 'Fee Code details are missing for the visit fee products ';
            ExceptionCustomLog.captureCustomException(
              thisMUID,
              'GCRM_Process_OrderV3',
              'ProcessOrderByMUID',
              'orderItemV3',
              '',
              '',
              errMsg,
              errDetail
            );
          }
        }
      }
    } else {
      isPassedValidation = false;
      String errMsg = 'Failed: There are no order item record to process';
      String errDetail =
        'There is no order item record found under the MUID:' +
        thisMUID +
        ' for the processors accountv3, orderv3. \n Method: ProcessOrderByMUID \n Module: GCRM_Process_OrderV3';
      ExceptionCustomLog.captureCustomException(
        thisMUID,
        'GCRM_Process_OrderV3',
        'ProcessOrderByMUID',
        'orderItemV3',
        '',
        '',
        errMsg,
        errDetail
      );
    }
    return isPassedValidation;
  }

  public static void updateReBroadcasted(
    String accGUID,
    String oppGUID,
    String orderGUID
  ) {
    List<G2LCRM_item__c> gitems = [
      SELECT Id, Status__c, MUID__c
      FROM G2LCRM_item__c
      WHERE
        (Account_GUID__c = :accGUID
        AND Opp_GUId__c = :oppGUID)
        OR MUID__c = :thisMUID
    ];

    for (G2LCRM_Item__c gitem : gitems) {
      if (gitem.MUID__c == thisMUID) {
        gitem.Account_GUID__c = accGUID;
        gitem.Opp_GUId__c = oppGUID;
        gitem.Order_GUID__c = orderGUID;
      } else {
        if (
          ExceptionCustomLog.exceptionsFound != null &&
          ExceptionCustomLog.exceptionsFound.size() == 1
        ) {
          gitem.Status__c = 'Re-Broadcasted';
        }
      }
      Database.saveResult[] srRes = Database.update(gitems, false);
    }
  }

  public static Boolean CreateOrder(
    List<INT175_OrderV3.Order> orderRecords,
    List<INT175_OrderItemV3.OrderItems> orderItemRecords,
    List<INT175_OrderItemV3.Subscriptions> subscriptionRecords,
    List<INT175_OrderItemV3.Subscriptions> assetRecords,
    Account orderAccount,
    Map<String, Object> untypedOrderRecords,
    List<INT175_OrderItemV3.Assets> NonVisitFeeAssets
  ) {
    try {
      Opportunity targetOpp = new Opportunity();
      INT175_OrderV3.Order newOrder = orderRecords[0];
      orderGUID = (String) newOrder.orderGUID;
      oppGUID = (String) newOrder.opportunities[0].opportunityGUID;
      String targetOpportunityGUID = newOrder.opportunities[0].opportunityGUID;

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
        WHERE Opp_Guid__c = :targetOpportunityGUID
      ];

      String ObjName = 'order';
      Map<String, List<g2lcrm_mapping__mdt>> FieldMapping = new Map<String, List<g2lcrm_mapping__mdt>>();
      for (g2lcrm_mapping__mdt mapping : [
        SELECT
          Id,
          LCRM_Field_Name__c,
          LCRM_Object_name__c,
          JSON_Objects_Name__c,
          JSON_Field_Name__c,
          DataType__c
        FROM g2lcrm_mapping__mdt
      ]) {
        if (FieldMapping.get(mapping.JSON_Objects_Name__c) != null)
          FieldMapping.get(mapping.JSON_Objects_Name__c).add(mapping);
        else
          FieldMapping.put(
            mapping.JSON_Objects_Name__c,
            new List<g2lcrm_mapping__mdt>{ mapping }
          );
      }

      Map<String, Contact> ContactsToUpsert = new Map<String, Contact>();
      Map<String, Account> AccountsToUpsert = new Map<String, Account>();
      List<Object> ContactJSONMap = (List<Object>) untypedOrderRecords.get(
        'contacts'
      );
      Map<String, Map<String, Object>> ContactRoleMap = new Map<String, Map<String, Object>>();
      Map<String, id> OpportunityIdMap = new Map<String, id>();

      if (ContactJSONMap != null && ContactJSONMap.size() > 0) {
        ObjName = ObjName + '.contacts';
        for (Object contct : ContactJSONMap) {
          Map<String, Object> contactObj = (Map<String, Object>) contct;
          SObject ct = new Contact();
          for (g2lcrm_mapping__mdt mdt : FieldMapping.get(ObjName)) {
            if (mdt.LCRM_Object_name__c == 'Contact') {
              if (mdt.DataType__c == 'Decimal')
                ct.put(
                  mdt.LCRM_Field_Name__c,
                  (Decimal) contactObj.get(mdt.JSON_Field_Name__c)
                );
              if (mdt.DataType__c == 'String')
                ct.put(
                  mdt.LCRM_Field_Name__c,
                  (String) contactObj.get(mdt.JSON_Field_Name__c)
                );
            }
          }
          ct.put('AccountId', orderAccount.Id);
          if (
            ContactsToUpsert.get((String) contactObj.get('contactId')) == null
          ) {
            ContactsToUpsert.put(
              (String) contactObj.get('contactId'),
              (Contact) ct
            );
          }
        }
        ObjName = 'order';
      }
      try {
        String cadPriceBookId;
        for (PriceBookEntry pbe : mappedPbe.values()) {
          if (pbe.Pricebook2.name.containsIgnoreCase('canada')) {
            cadPriceBookId = pbe.priceBook2Id;
            break;
          }
        }
        ObjName = ObjName + '.opportunities';
        INT175_OrderV3.Opportunities gcrmOpp = newOrder.opportunities[0];
        if (!targetOpportunities.isEmpty()) {
          targetOpp = targetOpportunities[0];
          targetOpp.StageName = 'Contracting';
          isEarlyImplemented = targetOpportunities[0].Early_Implemented__c;
        } else {
          targetOpp.StageName = 'Discovery';
        }
        targetOpp.Opp_Guid__c = gcrmOpp.opportunityGUID;
        targetOpp.Amount = newOrder.totalAmount;
        targetOpp.StageName = 'Discovery';
        targetOpp.AccountId = orderAccount.Id;
        targetOpp.Name = gcrmOpp.opportunityName;
        targetOpp.Source__c = 'GCRM';
        targetOpp.GCRM_Source_Id__c = gcrmOpp.opportunityId;
        targetOpp.Initial_of_Lives__c = gcrmOpp.initialNumOfLives;
        targetOpp.Opportunity_Closed_Date__c = gcrmOpp.closeDate;
        targetOpp.CloseDate = Date.valueof(newOrder.effectiveDate);
        targetOpp.Decision_Date__c = gcrmOpp.closeDate;
        targetOpp.Business_Region__c = gcrmOpp.businessRegion;
        targetOpp.LeadSource = gcrmOpp.leadSource;
        targetOpp.Type = gcrmOpp.opportunityType;
        //SCDEV-4859 Changes Begin
        targetOpp.Sub_Type__c = gcrmOpp.opportunitySubType;
        targetOpp.Sub_Type_Detail__c = gcrmOpp.opportunitySubTypeDetail;
        //SCDEV-4859 Changes End
        targetOpp.Line_of_Business_CP__c = gcrmOpp.clientLineOfBusiness;
        targetOpp.GCRM_Contract_Path__c = gcrmOpp.contractPath;
        targetOpp.GCRM_Contracting_Account__c = gcrmOpp.contractingAccountName;
        targetOpp.currencyIsoCode = gcrmOpp.currencyIsoCode;
        if (gcrmOpp.currencyIsoCode == 'CAD') {
          targetOpp.Pricebook2Id = cadPriceBookId;
        }
        targetOpp.OwnerId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
          gcrmOpp.ownerId
        );
        Database.UpsertResult[] svRes = Database.upsert(
          new List<Opportunity>{ targetOpp },
          Opportunity.Opp_Guid__c
        );
        for (Database.UpsertResult sr : svRes) {
          ObjName = ObjName + '.contacts';
          List<Object> opp = (List<Object>) untypedOrderRecords.get(
            'opportunities'
          );
          List<Object> OppContacts = (List<Object>) ((Map<String, Object>) opp[0])
            .get('contacts');
          Map<String, Object> AccountRecord = new Map<String, Object>();
          Map<String, String> ContactAccountMap = new Map<String, String>();
          if (sr.isSuccess()) {
            Set<Id> conAccGCRMOwners = new Set<Id>();
            if (OppContacts != null && OppContacts.size() > 0) {
              for (Object contct : OppContacts) {
                Map<String, Object> contactObj = (Map<String, Object>) contct;
                SObject ct = new Contact();
                for (g2lcrm_mapping__mdt mdt : FieldMapping.get(ObjName)) {
                  if (mdt.LCRM_Object_name__c == 'Contact') {
                    if (mdt.DataType__c == 'Decimal')
                      ct.put(
                        mdt.LCRM_Field_Name__c,
                        (Decimal) contactObj.get(mdt.JSON_Field_Name__c)
                      );
                    if (mdt.DataType__c == 'String')
                      ct.put(
                        mdt.LCRM_Field_Name__c,
                        (String) contactObj.get(mdt.JSON_Field_Name__c)
                      );
                  }
                }
                AccountRecord = (Map<String, Object>) contactObj.get(
                  'contactAccount'
                );
                SObject accountToUpsert = new Account();
                String Objectname = ObjName + '.contactAccount';
                if (AccountRecord != null) {
                  conAccGCRMOwners.add((String) AccountRecord.get('OwnerId'));
                  ContactAccountMap.put(
                    (String) contactObj.get('contactGUID'),
                    (String) AccountRecord.get('accountGUID')
                  );
                  for (
                    g2lcrm_mapping__mdt mdt : FieldMapping.get(Objectname)
                  ) {
                    if(
                      !GCRM_ProcessOrder_Utlity.isExistingAccount((String) AccountRecord.get('accountGUID'))
                    ) {
                        if (mdt.LCRM_Object_name__c == 'Account') {
                          if (mdt.DataType__c == 'Decimal')
                            accountToUpsert.put(
                              mdt.LCRM_Field_Name__c,
                              (Decimal) AccountRecord.get(mdt.JSON_Field_Name__c)
                            );
                          if (mdt.DataType__c == 'String')
                            accountToUpsert.put(
                              mdt.LCRM_Field_Name__c,
                              (String) AccountRecord.get(mdt.JSON_Field_Name__c)
                            );
                        }
                        String accType = (String) AccountRecord.get(
                          'accountType'
                        );
                        Map<String, Map<String, String>> valueMapping = GCRM_ProcessOrder_Utlity.g2lcrmPickListMapping(
                          'Account'
                        );
    
                        if (
                          valueMapping.containsKey('Account_Type__c') &&
                          valueMapping.get('Account_Type__c').containsKey(accType)
                        ) {
                          accountToUpsert.put(
                            'Account_Type__c',
                            valueMapping.get('Account_Type__c').get(accType)
                          );
                        } else {
                          accountToUpsert.put('Account_Type__c', accType);
                        }
                    } else{
                        accountToUpsert.put('GUID__c', (String) AccountRecord.get('accountGUID'));
                    }
                    AccountsToUpsert.put(
                      (String) AccountRecord.get('accountGUID'),
                      (account) accountToUpsert
                    );
                  }
                }
                if (
                  ContactsToUpsert.get((String) contactObj.get('contactId')) ==
                  null
                ) {
                  ContactsToUpsert.put(
                    (String) contactObj.get('contactId'),
                    (contact) ct
                  );
                }
                ContactRoleMap.put(
                  (String) contactObj.get('contactGUID'),
                  contactObj
                );
                OpportunityIdMap.put(
                  (String) contactObj.get('contactGUID'),
                  sr.getId()
                );
              }
            }
            //upsert account
            if (AccountsToUpsert.size() > 0) {
              Set<Id> existConAccOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
                conAccGCRMOwners
              );
              for (Account acct : AccountsToUpsert.values()) {
                if (!existConAccOwners.contains((String) acct.get('OwnerId'))) {
                  acct.put('OwnerId', tdSFSupportUserId);
                }
              }
              Database.upsertResult[] accountResult = Database.upsert(
                (AccountsToUpsert.values()),
                Account.GUID__c,
                false
              );

              Set<Id> accountIds = new Set<Id>();
              Map<String, Account> AccountMap = new Map<string, Account>();
              for (Database.upsertResult upsr : accountResult) {
                accountIds.add(upsr.getId());
                if (!upsr.isSuccess()) {
                  Database.Error error = upsr.getErrors().get(0);
                  List<String> errorFields = error.getFields();
                  String errorDetail = error.getMessage();
                  if (errorFields != null && errorFields.size() > 0) {
                    errorDetail =
                      errorDetail +
                      '\n' +
                      string.join(errorFields, ',\n');
                  }
                  ExceptionCustomLog.captureCustomException(
                    thisMUID,
                    'GCRM_Process_OrderV3',
                    'CreateOrder',
                    'orderV3',
                    'opportunity',
                    targetOpp.Opp_Guid__c,
                    String.valueOf(error.getStatusCode()),
                    errorDetail
                  );
                }
              }

              for (Account acct : [
                SELECT Id, GUID__c
                FROM Account
                WHERE Id IN :accountIds
              ]) {
                AccountMap.put(acct.GUID__c, acct);
              }

              Set<Id> conGCRMOwners = new Set<Id>();
              //repopulate Contact Account id based on the account upsert result
              for (Contact ct : ContactsToUpsert.values()) {
                if (
                  ContactAccountMap.get((String) ct.get('GUID__c')) != null &&
                  AccountMap.get(
                    ContactAccountMap.get((String) ct.get('GUID__c'))
                  ) != null
                ) {
                  ct.put(
                    'AccountId',
                    AccountMap.get(
                        ContactAccountMap.get((String) ct.get('GUID__c'))
                      )
                      .Id
                  );
                }
                conGCRMOwners.add((String) ct.get('OwnerId'));
              }

              Set<Id> existConOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
                conGCRMOwners
              );
              for (Contact ct : ContactsToUpsert.values()) {
                if (!existConOwners.contains((String) ct.get('OwnerId'))) {
                  ct.put('OwnerId', tdSFSupportUserId);
                }
              }
            }
          } else {
            Database.Error error = sr.getErrors().get(0);
            List<String> errorFields = error.getFields();
            String errorDetail = error.getMessage();
            if (errorFields != null && errorFields.size() > 0) {
              errorDetail =
                errorDetail +
                '\n' +
                string.join(errorFields, ',\n');
            }
            ExceptionCustomLog.captureCustomException(
              thisMUID,
              'GCRM_Process_OrderV3',
              'CreateOrder',
              'orderV3',
              'opportunity',
              targetOpp.Opp_Guid__c,
              String.valueOf(error.getStatusCode()),
              errorDetail
            );
          }
        }
        if (ContactsToUpsert.size() > 0) {
          List<OpportunityContactRole> existingCtRoles = [
            SELECT Id, OpportunityId, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId IN :OpportunityIdMap.values()
          ];
          for (OpportunityContactRole ct : existingCtRoles) {
            OppContactRoleMap.put(
              String.valueOf(ct.OpportunityId) + String.valueOf(ct.ContactId),
              ct
            );
          }

          Set<Id> ContactIds = new Set<Id>();
          String ObjctName = ObjName + '.contactrole';
          Map<String, Contact> contactmap = new Map<String, Contact>();
          List<OpportunityContactRole> contactRoletoInsert = new List<OpportunityContactRole>();

          Database.upsertResult[] contactResult = Database.upsert(
            (ContactsToUpsert.values()),
            Contact.Source_Id__c,
            false
          );

          for (Database.upsertResult upsr : contactResult) {
            ContactIds.add(upsr.getId());
          }
          for (Contact cts : [
            SELECT Id, GUID__c
            FROM Contact
            WHERE Id IN :ContactIds
          ]) {
            SObject ctRole = new OpportunityContactRole();
            for (g2lcrm_mapping__mdt mdt : FieldMapping.get(ObjctName)) {
              if (mdt.LCRM_Object_name__c == 'OpportunityContactRole') {
                if (
                  mdt.DataType__c == 'Decimal' &&
                  ContactRoleMap.containsKey(cts.GUID__c)
                )
                  ctRole.put(
                    mdt.LCRM_Field_Name__c,
                    (Decimal) (ContactRoleMap.get(cts.GUID__c)
                      .get(mdt.JSON_Field_Name__c))
                  );
                if (
                  mdt.DataType__c == 'String' &&
                  ContactRoleMap.containsKey(cts.GUID__c)
                )
                  ctRole.put(
                    mdt.LCRM_Field_Name__c,
                    (String) ContactRoleMap.get(cts.GUID__c)
                      .get(mdt.JSON_Field_Name__c)
                  );
              }
            }
            ctRole.put('OpportunityId', OpportunityIdMap.get(cts.GUID__c));
            ctRole.put('ContactId', cts.get('Id'));
            String externalId =
              String.valueOf(OpportunityIdMap.get(cts.GUID__c)) +
              String.valueOf(cts.get('Id'));
            String ctId = OppContactRoleMap.get(externalId) != null
              ? OppContactRoleMap.get(externalId).Id
              : null;
            ctRole.put('Id', ctId);

            if (OpportunityIdMap.containsKey(cts.GUID__c)) {
              contactRoletoInsert.add((OpportunityContactRole) ctRole);
            }
          }
          if (contactRoletoInsert.size() > 0) {
            try {
              Database.UpsertResult[] svResult = Database.upsert(
                contactRoletoInsert,
                false
              );
            } catch (Exception ex) {
              ExceptionCustomLog.captureException(
                thisMUID,
                'GCRM_Process_OrderV3',
                'CreateOrder',
                'orderV3',
                'opportunity',
                newOrder.opportunities[0].opportunityGUID,
                ex
              );
            }
          }
        }
      } catch (Exception ex) {
        System.debug('Exception:: ' + Ex.getMessage());
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderV3',
          'opportunity',
          newOrder.opportunities[0].opportunityGUID,
          ex
        );
      }

      Contract newContract = new Contract();
      try {
        if (newOrder.contract != null) {
          newContract = CreateContract(
            newOrder.contract,
            targetOpp,
            orderAccount.Id
          );
          if (newContract.Id == null) {
            Database.UpsertResult[] cnrtSr = Database.upsert(
              new List<Contract>{ newContract },
              contract.External_Id__c,
              false
            );
            if (cnrtSr != null && cnrtSr.size() > 0) {
              for (Integer i = 0; i < cnrtSr.size(); i++) {
                if (!cnrtSr.get(i).isSuccess()) {
                  Database.Error error = cnrtSr.get(i).getErrors().get(0);
                  List<String> errorFields = error.getFields();
                  String errorDetail = error.getMessage();
                  if (errorFields != null && errorFields.size() > 0) {
                    errorDetail =
                      errorDetail +
                      '\n' +
                      string.join(errorFields, ',\n');
                  }
                  ExceptionCustomLog.captureCustomException(
                    thisMUID,
                    'GCRM_Process_OrderV3',
                    'CreateOrder',
                    'orderV3',
                    'contract',
                    newContract.External_Id__c,
                    String.valueOf(error.getStatusCode()),
                    errorDetail
                  );
                }
              }
            }
          } else {
            Database.SaveResult[] cnrtSr;
            if (isEarlyImplemented) {
              cnrtSr = Database.update(
                new List<Contract>{ newContract },
                false
              );
            }
            if (cnrtSr != null && cnrtSr.size() > 0) {
              for (Integer i = 0; i < cnrtSr.size(); i++) {
                if (!cnrtSr.get(i).isSuccess()) {
                  Database.Error error = cnrtSr.get(i).getErrors().get(0);
                  List<String> errorFields = error.getFields();
                  String errorDetail = error.getMessage();
                  if (errorFields != null && errorFields.size() > 0) {
                    errorDetail =
                      errorDetail +
                      '\n' +
                      string.join(errorFields, ',\n');
                  }
                  ExceptionCustomLog.captureCustomException(
                    thisMUID,
                    'GCRM_Process_OrderV3',
                    'CreateOrder',
                    'orderV3',
                    'contract',
                    newContract.External_Id__c,
                    String.valueOf(error.getStatusCode()),
                    errorDetail
                  );
                }
              }
            }
          }
        }
      } catch (Exception ex) {
        String contractGUID = '';
        if (newOrder.contract != null) {
          contractGUID = newOrder.contract.contractGUID;
        }
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderV3',
          'contract',
          contractGUID,
          ex
        );
      }

      Id quoteId = CreateQuote(
        newOrder.quote,
        orderAccount.Id,
        targetOpp.Id,
        newOrder.orderGUID
      );

      // Record creation block.  All records created below.  Avoiding issues with side-effects
      Map<String, String> VisitCodeMap = new Map<String, String>();
      Map<Id, INT175_OrderItemV3.OrderItems> mappedOrderItems = new Map<Id, INT175_OrderItemV3.OrderItems>();

      for (INT175_OrderItemV3.OrderItems tmpOi : orderItemRecords) {
        mappedOrderItems.put(tmpOi.orderItemId, tmpOi);
        if (tmpOi.assets != null) {
          assetQLIMap.put(tmpOi.orderItemId, tmpOi.assets[0].latestQuoteLineId);
        }
      }
      // Product Code remapping for VISITFEE
      for (INT175_OrderItemV3.Subscriptions tmpAsset : assetRecords) {
        INT175_OrderItemV3.OrderItems targetItem = mappedOrderItems.get(
          tmpAsset.orderItemId
        );
        switch on targetItem.productCode {
          when 'PRIM360CARE-BUNDLE' {
            targetItem.productCode = 'PRIM360CARE';
          }
          when 'VISITFEE' {
            targetItem.productId = mappedPbe.get(
                tmpAsset.lcrmVisitFeeCode + '-' + targetItem.currencyIsoCode
              )
              .Product2Id;
          }
          when 'BD-CANADA-BUNDLE' {
            if (targetItem.quoteLine.productVersion == '2.0') {
              String key =
                targetItem.productCode +
                '-' +
                targetItem.quoteLine.productVersion +
                '-' +
                targetItem.currencyIsoCode;
              if (mappedPbe.containsKey(key) != null)
                targetItem.productId = mappedPbe.get(key).Product2Id;
            }
          }
        }
        VisitCodeMap.put(targetItem.orderItemId, tmpAsset.lcrmVisitFeeCode);
        mappedOrderItems.put(tmpAsset.orderItemId, targetItem);
        String gcrmQuoteLineId = tmpAsset.quoteLineid != null
          ? tmpAsset.quoteLineid
          : tmpAsset.originalQuoteLineid;
        assetQLIMap.put(tmpAsset.orderItemId, gcrmQuoteLineId);
      }

      system.debug('assetQLIMap : ' + assetQLIMap);

      Map<String, SBQQ__QuoteLine__c> mappedQuoteLines;
      Map<String, String> requiredByMap = new Map<String, String>();
      Map<String, Id> Parentproductmap = new Map<String, Id>();
      Map<String, SBQQ__QuoteLine__c> QuoteLineMap = new Map<String, SBQQ__QuoteLine__c>();

      for (INT175_OrderItemV3.OrderItems oitem : mappedOrderItems.values()) {
        requiredByMap.put(oitem.orderItemId, oitem.requiredBy);
      }
      Database.UpsertResult[] qlSr;
      try {
        mappedQuoteLines = CreateQuoteLines(
          quoteId,
          mappedOrderItems.values(),
          assetRecords
        );
        // Create quote lines as an atomic all/none scenario
        Schema.SObjectField gcrmQuoteLineId = SBQQ__QuoteLine__c.Fields.GCRM_Quote_Line_ID__c;
        qlSr = Database.upsert(
          mappedQuoteLines.values(),
          gcrmQuoteLineId,
          false
        );
        Set<id> qliIds = new Set<id>();
        if (qlSr != null && qlSr.size() > 0) {
          for (Integer i = 0; i < qlSr.size(); i++) {
            if (!qlSr.get(i).isSuccess()) {
              Database.Error error = qlSr.get(i).getErrors().get(0);
              List<String> errorFields = error.getFields();
              String errorDetail = error.getMessage();
              if (errorFields != null && errorFields.size() > 0) {
                errorDetail =
                  errorDetail +
                  '\n' +
                  string.join(errorFields, ',\n');
              }
              ExceptionCustomLog.captureCustomException(
                thisMUID,
                'GCRM_Process_OrderV3',
                'CreateOrder',
                'orderItemV3',
                'quoteLine',
                mappedQuoteLines.values().get(i).External_Id__c,
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            } else {
              qliIds.add(qlSr.get(i).getId());
            }
          }
          List<SBQQ__QuoteLine__c> qliList = [
            SELECT id, External_Id__c, SBQQ__RequiredBy__c
            FROM SBQQ__QuoteLine__c
            WHERE id IN :qliIds
          ];
          List<SBQQ__QuoteLine__c> quoteLinestoUpdate = new List<SBQQ__QuoteLine__c>();
          for (SBQQ__QuoteLine__c qli : qliList) {
            QuoteLineMap.put(qli.External_Id__c, qli);
          }
          for (SBQQ__QuoteLine__c qli : qliList) {
            System.debug(
              'qli external id' +
                qli.External_Id__c +
                requiredByMap.get(qli.External_Id__c)
            );
            if (requiredByMap.get(qli.External_Id__c) != null) {
              qli.SBQQ__RequiredBy__c = QuoteLineMap.get(
                  requiredByMap.get(qli.External_Id__c)
                )
                .id;
            }
            quoteLinestoUpdate.add(qli);
          }
          List<Database.SaveResult> qliSr = Database.update(
            quoteLinestoUpdate,
            false
          );
          if (qliSr != null && qliSr.size() > 0) {
            for (Integer i = 0; i < qliSr.size(); i++) {
              if (!qliSr.get(i).isSuccess()) {
                Database.Error error = qliSr.get(i).getErrors().get(0);
                List<String> errorFields = error.getFields();
                String errorDetail = error.getMessage();
                if (errorFields != null && errorFields.size() > 0) {
                  errorDetail =
                    errorDetail +
                    '\n' +
                    string.join(errorFields, ',\n');
                }
                ExceptionCustomLog.captureCustomException(
                  thisMUID,
                  'GCRM_Process_OrderV3',
                  'CreateOrder',
                  'orderItemV3',
                  'quoteLine',
                  mappedQuoteLines.values().get(i).External_Id__c,
                  String.valueOf(error.getStatusCode()),
                  errorDetail
                );
              }
            }
          }
        }
      } catch (Exception ex) {
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderItemV3',
          'quoteLine',
          '',
          ex
        );
      }

      Database.UpsertResult[] oliSr;

      try {
        Map<String, OpportunityLineItem> mappedOli = CreateOpportunityLineItems(
          targetOpp.Id,
          mappedOrderItems.values(),
          VisitCodeMap,
          mappedQuoteLines
        );
        // Create opportunity line items as an atomic all/none scenario
        Schema.SObjectField gcrmOppQuoteLineId = OpportunityLineItem.Fields.GCRM_Quote_Line_ID__c;
        oliSr = Database.upsert(mappedOli.values(), gcrmOppQuoteLineId, false);
        if (oliSr != null && oliSr.size() > 0) {
          for (Integer i = 0; i < oliSr.size(); i++) {
            if (!oliSr.get(i).isSuccess()) {
              Database.Error error = oliSr.get(i).getErrors().get(0);
              List<String> errorFields = error.getFields();
              String errorDetail = error.getMessage();
              if (errorFields != null && errorFields.size() > 0) {
                errorDetail =
                  errorDetail +
                  '\n' +
                  string.join(errorFields, ',\n');
              }
              ExceptionCustomLog.captureCustomException(
                thisMUID,
                'GCRM_Process_OrderV3',
                'CreateOrder',
                'orderItemV3',
                'oppLineItem',
                mappedOli.values().get(i).Source_Id__c,
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            }
          }
        }
      } catch (Exception ex) {
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderItemV3',
          'oppLineItem',
          '',
          ex
        );
      }

      Database.upsertResult[] subSr;

      Map<String, SBQQ__Subscription__c> mappedSubscriptions = new Map<String, SBQQ__Subscription__c>();
      Map<String, Id> subscriptionIdMap = new Map<String, Id>();
      Set<Id> SubsId = new Set<Id>();

      try {
        mappedSubscriptions = CreateSubscriptions(
          mappedOrderItems,
          subscriptionRecords,
          mappedQuoteLines,
          orderAccount.Id,
          newContract.Id,
          assetrecords
        );
        subSr = Database.upsert(
          mappedSubscriptions.values(),
          SBQQ__Subscription__c.External_Id__c,
          false
        );
        if (subSr != null && subSr.size() > 0) {
          for (Integer i = 0; i < subSr.size(); i++) {
            if (!subSr.get(i).isSuccess()) {
              Database.Error error = subSr.get(i).getErrors().get(0);
              List<String> errorFields = error.getFields();
              String errorDetail = error.getMessage();
              if (errorFields != null && errorFields.size() > 0) {
                errorDetail =
                  errorDetail +
                  '\n' +
                  string.join(errorFields, ',\n');
              }
              ExceptionCustomLog.captureCustomException(
                thisMUID,
                'GCRM_Process_OrderV3',
                'CreateOrder',
                'orderItemV3',
                'subscription',
                mappedSubscriptions.values().get(i).Source_Id__c,
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            } else {
              SubsId.add(subSr.get(i).getId());
            }
          }
          for (SBQQ__Subscription__c subs : [
            SELECT Id, External_Id__c, SBQQ__SubscriptionStartDate__c
            FROM SBQQ__Subscription__c
            WHERE Id IN :SubsId
          ]) {
            subscriptionIdMap.put(subs.External_Id__c, subs.Id);
          }
        }
      } catch (Exception ex) {
        System.debug('Exception:: ' + Ex.getMessage());
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderItemV3',
          'subscription',
          '',
          ex
        );
      }

      Database.UpsertResult[] assetSr;

      try {
        Map<String, Asset> mappedAssets = CreateAssets(
          orderAccount.Id,
          assetRecords,
          mappedSubscriptions,
          subscriptionIdMap,
          NonVisitFeeAssets
        );
        assetSr = Database.upsert(
          mappedAssets.values(),
          Asset.GCRM_Quote_Line_ID__c,
          false
        );
        if (assetSr != null && assetSr.size() > 0) {
          for (Integer i = 0; i < assetSr.size(); i++) {
            if (!assetSr.get(i).isSuccess()) {
              Database.Error error = assetSr.get(i).getErrors().get(0);
              List<String> errorFields = error.getFields();
              String errorDetail = error.getMessage();
              if (errorFields != null && errorFields.size() > 0) {
                errorDetail =
                  errorDetail +
                  '\n' +
                  string.join(errorFields, ',\n');
              }
              ExceptionCustomLog.captureCustomException(
                thisMUID,
                'GCRM_Process_OrderV3',
                'CreateOrder',
                'orderItemV3',
                'asset',
                mappedAssets.values().get(i).Source_Id__c,
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            }
          }
        }
      } catch (Exception ex) {
        ExceptionCustomLog.captureException(
          thisMUID,
          'GCRM_Process_OrderV3',
          'CreateOrder',
          'orderItemV3',
          'asset',
          '',
          ex
        );
      }
      UpdateOppStage(targetOpportunityGUID);
      return false;
    } catch (Exception ex) {
      ExceptionCustomLog.captureException(
        thisMUID,
        'GCRM_Process_OrderV3',
        'CreateOrder',
        '',
        '',
        '',
        ex
      );
      return true;
    }
  }

  public static Map<String, Asset> CreateAssets(
    Id accountId,
    List<INT175_OrderItemV3.Subscriptions> assets,
    Map<String, SBQQ__Subscription__c> targetSubscriptions,
    Map<String, Id> subscriptionIdMap,
    List<INT175_OrderItemV3.Assets> assetRecords
  ) {
    Set<Id> SubAssetOwners = new Set<Id>();
    Set<Id> AssetOwners = new Set<Id>();
    for (INT175_OrderitemV3.Subscriptions asst : assets) {
      SubAssetOwners.add(asst.OwnerId);
    }

    Set<String> AssetProducts = new Set<String>();
    for (INT175_OrderitemV3.Assets asst : assetRecords) {
      AssetProducts.add(asst.assetName);
      AssetOwners.add(asst.OwnerId);
    }

    Map<String, Id> AssetProdmap = new Map<String, Id>();
    for (Product2 prod : [
      SELECT Id, Name
      FROM product2
      WHERE name IN :AssetProducts
    ]) {
      AssetProdmap.put(prod.Name.toLowerCase(), prod.Id);
    }

    Set<Id> existSubAssetOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
      SubAssetOwners
    );
    Set<Id> existAssetOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
      AssetOwners
    );
    Map<String, Asset> mappedAssets = new Map<String, Asset>();
    for (INT175_OrderItemV3.Subscriptions gcrmAsset : assets) {
      Id assetSubscriptionId = null;
      Id subscriptionProductId = null;
      String key;
      if (gcrmAsset.revisedSubscription != null)
        key =
          subQlimap.get(RevSubMap.get(gcrmAsset.requiredBySubscription)) +
          '-' +
          String.valueOf(Date.valueOf(gcrmAsset.subscriptionStartDate));
      else
        key =
          subQlimap.get(gcrmAsset.requiredBySubscription) +
          '-' +
          String.valueOf(Date.valueOf(gcrmAsset.subscriptionStartDate));
      if (assetSubscriptionId == null && subscriptionIdMap.containsKey(key)) {
        assetSubscriptionId = subscriptionIdMap.get(key);
      }
      System.debug('CreateAsset: gcrmAsset => ' + JSON.serialize(gcrmAsset));
      String assetName = gcrmAsset.lcrmvisitFeeCode;
      String assetDescription = gcrmAsset.lcrmvisitFeeDesc;
      String assetCurrenyIsoCode = gcrmAsset.currencyIsoCode;
      System.debug('assetCurrenyIsoCode' + assetCurrenyIsoCode);  
      

      if (assetName.contains('-')) {
        List<String> nameParts = assetName.split('-');
        assetName = nameParts[1];
        subscriptionProductId = mappedPbe.get(
            assetName + '-' + assetCurrenyIsoCode
          )
          .Product2Id;
      } else {
        subscriptionProductId = mappedPbe.get(
            assetName + '-' + assetCurrenyIsoCode
          )
          .Product2Id;
      }
      Asset assetRecord = new Asset();
      assetRecord.Name = assetDescription;
      assetRecord.Description = assetDescription;
      assetRecord.Fee_Type__c = gcrmAsset.feeType;
      assetRecord.Source_Id__c = gcrmAsset.subscriptionId;
      assetRecord.Product2Id = subscriptionProductId;
      assetRecord.Quantity = gcrmAsset.assetQuantity;
      assetRecord.Consult_Fees__c = gcrmAsset.consultFee;
      assetRecord.CurrencyIsoCode = gcrmAsset.currencyIsoCode;
      if (!existSubAssetOwners.contains(gcrmAsset.ownerId)) {
        assetRecord.OwnerId = tdSFSupportUserId;
      }
      assetRecord.SBQQ__RequiredBySubscription__c = assetSubscriptionId;
      assetRecord.SBQQ__AdditionalDiscountAmount__c = gcrmAsset.additionalDiscountAmount;
      assetRecord.AccountId = accountId;
      system.debug('Asset Account Id:::: ' + assetRecord.AccountId);
      String gcrmQuoteLineId = gcrmAsset.quoteLineId != null
        ? gcrmAsset.quoteLineId
        : gcrmAsset.originalQuoteLineId;
      assetRecord.GCRM_Quote_Line_ID__c = gcrmQuoteLineId;
      assetRecord.GCRM_Subscription_ID__c = gcrmAsset.subscriptionId;
      mappedAssets.put(gcrmAsset.assetId, assetRecord);
    }

    for (INT175_OrderitemV3.Assets asst : assetRecords) {
      Id assetSubscriptionId = null;
      String key =
        asst.requiredBySubscription +
        '-' +
        String.valueOf(Date.valueOf(asst.purchaseDate));
      if (assetSubscriptionId == null && subscriptionIdMap.containsKey(key)) {
        assetSubscriptionId = subscriptionIdMap.get(key);
      }
      Asset assetRecord = new Asset();
      assetRecord.Name = asst.assetName;
      assetRecord.Description = asst.assetName;
      assetRecord.Fee_Type__c = asst.feeType;
      assetRecord.Source_Id__c = asst.assetId;
      assetRecord.Product2Id = AssetProdmap?.get(asst.assetName.toLowerCase());
      assetRecord.Quantity = asst.assetQuantity;
      assetRecord.Consult_Fees__c = asst.consultFee;
      assetRecord.SBQQ__RequiredBySubscription__c = assetSubscriptionId;
      assetRecord.SBQQ__AdditionalDiscountAmount__c = asst.additionalDiscountAmount;
      assetRecord.currencyIsoCode = asst.currencyIsoCode;
      assetRecord.AccountId = accountId;

      if (!existAssetOwners.contains(asst.ownerId)) {
        assetRecord.OwnerId = tdSFSupportUserId;
      }

      assetRecord.GCRM_Quote_Line_ID__c = asst.latestQuoteLineId;
      assetRecord.GCRM_Subscription_ID__c = asst.requiredBySubscription;
      mappedAssets.put(asst.assetId, assetRecord);
    }
    return mappedAssets;
  }

  // Verified
  public static Account CreateAccount(
    List<INT175_AccountV3.Account> accountRecords
  ) {
    Account newAccount = new Account();
    try {
      for (INT175_AccountV3.Account candidateAccount : accountRecords) {
        accGUID = (String) candidateAccount.accountGUID;
        List<Account> currentAccounts = [
          SELECT Id, Name, GUID__c, GCRM_Account_ID__c
          FROM Account
          WHERE GUID__c = :candidateAccount.accountGUID
        ];
        if (!currentAccounts.isEmpty()) {
          Account existAccount = currentAccounts[0];
          existAccount.GCRM_Account_ID__c = candidateAccount.accountId;
          List<Database.UpsertResult> sresult = Database.upsert(
            new List<Account>{ existAccount }
          );
          if (sresult != null && sresult.size() > 0) {
            for (Integer i = 0; i < sresult.size(); i++) {
              if (!sresult.get(i).isSuccess()) {
                Database.Error error = sresult.get(i).getErrors().get(0);
                List<String> errorFields = error.getFields();
                String errorDetail = error.getMessage();
                if (errorFields != null && errorFields.size() > 0) {
                  errorDetail =
                    errorDetail +
                    '\n' +
                    string.join(errorFields, ',\n');
                }
                ExceptionCustomLog.captureCustomException(
                  thisMUID,
                  'GCRM_Process_OrderV3',
                  'CreateAccount',
                  'accountV3',
                  'account',
                  existAccount.GUID__c,
                  String.valueOf(error.getStatusCode()),
                  errorDetail
                );
              }
            }
          }
          return existAccount;
        }
        newAccount.GCRM_Account_ID__c = candidateAccount.accountId;
        newAccount.Name = candidateAccount.accountName;
        newAccount.GUID__c = candidateAccount.accountGUID;
        newAccount.Source_Id__c = candidateAccount.accountId;
        newAccount.OwnerId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
          candidateAccount.ownerId
        );
        newAccount.Source__c = 'GCRM';
        newAccount.Account_Type__c = candidateAccount.accountType;
        Map<String, Map<String, String>> valueMapping = GCRM_ProcessOrder_Utlity.g2lcrmPickListMapping(
          'Account'
        );
        if (
          valueMapping.containsKey('Account_Type__c') &&
          valueMapping.get('Account_Type__c')
            .containsKey(candidateAccount.accountType)
        ) {
          newAccount.Account_Type__c = valueMapping.get('Account_Type__c')
            .get(candidateAccount.accountType);
        } else {
          newAccount.Account_Type__c = candidateAccount.accountType;
        }
        newAccount.Friendly_Account_Name__c = candidateAccount.accountName;
        newAccount.Account_Legal_Name__c = candidateAccount.accountName;
        newAccount.AccountSource = candidateAccount.accountSource;
        newAccount.Phone = candidateAccount.phone;
        newAccount.Business_Region__c = candidateAccount.businessRegion;
        newAccount.SBQQ__ContractCoTermination__c = candidateAccount.contractCoTermination;
        newAccount.SBQQ__PreserveBundle__c = candidateAccount.hasPreserveStructureBundled;
        newAccount.SBQQ__AssetQuantitiesCombined__c = candidateAccount.isAssetQuantitiesCombined;
        newAccount.SBQQ__CoTermedContractsCombined__c = candidateAccount.isCoTermedContractsCombined;
        newAccount.Total_US_Employees_Benefits_Enrolled__c = candidateAccount.totalUSEmployeesBenefitsEnrolled;
        newAccount.currencyIsoCode = candidateAccount.currencyIsoCode;
        for (integer i = 0; i < candidateAccount.addresses.size(); i++) {
          if (candidateAccount.addresses[i].Type == 'Billing') {
            newAccount.BillingCity = candidateAccount.addresses[i].city;
            newAccount.BillingState = candidateAccount.addresses[i].state;
            newAccount.BillingCountry = candidateAccount.addresses[i].country;
            newAccount.Billingstreet = candidateAccount.addresses[i].street;
            newAccount.BillingPostalCode = candidateAccount.addresses[i]
              .postalCode;
          } else if (candidateAccount.addresses[i].Type == 'Shipping') {
            newAccount.ShippingCity = candidateAccount.addresses[i].city;
            newAccount.ShippingState = candidateAccount.addresses[i].state;
            newAccount.ShippingCountry = candidateAccount.addresses[i].country;
            newAccount.Shippingstreet = candidateAccount.addresses[i].street;
            newAccount.ShippingPostalCode = candidateAccount.addresses[i]
              .postalCode;
          }
        }
      }
      //insert newAccount;
      List<Database.SaveResult> sresult = Database.insert(
        new List<Account>{ newAccount }
      );

      if (sresult != null && sresult.size() > 0) {
        for (Integer i = 0; i < sresult.size(); i++) {
          if (!sresult.get(i).isSuccess()) {
            Database.Error error = sresult.get(i).getErrors().get(0);
            List<String> errorFields = error.getFields();
            String errorDetail = error.getMessage();
            if (errorFields != null && errorFields.size() > 0) {
              errorDetail =
                errorDetail +
                '\n' +
                string.join(errorFields, ',\n');
            }
            ExceptionCustomLog.captureCustomException(
              thisMUID,
              'GCRM_Process_OrderV3',
              'CreateAccount',
              'accountV3',
              'account',
              newAccount.GUID__c,
              String.valueOf(error.getStatusCode()),
              errorDetail
            );
          }
        }
      }
    } catch (Exception ex) {
      ExceptionCustomLog.captureException(
        thisMUID,
        'GCRM_Process_OrderV3',
        'CreateAccount',
        'accountV3',
        'account',
        '',
        ex
      );
    }
    return newAccount;
  }

  public static Contract CreateContract(
    INT175_OrderV3.Contract contract,
    Opportunity targetOpp,
    Id accountId
  ) {
    List<Contract> conList = [
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
    ];

    if (!conList.isEmpty()) {
      conList[0].GCRM_Contract_ID__c = contract.contractId;
      conList[0].External_Id__c = contract.contractId;
      return conList[0];
    }

    Contract newContract = new Contract();
    newContract.ContractTerm = contract.contractTerm;
    newContract.Name = contract.contractNumber;
    newContract.SBQQ__Opportunity__c = targetOpp.Id;
    newContract.Pricebook2Id = targetOpp.Pricebook2Id;
    newContract.AccountId = accountId;
    newContract.External_Id__c = contract.contractId;
    newContract.GCRM_Contract_ID__c = contract.contractId;
    newContract.OwnerId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
      contract.ownerId
    );
    return newContract;
  }

  public static Id CreateQuote(
    INT175_OrderV3.Quote quote,
    Id accountId,
    Id opportunityId,
    String orderGUID
  ) {
    List<SBQQ__Quote__c> existingQuote = [
      SELECT Id
      FROM SBQQ__Quote__c
      WHERE
        SBQQ__Account__c = :accountId
        AND SBQQ__Opportunity2__c = :opportunityId
        AND SBQQ__Primary__c = TRUE
    ];
    if (!existingQuote.isEmpty()) {
      return existingQuote[0].Id;
    }
    SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
    newQuote.SBQQ__Account__c = accountId;
    newQuote.SBQQ__Opportunity2__c = opportunityId;
    newQuote.SBQQ__Primary__c = true;
    newQuote.External_Id__c = orderGUID;
    newQuote.OwnerId = tdSFSupportUserId;
    if (quote.ownerId != null) {
      newQuote.OwnerId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
        quote.ownerId
      );
    }
    newQuote.GCRM_Quote_ID__c = quote.quoteId;
    Schema.SObjectField gcrmQuoteId = SBQQ__Quote__c.Fields.GCRM_Quote_ID__c;
    List<Database.UpsertResult> qteSr = Database.upsert(
      new List<SBQQ__Quote__c>{ newQuote },
      gcrmQuoteId
    );
    if (qteSr != null && qteSr.size() > 0) {
      for (Integer i = 0; i < qteSr.size(); i++) {
        if (!qteSr.get(i).isSuccess()) {
          Database.Error error = qteSr.get(i).getErrors().get(0);
          List<String> errorFields = error.getFields();
          String errorDetail = error.getMessage();
          if (errorFields != null && errorFields.size() > 0) {
            errorDetail = errorDetail + '\n' + string.join(errorFields, ',\n');
          }
          ExceptionCustomLog.captureCustomException(
            thisMUID,
            'GCRM_Process_OrderV3',
            'CreateQuote',
            'orderV3',
            'quote',
            '',
            String.valueOf(error.getStatusCode()),
            errorDetail
          );
        }
      }
    }
    //insert newQuote;
    System.debug(LoggingLevel.FINE, '[' + newQuote.Id + '] new quote');
    return newQuote.Id; // TODO: EEM - Bulkify/Errorhandling
  }

  public static Map<String, OpportunityLineItem> CreateOpportunityLineItems(
    Id opportunityId,
    List<INT175_OrderItemV3.OrderItems> orderItems,
    Map<String, String> VisitCodeMap,
    Map<String, SBQQ__QuoteLine__c> targetQuoteLines
  ) {
    Map<String, OpportunityLineItem> mappedOli = new Map<String, OpportunityLineItem>();

    for (INT175_OrderItemV3.OrderItems newOrderItem : orderItems) {
      String visitfeecode;

      if (newOrderItem.productCode == 'VISITFEE') {
        visitfeecode = VisitCodeMap.get(newOrderitem.orderItemId);
      }

      String productid = mappedPbe.containsKey(
          newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
        )
        ? mappedPbe.get(
              newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
            )
            .product2Id
        : newOrderItem.productId;
      String PricebookentryId = mappedPbe.get(
          newOrderItem.productCode + '-' + newOrderItem.CurrencyIsoCode
        ) == null
        ? (mappedPbe.get(visitfeecode + '-' + newOrderItem.CurrencyIsoCode) !=
            null
            ? mappedPbe.get(visitfeecode + '-' + newOrderItem.CurrencyIsoCode)
                .Id
            : null)
        : mappedPbe.get(
              newOrderItem.productCode + '-' + newOrderItem.CurrencyIsoCode
            )
            .Id;
      String key;

      if (
        newOrderItem.productCode == 'BD-CANADA-BUNDLE' &&
        newOrderItem.quoteLine.productVersion == '2.0'
      ) {
        key =
          newOrderItem.productCode +
          '-' +
          newOrderItem.quoteLine.productVersion +
          '-' +
          newOrderItem.currencyIsoCode;
        productid = mappedPbe.containsKey(key)
          ? mappedPbe.get(key).Product2Id
          : newOrderItem.productId;
        PricebookentryId = mappedPbe.containsKey(key)
          ? mappedPbe.get(key).id
          : null;
      }
      if (productid == null || newOrderItem.servicingPlatform == 'HHS') {
        System.debug(
          '[CreateOpportunityLines]: ' +
            newOrderItem.orderItemId +
            '/' +
            newOrderItem.productCode +
            '/' +
            newOrderItem.servicingPlatform
        );
        continue;
      }
      SBQQ__QuoteLine__c targetQLine = targetQuoteLines.get(
        newOrderItem.orderItemId +
          '-' +
          String.valueOf(Date.valueOf(newOrderItem.serviceDate))
      );

      String gcrmQuoteLineId = '';

      if (
        newOrderItem.subscriptions != null &&
        newOrderItem.subscriptions.size() > 0
      ) {
        gcrmQuoteLineid = newOrderItem.subscriptions[0].quoteLineId != null
          ? newOrderItem.subscriptions[0].quoteLineId
          : newOrderItem.subscriptions[0].originalQuoteLineId;
      } else if (assetQLIMap.get(newOrderItem.orderItemId) != null) {
        gcrmQuoteLineId = assetQLIMap.get(newOrderItem.orderItemId);
      }
      system.debug(
        'OI : '  + newOrderItem.orderItemId + ' ::OLI: ' + gcrmQuoteLineId
      );
      mappedOli.put(
        newOrderItem.orderItemId,
        new OpportunityLineItem(
          OpportunityId = opportunityId,
          Source_Id__c = newOrderItem.orderItemId,
          Quantity = newOrderItem.orderedQuantity,
          SBQQ__QuoteLine__c = targetQLine?.Id,
          PricebookEntryId = PricebookentryId,
          Product2Id = productid,
          ServiceDate = newOrderItem.serviceDate,
          TotalPrice = newOrderItem.totalPrice,
          GCRM_Quote_Line_ID__c = gcrmQuoteLineId,
          Bundle_Type__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].bundleType
            : null,
          Anchor__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderitem.subscriptions[0].isAnchor
            : false,
          Vendor_Partner__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].vendorPartner
            : null
        )
      );
    }
    return mappedOli;
  }

  public static Map<String, SBQQ__QuoteLine__c> CreateQuoteLines(
    Id quoteId,
    List<INT175_OrderItemV3.OrderItems> orderItems,
    List<INT175_OrderItemV3.Subscriptions> assetRecords
  ) {
    Map<String, SBQQ__QuoteLine__c> mappedQl = new Map<String, SBQQ__QuoteLine__c>();
    Map<String, Date> assetMap = new Map<String, Date>();

    for (INT175_OrderItemV3.Subscriptions asst : assetRecords) {
      assetMap.put(
        asst.orderProductId,
        Date.valueof(asst.subscriptionStartDate)
      );
    }
    for (INT175_OrderItemV3.OrderItems newOrderItem : orderItems) {
      String productid;
      productid = mappedPbe.containsKey(
          newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
        )
        ? mappedPbe.get(
              newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
            )
            .Product2Id
        : newOrderItem.productId;

      if (
        newOrderItem.productCode == 'BD-CANADA-BUNDLE' &&
        newOrderItem.quoteLine.productVersion == '2.0'
      ) {
        String key =
          newOrderItem.productCode +
          '-' +
          newOrderItem.quoteLine.productVersion +
          '-' +
          newOrderItem.currencyIsoCode;
        productid = mappedPbe.containsKey(key)
          ? mappedPbe.get(key).Product2Id
          : newOrderItem.productId;
      }
      if (productid == null || newOrderItem.servicingPlatform == 'HHS') {
        System.debug(
          '[CreateQuoteLines] SKIPPED: ' +
            newOrderItem.productCode +
            '/' +
            newOrderItem.servicingPlatform
        );
        continue;
      }
      System.debug(
        'Subscription in create quote line' + newOrderItem.subscriptions
      );

      Date StartDate = newOrderItem.subscriptions != null &&
        newOrderItem.subscriptions.size() > 0
        ? newOrderItem.subscriptions[0].subscriptionStartDate
        : (assetMap.get(newOrderItem.orderItemId) != null
            ? assetMap.get(newOrderItem.orderItemId)
            : null);
      String gcrmQuoteLineId = '';

      if (
        newOrderItem.subscriptions != null &&
        newOrderItem.subscriptions.size() > 0
      ) {
        gcrmQuoteLineId = newOrderItem.subscriptions[0].quoteLineId != null
          ? newOrderItem.subscriptions[0].quoteLineId
          : newOrderItem.subscriptions[0].originalQuoteLineId;
      } else if (assetQLIMap.get(newOrderItem.orderItemId) != null) {
        gcrmQuoteLineId = assetQLIMap.get(newOrderItem.orderItemId);
      }
      system.debug(
        'OI : ' + newOrderItem.orderItemId + ' ::QLI: ' + gcrmQuoteLineId
      );
      mappedQl.put(
        newOrderItem.orderItemId + '-' + String.valueOf(StartDate),
        new SBQQ__QuoteLine__c(
          SBQQ__Quote__c = quoteId,
          SBQQ__Product__c = productid,
          External_Id__c = newOrderItem.orderItemId,
          Anchor__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].isAnchor
            : false,
          GCRM_Quote_Line_ID__c = gcrmQuoteLineId,
          Bundle_Type__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].bundleType
            : null,
          Consult_Type__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].consultType
            : null,
          SBQQ__StartDate__c = StartDate,
          Participant_Quantity__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].participantQuantity
            : null,
          Subscription_Fee__c = newOrderitem.membershipFee,
          CurrencyIsoCode = newOrderItem.currencyIsoCode,
          SBQQ__ListPrice__c = newOrderitem.listPrice,
          Vendor_Partner__c = newOrderItem.subscriptions != null &&
            newOrderItem.subscriptions.size() > 0
            ? newOrderItem.subscriptions[0].vendorPartner
            : null
        )
      );
    }
    return mappedQl;
  }

  public static Map<String, SBQQ__Subscription__c> CreateSubscriptions(
    Map<Id, INT175_OrderItemV3.OrderItems> mappedOrderItems,
    List<INT175_OrderItemV3.Subscriptions> subscriptionRecords,
    Map<String, SBQQ__QuoteLine__c> targetQuoteLines,
    Id accountId,
    Id contractId,
    List<INT175_OrderItemV3.Subscriptions> assetRecords
  ) {
    Map<String, SBQQ__Subscription__c> mappedSubs = new Map<String, SBQQ__Subscription__c>();
    set<id> subIds = new Set<id>();
    Set<Id> SubsOwners = new Set<Id>();

    for (INT175_OrderitemV3.Subscriptions sub : subscriptionRecords) {
      SubsOwners.add(sub.OwnerId);
    }

    Set<Id> existSubsOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
      SubsOwners
    );

    for (INT175_OrderItemV3.Subscriptions gcrmSub : subscriptionRecords) {
      if (gcrmSub.orderProductId == null) {
        System.debug(
          '[CreateSubscription] gcrmSub.orderProductId == null: ' +
          gcrmSub.subscriptionId
        );
      }
      SBQQ__QuoteLine__c targetQLine = targetQuoteLines.get(
        gcrmSub.orderProductId +
          '-' +
          String.valueOf(Date.valueOf(gcrmSub.subscriptionStartDate))
      );
      INT175_OrderItemV3.OrderItems newOrderItem = mappedOrderItems.get(
        gcrmSub.orderProductId
      );

      // TODO: add 'None' to SBQQ__Subscription__c.Consult_Type__c
      // TODO: Create DEFECT ticket: gcrmSub.subscriptionType => SBQQ__ProductSubscriptionType
      // TODO: pricing missing on subscription

      String productid = mappedPbe.get(
          newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
        ) != null
        ? mappedPbe.get(
              newOrderItem.productCode + '-' + newOrderItem.currencyIsoCode
            )
            .Product2Id
        : null;

      if (
        newOrderItem.productCode == 'BD-CANADA-BUNDLE' &&
        newOrderItem.quoteLine.productVersion == '2.0'
      ) {
        String key =
          newOrderItem.productCode +
          '-' +
          newOrderItem.quoteLine.productVersion +
          '-' +
          newOrderItem.currencyIsoCode;
        productid = mappedPbe.containsKey(key)
          ? mappedPbe.get(key).Product2Id
          : newOrderItem.productId;
      }

      String gcrmQuoteLineid = gcrmSub.quoteLineId != null
        ? gcrmSub.quoteLineId
        : gcrmSub.quoteLineId;

      SBQQ__Subscription__c tmpSub = new SBQQ__Subscription__c();
      tmpSub.External_Id__c =
        gcrmQuoteLineid +
        '-' +
        String.valueOf(Date.valueOf(gcrmSub.subscriptionStartDate));
      tmpSub.SBQQ__Bundle__c = gcrmSub.isBundled;
      tmpSub.Bundle_Type__c = gcrmSub.bundleType;
      tmpSub.SBQQ__QuoteLine__c = targetQLine.Id;
      tmpSub.SBQQ__Product__c = productid;
      tmpSub.SBQQ__Quantity__c = gcrmSub.subscriptionQuantity;
      tmpSub.Participant_Quantity__c = gcrmSub.subscriptionQuantity;
      tmpSub.SBQQ__SubscriptionPricing__c = gcrmSub.subscriptionPricing;
      tmpSub.SBQQ__ProductSubscriptionType__c = gcrmSub.subscriptionType;
      tmpSub.SBQQ__AdditionalDiscountAmount__c = gcrmSub.additionalDiscountAmount;
      tmpSub.SBQQ__SubscriptionType__c = gcrmSub.subscriptionType;
      if (!existSubsOwners.contains(gcrmSub.ownerId)) {
        tmpSub.OwnerId = tdSFSupportUserId;
      }
      tmpSub.GCRM_Quote_Line_ID__c = gcrmQuoteLineid;
      tmpSub.GCRM_Subscription_ID__c = gcrmSub.subscriptionId;
      tmpSub.Consult_Type__c = gcrmSub.consultType;
      tmpSub.Fee_Type__c = gcrmSub.feeType;
      tmpSub.SBQQ__ProrateMultiplier__c = gcrmSub.prorateMultiplier;
      tmpSub.SBQQ__RenewalPrice__c = gcrmSub.renewalPrice;
      tmpSub.SBQQ__RenewalQuantity__c = gcrmSub.renewalQuantity;
      tmpSub.CurrencyIsoCode = gcrmSub.currencyIsoCode;
      tmpSub.SBQQ__Contract__c = contractId;
      tmpSub.Current_Membership_Fee__c = newOrderItem.membershipFee;
      tmpSub.SBQQ__SubscriptionStartDate__c = gcrmSub.subscriptionStartDate;
      tmpSub.Vendor_Partner__c = gcrmSub.vendorPartner;
      tmpSub.SBQQ__Account__c = accountId;
      mappedSubs.put(
        gcrmQuoteLineid +
          '-' +
          String.valueOf(Date.valueOf(gcrmSub.subscriptionStartDate)),
        tmpSub
      );
      subIds.add(gcrmQuoteLineid);
      subQlimap.put(gcrmSub.subscriptionId, gcrmQuoteLineid);
      if (gcrmSub.revisedSubscription != null)
        RevSubMap.put(gcrmSub.revisedSubscription, gcrmSub.subscriptionId);
    }

    //Create map of Subscriptions to assets
    Map<String, List<INT175_OrderItemV3.Subscriptions>> subsAssetMap = new Map<String, List<INT175_OrderItemV3.Subscriptions>>();

    for (INT175_OrderItemV3.Subscriptions asst : assetRecords) {
      if (subIds.contains(subQlimap.get(asst.requiredBySubscription))) {
        if (
          subsAssetMap.containsKey(subQlimap.get(asst.requiredBySubscription))
        )
          subsAssetMap.get(subQlimap.get(asst.requiredBySubscription))
            .add(asst);
        else
          subsAssetMap.put(
            subQlimap.get(asst.requiredBySubscription),
            new List<INT175_OrderItemV3.Subscriptions>{ asst }
          );
      }
    }

    // Get ProductId, membership Fee and Account details from master subscription for Visit Fee products
    Map<String, Decimal> membershipFee = new Map<String, Decimal>();
    Map<String, Id> productId = new Map<String, Id>();
    Map<String, Id> acctId = new Map<String, Id>();
    Set<Id> SubAssetOwners = new Set<Id>();

    for (String subsId : subsAssetMap.keySet()) {
      if (subsAssetMap.get(subsId).size() > 1) {
        for (INT175_OrderItemV3.Subscriptions asst : subsAssetMap.get(subsId)) {
          if (
            mappedSubs.get(
              subsId +
                '-' +
                String.valueOf(Date.valueOf(asst.subscriptionStartDate))
            ) == null
          ) {
            SubAssetOwners.add(asst.OwnerId);
          }
          if (
            mappedSubs.get(
              subsId +
                '-' +
                String.valueOf(Date.valueof(asst.subscriptionStartDate))
            ) != null
          ) {
            membershipFee.put(
              subQlimap.get(asst.requiredBySubscription),
              mappedSubs.get(
                  subsId +
                    '-' +
                    String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                ) != null
                ? mappedSubs.get(
                      subsId +
                        '-' +
                        String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                    )
                    .Current_Membership_Fee__c
                : null
            );
            productId.put(
              subQlimap.get(asst.requiredBySubscription),
              mappedSubs.get(
                  subsId +
                    '-' +
                    String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                ) != null
                ? mappedSubs.get(
                      subsId +
                        '-' +
                        String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                    )
                    .SBQQ__Product__c
                : null
            );
            acctId.put(
              subQlimap.get(asst.requiredBySubscription),
              mappedSubs.get(
                  subsId +
                    '-' +
                    String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                ) != null
                ? mappedSubs.get(
                      subsId +
                        '-' +
                        String.valueOf(Date.valueOf(asst.subscriptionStartDate))
                    )
                    .SBQQ__Account__c
                : null
            );
          }
        }
      }
    }

    Set<Id> existSubAssetsOwners = GCRM_ProcessOrder_Utlity.getExistingUsersSet(
      SubAssetOwners
    );

    //create subscription records for visit fee of subsequent years
    for (String subsId : subsAssetMap.keySet()) {
      if (subsAssetMap.get(subsId).size() > 1) {
        for (INT175_OrderItemV3.Subscriptions asst : subsAssetMap.get(subsId)) {
          if (
            mappedSubs.get(
              subsId +
                '-' +
                String.valueOf(Date.valueOf(asst.subscriptionStartDate))
            ) == null
          ) {
            SBQQ__QuoteLine__c targetQLine = targetQuoteLines.get(
              asst.orderProductId +
                '-' +
                String.valueOf(Date.valueOf(asst.subscriptionStartDate))
            );
            SBQQ__Subscription__c tmpSub = new SBQQ__Subscription__c();
            tmpSub.External_Id__c =
              subQlimap.get(asst.requiredBySubscription) +
              '-' +
              String.valueOf(Date.valueOf(asst.subscriptionStartDate));
            tmpSub.SBQQ__Bundle__c = asst.isBundled;
            tmpSub.Bundle_Type__c = asst.bundleType;
            tmpSub.SBQQ__QuoteLine__c = targetQLine.Id;
            tmpSub.SBQQ__Product__c = productid.get(
              subQlimap.get(asst.requiredBySubscription)
            );
            tmpSub.SBQQ__Quantity__c = asst.subscriptionQuantity;
            tmpSub.Participant_Quantity__c = asst.subscriptionQuantity;
            tmpSub.SBQQ__SubscriptionPricing__c = asst.subscriptionPricing;
            tmpSub.SBQQ__ProductSubscriptionType__c = asst.subscriptionType;
            tmpSub.SBQQ__AdditionalDiscountAmount__c = asst.additionalDiscountAmount;
            tmpSub.SBQQ__SubscriptionType__c = asst.subscriptionType;
            tmpSub.Consult_Type__c = asst.consultType;
            tmpSub.Fee_Type__c = asst.feeType;
            tmpSub.SBQQ__ProrateMultiplier__c = asst.prorateMultiplier;
            tmpSub.SBQQ__RenewalPrice__c = asst.renewalPrice;
            tmpSub.SBQQ__RenewalQuantity__c = asst.renewalQuantity;
            tmpSub.CurrencyIsoCode = asst.currencyIsoCode;
            tmpSub.SBQQ__Contract__c = contractId;
            tmpSub.Current_Membership_Fee__c = membershipFee.get(
              subQlimap.get(asst.requiredBySubscription)
            );
            tmpSub.SBQQ__SubscriptionStartDate__c = asst.subscriptionStartDate;
            tmpSub.SBQQ__Account__c = acctId.get(
              subQlimap.get(asst.requiredBySubscription)
            );
            if (!existSubAssetsOwners.contains(asst.ownerId)) {
              tmpSub.OwnerId = tdSFSupportUserId;
            }
            tmpSub.GCRM_Quote_Line_ID__c = targetQLine.GCRM_Quote_Line_ID__c;
            tmpSub.GCRM_Subscription_ID__c = asst.subscriptionId;
            tmpSub.Vendor_Partner__c = asst.vendorPartner;
            mappedSubs.put(
              asst.requiredBySubscription +
                '-' +
                String.valueOf(Date.valueOf(asst.subscriptionStartDate)),
              tmpSub
            );
            system.debug(
              'subscription key' +
                subQlimap.get(asst.requiredBySubscription) +
                '-' +
                String.valueOf(Date.valueOf(asst.subscriptionStartDate))
            );
          }
        }
      }
    }

    return mappedSubs;
  }

  public static void UpdateOppStage(String OppGuid) {
    List<Opportunity> createdOpportunities = [
      SELECT
        Id,
        Name,
        Opp_Guid__c,
        Amount,
        StageName,
        AccountId,
        Source__c,
        Initial_of_Lives__c,
        CloseDate,
        CreatedDate
      FROM Opportunity
      WHERE Opp_Guid__c = :OppGuid
    ];
    Opportunity createdOpp = createdOpportunities[0];
    List<OpportunityLineItem> oppliList = [
      SELECT Id, OpportunityId
      FROM OpportunityLineItem
      WHERE OpportunityId = :createdOpp.Id
    ];
    createdOpp.StageName = 'Closed Won';
    update createdOpp;
  }

  public static Map<String, PricebookEntry> GatherPbe(String CurrencyCode) {
    String pricebookname;
    Map<String, PricebookEntry> mappedPbe = new Map<String, PricebookEntry>();

    if (CurrencyCode == 'USD') {
      pricebookname = 'Teladoc Price Book';
    } else if (CurrencyCode == 'CAD') {
      pricebookname = 'Canada Pricebook';
    }

    List<PricebookEntry> localPbe = [
      SELECT
        Id,
        Name,
        Pricebook2Id,
        Pricebook2.Name,
        Product2Id,
        CurrencyIsoCode,
        UnitPrice,
        IsActive,
        UseStandardPrice,
        CreatedDate,
        CreatedById,
        LastModifiedDate,
        LastModifiedById,
        SystemModstamp,
        ProductCode,
        IsDeleted,
        IsArchived,
        Fee_Display_Picklist__c,
        Copado_External_Id__c
      FROM PricebookEntry
      WHERE
        Pricebook2.Name = :pricebookname
        AND currencyISOCode = :CurrencyCode
        AND IsActive = TRUE
    ];
    for (PricebookEntry tmpPbe : localPbe) {
      String mapKey = tmpPbe.ProductCode + '-' + tmpPbe.CurrencyIsoCode;
      mappedPbe.put(mapKey, tmpPbe);
    }

    return mappedPbe;
  }

}