public with sharing class MassPsfCreationButtonController {
  @AuraEnabled
  public static Integer doCount(Id recordId) {
    SBQQ__Subscription__c currentSubscription = [
      SELECT id, SBQQ__Account__c
      FROM SBQQ__Subscription__c
      WHERE id = :recordId
    ];
    List<Mbr_Group__c> mbrGrpList = [
      SELECT Id
      FROM Mbr_Group__c
      WHERE
        Client_Account__c = :currentSubscription.SBQQ__Account__c
        AND status__c IN ('Pending', 'Active')
    ];
    return mbrGrpList.size();
  }

  @AuraEnabled
  public static void callMassiveCreation(Id recordId) {
    PsfMassCreate.CreateForSubscription(recordId);
  }
}