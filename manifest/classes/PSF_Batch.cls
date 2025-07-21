/**
 * Created by jpatel on 4/18/19.
 */

global without sharing class PSF_Batch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'select id,Client_Account__c,Actual_Copay_May_Be_Less__c from Mbr_Group__c where Source__c = \'BD\' and LastModifiedDate  = TODAY'
    );
  }
  global void execute(
    Database.BatchableContext BC,
    List<Mbr_Group__c> mbrGroups
  ) {
    Set<Id> accountIds = new Set<Id>();
    List<Plan_Specific_Fees__c> psfList = new List<Plan_Specific_Fees__c>();
    Map<Id, Integer> SubPSFMap = new Map<Id, Integer>();

    //Collect all AccountIds for the MemberGroups
    for (Mbr_Group__c mbrGroup : mbrGroups) {
      accountIds.add(mbrGroup.Client_Account__c);
    }

    //Check existing PSF records on the subscription
    for (SBQQ__Subscription__c sub : [
      SELECT id, (SELECT id FROM Plan_Specific_Fees__r), SBQQ__Account__c
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Account__c = :accountIds
    ]) {
      SubPSFMap.put(sub.id, sub.Plan_Specific_Fees__r.size());
    }

    for (Mbr_Group__c mbrGroup : [
      SELECT
        id,
        (SELECT id, subscription__c FROM Plan_Specific_Fees_By_Product__r)
      FROM mbr_group__c
      WHERE client_account__c = :accountIds
    ]) {
      for (
        Plan_Specific_Fees__c psf : mbrGroup.Plan_Specific_Fees_By_Product__r
      ) {
      }
    }

    //Get all the Expert Medical Service Subscription Map
    Map<Id, Account> accounts = new Map<Id, Account>(
      [
        SELECT
          id,
          (
            SELECT id, SBQQ__product__r.family
            FROM SBQQ__Subscriptions__r
            WHERE SBQQ__product__r.family = 'Expert Medical Services'
          )
        FROM Account
        WHERE id = :accountIds
      ]
    );

    for (Mbr_Group__c mbrGroup : mbrGroups) {
      System.debug('Member Group Id ' + mbrGroup.id);
      for (
        SBQQ__Subscription__c subscription : accounts.get(
            mbrGroup.Client_Account__c
          )
          .SBQQ__Subscriptions__r
      ) {
        System.debug('Subscription  Id ' + subscription.id);
        //if(SubPSFMap.get(subscription.id) == 0) {
        Plan_Specific_Fees__c psf = new Plan_Specific_Fees__c(
          Subscription__c = subscription.id,
          Member_Group__c = mbrGroup.id,
          Actual_Copay_May_Be_Less__c = mbrGroup.Actual_Copay_May_Be_Less__c,
          Product_Start_Date__c = Date.today()
        );
        psfList.add(psf);
        //}else{
        //    System.debug('PSF record exist for the Subscription');
        //}
      }
    }
    if (psfList != null && psfList.size() > 0) {
      Database.insert(psfList, true);
    }
  }
  global void finish(Database.BatchableContext BC) {
  }
}