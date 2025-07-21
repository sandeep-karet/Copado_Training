/**
 * @description This class is used in the LWC for the PG/SLA
 * @param PerformanceGuaranteeController
 * @Author InfoSys Developer
 **/
public with sharing class PerformanceGuaranteeController {
  /**
   * @description This Method is used to retrieve the Agreement Line Items of the respective Agreement
   * @param agmtId String Agreement Id
   * @return agrLineitems Agreement Line Item Records
   * @Author InfoSys Developer
   **/
  @AuraEnabled(cacheable=true)
  public static List<Apttus__AgreementLineItem__c> getLineItems(String agmtId) {
    List<Apttus__AgreementLineItem__c> agrLineitems = [
      SELECT
        Id,
        Name,
        Apttus__AgreementId__c,
        Apttus__AgreementId__r.Name,
        APTS_Consult_Fees__c,
        APTS_Product_Start_Date__c,
        APTS_Product_End_Date__c,
        APTS_ProductName__c,
        Apttus__ProductId__c,
        Apttus__ProductId__r.Name,
        APTS_Product_Family__c,
        APTS_Membership_Fee__c,
        APTS_NumberofLives__c
      FROM Apttus__AgreementLineItem__c
      WHERE Apttus__AgreementId__c = :agmtId
    ];
    return agrLineitems;
  }

  /**
   * @description This Method retrieves the PG Association Records
   * @param agmtId String Agreement Id
   * @return records - PGAssociation Records
   * @Author InfoSys Developer
   **/
  @AuraEnabled(cacheable=true)
  public static List<PG_Association__c> getPGAssociationRecords(String agmtId) {
    List<PG_Association__c> records = [
      SELECT ID, Agreement_Line_Item__c, Performance_Guarantee__c
      FROM PG_Association__c
      WHERE
        Agreement_Line_Item__c IN (
          SELECT Id
          FROM Apttus__AgreementLineItem__c
          WHERE Apttus__AgreementId__c = :agmtId
        )
    ];
    return records;
  }

  /**
   * @description This Method retrieves the PG records related to the respective Agreement
   * @param agrId String Agreement Id
   * @return pgList - List of PG Records
   * @Author InfoSys Developer
   **/
  @AuraEnabled(cacheable=true)
  public static List<Performance_Guarantees__c> getPGRecords(String agrId) {
    List<Performance_Guarantees__c> pgList = [
      SELECT
        Id,
        Name,
        PG_Status__c,
        Product_Name__c,
        Product_Family__c,
        Agreement__c,
        Agreement__r.Name,
        Agreement_Line_Item__c,
        Agreement_Line_Item__r.Name,
        Agreement_Line_Item__r.Apttus__ProductId__c,
        Agreement_Line_Item__r.Apttus__ProductId__r.Name,
        PG_Start_Date__c,
        PG_End_Date__c,
        Guarantee_Type__c,
        Guarantee_Subtype__c
      FROM Performance_Guarantees__c
      WHERE Agreement__c = :agrId
    ];
    return pgList;
  }

  /**
   * @description Wrapper to hold the PG Id and Line Item Id
   * @Author InfoSys Developer
   **/
  public class PGWrapper {
    /**
     * @description id String PG object Id
     */
    @AuraEnabled
    public String id { get; set; }
    /**
     * @description lineItemid String Line Item Id
     */
    @AuraEnabled
    public String lineItemid { get; set; }
  }

  /**
   * @description Update the PG Association record fields - Line Item Id and PG Id
   * @param pgrList List<PGWrapper> Passing the Wrapper class
   * @Author InfoSys Developer
   **/
  @SuppressWarnings('PMD.AvoidDebugStatements')
  @AuraEnabled
  public static void updateRecords(List<PGWrapper> pgrList) {
    List<PG_Association__c> pgAList = new List<PG_Association__c>();
    for (PGWrapper pg : pgrList) {
      PG_Association__c record = new PG_Association__c();
      record.Agreement_Line_Item__c = pg.lineItemid;
      record.Performance_Guarantee__c = pg.id;
      pgAList.add(record);
    }
    if (pgAList.size() > 0) {
      try {
        insert pgAList;
      } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, e.getMessage());
      }
    }
  }

  /**
   * @description Insert or delete the PG Association Object records
   * @param pgrList List<PGWrapper> PG Wrapper
   * @param itemsList List<String> List of PG Association records
   * @param agmtId String Agreement Id
   * @return getPGAssociationRecords
   * Author InfoSys Developer
   **/
  @AuraEnabled
  @SuppressWarnings('PMD.AvoidDebugStatements')
  public static List<PG_Association__c> insertAndDeleteRecords(
    List<PGWrapper> pgrList,
    List<String> itemsList,
    String agmtId
  ) {
    List<PG_Association__c> deleteList = new List<PG_Association__c>();
    if (itemsList.size() > 0) {
      for (String id : itemsList) {
        PG_Association__c record = new PG_Association__c();
        record.Id = id;
        deleteList.add(record);
      }

      try {
        delete deleteList;
      } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, e.getMessage());
      }
    }

    Set<Id> agreementLineitemsids = new Set<Id>();
    Set<Id> performanceGuaranteeids = new Set<Id>();
    for (PGWrapper pg : pgrList) {
      agreementLineitemsids.add(pg.lineItemid);
      performanceGuaranteeids.add(pg.Id);
    }

    List<PG_Association__c> records = [
      SELECT ID, Agreement_Line_Item__c, Performance_Guarantee__c
      FROM PG_Association__c
      WHERE
        Agreement_Line_Item__c IN :AgreementLineItemsIds
        AND Performance_Guarantee__c IN :PerformanceGuaranteeIds
    ];

    Map<String, PG_Association__c> pgMap = new Map<String, PG_Association__c>();
    for (PG_Association__c record : records) {
      String key =
        record.Agreement_Line_Item__c +
        '' +
        record.Performance_Guarantee__c;
      pgMap.put(key, record);
    }
    List<PG_Association__c> pgAList = new List<PG_Association__c>();
    for (PGWrapper pg : pgrList) {
      String key = pg.lineItemid + pg.Id;
      if (!pgMap.containsKey(key)) {
        PG_Association__c newRecord = new PG_Association__c();
        newRecord.Agreement_Line_Item__c = pg.lineItemid;
        newRecord.Performance_Guarantee__c = pg.Id;
        pgAList.add(newRecord);
      }
    }
    if (pgAList.size() > 0) {
      try {
        insert pgAList;
      } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, e.getMessage());
      }
    }

    return getPGAssociationRecords(agmtId);
  }
}