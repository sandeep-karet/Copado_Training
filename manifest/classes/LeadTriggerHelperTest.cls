@isTest
public with sharing class LeadTriggerHelperTest {
  @TestSetup
  static void setup() {
    List<Lead> testLeads = TestDataFactory.createLeads(10);
  }
  @isTest
  static void testLeadConversion() {
    Test.startTest();
    List<Lead> testLeads = TestDataFactory.createLeads(1);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    for (Lead lead : testLeads) {
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(lead.id);
      lc.setConvertedStatus(convertStatus.MasterLabel);
      Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
    Test.stopTest();
  }

  @isTest
  static void testCanCurrency() {
    //List<Lead> testLeads = TestDataFactory.createLeads(1);

    User u1 = [
      SELECT Id
      FROM User
      WHERE DefaultCurrencyIsoCode = 'CAD'
      LIMIT 1
    ];
    User u2 = [
      SELECT Id
      FROM User
      WHERE DefaultCurrencyIsoCode = 'USD'
      LIMIT 1
    ];

    List<Lead> leadList = [SELECT CurrencyIsoCode FROM Lead];
    for (lead l : leadList) {
      system.assertEquals('USD', l.CurrencyIsoCode);
    }
    for (lead l : leadList) {
      l.ownerId = u1.Id;
    }
    update leadList;

    List<lead> updateLeadList = [SELECT CurrencyIsoCode FROM Lead];
    for (lead l : updateLeadList) {
      system.assertEquals('CAD', l.CurrencyIsoCode);
    }
    for (lead l : updateLeadList) {
      l.ownerId = u2.Id;
    }
    update updateLeadList;

    List<lead> updateLeadList2 = [SELECT CurrencyIsoCode FROM Lead];
    for (lead l : updateLeadList2) {
      system.assertEquals('USD', l.CurrencyIsoCode);
    }
  }
}