public with sharing class IntakeFormViewController {
  public List<PDFItem> pdfinfo { get; set; }
  public Id opportunityId { get; set; }
  private Id accountId { get; set; }
  private Account selAccount { get; set; }
  private Opportunity selOpp { get; set; }
  public String renderMode { get; set; }
  public String version { get; set; }
  public String currDateTime { get; set; }

  public IntakeFormViewController() {
    // Converts intake data to generic PDF structure
    // Note: PDF builder was copied from NASF Preview with the assumption they will diverge quickly.
    // If you notice they're the same after a while, consider consolidating and having one PDF builder
    PageReference page = System.currentPageReference();
    renderMode = page.getParameters().get('view');
    if (opportunityId == null) {
      opportunityId = page.getParameters().get('oid');
    }
    // First time setup
    selOpp = [
      SELECT
        Id,
        Name,
        AccountId,
        Initial_of_Lives__c,
        CloseDate,
        Country__c,
        Fee_Type__c,
        Contract.Account.Name
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];
    currDateTime = String.valueOf(Datetime.now());
    accountId = selOpp.AccountId;

    selAccount = [
      SELECT
        Id,
        Name,
        Friendly_Account_Name__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        Phone,
        Owner.Name,
        Owner.Id,
        Total_US_Employees_Benefits_Enrolled__c,
        BillingCountry,
        Business_Region__c,
        Primary_Billing_Contact__r.Name,
        Primary_Billing_Contact__r.Title,
        Primary_Billing_Contact__r.Phone,
        Primary_Billing_Contact__r.Fax,
        Primary_Billing_Contact__r.Email,
        Payment_Terms__c,
        Special_Instructions_for_Implementatio__c,
        States_of_Operation__c
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];

    List<OpportunityLineItem> oppProducts = [
      SELECT
        Id,
        PricebookEntry.Name,
        UnitPrice,
        TotalPrice,
        ServiceDate,
        Quantity,
        PricebookEntry.Product2.Id,
        OpportunityId,
        Product__c,
        ListPrice,
        Product2.Family,
        Product2.Name,
        ProductCode,
        Membership_Fee__c,
        Consult_Fees__c,
        Opportunity.Fee_Type__c,
        SBQQ__QuoteLine__r.SBQQ__Bundled__c,
        Opportunity.CurrencyIsoCode
      FROM OpportunityLineItem
      WHERE OpportunityId = :opportunityId
      ORDER BY Product2.SBQQ__SortOrder__c
    ];

    List<Acct_Rel__c> svcAccounts = [
      SELECT
        Id,
        Broker_Contact__r.Name,
        Svc_Acct__r.Name,
        Broker_Contact__r.Title,
        Broker_Contact__r.Phone,
        Broker_Contact__r.Fax,
        Broker_Contact__r.Email,
        Broker_Loc_Name__c,
        Broker_Location__c,
        Start_Date__c,
        End_Date__c,
        Broker_Percentage__c,
        Broker_Flat_Rate__c,
        Broker_Location__r.Name,
        Broker_Location__r.Address__c,
        Relationship_Type__c,
        Svc_Acct__r.Payment_Terms__c
      FROM Acct_Rel__c
      WHERE
        Benefit_Sponsor__c = :accountId
        AND Relationship_Type__c IN ('Broker', 'Contractee')
        AND Start_Date__c < TODAY
        AND (End_Date__c = NULL
        OR End_Date__c > TODAY)
    ];

    List<Acct_Rel__c> brokers = new List<Acct_Rel__c>();
    List<Acct_Rel__c> contractees = new List<Acct_Rel__c>();
    for (Acct_Rel__c ar : svcAccounts) {
      if (ar.Relationship_Type__c == 'Broker') {
        brokers.add(ar);
      } else if (ar.Relationship_Type__c == 'Contractee') {
        contractees.add(ar);
      }
    }

    // Get latest version number from Metadata
    NASF_Metadata__mdt md = [
      SELECT Id, Value__c, Label
      FROM NASF_Metadata__mdt
      WHERE Label = 'Intake Version'
    ];
    version = md.Value__c;
    pdfinfo = new List<PDFItem>();

    // Build form header
    PDFItem ai = new PDFItem();
    ai.header = 'CLIENT INTAKE FORM: ' + selAccount.Name;
    ai.infoType = 'major';
    pdfinfo.add(ai);

    // Build General info section
    ai = new PDFItem();
    ai.header = 'General Information';
    ai.infoType = 'detail';
    ai.addRow('Client Legal Name', selAccount.Name);
    ai.addRow('Client Friendly Name', selAccount.Friendly_Account_Name__c);
    ai.addRow(
      'Address',
      selAccount.BillingStreet +
        '<br />' +
        selAccount.BillingCity +
        ', ' +
        selAccount.BillingState +
        '<br />' +
        selAccount.BillingPostalCode
    );
    ai.addRow('Account Owner', selAccount.Owner.Name);
    ai.addRow(
      'Total Number of Employees/Primary Members Eligible for Teladoc',
      String.valueOf(selOpp.Initial_of_Lives__c)
    );
    ai.addRow('Revenue Effective Date', String.valueOf(selOpp.CloseDate));
    ai.addRow(
      'Country and Business Region',
      selAccount.Business_Region__c + ' / ' + selAccount.States_of_Operation__c
    );
    pdfinfo.add(ai);

    // LOOP THROUGH Service accounts / "Contractee"
    // Make a list of brokers and a list of contractees
    for (Acct_Rel__c ar : contractees) {
      ai = new PDFItem();
      ai.header = 'Contract Information';
      ai.infoType = 'detail';
      ai.addRow('Contracting Account Name', ar.Svc_Acct__r.Name);
      ai.addRow(
        'Payment Terms: (If other than Due Upon Receipt)',
        ar.Svc_Acct__r.Payment_Terms__c
      );
      pdfinfo.add(ai);
    }

    // Build primary contact section
    ai = new PDFItem();
    ai.header = 'Contact Information';
    ai.infoType = 'detail';
    ai.addRow(
      'Primary Contact Name',
      selAccount.Primary_Billing_Contact__r.Name
    );
    ai.addRow('Title', selAccount.Primary_Billing_Contact__r.Title);
    ai.addRow('Phone', selAccount.Primary_Billing_Contact__r.Phone);
    ai.addRow('Fax', selAccount.Primary_Billing_Contact__r.Fax);
    ai.addRow('Email', selAccount.Primary_Billing_Contact__r.Email);
    pdfinfo.add(ai);

    // Loop through brokers and add to result
    for (Acct_Rel__c ar : brokers) {
      ai = new PDFItem();
      ai.header = 'Broker Contact Information: ' + ar.Broker_Contact__r.Name;
      ai.infoType = 'detail';

      ai.addRow('Contact Name', ar.Broker_Contact__r.Name);
      ai.addRow('Title', ar.Broker_Contact__r.Title);

      ai.addRow('Phone', ar.Broker_Contact__r.Phone);
      ai.addRow('Fax', ar.Broker_Contact__r.Fax);

      //result.a InfoRows('Client Legal Name',n.general_info.address_city));
      ai.addRow('Email', ar.Broker_Contact__r.Email);
      ai.addRow('Account Name', ar.Svc_Acct__r.Name);

      ai.addRow('Location Name', ar.Broker_Loc_Name__c);
      ai.addRow('Location ID', ar.Broker_Location__r.Name);
      ai.addRow('Location Address', ar.Broker_Location__r.Address__c);

      ai.addRow(
        'Start Date',
        ar.Start_Date__c == null ? '' : ar.Start_Date__c.format()
      );
      ai.addRow(
        'End Date',
        ar.End_Date__c == null ? '' : ar.End_Date__c.format()
      );

      ai.addRow('Commission %', String.valueOf(ar.Broker_Percentage__c));
      ai.addRow('Commission Flat Rate', String.valueOf(ar.Broker_Flat_Rate__c));
      pdfinfo.add(ai);
    }

    ai = new PDFItem();
    ai.header =
      'Billing & Benefit Structures : Membership Fee Type ( ' +
      selOpp.Fee_Type__c +
      ' )';
    ai.infoType = 'table';
    List<String> tblheaders = new List<String>{
      'Product Family',
      'Product Codes (SF)',
      'Product Name',
      'Membership Fee',
      'Consulting Fee'
    };

    List<List<String>> tblrows = new List<List<String>>();
    for (OpportunityLineItem oli : oppProducts) {
      // figure out currency
      String prodCode = oli.ProductCode.toUpperCase();
      String membershipFee = oli.SBQQ__QuoteLine__r.SBQQ__Bundled__c
        ? 'Included'
        : oli.Opportunity.CurrencyIsoCode +
          ' ' +
          String.valueOf(oli.Membership_Fee__c);
      String consultingFee = oli.Consult_Fees__c != null
        ? oli.Opportunity.CurrencyIsoCode + ' ' + oli.Consult_Fees__c
        : '';
      List<String> row = new List<String>{
        nullToBlank(oli.Product2.Family),
        nullToBlank(prodCode),
        nullToBlank(oli.Product2.Name),
        nullToBlank(membershipFee),
        nullToBlank(consultingFee)
      };
      tblrows.add(row);
    }
    ai.rows = tblrows;
    ai.headers = tblheaders;
    pdfinfo.add(ai);

    ai = new PDFItem();
    ai.header = 'Special Instructions';
    ai.infoType = 'detail';
    ai.addRow(
      'Special Instructions for Implementations',
      selAccount.Special_Instructions_for_Implementatio__c
    );
    pdfinfo.add(ai);
  }

  // Generic PDF section, can contain detail or a table
  public class PDFItem {
    public String infoType { get; set; }
    public String header { get; set; }
    public List<InfoRows> infoRows { get; set; }
    public List<String> headers { get; set; }
    public List<List<String>> rows { get; set; }

    public PDFItem() {
      infoRows = new List<InfoRows>();
    }

    public void addRow(String key, String val) {
      InfoRows row = new InfoRows(key, val, infoRows.size());
      infoRows.add(row);
    }
  }

  // Generic row of information (name/value pairs)
  public class InfoRows {
    public InfoRows(String label, String val, Integer ix) {
      name = label;
      value = val;
      index = ix;
    }
    public String name { get; set; }
    public String value { get; set; }
    public Integer index { get; set; }
  }

  private String nullToBlank(String s) {
    return (s == null ? '' : s);
  }
}