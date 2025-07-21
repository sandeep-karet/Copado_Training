/**
 * Created by jpatel on 4/23/18.
 */

public with sharing class LeadTriggerHelper {
  public static void leadConvertionUpdate(List<Lead> leads) {
    //List of opportunity and Contact to update
    List<Opportunity> updateOppList = new List<Opportunity>();
    List<Contact> updateContactList = new List<Contact>();
    for (Lead l : leads) {
      if (l.IsConverted) {
        if (l.convertedOpportunityId != null)
          updateOppList.add(
            new Opportunity(id = l.convertedOpportunityId, Lead__c = l.Id)
          );
        if (l.ConvertedContactId != null)
          updateContactList.add(
            new Contact(id = l.ConvertedContactId, Lead__c = l.Id)
          );
      }
    }
    //update Contact and Opportunity
    update updateOppList;
    update updateContactList;
  }

  //This is to capture the LastStatus Change and LastStatusDate so these values can be added to the single report instead of looking into Lead History table
  public static void leadStatusChange(List<Lead> leads, Map<Id, Lead> oldMap) {
    Lead oldLead;
    for (Lead l : leads) {
      if (oldMap == null) {
        l.Last_Status__c = l.status;
        l.Last_Status_Date__c = Datetime.now();
      } else if (
        oldMap.get(l.id) != null &&
        l.status != oldMap.get(l.id).status
      ) {
        l.Last_Status__c = oldMap.get(l.id).status;
        l.Last_Status_Date__c = Datetime.now();
      }
    }
  }

  public static void leadCurrencyChange(
    List<Lead> leads,
    Map<Id, Lead> oldMap
  ) {
    Map<Id, User> CadUser = new Map<Id, User>(
      [SELECT Id FROM User WHERE DefaultCurrencyIsoCode = 'CAD']
    );
    for (Lead l : leads) {
      if (
        oldMap.get(l.Id) != null &&
        l.OwnerId != oldMap.get(l.Id).OwnerId &&
        CadUser.containsKey(l.ownerId) &&
        l.CurrencyIsoCode != 'CAD'
      ) {
        l.CurrencyIsoCode = 'CAD';
      } else if (
        oldMap.get(l.Id) != null &&
        l.OwnerId != oldMap.get(l.Id).OwnerId &&
        !CadUser.containsKey(l.ownerId) &&
        l.CurrencyIsoCode != 'USD'
      ) {
        l.CurrencyIsoCode = 'USD';
      }
    }
  }
}