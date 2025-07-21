public with sharing class NASFPreviewController {
  public Id accountId { get; private set; }
  private Account selAccount { get; set; }
  public transient String newCaseId { get; set; }
  public transient Boolean showNewCase { get; set; }
  public Set<Id> selectedGroupIds { get; set; }
  public Boolean toggle_flow_code { get; set; }

  public NASFPreviewController() {
    PageReference page = System.currentPageReference();
    // First time setup
    accountId = page.getParameters().get('aid');
    selAccount = [
      SELECT Name, Allow_Flow__c
      FROM Account
      WHERE Id = :accountId
    ];
    Flow__c FS = Flow__c.getInstance(UserInfo.getProfileId());
    // If a custom setting has not been defined for a given profile then toggle code off
    if (FS == null)
      toggle_flow_code = false;
    else
      toggle_flow_code = FS.Enabled__c;

    if (selAccount.Allow_Flow__c == false && toggle_flow_code == true) {
      ApexPages.Message allow_flow_msg = new ApexPages.Message(
        ApexPages.Severity.WARNING,
        'ACCOUNT (' +
          selAccount.Name +
          ') is not eligible for FLOW. The group(s) below must be MANUALLY configured in ADMIN.'
      );
      ApexPages.addMessage(allow_flow_msg);
    }
    selectedGroupIds = new Set<Id>();
    String idValString;
    Cookie idCookie = page.getCookies().get('g:' + accountId);
    if (idCookie == null) {
      idValString = page.getParameters().get('ids');
    } else {
      idValString = idCookie.getValue();
    }

    if (!String.isBlank(idValString)) {
      for (String s : idValString.split(',')) {
        selectedGroupIds.add(Id.valueOf(s));
      }
    }
  }

  // Create attachment, send email and create case
  public PageReference passToConfig() {
    Attachment att = new Attachment(Name = getPDFFilename());

    Blob content = getPDFasBlob();
    att.ContentType = 'application/pdf';
    att.Body = content;

    User current_user = [
      SELECT id, alias
      FROM User
      WHERE id = :UserInfo.getUserId()
    ];
    if (current_user.alias != 'emart')
      sendEmailToUser(content);

    Group adminQueue = [
      SELECT Id, name, type
      FROM group
      WHERE name = 'Admin Config User Queue' AND type = 'Queue'
      LIMIT 1
    ];

    // Make a new Case
    Case newCase = new Case();
    newCase.Subject =
      'New Account Setup (' +
      selAccount.Name +
      ') - ' +
      date.today().format();
    newCase.AccountId = accountId;
    newCase.status = 'Not Started';
    newCase.ownerId = adminQueue.id;
    newCase.Due_Date__c = CrmHelpers.validBusinessDate(Date.today() + 3);

    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
      .get('Admin Config')
      .getRecordTypeId();

    // Save the Case
    try {
      insert newCase;
      att.ParentId = newCase.Id;
      insert att;
      newCase.Description =
        'New account setup requested for (' +
        selAccount.Name +
        ' ) - Link to account setup form pdf: ' +
        URL.getOrgDomainUrl().toExternalForm() +
        '/servlet/servlet.FileDownload?file=' +
        att.id;
      update newCase;

      // Set a link for the page
      showNewCase = true;
      newCaseId = newCase.Id;
      List<Mbr_Group__c> outgoing_groups = [
        SELECT id, guid__c
        FROM Mbr_Group__c
        WHERE id IN :selectedGroupIds
      ];
      // Build our list of group guids
      Set<String> group_guids = new Set<String>();
      for (Mbr_Group__c temp_group : outgoing_groups)
        group_guids.add(temp_group.GUID__c);

      if (selAccount.Allow_Flow__c == true && toggle_flow_code) {
        System.Debug('guids being submitted for tas tasks: ' + group_guids);
        Boolean processing_needed = Eds2MwProcs.CreateTasTasks(
          group_guids,
          newCaseId
        );
        Database.executeBatch(new FlowOut_Bch(null), 1);
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'A new case has been created for configuration. <a href=\'/' +
              newCaseId +
              '\' target=\'_blank\'>View case</a>'
          )
        );
        if (processing_needed == true) {
          newCase.Sent_to_Admin__c = true;
          System.debug('newCase due date = ' + newCase.Due_Date__c);
          update newCase;
          PageReference callPage = new PageReference('/' + newcase.Id);
          callPage.setRedirect(true);
          return callPage;
        }
      }
      PageReference callPage = new PageReference(
        '/' + newCase.Id + '/e?retURL=/' + accountId
      );
      callPage.setRedirect(true);
      return callPage;
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to create new case for configuration. Message:' +
          e.getMessage()
        )
      );
      return null;
    }
  }

  public PageReference sendAcctForm() {
    sendEmailToUser();
    return null;
  }

  private Blob getPDFasBlob() {
    // Getting the page as email does not work with cookies, so get/post here
    PageReference callPage = Page.NASFView;
    callPage.getParameters().put('aid', accountId);
    callPage.getParameters().put('view', 'pdf');
    callPage.getParameters().put('ids', getSelectedIds());

    Blob content;
    try {
      content = callPage.getContentAsPDF();
    } catch (VisualforceException e) {
      // This makes your unit tests work.
      content = Blob.valueOf('Unable to generate PDF');
    }
    return content;
  }

  private String getSelectedIds() {
    List<Id> listIds = new List<Id>(selectedGroupIds);
    String selIds = String.join(listIds, ',');
    return selIds;
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
    mail.setSenderDisplayName('Salesforce New Account Form');
    mail.setBccSender(false);
    mail.setUseSignature(false);
    mail.setSaveAsActivity(false);

    mail.setSubject('Account setup form: ' + selAccount.Name);
    mail.setHtmlBody(
      '<html><body>Please find attached a pdf version of the Account Setup Form for ' +
        accountId +
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
    return 'Teladoc NASF ' +
      selAccount.Name.replaceAll('[\\\\/:*?\'<>|]', '') +
      ' - ' +
      Datetime.now() +
      '.pdf';
  }

  private void sendEmailToUser() {
    sendEmailtoUser(getPDFasBlob());
  }

  public PageReference generatePDFPreview() {
    PageReference callPage = Page.NASFView;
    callPage.getParameters().put('aid', accountId);
    callPage.getParameters().put('view', 'pdf');
    callPage.setRedirect(true);
    return callPage;
  }

  public PageReference cancelForm() {
    PageReference callPage = Page.NASFGroupSelection;
    callPage.getParameters().put('aid', accountId);
    callPage.setRedirect(true);
    return callPage;
  }
}