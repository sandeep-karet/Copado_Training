@isTest
private class PrimaryCarrierLookupLWC_Controller_Test {
  @testSetup
  static void setupdata() {
    Account umrAcct = TestDataFactory.createUMR();
    //create an account record
    Account accObj = TestDataFactory.createAccountUMR();

    //Create Account Relationships
    List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();

    Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
    acctRel1.Relationship_Type__c = 'Payer and Eligibility Provider';
    acctRel1.Contract_Type__c = null;
    accRelList.add(acctRel1);

    Acct_Rel__c acctRel2 = TestDataFactory.createAccRel(accObj.Id);
    acctRel2.Relationship_Type__c = 'Eligibility Provider Only';
    acctRel2.Contract_Type__c = null;
    accRelList.add(acctRel2);

    insert accRelList;

    //create an opportunity record
    Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
    oppObj2.LeadSource = 'Sales';
    insert oppObj2;
  }

  @isTest
  static void fetchAcctRel_Test() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
    List<Acct_Rel__c> acctRelList = PrimaryCarrierLookupLWC_Controller.fetchAcctRel(
      opp.Id
    );
    system.assertEquals(2, acctRelList.size());
  }

  @isTest
  static void updateOpp_Test() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
    Acct_Rel__c acctRel = [SELECT Id FROM Acct_Rel__c LIMIT 1];
    PrimaryCarrierLookupLWC_Controller.updateOpp(opp.Id, acctRel.Id);
    system.assertEquals(
      acctRel.Id,
      [SELECT Primary_Carrier__c FROM Opportunity].Primary_Carrier__c
    );
  }

  @isTest
  static void fetchCurrnetCarrier_Test() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
    Acct_Rel__c acctRel = PrimaryCarrierLookupLWC_Controller.fetchCurrnetCarrier(
      opp.Id
    );
    system.assertEquals(null, acctRel);
  }

  @isTest
  static void validatePC_Test() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
    Opportunity oppTest = PrimaryCarrierLookupLWC_Controller.validatePC(opp.Id);
    system.assertEquals(null, oppTest);
  }
}