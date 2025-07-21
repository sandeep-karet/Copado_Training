/***********************************************************************************************************
Class Name : OpportunityContactRoleHelper
Created by : Vineel Muppa
**************** Revision History*****************

* JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION      
*---------------------------------------------------------------------------------
* SCDEV-4353    27-Dec-2023		Elambaruthi T		Setup Default Owner to Salesforce Support User
* SCDEV-4762    23-Jan-2024		Elambaruthi T		Account Relationship Mapping (Servicing Account Role)

***********************************************************************************************************/
public class OpportunityContactRoleHelper {
  public static void createAccouintRelationship(
    List<OpportunityContactRole> listOppConRoles
  ) {
    /* SCDEV-4353 [Starts] */
    String tdSFSupportUserId = GCRM_ProcessOrder_Utlity.getMuleSoftIntegrationDefaultOwner(
      UserInfo.getUserId()
    );
    /* SCDEV-4353 [Ends] */
    /* SCDEV-4762 [Starts] */
    Picklist_Value_Mapping__mdt pvMap = Picklist_Value_Mapping__mdt.getInstance(
      'Servicing_Account_Role_Mapping'
    );
    Map<String, String> relTypePicklistValueMap = (Map<String, String>) JSON.deserialize(
      pvMap.Value_Mapping__c,
      Map<String, String>.class
    );
    /* SCDEV-4762 [Ends] */

    Set<String> setConRoles = new Set<String>{
      'General Agency',
      'Broker',
      'Benefit Consultant'
    };
    Set<Id> setOppIds = new Set<Id>();
    Set<Id> setConIds = new Set<Id>();
    Set<Id> setAccIds = new Set<Id>();

    for (OpportunityContactRole recOCR : listOppConRoles) {
      if (setConRoles.contains(recOCR.Role)) {
        setOppIds.add(recOCR.OpportunityId);
        setConIds.add(recOCR.ContactId);
      }
    }
    Map<Id, Contact> mapCon = new Map<Id, Contact>(
      [SELECT Id, AccountId, Location__c FROM Contact WHERE id IN :setConIds]
    );
    Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
    for (Opportunity recOpp : [
      SELECT Id, AccountId, CloseDate
      FROM Opportunity
      WHERE id IN :setOppIds
    ]) {
      setAccIds.add(recOpp.AccountId);
      mapOpp.put(recOpp.id, recOpp);
    }
    Set<String> setAccRel = new Set<String>();
    for (Acct_Rel__c recAR : [
      SELECT
        Broker_Contact__c,
        Broker_Flat_Rate__c,
        Broker_Percentage__c,
        Chronic_Care_Broker_Flat_Rate__c,
        Chronic_Care_Broker_Percentage__c,
        Relationship_Type__c
      FROM Acct_Rel__c
      WHERE
        Benefit_Sponsor__c IN :setAccIds
        AND Broker_Contact__c IN :setConIds
        AND Relationship_Type__c IN :setConRoles
    ]) {
      setAccRel.add(
        recAR.Broker_Contact__c +
          '-' +
          recAR.Broker_Flat_Rate__c +
          '-' +
          recAR.Chronic_Care_Broker_Flat_Rate__c +
          '-' +
          recAR.Chronic_Care_Broker_Percentage__c +
          '-' +
          recAR.Relationship_Type__c
      );
    }
    List<Acct_Rel__c> listAccRelInsert = new List<Acct_Rel__c>();
    for (OpportunityContactRole recOCR : listOppConRoles) {
      /* SCDEV-4762 [Starts] */
      //String roleName=(recOCR.Role=='Broker' || recOCR.Role=='General Agency')?'Broker':'Benefit Partner or Vendor';
      String roleName = 'Benefit Partner or Vendor';
      if (relTypePicklistValueMap.containsKey(recOCR.Role)) {
        roleName = relTypePicklistValueMap.get(recOCR.Role);
      }
      /* SCDEV-4762 [Ends] */
      if (
        setConRoles.contains(recOCR.Role) &&
        setAccRel.add(
          recOCR.ContactId +
            '-' +
            recOCR.Broker_Flat_Rate__c +
            '-' +
            recOCR.Chronic_Care_Broker_Flat_Rate__c +
            '-' +
            recOCR.Chronic_Care_Broker_Percentage__c +
            '-' +
            roleName
        )
      ) {
        Acct_Rel__c objAR = new Acct_Rel__c();
        objAR.Benefit_Sponsor__c = mapOpp.get(recOCR.OpportunityId).AccountId;
        objAR.Start_Date__c = mapOpp.get(recOCR.OpportunityId).CloseDate;
        objAR.Broker_Contact__c = recOCR.ContactId;
        objAR.Broker_Flat_Rate__c = recOCR.Broker_Flat_Rate__c;
        objAR.Broker_Percentage__c = recOCR.Broker_Percentage__c;
        objAR.Chronic_Care_Broker_Flat_Rate__c = recOCR.Chronic_Care_Broker_Flat_Rate__c;
        objAR.Chronic_Care_Broker_Percentage__c = recOCR.Chronic_Care_Broker_Percentage__c;
        objAR.Relationship_Type__c = roleName;
        objAR.Broker_Location__c = mapCon.get(recOCR.ContactId).Location__c;
        objAR.Svc_Acct__c = mapCon.get(recOCR.ContactId).AccountId;
        /* SCDEV-4353 [Starts] */
        objAR.OwnerId = tdSFSupportUserId;
        /* SCDEV-4353 [Ends] */
        listAccRelInsert.add(objAR);
      }
    }
    if (listAccRelInsert != null && listAccRelInsert.size() > 0)
      insert listAccRelInsert;
  }
}