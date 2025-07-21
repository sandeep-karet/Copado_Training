public with sharing class PipelineNotification implements Schedulable {
  public void execute(System.SchedulableContext sc) {
    //Date nextMonday = Date.today().toStartOfWeek().addDays(1);
    Date dueDate = Date.today() + 1;
    //DateTime nextMondayTime = DateTime.newInstance(nextMonday,Time.newInstance(24,0,0,0)); // noon GMT = 8am EST

    List<User> usersToNotify = [
      SELECT Id, Email
      FROM User
      WHERE Send_Pipeline_Notifications__c = TRUE
    ];
    if (usersToNotify.size() > 0) {
      OrgWideEmailAddress owa = [
        SELECT Id, DisplayName, Address
        FROM OrgWideEmailAddress
        LIMIT 1
      ];
      EmailTemplate template = [
        SELECT Id, Name
        FROM EmailTemplate
        WHERE developername = 'Weekly_Pipeline_Report_Email'
        LIMIT 1
      ];

      List<Task> tasks = new List<Task>();
      List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
      for (User u : usersToNotify) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(template.Id);
        mail.setTargetObjectId(u.Id);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(owa.Id);
        System.debug('Sending: ' + mail);
        allmsg.add(mail);

        Task t = new Task();
        t.OwnerId = u.Id;
        t.Subject = 'Review Your Open Pipeline.';
        t.Priority = 'High';
        t.Status = 'Open';
        t.Description = 'Please review your dashboard and complete the task.';

        t.ActivityDate = dueDate;
        t.Type = 'Weekly Pipeline Review';

        tasks.add(t);
      }

      Messaging.SendEmailResult[] result = Messaging.sendEmail(allmsg, false);
      System.debug('Mail sent, result: ' + result);
      insert tasks;
    }
  }
}