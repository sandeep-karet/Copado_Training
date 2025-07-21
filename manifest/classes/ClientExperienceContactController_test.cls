@IsTest
private class ClientExperienceContactController_test {
  @IsTest
  static void createExperienceContact_Test() {
    Account testAcct = TestDataFactory.createParentAccount();
    Contact conObj = TestDataFactory.createContact(testAcct.Id);
    Opportunity oppObj = TestDataFactory.createOpportunity(testAcct.Id);
    insert oppObj;
    Briefing__c ecbr = TestDataFactory.createBriefing(oppObj.Id);
    insert ecbr;

    ClientExperienceContactController.createExperienceContact(
      conObj.Id,
      ecbr.Id,
      true
    );
    system.assertEquals(1, [SELECT COUNT() FROM Experience_Center_Contact__c]);
  }
}