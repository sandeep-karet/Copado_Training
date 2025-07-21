/**
 *Createdbyjpatelon8/5/19.
 */

public with sharing class OpportunityReopencontroller {
  public Opportunity opp { get; set; }
  public Boolean isReopen { get; set; }
  public List<Contract> contractList { get; set; }
  public List<SBQQ__Quote__c> pQuoteList { get; set; }
  public List<SBQQ__Subscription__c> subscriptionList { get; set; }
  public List<Asset> assetList { get; set; }
  public List<Plan_Specific_Fees__c> psfList { get; set; }
  public String selectedRT { get; set; }
  public Boolean IsError { get; set; }

  // Class properties
  private ApexPages.StandardController sc { get; set; }
  public Id oppid;
  public Id AccountId;
  public List<SelectOption> recordTypeList { get; set; }

  // Controller primarily for MemberGroup page, but manages rules for Group roles as well
  public OpportunityReopencontroller(ApexPages.StandardController stdCntrl) {
    IsError = false;
    sc = stdCntrl;
    oppid = stdCntrl.getId();
    contractList = new List<Contract>();
    pQuoteList = new List<SBQQ__Quote__c>();
    subscriptionList = new List<SBQQ__Subscription__c>();
    psfList = new List<Plan_Specific_Fees__c>();
    assetList = new List<Asset>();
    recordTypeList = new List<SelectOption>();
    getRecordTypeList();
    String userProfileName = [
      SELECT Name
      FROM profile
      WHERE id = :userinfo.getProfileId()
    ]
    .Name;
  
    if (userProfileName != 'System Administrator') { 
      IsError = true;
      ApexPages.addmessage(
        new ApexPages.message(
          ApexPages.severity.ERROR,
          'Only System Administrator can re-open an opportunity'
        )
      );
      return;
    }
    opp = [
      SELECT
        id,
        Name,
        accountId,
        stagename,
        Probability,
        SBQQ__Contracted__c,
        CPQ_Contracted_Date__c,
        recordtypeId,
        recordtype.name
      FROM Opportunity
      WHERE Id = :oppid
    ];

    if (opp.stageName != 'Closed Won' && opp.stageName != 'Contracting') {
      IsError = true;
      ApexPages.addmessage(
        new ApexPages.message(
          ApexPages.severity.ERROR,
          'Opportunity stage is not Closed Won or Contracting.'
        )
      );
      return;
    }
    AccountId = opp.accountId;
    pQuoteList = new List<SBQQ__Quote__c>(
      [
        SELECT id, recordtypeId
        FROM SBQQ__quote__c
        WHERE SBQQ__Opportunity2__c = :oppid AND SBQQ__Primary__c = TRUE
      ]
    );

    contractList = new List<Contract>(
      [
        SELECT
          id,
          ContractNumber,
          Name,
          SBQQ__Opportunity__c,
          StartDate,
          EndDate,
          Status
        FROM Contract
        WHERE SBQQ__Opportunity__c = :oppid
      ]
    );
    Map<Id, SBQQ__Subscription__c> subscriptionMap = new Map<Id, SBQQ__Subscription__c>();
    subscriptionMap = new Map<Id, SBQQ__Subscription__c>(
      [
        SELECT
          id,
          Name,
          SBQQ__QuoteLine__c,
          Fee_Type__c,
          SBQQ__ProductName__c,
          Membership_Fee__c,
          Consult_Type__c,
          Current_Membership_Fee__c,
          SBQQ__Quantity__c,
          SBQQ__StartDate__c,
          SBQQ__EndDate__c
        FROM SBQQ__Subscription__c
        WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :pQuoteList
      ]
    );
    subscriptionList = subscriptionMap.values();
    assetList = new List<Asset>(
      [
        SELECT
          id,
          Name,
          Product2.Name,
          Status,
          Implementation_Status__c,
          Number_of_Lives__c,
          Teladoc_Net_Fee__c,
          SBQQ__RequiredBySubscription__c,
          Fee_Type__c,
          Consult_Fees__c
        FROM Asset
        WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN :pQuoteList
      ]
    );
    psfList = new List<Plan_Specific_Fees__c>(
      [
        SELECT
          id,
          Name,
          Product__c,
          CreatedDate,
          Member_Group__c,
          Member_Group_Name__c,
          Product_End_Date__c,
          Product_Start_Date__c,
          Subscription__c
        FROM plan_specific_fees__c
        WHERE Subscription__c IN :subscriptionMap.keySet()
      ]
    );
  }

  public PageReference cancel() {
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    if (String.isBlank(retUrl)) {
      retUrl = '/' + oppid;
    }
    PageReference newPage = new PageReference(retUrl);
    newPage.setRedirect(true);
    return newPage;
  }

  public void getRecordTypeList() {
    List<RecordType> rtList = [
      SELECT Id, Name
      FROM RecordType
      WHERE SObjectType = 'Opportunity'
    ];
    recordTypeList.add(new SelectOption('', '--None--'));
    for (RecordType rt : rtList) {
      recordTypeList.add(new SelectOption(rt.Id, rt.Name));
    }
  }
  public PageReference saveOpp() {
    opp.SBQQ__Contracted__c = false;
    opp.CPQ_Contracted_Date__c = null;
    opp.recordtypeId = selectedRT;
    system.debug('=opp' + selectedRT);
    system.debug('=opp stage name ' + opp.stagename);

    // List<SBQQ__Quote__c> pQuoteList = new List<SBQQ__Quote__c>([select id,recordtypeId from SBQQ__quote__c where SBQQ__Opportunity2__c =:oppid and SBQQ__Primary__c = true]);
    system.debug('==pQuoteList ==' + pQuoteList);
    system.debug('==AccountId ' + AccountId);
    List<SBQQ__Quote__c> quote2Update = new List<SBQQ__Quote__c>();
    for (SBQQ__Quote__c quote : pQuoteList) {
      quote.recordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName()
        .get('Teladoc')
        .getRecordTypeId();
      System.debug('RecordTypeId ' + quote.recordtypeId);
      quote2Update.add(quote);
    }
    Map<Id, opportunity> oppMap = new Map<Id, opportunity>();
    for (opportunity opp : [
      SELECT id, stageName, AccountId
      FROM opportunity
      WHERE AccountId = :AccountId AND stageName = :'Closed Won'
    ]) {
      oppMap.put(opp.AccountId, opp);
    }
    List<Account> accounts2Update = new List<Account>();
    for (Account account : [
      SELECT id, type
      FROM Account
      WHERE id = :AccountId
    ]) {
      if (
        !oppMap.containsKey(account.Id) &&
        account.type != null &&
        account.type == 'Customer'
      ) {
        account.type = 'Prospect';
        accounts2Update.add(account);
      }
    }

    Database.delete(psfList);
    Database.delete(AssetList);
    Database.delete(SubscriptionList);
    Database.delete(contractList);
    Database.update(quote2Update);
    Database.update(opp);
    Database.update(accounts2Update);
    PageReference newPage = new PageReference('/' + opp.id);
    newPage.setRedirect(true);
    return newPage;
    //return null;
  }
}