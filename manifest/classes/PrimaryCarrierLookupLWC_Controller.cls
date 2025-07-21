public with sharing class PrimaryCarrierLookupLWC_Controller {
  @AuraEnabled
  public static List<Acct_Rel__c> fetchAcctRel(String recordId) {
    String acctId = [SELECT AccountId FROM Opportunity WHERE Id = :RecordId]
    .AccountId;
    List<Acct_Rel__c> acctRelList = [
      SELECT
        Id,
        Name,
        Svc_Acct__r.Name,
        Relationship_Type__c,
        Contract_Type__c,
        Line_of_Business__c
      FROM Acct_Rel__c
      WHERE
        (End_Date__c > today
        OR End_Date__c = NULL)
        AND Benefit_Sponsor__c = :acctId
    ];
    return acctRelList;
  }

  @AuraEnabled
  public static void updateOpp(String recordId, String acctRelId) {
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :recordId];
    opp.Primary_Carrier__c = acctRelId;
    update opp;
  }

  @AuraEnabled
  public static Acct_Rel__c fetchCurrnetCarrier(String recordId) {
    Opportunity opp = [
      SELECT Id, Primary_Carrier__c
      FROM Opportunity
      WHERE Id = :recordId
    ];
    try {
      Acct_Rel__c acctRel = [
        SELECT Id, Name, Svc_Acct__r.Name, Svc_Acct__c
        FROM Acct_Rel__c
        WHERE Id = :opp.Primary_Carrier__c
      ];
      return acctRel;
    } catch (exception e) {
      return null;
    }
  }

  @AuraEnabled
  public static Opportunity validatePC(String recordId) {
    try {
      Opportunity opp = [
        SELECT Id, Primary_Carrier__c, Sub_Channel__c
        FROM Opportunity
        WHERE
          Id = :recordId
          AND Sub_Channel__c IN (
            'Aetna',
            'Government',
            'HP Core',
            'HP Enterprise',
            'HP Key',
            'United'
          )
      ];
      return opp;
    } catch (exception e) {
      return null;
    }
  }
}