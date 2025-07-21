/**
 * Created by amruthakommuri on 2019-06-17.
 */

public with sharing class OpportunityValidator {
  public static Boolean bypassReadOnly(Opportunity opp, Opportunity oldOpp) {
    Set<String> blacklistedFields = new Set<String>{
      'SYSTEMMODSTAMP',
      'LASTMODIFIEDBYID',
      'LASTMODIFIEDDATE'
    };
    List<String> editField = new List<String>();
    List<String> bypassField = new List<String>();
    for (
      Schema.FieldSetMember fld : SObjectType.Opportunity.FieldSets.Bypass_Read_Only.getFields()
    ) {
      bypassField.add(fld.getFieldPath().toUppercase());
    }
    Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Opportunity.fields.getMap();
    for (String field : mapFields.keyset()) {
      if (opp.get(field) != oldOpp.get(field) && !bypassField.contains(field)) {
        editField.add(field.toUppercase());
      }
    }
    if (editField.isEmpty()) {
      return false;
    } else {
      Boolean isBypass = true;
      for (String field : editField) {
        system.debug(field);
        if (
          !bypassField.contains(field) && !blacklistedFields.contains(field)
        ) {
          isBypass = false;
        }
      }
      return isBypass;
    }
  }

  public static void validateContractingOtherOpp(
    Opportunity opp,
    Opportunity oldOpp
  ) {
    Id profileId = userinfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    List<PermissionSetAssignment> contractPerm = [
      SELECT AssigneeId
      FROM PermissionSetAssignment
      WHERE
        PermissionSet.Name = 'Contracting_User_Permission_Set'
        AND AssigneeId = :UserInfo.getUserId()
    ];
    List<PermissionSetAssignment> asoPerm = [
      SELECT AssigneeId
      FROM PermissionSetAssignment
      WHERE
        PermissionSet.Name = 'ASO_User_Permission_Set'
        AND AssigneeId = :UserInfo.getUserId()
    ];
    List<String> prodList = System.Label.Chronic_Care_Products.replaceAll(
        '\\s+',
        ''
      )
      .split(',');
    List<String> oppIdList = new List<String>();
    List<OpportunityLineItem> oppliList = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE ProductCode IN :prodList AND OpportunityId = :opp.Id
    ];
    if (
      !profileName.contains('System Administrator') &&
      opp.StageName == 'Closed Won' &&
      oldOpp.StageName != 'Closed Won' &&
      oppliList.size() > 0 &&
      contractPerm.size() == 0
    ) {
      opp.addError(
        'Only Contracts Team user will be able to close Opportuntiy with Chronic Care products.'
      );
    }
    if (
      !profileName.contains('System Administrator') &&
      asoPerm.isEmpty() &&
      contractPerm.isEmpty()
    ) {
      opp.addError(
        'Only user with Contracting Permission or System Administrator can modify opportunity after the CPQ Records are created.'
      );
    }
  }

  public static void validateContractingOpp(
    Opportunity opp,
    Opportunity oldOpp
  ) {
    User currentUser = [
      SELECT Id, UserRole.Name, Profile.Name
      FROM User
      WHERE Id = :userinfo.getUserId()
    ];
    boolean isBypass = bypassReadOnly(opp, oldOpp);
    if (!isBypass) {
      if (
        !currentUser.Profile.Name.contains('System Administrator') &&
        currentUser.UserRole.Name != 'Contracts'
      ) {
        opp.addError(
          'You do not have permission to edit this read-only Opportunity. Please contact your system administrator.'
        );
      }
    }
  }

  public static void validateClosedWonOpp(Opportunity opp) {
    Id profileId = userinfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    if (!profileName.contains('System Administrator')) {
      opp.addError(
        'Only System Administrators can edit a Closed Won Opportunity.'
      );
    }
  }
  /*
    //Contratee Relationship validation on the Opportunity Stage Change
    public static void validateStageChange(List<Opportunity> Opps) {
        Integer ContracteeRel = 0;
        for(Opportunity opp : opps) {
            List<Acct_Rel__c> accRelList = [select Relationship_Type__c from Acct_Rel__c where Benefit_Sponsor__c =: opp.AccountId AND (End_Date__c > TODAY OR End_Date__c = null) ];
            RecordType ProviderRecordType = [select ID from RecordType where name = 'Provider - Platform'];
            Id profileId=userinfo.getProfileId();
            String profileName =[Select Id,Name from Profile where Id=:profileId].Name;
            if (opp.StageName == 'contracting' || opp.StageName == 'Closed Won' && (opp.RecordTypeId != ProviderRecordType.Id || profileName != 'System Administrator')) {
                for (Acct_Rel__c relList : accRelList) {
                    
                    if (relList.Relationship_Type__c == 'Contractee') {
                        ContracteeRel = 1;
                    }
                }
            }
            
            System.debug(opp.RecordTypeId+'======'+ProviderRecordType.Id);
            if (opp.CPQ_Pricebook__c == 'HHS' || profileName == 'System Administrator') {
                ContracteeRel = 1;
            }
            system.debug('ContracteeeRel AFTER CHECK======'+ContracteeRel);
            if (ContracteeRel == 0 && (opp.StageName == 'contracting' || opp.StageName == 'Closed Won')) {
                opp.StageName.addError('No Contractee relationship exists on account');
            }
        }
    }
    */

  // refactor version
  public static void validateStageChange(List<Opportunity> Opps) {
    Integer ContracteeRel = 0;
    Id profileId = userinfo.getProfileId();
    Set<Id> accountIdSet = new Set<Id>();
    Map<String, List<Acct_Rel__c>> acctRelMap = new Map<String, List<Acct_Rel__c>>();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    RecordType ProviderRecordType = [
      SELECT ID
      FROM RecordType
      WHERE name = 'Provider - Platform'
    ];

    for (Opportunity opp : Opps) {
      accountIdSet.add(opp.AccountId);
    }
    List<Acct_Rel__c> accRelList = [
      SELECT Relationship_Type__c, Benefit_Sponsor__c
      FROM Acct_Rel__c
      WHERE
        Benefit_Sponsor__c IN :accountIdSet
        AND (End_Date__c > TODAY
        OR End_Date__c = NULL)
    ];
    for (Acct_Rel__c acctRel : accRelList) {
      if (!acctRelMap.containsKey(acctRel.Benefit_Sponsor__c)) {
        List<Acct_Rel__c> newList = new List<Acct_Rel__C>();
        newList.add(acctRel);
        acctRelMap.put(acctRel.Benefit_Sponsor__c, newList);
      } else {
        List<Acct_Rel__c> oldList = acctRelMap.get(acctRel.Benefit_Sponsor__c);
        oldList.add(acctRel);
        acctRelMap.put(acctRel.Benefit_Sponsor__c, oldList);
      }
    }

    for (Opportunity opp : opps) {
      if (
        opp.StageName == 'contracting' ||
        opp.StageName == 'Closed Won' &&
        (opp.RecordTypeId != ProviderRecordType.Id ||
        !profileName.contains('System Administrator'))
      ) {
        List<Acct_Rel__c> acctRelList = new List<Acct_Rel__c>();
        if (acctRelMap.get(opp.AccountId) != null) {
          acctRelList.addAll(acctRelMap.get(opp.AccountId));
        }
        for (Acct_Rel__c relList : acctRelList) {
          if (relList.Relationship_Type__c == 'Contractee') {
            ContracteeRel = 1;
          }
        }
      }

      if (
        opp.CPQ_Pricebook__c == 'HHS' ||
        profileName.contains('System Administrator')
      ) {
        ContracteeRel = 1;
      }

      //Below values will be deprecated later for Contract Path LOB functionality
      /*if (ContracteeRel == 0 && (opp.StageName == 'contracting' || opp.StageName == 'Closed Won')) {
                opp.StageName.addError('No Contractee relationship exists on account');
            }*/
    }
  }
}