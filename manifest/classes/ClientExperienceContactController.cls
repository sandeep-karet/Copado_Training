public with sharing class ClientExperienceContactController {
  @AuraEnabled
  public static void createExperienceContact(
    Id contactId,
    Id parentId,
    Boolean isAttend
  ) {
    Experience_Center_Contact__c ecc = new Experience_Center_Contact__c();
    ecc.Attendee__c = isAttend;
    ecc.Experience_Center_Briefing_Request__c = parentId;
    ecc.Contact__c = contactId;
    insert ecc;
  }
}