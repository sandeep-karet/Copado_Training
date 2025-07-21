public without sharing class MemberGroupCloneController {
  @AuraEnabled
  public static String createMbrGroup(Mbr_Group__c newRecord) {
    try {
      insert newRecord;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return newRecord.Id;
  }
}