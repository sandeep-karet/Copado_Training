@IsTest
public with sharing class IntakeFormController_Test {
  static testMethod void testNASF() {
    Account umrAcct = TestDataFactory.createUMR();
    Profile p = [SELECT Id FROM Profile LIMIT 1];
    User u = TestDataFactory.createUser(p.Id);

    Contact am = TestDataFactory.createContactDynamicVals(
      'Tim',
      'Amity',
      'tim@amity.tim',
      null
    );

    Account ab = TestDataFactory.createAccountUMRNoInsert();
    ab.Friendly_Account_Name__c = 'Brk';
    ab.GUID__c = 'ced85d79-65b7-4b3e-aa3c-039c0fe65406';
    insert ab;

    Contact cb = TestDataFactory.createContactDynamicVals(
      'Barry',
      'Broker',
      'barry@broker.barry',
      ab.Id
    );

    insert new List<SObject>{ u, am, cb };

    Account a = TestDataFactory.createAccount('Test Account, LLC');

    Acct_Rel__c arc = TestDataFactory.createAccRel(ab.Id, 'Broker', null, null);
    arc.Benefit_Sponsor__c = a.Id;
    arc.Svc_Acct__c = ab.Id;
    arc.Broker_Contact__c = cb.Id;
    arc.Broker_Flat_Rate__c = 100.30;

    Acct_Rel__c arc2 = TestDataFactory.createAccRel(
      ab.Id,
      'Payer Only',
      null,
      null
    );
    arc2.Svc_Acct__c = a.Id;
    arc2.Benefit_Sponsor__c = a.Id;

    Acct_Rel__c arc3 = TestDataFactory.createAccRel(
      ab.Id,
      'Broker',
      null,
      null
    );
    arc3.Svc_Acct__c = a.Id;
    arc3.Benefit_Sponsor__c = a.Id;
    arc3.Broker_Contact__c = cb.Id;
    arc3.Broker_Flat_Rate__c = 100.30;

    Acct_Rel__c arc4 = TestDataFactory.createAccRel(
      ab.Id,
      'Contractee',
      'Direct',
      'N/A'
    );
    arc4.Benefit_Sponsor__c = a.Id;

    Mbr_Group__c mg = TestDataFactory.createMbrGroup(a.Id)[0];
    /*mg.Client_Account__c = a.Id;
        mg.Active_Date__c = Date.today() - 30;
        mg.Name__c = 'great group';*/

    insert new List<SObject>{ arc, arc2, arc4 };

    Plan_Specific_Fees__c psf = TestDataFactory.PlanSpecificFees();
    psf.Member_Group__c = mg.Id;

    Mbr_Group_Role__c mgr = TestDataFactory.createGroupRole(
      mg.Id,
      'Billing',
      ab.Id,
      cb.Id
    );
    insert new List<SObject>{ mgr, psf };
    Id tmpPb = Test.getStandardPricebookId();

    Opportunity o = TestDataFactory.createOpportunityWithPriceBook(
      a.Id,
      tmpPb,
      null
    );
    o.LeadSource = 'Sales';
    insert o;

    Product2 prod = TestDataFactory.createSingleProduct(
      'Behavioral Health',
      'Behavioral Health',
      'BH1PT'
    );
    insert prod;

    PricebookEntry tmpPbe = TestDataFactory.createPriceBookEntries(
      new List<Product2>{ prod },
      tmpPb
    )[0];
    //new PricebookEntry(Pricebook2Id = tmpPb, Product2Id = prod.Id, UnitPrice = 0, IsActive = true);
    insert tmpPbe;
    SBQQ__Subscription__c sub = TestDataFactory.createSBQQSubscription(a.Id);
    sub.SBQQ__Product__c = prod.Id;
    insert sub;

    /* OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.Consult_Fees__c = 2;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = tmpPbe.Id;
        oli.Quantity=1;
        oli.TotalPrice = 23;
        insert oli;*/

    Test.startTest();
    // Open the preview page, run all three actions
    Test.setCurrentPage(Page.IntakeFormPreview);
    ApexPages.currentPage().getParameters().put('oid', o.Id);
    IntakeFormPreviewController ic = new IntakeFormPreviewController();
    ic.sendIntakeForm();
    ic.showPDF();
    ic.cancelIntakeForm();

    // Open the View page as PDF
    Test.setCurrentPage(Page.IntakeFormView);
    ApexPages.currentPage().getParameters().put('oid', o.Id);
    ApexPages.currentPage().getParameters().put('view', 'pdf');
    IntakeFormViewController pc = new IntakeFormViewController();
    System.assert(pc.opportunityId == o.Id);
    Test.stopTest();
  }
}