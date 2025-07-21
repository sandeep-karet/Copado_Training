@isTest
public class Eval_Acct_For_Flow_Test {
  // Set up base account for all tests
  @testSetup
  static void setup() {
    Account svc_acct = new Account(
      name = 'Servicing Account',
      account_type__c = 'Employer',
      Allow_Flow__c = true
    );
    insert svc_acct;
  }

  // Confirm a new account will NOT let you set ALLOW_FLOW__C to true
  @isTest
  static void confirmNoFlow() {
    Account target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    System.assertEquals(false, target_acct.allow_flow__c);
  }

  // Confirm that creating an Acct Rel of Contractee/Direct with SVC ACCT of 'Employer'
  // will make Allow_Flow__c == true
  @isTest
  static void allowWhenContracteeDirectEmployer() {
    Account target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    Acct_Rel__c cde = new Acct_Rel__c(
      svc_acct__c = target_acct.id,
      benefit_sponsor__c = target_acct.Id,
      relationship_type__c = 'Contractee',
      contract_type__c = 'Direct',
      start_date__c = Date.today()
    );
    insert cde;
    target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    System.assertEquals(true, target_acct.allow_flow__c);
  }

  // Confirm flag is unchecked when acct rel contract type is changed
  @isTest
  static void uncheckWhenNotContracteeDirectEmployer() {
    Account target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    Acct_Rel__c cde = new Acct_Rel__c(
      svc_acct__c = target_acct.id,
      benefit_sponsor__c = target_acct.Id,
      relationship_type__c = 'Contractee',
      contract_type__c = 'Direct',
      start_date__c = Date.today()
    );
    insert cde;
    cde.contract_type__c = 'Reseller';
    update cde;
    target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    System.assertEquals(false, target_acct.allow_flow__c);
  }

  // Confirm flag is unchecked when account_type__c is changed from EMPLOYER
  @isTest
  static void uncheckWhenNotEmployer() {
    Account target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    Acct_Rel__c cde = new Acct_Rel__c(
      svc_acct__c = target_acct.id,
      benefit_sponsor__c = target_acct.Id,
      relationship_type__c = 'Contractee',
      contract_type__c = 'Direct',
      start_date__c = Date.today()
    );
    insert cde;
    target_acct.Account_Type__c = 'Broker';
    update target_acct;

    target_acct = [
      SELECT id, name, account_type__c, allow_flow__c
      FROM account
      WHERE name = 'Servicing Account'
      LIMIT 1
    ];
    System.assertEquals(false, target_acct.allow_flow__c);
  }
}