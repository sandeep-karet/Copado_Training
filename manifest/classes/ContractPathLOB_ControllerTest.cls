/**
 * @date Aug 08, 2022
 * @description: Test class for ContractPathLOB_Controller class
 */
@isTest
public class ContractPathLOB_ControllerTest {
  //Defined test dataset
  @testSetup
  static void setupdata() {
    Account umrAcct = TestDataFactory.createUMR();

    //create an account record
    Account accObj = TestDataFactory.createAccountUMR();

    //create an opportunity record
    Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
    insert oppObj2;
  }

  /**
   * @description Test method for updateOpp
   * Test Positive scenario for updating the opportunity
   */
  @isTest
  static void updateOpp_positive() {
    Opportunity Opp = [
      SELECT Id, AccountId, Line_of_Business_CP__c
      FROM Opportunity
      LIMIT 1
    ];
    Account account = [SELECT Id, Name FROM Account LIMIT 1];

    Test.startTest();
    ContractPathLOB_Controller.updateOpp(
      Opp.Id,
      'YES',
      'NO',
      'Reseller',
      'Reseller',
      account.Id
    );
    Test.stopTest();

    Opportunity OppAfterUpdate = [
      SELECT Id, AccountId, Line_of_Business_CP__c
      FROM Opportunity
      WHERE id = :Opp.Id
    ];

    //Validate if the Line of Business got updated on Opportunity
    System.assertEquals(OppAfterUpdate.Line_of_Business_CP__c, 'Reseller');
  }

  /**
   * @description Test method for accountValidation
   * Test Method for validating the Account for Contract Path selection which triggers when an Account the opportunity is on is selected
   */
  @isTest
  static void accountValidation_positive1() {
    String errorMessage = '';
    Opportunity Opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

    Test.startTest();
    errorMessage = ContractPathLOB_Controller.accountValidation(
      Opp.Id,
      Opp.AccountId
    );
    Test.stopTest();

    //Validate if the Opportunty's Account is selected for Contract Path's Value
    System.assertEquals(
      errorMessage,
      'Account the opportunity is on can not be selected as Contract Path for a non direct contract'
    );
  }

  /**
   * @description Test method for accountValidation
   * Test Method for validating the Account for Contract Path selection which triggers when Teladoc Account is selected
   */
  @isTest
  static void accountValidation_positive2() {
    String errorMessage = '';
    String teladocId = System.Label.TD_Teladoc_Account;

    Opportunity Opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

    Test.startTest();
    errorMessage = ContractPathLOB_Controller.accountValidation(
      Opp.Id,
      teladocId
    );
    Test.stopTest();

    //Validate when Teladoc Account is selected as a Contract Path when it is not a Direct TDH Contract
    System.assertEquals(
      errorMessage,
      'Teladoc Account can not be selected as Contract Path for a non direct contract'
    );
  }

  /**
   * @description Test method for validateStage
   * Test method to fetch the Opportunity Stage
   */
  @isTest
  static void validateStagAe_positive() {
    String opportunityStage;
    Opportunity Opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

    Test.startTest();
    opportunityStage = ContractPathLOB_Controller.validateStage(Opp.Id);
    Test.stopTest();

    System.assertEquals(opportunityStage, 'Prospect');
  }

  /**
   * @description Test method for getOppSubchannel
   * Test method to fetch the Opportunity Sub Channel
   */
  @isTest
  static void getOppSubchannel_positive() {
    String opportunitySubChannel;
    Opportunity Opp = [
      SELECT Id, AccountId, Sub_Channel__c
      FROM Opportunity
      LIMIT 1
    ];
    Opp.Sub_Channel__c = 'Employer';
    update Opp;
    Test.startTest();
    opportunitySubChannel = ContractPathLOB_Controller.getOppSubchannel(Opp.Id);
    Test.stopTest();

    System.assertEquals(opportunitySubChannel, 'Employer');
  }
}