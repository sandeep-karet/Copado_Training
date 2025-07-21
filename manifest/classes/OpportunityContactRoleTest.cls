@isTest
public class OpportunityContactRoleTest {
  @TestSetup
  static void setup() {
    Contact con = new Contact();

    Account parentAcctTest = TestDataFactory.createParentAccount();
    con = TestDataFactory.createContact(parentAcctTest.Id);
    parentAcctTest.Primary_Billing_Contact__c = con.Id;
    parentAcctTest.Account_Type__c = 'Hospital and Health System';
    update parentAcctTest;

    Id pricebookId = Test.getStandardPricebookId();

    Opportunity opp = TestDataFactory.createOpportunity(parentAcctTest.Id);
    opp.Pricebook2Id = pricebookId;
    opp.Benefit_Consultant_Involved_in_Deal__c = 'NO';
    opp.LeadSource = 'Sales';
    insert opp;
  }
  @IsTest
  static void testOppContactRole() {
    Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
    Contact objCon = [SELECT id FROM Contact LIMIT 1];
    System.assertNotEquals(objOpp, null);
    System.assertNotEquals(objCon, null);

    OpportunityContactRole oppRole = new OpportunityContactRole();
    oppRole.OpportunityId = objOpp.Id;
    oppRole.ContactId = objCon.Id;
    oppRole.Role = 'Broker';
    insert oppRole;

    List<Acct_Rel__c> accRels = [
      SELECT Id, Benefit_Sponsor__c, Broker_Contact__c, Relationship_Type__c
      FROM Acct_Rel__c
    ];
    System.assertEquals(1, accRels.size());

    update oppRole;
    delete oppRole;
  }
}