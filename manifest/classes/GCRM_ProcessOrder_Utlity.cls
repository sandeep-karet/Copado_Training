/*
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-4353    12-Dec-2023    Elambaruthi T   Setup Default Owner to Salesforce Support User
 */
public with sharing class GCRM_ProcessOrder_Utlity {
    public static Map<String, List<g2lcrm_mapping__mdt>> fieldMapping = new Map<String, List<g2lcrm_mapping__mdt>>();
    public static Map<String, String> processorMapping = new Map<String, String>();
    public static Map<String, priceBookEntry> mappedPbe = new Map<String, PriceBookEntry>();
    public static Id cadPriceBookId;
    public static String defaultOwner;
    public static Map<String,String> defaultOwnerMap = new Map<String,String>();
    public static String msIntegrationUsername = System.Label.Mulesoft_Integration_User;
    public static void initUtil(String currencyCode) {
      for (g2lcrm_mapping__mdt mapping : [
        SELECT
          Id,
          LCRM_Field_Name__c,
          LCRM_Object_name__c,
          JSON_Objects_Name__c,
          JSON_Field_Name__c,
          DataType__c,
          Field_Name__c,
          Field_Value__c,
          Processor__c
        FROM g2lcrm_mapping__mdt
        WITH SECURITY_ENFORCED
      ]) {
        if (
          fieldMapping.get(
            mapping.JSON_Objects_Name__c + '-' + mapping.LCRM_Object_name__c
          ) != null
        ){
          fieldMapping.get(
              mapping.JSON_Objects_Name__c + '-' + mapping.LCRM_Object_name__c
            )
            .add(mapping);
        }          
        else{
          fieldMapping.put(
            mapping.JSON_Objects_Name__c + '-' + mapping.LCRM_Object_name__c,
            new List<g2lcrm_mapping__mdt>{ mapping }
          );
        }          
      }
      //Gather PriceBookEntries
      mappedPbe = gatherPbe(currencyCode);
    }
    /*****************************************************
      /* Method Name        : getProductFamily
      /* Method Description : Method to Map fields from payload to Fields
      /* Method Parameters  : Object Name, List of payloadObj
      ******************************************************/
    public static string getProductFamily(
      Map<String, Object> orderItemRecord,
      String currencyCode
    ) {
      if (currencyCode == null){
        currencyCode = 'USD';
      }
      String productkey =
        (String) orderItemRecord.get('productCode') +
        '-' +
        currencyCode;
        System.debug('UTILITY Initial '+productkey);
      switch on (String) orderItemRecord.get('productCode') {
        when 'PRIM360CARE-BUNDLE' {
          productkey = 'PRIM360CARE' + '-' + currencyCode;
        }
        when 'VISITFEE' {
          String visitFeeCode = orderItemRecord.get('lcrmvisitFeeCode') != null
            ? (String) orderItemRecord.get('lcrmvisitFeeCode')
            : (String) orderItemRecord.get('feeCode');
          productkey = visitFeeCode + '-' + currencyCode;
        }
        when 'BD-CANADA-BUNDLE' {
          Map<String, Object> quoteLine = (Map<String, Object>) orderItemRecord.get(
            'quoteLine'
          );
          if (quoteLine.get('productVersion') == '2.0'){
            productkey =
              orderItemRecord.get('productCode') +
              '-' +
              quoteLine.get('productVersion') +
              '-' +
              currencyCode;
          }            
        }
      }
      System.debug('UTILITY get '+productkey+':'+mappedPbe.get(productkey)?.Product2.Family);
      return mappedPbe.get(productkey)?.Product2.Family;
    }
    
      /*****************************************************
      /* Method Name        : fieldMapping
      /* Method Description : Method to Map fields from payload to Fields
      /* Method Parameters  : Object Name, List of payloadObj,Processor name
      ******************************************************/
      public static List<SObject> fieldMapping(
      String objectName,
      String lcrmObjectname,
      List<Map<String, Object>> payloadObj,
      String processor
      ) {
      List<SObject> mappedObject = new List<Sobject>();
      SObject recordObject;
      for (Map<String, Object> objmap : payloadObj) {
        List<g2lcrm_mapping__mdt> mappingList = fieldMapping
          ?.get(objectName + '-' + lcrmObjectname);
        if (mappingList != null) {
          recordObject = constructObject(lcrmObjectname);
          for (g2lcrm_mapping__mdt mdt : mappingList) {
            if (
              mdt.Field_Name__c == null 
              && mdt.Field_Value__c == null
              && mdt.LCRM_Object_name__c == lcrmObjectname
              && mdt.JSON_Objects_Name__c == objectName 
              && mdt.processor__c == processor
              && objmap.get(mdt.JSON_Field_Name__c) != null
            ) {
                if (mdt.DataType__c.equalsIgnoreCase('Decimal')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Decimal.valueOf(
                      String.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                    )
                  );
                }                
                else if (mdt.DataType__c.equalsIgnoreCase('String')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    (String) objmap.get(mdt.JSON_Field_Name__c)
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Boolean')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    (Boolean) objmap.get(mdt.JSON_Field_Name__c)
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Date')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Date.valueOf(
                      String.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                    )
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Integer')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Integer.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                  );
                }                  
              }
            }
          }
        mappedObject.add(recordObject);
      }
      return mappedObject;
    }
   
    /*****************************************************
      /* Method Name        : fieldMapping
      /* Method Description : Method to Map fields from payload to Fields irrespective of processor value
      /* Method Parameters  : Object Name, List of payloadObj
      ******************************************************/
    public static List<SObject> fieldMapping(
      String objectName,
      String lcrmObjectname,
      List<Map<String, Object>> payloadObj
    ) {
      List<SObject> mappedObject = new List<Sobject>();
      SObject recordObject;
      for (Map<String, Object> objmap : payloadObj) {
        List<g2lcrm_mapping__mdt> mappingList = fieldMapping?.get(objectName + '-' + lcrmObjectname);
        if (mappingList != null) {
          recordObject = constructObject(lcrmObjectname);
          for (g2lcrm_mapping__mdt mdt : mappingList) {
            if (
              mdt.Field_Name__c == null &&
              mdt.Field_Value__c == null &&
              mdt.LCRM_Object_name__c == lcrmObjectname
              && mdt.JSON_Objects_Name__c == objectName &&
              objmap.get(mdt.JSON_Field_Name__c) != null
            ) {
                if (mdt.DataType__c.equalsIgnoreCase('Decimal')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Decimal.valueOf(
                      String.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                    )
                  );
                }                
                else if (mdt.DataType__c.equalsIgnoreCase('String')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    (String) objmap.get(mdt.JSON_Field_Name__c)
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Boolean')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    (Boolean) objmap.get(mdt.JSON_Field_Name__c)
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Date')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Date.valueOf(
                      String.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                    )
                  );
                }                  
                else if (mdt.DataType__c.equalsIgnoreCase('Integer')){
                  recordObject.put(
                    mdt.LCRM_Field_Name__c,
                    Integer.valueOf(objmap.get(mdt.JSON_Field_Name__c))
                  );
                }                  
              }
            }
          }
        mappedObject.add(recordObject);
      }
      return mappedObject;
    }
   
    /*****************************************************
      /* Method Name        : constructObject
      /* Method Description : Method toConstruct the SOject depending on the object Name
      /* Method Parameters  : Object Name
      ******************************************************/
    static SObject constructObject(String objName) {
      SObject recordObject;
      
      if (objName.equalsIgnoreCase('Account')){
        recordObject = new Account();
      }        
      else if (objName.equalsIgnoreCase('Contact')){
        recordObject = new Contact();
      }        
      else if (objName.equalsIgnoreCase('Opportunity')){
        recordObject = new Opportunity();
      }        
      else if (objName.equalsIgnoreCase('OpportunityLineItem')){
        recordObject = new OpportunityLineItem();
      }        
      else if (objName.equalsIgnoreCase('OpportunityContactRole')){
        recordObject = new OpportunityContactRole();
      }        
      else if (objName.equalsIgnoreCase('SBQQ__Quote__c')){
        recordObject = new SBQQ__Quote__c();
      }       
      else if (objName.equalsIgnoreCase('SBQQ__QuoteLine__c')){
        recordObject = new SBQQ__QuoteLine__c();
      }        
      else if (objName.equalsIgnoreCase('Contract')){
        recordObject = new Contract();
      }        
      else if (objName.equalsIgnoreCase('SBQQ__Subscription__c')){
        recordObject = new SBQQ__Subscription__c();
      }        
      else if (objName.equalsIgnoreCase('Asset')){
        recordObject = new Asset();
      }
        
      return recordObject;
    }
    /*****************************************************
      /* Method Name        : GatherPbe
      /* Method Description : Method to Query price book entries
      /* Method Parameters  : NA
      ******************************************************/
    static Map<String, PricebookEntry> gatherPbe(String currencyCode) {
      String pricebookname;
      if (currencyCode == 'USD') {
        pricebookname = 'Teladoc Price Book';
      } else {
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
          Copado_External_Id__c,
          Product2.Family
        FROM PricebookEntry
        WHERE
          Pricebook2.Name = :pricebookname
          AND currencyISOCode = :currencyCode
          AND IsActive = TRUE
        WITH SECURITY_ENFORCED
      ];
      Map<String, PricebookEntry> mappedPbe = new Map<String, PricebookEntry>();
      for (PricebookEntry tmpPbe : localPbe) {
        String mapKey = tmpPbe.ProductCode + '-' + tmpPbe.CurrencyIsoCode;
        mappedPbe.put(mapKey, tmpPbe);
        if (tmpPbe.Pricebook2.name.containsIgnoreCase('canada')) {
          cadPriceBookId = tmpPbe.priceBook2Id;
        }
      }
      return mappedPbe;
    }
    /*****************************************************
      /* Method Name        : conditionalfieldMapping
      /* Method Description : Method to Map fields from payload to Fields based on critiera
      /* Method Parameters  : Object Name, Object to map
      ******************************************************/
    public static SObject conditionalfieldMapping(
      String objectName,
      String lcrmObjectName,
      SObject resObj,
      List<Map<String, Object>> payloadObj
    ) {
      if (resObj == null) {
        resObj = constructObject(lcrmObjectname);
      }
      for (Map<String, Object> dataObj : payloadObj) {
        for (
          g2lcrm_mapping__mdt mdt : fieldMapping
            ?.get(objectName + '-' + lcrmObjectname)
        ) {
          if (
            mdt.LCRM_Object_name__c.equalsIgnoreCase(lcrmObjectName) &&
            mdt.JSON_Objects_Name__c.equalsIgnoreCase(objectName) &&
            mdt.Field_Name__c != null &&
            mdt.Field_Value__c != null
          ) {
            if (
              (dataObj.get(mdt.Field_Name__c) != null &&
              ((String) dataObj.get(mdt.Field_Name__c) == mdt.Field_Value__c)) ||
              (mdt.Field_Value__c == 'null' &&
              dataObj.get(mdt.Field_Name__c) == null)
            ) {
              if (mdt.DataType__c == 'Decimal'){
                resObj.put(
                  mdt.LCRM_Field_Name__c,
                  (Decimal) dataObj.get(mdt.JSON_Field_Name__c)
                );
              }                
              if (mdt.DataType__c == 'String'){
                resObj.put(
                  mdt.LCRM_Field_Name__c,
                  (String) dataObj.get(mdt.JSON_Field_Name__c)
                );
              }
                
            }
          }
        }
      }
      return resObj;
    }
    /*****************************************************
      /* Method Name        : upsertRecords
      /* Method Description : Method to upsertRecords
      /* Method Parameters  : muid, List of Records, Module Name,Method Name ,processor ,ExternalId Field
      ******************************************************/
    public static Set<Id> upsertRecords(
      String muid,
      List<SObject> recordsTpUpsert,
      String methodName,
      String processor,
      String process,
      Schema.SObjectField externalIdField
    ) {
      Set<Id> successIds = new Set<Id>();
      Database.upsertResult[] upsr;
      try {
        if (externalIdField != null) {
          upsr = Database.upsert(recordsTpUpsert, externalIdField, false);
          for (Database.UpsertResult sr : upsr) {
            if (sr.isSuccess()) {
              successIds.add(sr.getId());
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
                muid,
                'GCRM_Process_OrderV4',
                methodName,
                processor,
                process,
                '',
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            }
          }
        } else {
          upsr = Database.upsert(recordsTpUpsert, false);
          for (Database.UpsertResult sr : upsr) {
            if (sr.isSuccess()) {
              successIds.add(sr.getId());
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
                muid,
                'GCRM_Process_OrderV4',
                methodName,
                processor,
                process,
                '',
                String.valueOf(error.getStatusCode()),
                errorDetail
              );
            }
          }
        }
      } catch (Exception ex) {
        ExceptionCustomLog.captureException(
          muid,
          'GCRM_Process_OrderV4',
          methodName,
          processor,
          process,
          '',
          ex
        );
      }
      return successIds;
    }
   
    /*****************************************************
      /* Method Name        : getproductId
      /* Method Description : Method to get Product Id mapped
      /* Method Parameters  : Orderitem payload
      ******************************************************/
   
    public static PricebookEntry getproductId(
      Map<String, Object> orderItemRecord,
      String currencyCode
    ) {
      List<Map<String, Object>> subRecord = new List<Map<String, Object>>();
      if (orderItemRecord.get('subscriptions') != null) {
        for (Object obj : (List<object>) orderItemRecord.get('subscriptions')) {
          subRecord.add((map<String, Object>) obj);
        }
      }
      if (currencyCode == null){
        currencyCode = 'USD';
      }
        
      String productkey =
        (String) orderItemRecord.get('productCode') +
        '-' +
        currencyCode;
      String visitFeeCode;
      switch on (String) orderItemRecord.get('productCode') {
        when 'VISITFEE' {
          if (subRecord != null && subRecord.size() > 0) {
            visitFeeCode = subRecord != null &&
              subRecord[0].get('LCRMVisitFeeCode') != null
              ? (String) subRecord[0].get('LCRMVisitFeeCode')
              : (String) orderItemRecord.get('feeCode');
          } else {
            visitFeeCode = orderItemRecord.get('LCRMvisitFeeCode') != null
              ? (String) orderItemRecord.get('LCRMvisitFeeCode')
              : (String) orderItemRecord.get('feeCode');
          }
          productkey = visitFeeCode + '-' + currencyCode;
        }
        when 'BD-CANADA-BUNDLE' {
          Map<String, Object> quoteLine = (Map<String, Object>) orderItemRecord.get(
            'quoteLine'
          );
          if (quoteLine.get('productVersion') == '2.0'){
            productkey =
              orderItemRecord.get('productCode') +
              '-' +
              quoteLine.get('productVersion') +
              '-' +
              currencyCode;
          }
            
        }
      }
      return mappedPbe.get(productkey);
    }
   
    /*****************************************************
      /* Method Name        : deleteRecordsBymuid
      /* Method Description : Method to delete the child records during the Earley Implementation Opportunity ReOpen
      /* Method Parameters  : muid
      ******************************************************/
    public static void deleteRecordsBymuid(String oppGUID) {
      Savepoint objSavePoint = Database.setSavepoint();
      Set<Id> subIds = new Set<Id>();
      Set<id> qteIds = new Set<id>();
      List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
      try {
        Opportunity opp = [
          SELECT Id
          FROM Opportunity
          WHERE Opp_Guid__c = :oppGUID
          WITH SECURITY_ENFORCED
          LIMIT 1          
        ];
   
        List<Contract> contractList = [
          SELECT Id
          FROM Contract
          WHERE SBQQ__Opportunity__c = :opp.Id
          WITH SECURITY_ENFORCED
        ];
        for (SBQQ__Quote__c qte : [
          SELECT Id
          FROM SBQQ__Quote__c
          WHERE SBQQ__Opportunity2__c = :opp.Id AND SBQQ__Primary__c = TRUE
          WITH SECURITY_ENFORCED
        ]) {
          qteIds.add(qte.Id);
        }
   
        for (SBQQ__Subscription__c subs : [
          SELECT Id
          FROM SBQQ__Subscription__c
          WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :qteIds
          WITH SECURITY_ENFORCED
        ]) {
          subIds.add(subs.Id);
          subsList.add(subs);
        }
   
        List<Plan_Specific_Fees__c> psfList = [
          SELECT Id
          FROM Plan_Specific_Fees__c
          WHERE Subscription__c IN :subIds
          WITH SECURITY_ENFORCED
        ];
  
        List<Asset> assetList = [
          SELECT Id
          FROM Asset
          WHERE SBQQ__RequiredBySubscription__c IN :subIds
          WITH SECURITY_ENFORCED
        ];
   
        List<SBQQ__QuoteLine__c> qlList = [
          SELECT Id
          FROM SBQQ__QuoteLine__c
          WHERE SBQQ__Quote__c IN :qteIds
          WITH SECURITY_ENFORCED
        ];
   
        List<OpportunityLineItem> oliList = [
          SELECT Id
          FROM OpportunityLineItem
          WHERE OpportunityId = :opp.Id
          WITH SECURITY_ENFORCED
        ];
        SObjectAccessDecision assetListdecision = Security.stripInaccessible(AccessType.UPDATABLE, assetList);
        delete assetListdecision.getRecords();
        SObjectAccessDecision psfListdecision = Security.stripInaccessible(AccessType.UPDATABLE, psfList);
        delete psfListdecision.getRecords();
        SObjectAccessDecision subsListdecision = Security.stripInaccessible(AccessType.UPDATABLE, subsList);
        delete subsListdecision.getRecords();
        SObjectAccessDecision contractListdecision = Security.stripInaccessible(AccessType.UPDATABLE, contractList);
        delete contractListdecision.getRecords();
        SObjectAccessDecision qlListdecision = Security.stripInaccessible(AccessType.UPDATABLE, qlList);
        delete qlListdecision.getRecords();
        SObjectAccessDecision oliListdecision = Security.stripInaccessible(AccessType.UPDATABLE, oliList);
        delete oliListdecision.getRecords();
      } catch (Exception ex) {
        system.debug(
          'GCRM_ProcessOrder_Utlity: deleteRecordsBymuid: Deletion Exception: ' +
          ex
        );
        Database.RollBack(objSavePoint);
      }
    }
   
    /*****************************************************
      /* Method Name        : setPrimaryQuote
      /* Method Description : Method to keep only one primary quote.
      /* Method Parameters  : oppGUID, Quote ID.
      ******************************************************/
    public static void setPrimaryQuote(String oppGUID, String quoteId) {
      try {
        List<SBQQ__Quote__c> qteList = [
          SELECT Id, SBQQ__Primary__c
          FROM SBQQ__Quote__c
          WHERE SBQQ__Opportunity2__r.Opp_Guid__c = :oppGUID
          WITH SECURITY_ENFORCED
        ];
        for (SBQQ__Quote__c qte : qteList) {
          if (qte.Id == quoteId) {
            qte.SBQQ__Primary__c = true;
          } else {
            qte.SBQQ__Primary__c = false;
          }
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, qteList);
        update decision.getRecords();
      } catch (Exception ex) {
        system.debug(
          'GCRM_ProcessOrder_Utlity: setPrimaryQuote: Quote Primary Exception: ' +
          ex
        );
      }
    }
   
    /*****************************************************
      /* Method Name        : g2lcrmPickListMapping
      /* Method Description : Method to return the mapping values of the picklist values between g2l.
      /* Method Parameters  : Object API Name.
      /* Description        : Developed part of SCDEV-4107
      ******************************************************/
    public static Map<String, Map<String, String>> g2lcrmPickListMapping(
      String objApi
    ) {
      List<g2lcrm_picklist_mapping__mdt> fieldMapping = [
        SELECT PickList_Field_API_Name__c, PickList_Mapping__c
        FROM g2lcrm_picklist_mapping__mdt
        WHERE Object_API_Name__c = :objApi
        WITH SECURITY_ENFORCED
      ];
      Map<String, Map<String, String>> valueMapping = new Map<String, Map<String, String>>();
      for (g2lcrm_picklist_mapping__mdt mapping : fieldMapping) {
        Map<String, String> picklistMap = (Map<String, String>) JSON.deserialize(
          mapping.PickList_Mapping__c,
          Map<String, String>.class
        );
        valueMapping.put(mapping.PickList_Field_API_Name__c, picklistMap);
      }
      return valueMapping;
    }
   
    /*****************************************************
      /* Method Name        : getPicklistMappingValue
      /* Method Description : Method to return the mapping value of the picklist value between g2l.
      /* Method Parameters  : Object API Name.
      /* Description        :
      ******************************************************/
    public static String getPicklistMappingValue(
      String objName,
      String fieldName,
      String key
    ) {
      g2lcrm_picklist_mapping__mdt fieldMapping = [
        SELECT PickList_Field_API_Name__c, PickList_Mapping__c
        FROM g2lcrm_picklist_mapping__mdt
        WHERE
          Object_API_Name__c = :objName
          AND PickList_Field_API_Name__c = :fieldName
          WITH SECURITY_ENFORCED
        LIMIT 1        
      ];
      Map<String, String> picklistMap = (Map<String, String>) JSON.deserialize(
        fieldMapping.PickList_Mapping__c,
        Map<String, String>.class
      );
      return picklistMap.get(key);
    }
    
    /*****************************************************
      /* Method Name        : getExistingUsersSet
      /* Method Description : Check and return Existing Active users on certain conditions
      /* Method Parameters  : Id of set of Users
      ******************************************************/
    public static Set<Id> getExistingUsersSet(Set<Id> setUserId) {
      Set<Id> existingUsers = new Set<Id>();
      existingUsers = (new Map<Id, User>(
          [
            SELECT Id
            FROM User
            WHERE
              Id IN :setUserId
              AND Username != :msIntegrationUsername
              AND IsActive = TRUE
              WITH SECURITY_ENFORCED
          ]
        ))
        .keySet();
      return existingUsers;
    }
     /*****************************************************
    /* Method Name        : getExistingUsersIds
    /* Method Description : Process list of sObjects to identify owner ids and returning active ids under certain conditions
    /* Method Parameters  : List of sObjects, String to return results of Owner/CreatedBy User
    ******************************************************/
    public static Set<Id> getExistingUsersIds(List<SObject> lstsObjectRecords, String resultOf ){
      Set<String> resultForSet = new Set<String>();
      for(SObject obj: lstsObjectRecords){
          If(resultOf == 'OwnerId'){
              if(obj.get('ownerId') != null){
                  resultForSet.add((String)obj.get('ownerId'));
              }
          }else{
              if(obj.get('createdById') != null){
                  resultForSet.add((String)obj.get('createdById'));
              }
          }
      }        
      Set<Id> existingUsers = new Set<Id>();       
      existingUsers = (new Map<Id, User>([SELECT Id FROM User WHERE Id IN:resultForSet AND Username !=:msIntegrationUsername AND IsActive=true])).keySet();
      return existingUsers;
    }  
    /*****************************************************
      /* Method Name        : getCurrentOwnerforIntegrationUser(In presale)
      /* Method Description : Checking the user and returning td sf support user by conditoins
      /* Method Parameters  : User Id
      ******************************************************/
   
    public static String getMuleSoftIntegrationdefaultOwner(String userId) {
      String defaultOwnerEmail = System.Label.Default_LV_Owner;
      String mulesoftIntegrationUser = System.Label.Mulesoft_Integration_User;
      Boolean isOwnerInactive = false;
      String defaultOwnerId;
      for (User u : [
        SELECT Id, IsActive, Username
        FROM User
        WHERE
          (Username = :defaultOwnerEmail
          OR Id = :userId)
          AND Username != :mulesoftIntegrationUser
          AND IsActive = TRUE
          WITH SECURITY_ENFORCED
      ]) {
        if (userId != '' && u.Id == userId) {
          defaultOwnerId = u.Id;
          break;
        }
        if (u.Username == defaultOwnerEmail){
          defaultOwnerId = u.Id;
        }

      }
      return defaultOwnerId;
    }
    
    /*****************************************************
      /* Method Name        : updateOppStage
      /* Method Description : Update opportunity stage to closed won
      /* Method Parameters  : oppGuid
      ******************************************************/
   
    public static void updateOppStage(String oppGuid) {
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
        WHERE Opp_Guid__c = :oppGuid
        WITH SECURITY_ENFORCED
      ];
      Opportunity createdOpp = createdOpportunities[0];
      List<OpportunityLineItem> oppliList = [
        SELECT Id, OpportunityId
        FROM OpportunityLineItem
        WHERE OpportunityId = :createdOpp.Id
        WITH SECURITY_ENFORCED
      ];
      createdOpp.StageName = 'Closed Won';
      SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{createdOpp});
      update decision.getRecords();
    }
    
    public static void updateOppStageNew(String oppGuid, Boolean earlyImplementation, Boolean isLVN) {
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
            WHERE Opp_Guid__c = :oppGuid
            WITH SECURITY_ENFORCED
        ];
        System.debug('OppGuid '+oppGuid);
        if(createdOpportunities != NULL && createdOpportunities.size()>0){
            Opportunity createdOpp = createdOpportunities[0];
            List<OpportunityLineItem> oppliList = [
                SELECT Id, OpportunityId
                FROM OpportunityLineItem
                WHERE OpportunityId = :createdOpp.Id
                WITH SECURITY_ENFORCED
            ];
            if(!earlyImplementation){
                createdOpp.StageName = 'Closed Won';
            } else {
                createdOpp.StageName = 'Contracting';
                createdOpp.isLVN__c = isLVN;
            }
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{createdOpp});
            update decision.getRecords();
        }
    }
    public static boolean isExistingAccount(String accountGUID) {
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE GUID__c = :accountGUID
        ];
        return !accounts.isEmpty();
    }
    
    public static Map<String, String> isExistingAccountV4(Set<String> accountGUIDSet) {
        Map<String, String> accountExistMap = new Map<String,String>();
        Map<Id, Account> accountsMap = new Map<Id, Account>([
            SELECT Id, GUID__c
            FROM Account
            WHERE GUID__c = :accountGUIDSet
        ]);
        for(Account acc:accountsMap.values()){
            accountExistMap.put(acc.GUID__c, acc.Id);
        }
        return accountExistMap;
    }
  }