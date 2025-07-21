/**
 * @date July 07, 2022
 * @description: Apex Controller class for ContractPathLOB_Controller LWC component
 *
 */
public without sharing class ContractPathLOB_Controller {
  /**
   * @description: Method to update Opportunity with Contract Path related fields
   * @return void
   */
  @AuraEnabled
  public static void updateOpp(
    String recordId,
    String directCont,
    String directEmpl,
    String ContLens,
    String lineofBuss,
    Id accountName
  ) {
    try {
      Opportunity opp = [
        SELECT
          Id,
          Direct_Contract__c,
          Direct_Employer_Service__c,
          Contracting_Lens__c,
          Contract_Path__c,
          Contract_Path__r.Name,
          Line_of_Business_CP__c
        FROM Opportunity
        WHERE Id = :recordId
      ];

      if (directCont != '') {
        opp.Direct_Contract__c = directCont;
      }

      if (directEmpl != '') {
        opp.Direct_Employer_Service__c = directEmpl;
      }

      opp.Contracting_Lens__c = ContLens;
      opp.Line_of_Business_CP__c = lineofBuss;
      opp.Contract_Path__c = accountName;

      update opp;
    } catch (DmlException ex) {
      System.debug('The following exception has occurred: ' + ex.getMessage());
      throw new AurahandledException(ex.getDmlMessage(0));
    } catch (Exception ex) {
      System.debug('The following exception has occurred: ' + ex.getMessage());
      throw new AurahandledException(ex.getMessage());
    }
  }

  /**
   * @description: Fetch Opportunity Stage needed for validation on ContractPathLOB LWC component
   * @param oppId- Opportunity Id
   * @return Opporunity's Stage Name
   */
  @AuraEnabled
  public static String validateStage(String recordId) {
    Opportunity opp = new Opportunity();
    try {
      opp = [
        SELECT Id, Name, AccountId, StageName
        FROM Opportunity
        WHERE Id = :recordId
        LIMIT 1
      ];
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return opp.StageName;
  }

  /**
   * @description: Fetch Opportunity Sub-channel needed for validation on ContractPathLOB LWC component
   * @param oppId- Opportunity Id
   * @return Opporunity's Sub-channel
   */
  @AuraEnabled
  public static String getOppSubchannel(String recordId) {
    Opportunity opp = new Opportunity();
    try {
      opp = [
        SELECT Id, Name, AccountId, StageName, Sub_Channel__c
        FROM Opportunity
        WHERE Id = :recordId
        LIMIT 1
      ];
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return opp.Sub_Channel__c;
  }

  /**
   * @description: Validating if the Account is a Teladoc for LWC component
   * @param oppId- Opportunity Id, accId - AccountId related to Opportunity
   * @return Validation Error Message
   */
  @AuraEnabled
  public static String accountValidation(String oppId, String accId) {
    String teladocId = System.Label.TD_Teladoc_Account;
    String accValidationMessage = '';

    try {
      Opportunity opp = [
        SELECT Id, Name, AccountId, StageName
        FROM Opportunity
        WHERE Id = :oppId
        LIMIT 1
      ];

      if (accId == teladocId) {
        accValidationMessage = 'Teladoc Account can not be selected as Contract Path for a non direct contract';
      } else if (accId == opp.AccountId) {
        accValidationMessage = 'Account the opportunity is on can not be selected as Contract Path for a non direct contract';
      }
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    return accValidationMessage;
  }
}