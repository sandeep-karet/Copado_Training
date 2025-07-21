public without sharing class GCRM_Ingest_OrderV3 {
  static String moduleName = 'GCRM_Ingest_OrderV3';
  static String defaultSeverity = 'INFO';
  public static void ingestG2LByMUID(String targetMUID) {
    try {
      List<G2LCRM_Item__c> g2LCRMItems = [
        SELECT Id, Body__c, MUID__c, Processor__c, Action__c
        FROM G2LCRM_Item__c
        WHERE MUID__c = :targetMUID
        ORDER BY CreatedDate ASC
      ];
      if (g2LCRMItems.isEmpty()) {
        return;
      }
      // TODO: wipe and repeat for testing but refactor and make idempotent in future
      List<DOI__c> muidTarget = [
        SELECT Id, MUID__c
        FROM DOI__c
        WHERE MUID__c = :targetMUID
      ];
      delete muidTarget;
      List<G2LItemLog__c> muidLogs = [
        SELECT Id, MUID__c
        FROM G2LItemLog__c
        WHERE MUID__c = :targetMUID
      ];
      delete muidLogs;
      List<DOI__c> newRecords = new List<DOI__c>();
      List<G2LCRM_Item__c> accountRecords = new List<G2LCRM_Item__c>();
      List<G2LCRM_Item__c> orderRecords = new List<G2LCRM_Item__c>();
      List<G2LCRM_Item__c> orderItemRecords = new List<G2LCRM_Item__c>();
      for (G2LCRM_Item__c g2lci : g2LCRMItems) {
        switch on g2lci.Processor__c.toLowerCase() {
          when 'accountv3' {
            accountRecords.add(g2lci);
          }
          when 'orderv3' {
            orderRecords.add(g2lci);
          }
          when 'orderitemv3' {
            orderItemRecords.add(g2lci);
          }
        }
      }
      system.debug(
        'INGEST SIZE : ' +
          accountRecords.size() +
          ':::' +
          orderRecords.size() +
          ':::' +
          orderItemRecords.size()
      );
      if (
        accountRecords.size() <= 0 &&
        orderRecords.size() <= 0 &&
        orderItemRecords.size() <= 0
      ) {
        String errMsg = 'NO_RECORD_FOUND';
        String errDetail =
          'There is no records found under the MUID:' +
          targetMUID +
          ' for the processors accountv3, orderv3 and orderitemv3. \n Method: ingestG2LByMUID \n Module: GCRM_Ingest_OrderV3';
        ExceptionCustomLog.captureCustomException(
          targetMUID,
          'GCRM_Ingest_OrderV3',
          'ingestG2LByMUID',
          '',
          '',
          '',
          errMsg,
          errDetail
        );
        return;
      }

      if (accountRecords.size() > 0) {
        newRecords.addAll(deconstructAccounts(accountRecords));
      }
      // Pull OrderId (801 Id) from Order and feed to OrderItems
      if (orderRecords.size() > 0) {
        List<Doi__c> doiOrders = deconstructOrder(orderRecords);
        if (doiOrders.size() >= 1) {
          System.debug(
            'Submission has more than one order.  Ignoring all but first.'
          );

          newRecords.addAll(doiOrders);
          Id orderId = doiOrders[0].SourceId__c;
          if (orderItemRecords.size() >= 1) {
            List<Doi__c> doiOrderItems = deconstructOrderItems(
              orderItemRecords,
              orderId
            );
            if (doiOrderItems.size() >= 1) {
              newRecords.addAll(doiOrderItems);
            } else {
              String errMsg = 'DOI_ORDERITEM_NOT_RETURNED';
              String errDetail = 'There is no orderitem record returned from the method deconstructOrderItems \n Method: ingestG2LByMUID \n Module: GCRM_Ingest_OrderV3';
              ExceptionCustomLog.captureCustomException(
                targetMUID,
                'GCRM_Ingest_OrderV3',
                'ingestG2LByMUID',
                'orderItemV3',
                '',
                '',
                errMsg,
                errDetail
              );
            }
          }
        } else {
          String errMsg = 'DOI_ORDER_RECORD_NOT_FOUND';
          String errDetail = 'There is no order records returned from the method deconstructOrder \n Method: ingestG2LByMUID \n Module: GCRM_Ingest_OrderV3';
          ExceptionCustomLog.captureCustomException(
            targetMUID,
            'GCRM_Ingest_OrderV3',
            'ingestG2LByMUID',
            'orderV3',
            '',
            '',
            errMsg,
            errDetail
          );
        }
      }

      Set<String> dupeChecksums = new Set<String>();
      List<DOI__c> uniqueDOI = new List<DOI__c>();
      for (DOI__c tmpDoi : newRecords) {
        if (dupeChecksums.contains(tmpDoi.MD5Hash__c)) {
          System.debug('[DUPE] ' + tmpDoi.Payload__c);
        } else {
          dupeChecksums.add(tmpDoi.MD5Hash__c);
          uniqueDOI.add(tmpDoi);
        }
      }
      Database.SaveResult[] doiSr = Database.insert(uniqueDOI);
      //GCRM_Process_OrderV3.log(null,null,null,null,null);
      if (doiSr != null && doiSr.size() > 0) {
        for (Integer i = 0; i < doiSr.size(); i++) {
          if (!doiSr.get(i).isSuccess()) {
            Database.Error error = doiSr.get(i).getErrors().get(0);
            List<String> errorFields = error.getFields();
            String errorDetail = error.getMessage();
            if (errorFields != null && errorFields.size() > 0) {
              errorFields.remove(null);
              errorDetail =
                errorDetail +
                '\n' +
                string.join(errorFields, ',\n');
            }
            ExceptionCustomLog.captureCustomException(
              targetMUID,
              'GCRM_Ingest_OrderV3',
              'ingestG2LByMUID',
              uniqueDOI.get(i).Processor__c,
              uniqueDOI.get(i).ObjectName__c,
              uniqueDOI.get(i).GUID__c,
              String.valueOf(error.getStatusCode()),
              errorDetail
            );
          }
        }
      }
    } catch (Exception ex) {
      ExceptionCustomLog.captureException(
        targetMUID,
        'GCRM_Ingest_OrderV3',
        'ingestG2LByMUID',
        '',
        '',
        '',
        ex
      );
    }
  }
  public static List<DOI__c> deconstructAccounts(
    List<G2LCRM_Item__c> accountRecords
  ) {
    Set<String> currentChecksums = new Set<String>();
    List<DOI__c> newRows = new List<DOI__c>();
    for (G2LCRM_Item__c g2lci : accountRecords) {
      INT175_AccountV3 tmpAccount = INT175_AccountV3.parse(g2lci.Body__c);
      if (tmpAccount.body == null) {
        String errMsg = 'ACCOUNT_PARSING_ERROR';
        String errDetail =
          '[PARSING_ERROR] Account for MUID: ' +
          g2lci.MUID__c +
          ' \n Method: deconstructAccounts \n Module: GCRM_Ingest_OrderV3';
        ExceptionCustomLog.captureCustomException(
          g2lci.MUID__c,
          'GCRM_Ingest_OrderV3',
          'deconstructAccounts',
          g2lci.Processor__c,
          'account',
          '',
          errMsg,
          errDetail
        );
        //GCRM_Process_OrderV3.log(defaultSeverity,moduleName, 'deconstructAccounts',null,'[PARSING_ERROR] Account for MUID: ' + g2lci.MUID__c);
        continue;
      }

      INT175_AccountV3.Account newAccount = tmpAccount.body.account;
      String resultingJSON = JSON.serialize(newAccount);
      String checksum = calculateMD5(resultingJSON);
      if (currentChecksums.contains(checksum)) {
        System.debug(
          LoggingLevel.ERROR,
          'Account: ' + newAccount.accountId + ' already exists.'
        );
      } else {
        currentChecksums.add(checksum);
      }
      DOI__c aRecord = new DOI__c();
      aRecord.GUID__c = newAccount.accountGUID;
      aRecord.SourceId__c = newAccount.accountId;
      aRecord.ParentId__c = newAccount.accountId;
      aRecord.MD5Hash__c = calculateMD5(resultingJSON);
      aRecord.ObjectName__c = 'account';
      aRecord.Processor__c = g2lci.Processor__c;
      aRecord.Payload__c = resultingJSON;
      aRecord.Action__c = g2lci.Action__c;
      aRecord.MUID__c = g2lci.MUID__c;
      if (aRecord.GUID__c == null) {
        system.debug(
          '[Account] NO_GUID : ' + g2lci.Id + '/' + newAccount.accountId
        );
      }
      newRows.add(aRecord);
    }
    return newRows;
  }
  public static List<DOI__c> deconstructOrderItems(
    List<G2LCRM_Item__c> orderItemRecords,
    Id orderId
  ) {
    Set<String> currentChecksums = new Set<String>();
    List<DOI__c> newRows = new List<DOI__c>();
    for (G2LCRM_Item__c g2lci : orderItemRecords) {
      G2LCRM_Item__c rawOrder = g2lci;
      INT175_OrderItemV3 parsedOrderItem = INT175_OrderItemV3.parse(
        rawOrder.Body__c
      );
      //GCRM_Process_OrderV3.log('INFO', moduleName, 'deconstructOrderItems',rawOrder.Body__c,JSON.serialize(parsedOrderItem));
      //system.debug(rawOrder.Body__c);
      System.debug(JSON.serialize(parsedOrderItem));
      if (parsedOrderItem.body == null) {
        String errMsg = 'ORDER_ITEM_PARSING_ERROR';
        String errDetail =
          '[PARSING_ERROR] OrderItem for MUID: ' +
          g2lci.MUID__c +
          ' \n Method: deconstructOrderItems \n Module: GCRM_Ingest_OrderV3';
        ExceptionCustomLog.captureCustomException(
          g2lci.MUID__c,
          'GCRM_Ingest_OrderV3',
          'deconstructOrderItems',
          g2lci.Processor__c,
          'orderItem',
          '',
          errMsg,
          errDetail
        );
        //GCRM_Process_OrderV3.log('ERROR', moduleName, 'deconstructOrderItems',null,'Error parsing orderItemV3 payload for MUID: ' + g2lci.MUID__c);
        continue;
      }
      // Process Order Items
      for (
        INT175_OrderItemV3.OrderItems newOrderItem : parsedOrderItem.body.order.orderItems
      ) {
        if (
          !(newOrderItem.subscriptions == null) &&
          (newOrderItem.productCode != 'VISITFEE')
        ) {
          for (
            INT175_OrderItemV3.Subscriptions aSubscription : newOrderItem.subscriptions
          ) {
            String resultingJSON = JSON.serialize(aSubscription);
            String checksum = calculateMD5(resultingJSON);
            if (currentChecksums.contains(checksum)) {
              System.debug(
                LoggingLevel.ERROR,
                'Subscription: ' +
                  aSubscription.subscriptionId +
                  ' already exists.'
              );
            } else {
              currentChecksums.add(checksum);
            }
            DOI__c aRecord = new DOI__c();
            aRecord.GUID__c = newOrderItem.orderItemGUID;
            aRecord.SourceId__c = aSubscription.subscriptionId;
            aRecord.ParentId__c = aSubscription.orderProductId;
            aRecord.MD5Hash__c = checksum;
            aRecord.ObjectName__c = 'subscription';
            aRecord.Processor__c = g2lci.Processor__c;
            aRecord.Payload__c = resultingJSON;
            aRecord.Action__c = g2lci.Action__c;
            aRecord.MUID__c = g2lci.MUID__c;
            if (aRecord.ParentId__c == null) {
              system.debug(
                '[subscription] No ParentID__c : ' +
                  g2lci.Id +
                  '/' +
                  aSubscription.orderProductId
              );
            }
            newRows.add(aRecord);
          }
          //newOrderItem.subscriptions.clear();
        }
        if (!(newOrderItem.assets == null)) {
          for (INT175_OrderItemV3.Assets assets : newOrderItem.assets) {
            String resultingJSON = JSON.serialize(assets);
            String checksum = calculateMD5(resultingJSON);
            if (currentChecksums.contains(checksum)) {
              System.debug(
                LoggingLevel.ERROR,
                'Asset: ' + assets.assetId + ' already exists.'
              );
            } else {
              currentChecksums.add(checksum);
            }
            DOI__c aRecord = new DOI__c();
            aRecord.GUID__c = newOrderItem.orderItemGUID;
            aRecord.SourceId__c = assets.assetId;
            aRecord.ParentId__c = assets.assetId;
            aRecord.MD5Hash__c = checksum;
            aRecord.ObjectName__c = 'asset';
            aRecord.Processor__c = g2lci.Processor__c;
            aRecord.Payload__c = resultingJSON;
            aRecord.Action__c = g2lci.Action__c;
            aRecord.MUID__c = g2lci.MUID__c;
            newRows.add(aRecord);
          }
        }

        //System.debug('newOrderItem.assets: ' + JSON.serialize(newOrderItem));
        //if (!(newOrderItem.assets == null)) {
        if (
          !(newOrderItem.subscriptions == null) &&
          (newOrderItem.productCode == 'VISITFEE')
        ) {
          for (
            INT175_OrderItemV3.Subscriptions anAsset : newOrderItem.subscriptions
          ) {
            system.debug('anAsset::: ' + anAsset);
            anAsset.orderItemId = newOrderItem.orderItemId;
            String resultingJSON = JSON.serialize(anAsset);
            system.debug('resultingJSON::: ' + resultingJSON);
            String checksum = calculateMD5(resultingJSON);
            if (currentChecksums.contains(checksum)) {
              System.debug(
                LoggingLevel.ERROR,
                'Asset: ' + anAsset.assetId + ' already exists.'
              );
            } else {
              system.debug('IN CheckSum::' + checksum);
              currentChecksums.add(checksum);
            }
            system.debug('RequiredBySub::: ' + anAsset.requiredBySubscription);
            DOI__c aRecord = new DOI__c();
            aRecord.GUID__c = newOrderItem.orderItemGUID;
            aRecord.SourceId__c = anAsset.assetId;
            //aRecord.SourceId__c = anAsset.subscriptionId;
            aRecord.ParentId__c = anAsset.requiredBySubscription;
            aRecord.MD5Hash__c = calculateMD5(resultingJSON);
            aRecord.ObjectName__c = 'asset';
            aRecord.Processor__c = g2lci.Processor__c;
            aRecord.Payload__c = resultingJSON;
            aRecord.Action__c = g2lci.Action__c;
            aRecord.MUID__c = g2lci.MUID__c;
            if (aRecord.ParentId__c == null) {
              system.debug(
                '[Asset] No ParentID__c : ' +
                  g2lci.Id +
                  '/' +
                  anAsset.assetId +
                  '/' +
                  anAsset.requiredBySubscription
              );
            } else {
              system.debug('aREcord::: ' + aRecord);
              newRows.add(aRecord);
            }
          }
          newOrderItem.subscriptions.clear();
        }

        // clear subs and assets
        String resultingJSON = JSON.serialize(newOrderItem);
        DOI__c aRecord = new DOI__c();
        aRecord.GUID__c = newOrderItem.orderItemGUID;
        aRecord.SourceId__c = newOrderItem.orderItemId;
        aRecord.ParentId__c = orderId;
        aRecord.MD5Hash__c = calculateMD5(resultingJSON);
        aRecord.ObjectName__c = 'orderitem';
        aRecord.Processor__c = g2lci.Processor__c;
        aRecord.Payload__c = resultingJSON;
        aRecord.Action__c = g2lci.Action__c;
        aRecord.MUID__c = g2lci.MUID__c;
        if (aRecord.ParentId__c == null) {
          system.debug(
            '[OrderItem] No ParentID__c : ' +
              g2lci.Id +
              '/' +
              newOrderItem.orderItemId
          );
        }
        newRows.add(aRecord);
      }
    }
    return newRows;
  }
  public static List<DOI__c> deconstructOrder(
    List<G2LCRM_Item__c> orderRecords
  ) {
    Set<String> currentChecksums = new Set<String>();
    List<DOI__c> newRows = new List<DOI__c>();
    for (G2LCRM_Item__c g2lci : orderRecords) {
      G2LCRM_Item__c rawOrder = g2lci;
      INT175_OrderV3 parsedOrder = INT175_OrderV3.parse(rawOrder.Body__c);
      if (parsedOrder.body == null) {
        //GCRM_Process_OrderV3.log(defaultSeverity, moduleName, 'deconstructOrder',null,'Error parsing payload for MUID: ' + g2lci.MUID__c);
        String errMsg =
          'Failed: Error parsing payload for MUID: ' + g2lci.MUID__c;
        String errDetail = 'While parsing the payload using INT175_OrderV3.parse method we received a null body content. \n Method: deconstructOrder \n Module: GCRM_Ingest_OrderV3';
        ExceptionCustomLog.captureCustomException(
          g2lci.MUID__c,
          'GCRM_Ingest_OrderV3',
          'deconstructOrder',
          g2lci.Processor__c,
          'order',
          '',
          errMsg,
          errDetail
        );
        continue;
      }
      INT175_OrderV3.Order newOrder = parsedOrder.body.order;
      INT175_OrderV3.Opportunities orderOpp = newOrder.opportunities[0];
      String OrderGUID = newOrder.orderGUID;
      // Process Order Items
      String resultingJSON = JSON.serialize(newOrder);
      String checksum = calculateMD5(resultingJSON);
      if (currentChecksums.contains(checksum)) {
        System.debug(
          LoggingLevel.ERROR,
          'aSubscription: ' + newOrder.orderId + ' already exists.'
        );
      } else {
        currentChecksums.add(checksum);
      }
      DOI__c aRecord = new DOI__c();
      aRecord.GUID__c = OrderGUID;
      aRecord.SourceId__c = newOrder.orderId;
      aRecord.ParentId__c = newOrder.accountId;
      aRecord.MD5Hash__c = calculateMD5(resultingJSON);
      aRecord.ObjectName__c = 'order';
      aRecord.Processor__c = 'orderV3';
      aRecord.Payload__c = resultingJSON;
      aRecord.Action__c = rawOrder.Action__c;
      aRecord.MUID__c = rawOrder.MUID__c;
      newRows.add(aRecord);
    }
    return newRows;
  }
  public static String calculateMD5(String input) {
    Blob myBlob = Blob.valueOf(input);
    Blob md5hash = Crypto.generateDigest('MD5', myBlob);
    return EncodingUtil.convertToHex(md5hash);
  }
}