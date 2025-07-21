public with sharing class IntakeFormPreviewController {
  public Id oppId { get; private set; }
  public Opportunity selOpp { get; set; }
  public Boolean validOpp { get; set; }
  public Boolean showOppLink { get; set; }
  public Boolean showContactLink { get; set; }
  public Account selAcc { get; set; }

  public IntakeFormPreviewController() {
    validOpp = true;
    oppId = ApexPages.currentPage().getParameters().get('oid');
    selOpp = [
      SELECT Id, Name, AccountId, Fee_Type__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
    selAcc = [
      SELECT
        Id,
        Name,
        Primary_Billing_Contact__c,
        Primary_Billing_Contact__r.Phone,
        Primary_Billing_Contact__r.Email,
        Primary_Billing_Contact__r.Name
      FROM Account
      WHERE Id = :selOpp.AccountId
    ];

    System.debug('OPPID: ' + oppId);
    List<String> errList = validateIntake();

    if (errList != null && errList.size() > 0) {
      validOpp = false;
      for (String err : errList) {
        ApexPages.addMessage(
          new ApexPages.Message(ApexPages.Severity.INFO, 'Missing info: ' + err)
        );
      }
    }
  }

  private List<String> validateIntake() {
    showContactLink = false;
    showOppLink = false;
    // First check: Missing fields
    List<String> errlist = new List<String>();
    /*
if (String.isBlank(selAcc.Primary_Billing_Contact__r.Phone))
{
errlist.add('Primary Billing Contact phone is required');
showContactLink = true;
}
if (String.isBlank(selAcc.Primary_Billing_Contact__r.Email))
{
errlist.add('Primary Billing Contact email is required');
showContactLink = true;
}
if (String.isBlank(selOpp.Fee_Type__c))
{
errlist.add('Opportunity Fee Type is required');
showOppLink = true;
}*/

    // Second check: requires one Contractee
    return errlist;
  }

  public PageReference sendIntakeForm() {
    sendEmailToUser();
    return null;
  }

  public PageReference showPDF() {
    PageReference callPage = Page.IntakeFormView;
    callPage.getParameters().put('oid', oppId);
    callPage.getParameters().put('view', 'pdf');
    callPage.setRedirect(true);
    return callPage;
  }

  private Blob getPDFasBlob() {
    // Getting the page as email does not work with cookies, so get/post here
    PageReference callPage = Page.IntakeFormView;
    callPage.getParameters().put('oid', oppId);
    callPage.getParameters().put('view', 'pdf');
    Blob content;
    try {
      content = callPage.getContentAsPDF();
    } catch (VisualforceException e) {
      // This makes your unit tests work.
      content = Blob.valueOf('Unable to generate PDF');
    }
    return content;
  }

  private void sendEmailToUser(Blob content) {
    // Create the email attachment
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(getPDFFilename());
    efa.setBody(content);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] ToAddresses;
    ToAddresses = new List<String>{ UserInfo.getUserEmail() };
    mail.setToAddresses(ToAddresses);

    // Specify the address used when the recipients reply to the email.
    mail.setReplyTo('salesforcesupport@teladoc.com');
    mail.setSenderDisplayName('Salesforce Intake Form');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setSaveAsActivity(false);

    mail.setSubject('Intake Form for Opportunity: ' + selOpp.Name);
    mail.setHtmlBody(
      '<html><body>Please find attached a pdf version of the Account Setup Form for ' +
        selOpp.Name +
        '.</body></html>'
    );

    mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ efa });
    if (!Test.isRunningTest()) {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        'New account setup form sent to: ' + UserInfo.getUserEmail()
      )
    );
  }

  private String getPDFFilename() {
    return 'Teladoc Intake Form ' +
      selOpp.Name.replaceAll('[\\\\/:*?\'<>|]', '') +
      ' - ' +
      Datetime.now() +
      '.pdf';
  }
  private void sendEmailToUser() {
    sendEmailToUser(getPDFasBlob());
  }

  public PageReference cancelIntakeForm() {
    PageReference callPage = new PageReference('/' + oppId).setRedirect(true);
    return callPage;
  }
}