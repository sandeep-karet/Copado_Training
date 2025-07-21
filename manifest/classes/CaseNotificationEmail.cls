global class CaseNotificationEmail implements Schedulable {
  global void execute(SchedulableContext SC) {
    sendCase();
  }
  public void sendCase() {
    List<String> omitList = new List<String>{
      'Admin Config User Queue',
      'William Uhrlaub',
      'Monteya Mitchell',
      'Brittney Collins',
      'Robin Durbin',
      'Evelyn Schultheis'
    };
    List<Case> caseList = [
      SELECT
        Id,
        OwnerId,
        Owner.Name,
        Owner.Email,
        CaseNumber,
        Account.Name,
        Type,
        Status,
        Priority,
        Due_Date__c
      FROM Case
      WHERE Status = 'Not Started' AND owner.name NOT IN :omitList
    ];
    Map<String, List<Case>> caseMap = new Map<String, List<Case>>();
    for (Case c : caseList) {
      if (caseMap.ContainsKey(c.Owner.Email)) {
        caseMap.get(c.Owner.Email).add(c);
      } else {
        List<Case> ownerCaseList = new List<Case>();
        ownercaseList.add(c);
        caseMap.put(c.Owner.Email, ownerCaseList);
      }
    }
    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    for (String owner : caseMap.keyset()) {
      String header =
        'Record Link,' +
        'Case Owner,' +
        'Case Number,' +
        'Account Name,' +
        'Case Action,' +
        'Status,' +
        'Priority,' +
        'Due Date' +
        '\n';
      String finalstr = header;
      for (Case c : caseMap.get(owner)) {
        String acctName = c.Account.Name == null ? '' : c.Account.Name;
        string recordString =
          URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          c.Id +
          ',' +
          c.Owner.Name +
          ',' +
          c.CaseNumber +
          ',' +
          acctName +
          ',' +
          c.Type +
          ',' +
          c.Status +
          ',' +
          c.Priority +
          ',' +
          c.Due_Date__c +
          '\n';
        finalstr = finalstr + recordString;
      }

      Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
      Blob csvBlob = blob.valueOf(finalstr);
      String csvName = 'Open Cases.csv';
      csvAttachment.setFileName(csvName);
      csvAttachment.setBody(csvBlob);
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ owner };
      String subject = '[OPEN CASE REMINDER] Your Open Cases';
      email.setSubject(subject);
      email.setToAddresses(toAddresses);
      email.setPlainTextBody(
        'Please see the open cases in the attachment. Thank you.'
      );
      email.setFileAttachments(
        new List<Messaging.EmailFileAttachment>{ csvAttachment }
      );
      lstMails.add(email);
    }
    if (!Test.isRunningTest()) {
      Messaging.sendEmail(lstMails);
    }
  }
}