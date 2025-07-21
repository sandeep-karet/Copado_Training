public with sharing class LaunchTinderboxController {
  Id oppid = System.currentPageReference().getParameters().get('id');
  string buttonid = System.currentPageReference().getParameters().get('bid');

  public Opportunity opp = new Opportunity();
  public Opportunity getOpp() {
    //opp = [SELECT Id, Proposal_Template__c, Tbox_template__c, Contract__c, Pricing_Option__c from Opportunity where Id = :oppid];
    opp = [
      SELECT
        Id,
        Proposal_Template__c,
        Tbox_template__c,
        Contract_Template__c,
        Pricing_Option__c,
        Include_Additional_Pricing_Option__c,
        Additional_Pricing_Option__c
      FROM Opportunity
      WHERE Id = :oppid
    ];

    return opp;
  }

  public PageReference gotoTinderbox() {
    getOpp();
    if (buttonid == 'proposal') {
      opp.Tbox_template__c = opp.Proposal_Template__c;
      update opp;
    }
    if (buttonid == 'contract') {
      //Removing Contract Template picklist and setting the single picklist for single template
      //opp.Tbox_template__c = opp.Contract_Template__c;
      opp.Tbox_template__c = 'TDH DTE Contract 2019';
      update opp;
    }
    if (buttonid == 'baa') {
      opp.Tbox_template__c = 'BAA';
      update opp;
    }

    //PageReference callPage = new PageReference('/apex/tinderbox__create_proposal_opp?Id='+oppid);
    PageReference callPage = new PageReference(
      '/apex/tinderbox__create_document?sObjectType=Opportunity&recordId=' +
      oppid
    );
    return callPage;
  }
}