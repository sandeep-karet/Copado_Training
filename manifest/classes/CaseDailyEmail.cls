global class CaseDailyEmail implements Schedulable {
  global void execute(SchedulableContext SC) {
    sendCase();
  }
  public void sendCase() {
    List<String> idList = new List<String>();
    Group gp = [
      SELECT (SELECT UserOrGroupId FROM GroupMembers)
      FROM Group
      WHERE Name = 'Admin Config' LIMIT 1
    ];
    for (GroupMember gm : gp.GroupMembers) {
      idList.add(gm.UserOrGroupId);
    }
    List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
    List<String> emailList = new List<String>();
    for (User u : userList) {
      emailList.add(u.Email);
    }
    List<Case> caseList = [
      SELECT
        Id,
        CreatedbyId,
        OwnerId,
        Previous_Owner__c,
        Owner.Name,
        Owner.Email,
        CaseNumber,
        Account.Name,
        Type,
        Status,
        Priority,
        Due_Date__c
      FROM Case
      WHERE Status != 'Completed'
    ];
    List<Case> caseEmailList = new List<Case>();
    for (Case c : caseList) {
      if (
        c.CreatedbyId == c.OwnerId &&
        c.OwnerId != c.Previous_Owner__c &&
        c.Previous_Owner__c != null
      ) {
        caseEmailList.add(c);
      }
    }
    if (!caseEmailList.isEmpty()) {
      Messaging.SingleEmailMessage mails = new Messaging.SingleEmailMessage();
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
      for (Case c : caseEmailList) {
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
      String csvName = 'Cases Assigned Back to Creator.csv';
      csvAttachment.setFileName(csvName);
      csvAttachment.setBody(csvBlob);
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String[] toAddresses = emailList;
      String subject = '[CASE NOTIFICATION] Cases Assigned Back to Creator';
      email.setSubject(subject);
      email.setToAddresses(toAddresses);
      email.setPlainTextBody(
        'Please see the open cases in the attachment. Thank you.'
      );
      email.setFileAttachments(
        new List<Messaging.EmailFileAttachment>{ csvAttachment }
      );
      if (!Test.isRunningTest()) {
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
      }
    }
  }
}