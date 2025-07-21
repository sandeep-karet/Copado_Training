/*
* ClassName: OpportunityPastDateAlerts 
* CreatedBy: Vineel Muppa
* Modified: Venu Peddu - Monthly email to SalesReps from Manager SCDEV-1155-05/12
***************************************************************
Revision History
***************************************************************

*/
global class OpportunityPastDateAlerts implements Database.Batchable<SOBJECT>, Schedulable {
  global Database.QueryLocator Start(Database.BatchableContext BC) {
    //return Database.getQueryLocator('Select Id,ManagerId,Manager.Email from User where IsActive = true and id=\'0057g000004vMZy\'');
    return Database.getQueryLocator(
      'Select Id,ManagerId,Manager.Email from User where IsActive = true'
    );
  }
  global void execute(SchedulableContext sc) {
    OpportunityPastDateAlerts OPA = new OpportunityPastDateAlerts();
    database.executebatch(OPA, 1);
  }
  global void Execute(Database.BatchableContext BC, List<User> listUsers) {
    Set<String> setOwnerIds = new Set<String>();
    Map<Id, User> mapUsers = new Map<Id, User>();
    for (User recUser : listUsers) {
      setOwnerIds.add(recUser.Id);
      mapUsers.put(recUser.Id, recUser);
    }
    Map<Id, List<Opportunity>> mapOpportunities = new Map<Id, List<Opportunity>>();
    Integer iCntDays1 = 0;
    Integer iCntDays2 = 0;
    for (Opportunity recOpp : [
      SELECT
        Id,
        Name,
        Description,
        Account.Name,
        StageName,
        Decision_Date__c,
        Net_ARR__c,
        Owner.Email,
        Owner.ManagerId,
        CloseDate
      FROM Opportunity
      WHERE
        OwnerId IN :setOwnerIds
        AND IsClosed = FALSE
        AND (Decision_Date__c < Today
        OR CloseDate < Today)
    ]) {
      iCntDays1 = (recOpp.Decision_Date__c != null
        ? recOpp.Decision_Date__c.daysBetween(Date.Today())
        : 0);
      iCntDays2 = (recOpp.CloseDate != null
        ? recOpp.CloseDate.daysBetween(Date.Today())
        : 0);
      if (Math.Mod(iCntDays1, 3) == 0 || Math.Mod(iCntDays2, 3) == 0) {
        List<Opportunity> listTemp = mapOpportunities.get(recOpp.OwnerId);
        if (listTemp == null) {
          listTemp = new List<Opportunity>();
          mapOpportunities.put(recOpp.OwnerId, listTemp);
        }
        listTemp.add(recOpp);
      }
    }

    List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
    String baseURL = system.URL.getOrgDomainUrl().toExternalForm();
    //Fetch Org-Wide Email Address
    List<OrgWideEmailAddress> lstEmailAddress = [
      SELECT Id, DisplayName
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'Robin Remmel'
      LIMIT 1
    ];

    for (Id ownerId : mapOpportunities.keyset()) {
      List<Opportunity> listOppData = mapOpportunities.get(ownerId);
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      List<String> toAddresses = new List<String>{ listOppData[0].Owner.Email };
      email.setToAddresses(toAddresses);
      List<String> ccAddresses = new List<String>();
      if (Label.Opportunity_Pas_Date_Alert_CC_Email != 'N/A') {
        ccAddresses.addAll(
          Label.Opportunity_Pas_Date_Alert_CC_Email.split(',')
        );
      }
      if (mapUsers.get(ownerId).ManagerId != null) {
        ccAddresses.add(mapUsers.get(ownerId).Manager.Email);
      }
      email.setCCAddresses(ccAddresses);
      if (lstEmailAddress.size() > 0)
        email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
      email.setSubject('Opportunity Past Date Alerts');
      String emailhtmlBody = 'Hello, <br/><br/> After review of the current USGH Pipeline, I have identified the following opportunities that require your attention. The Estimated Close Date that you have determined is now in the past. Please update the following opportunities as soon as possible. The suggested updates are:<br/><br/>1-Reset the Estimated Close date to a future date<br/><br/>2-Reset the Revenue Effective Date to reflect the "Go Live" date for the services(if not yet known, rule of thumb is to default to 30 days past the Estimated Close Date) <br/><br/>It is important that these dates are maintained as you progress through the selling process as this informs the business for implementation planning and forecasting. Opportunities not updated to reflect a future/ accurate date will automatically be "Closed Lost" when the Revenue Effective Date stays in the past and the Opportunity does not progress to the Contracting stage. <br/><br/>';
      emailhtmlBody += '<table border=\'1\' cellpadding=\'1\'><tr><th>Opportunity Name</th><th>Description</th><th>Account Name</th><th>Stage Name</th><th>Estimated ARR</th><th>Estimated CloseDate</th><th>Number of Days Past Close Date</th><th>Revenue Eff Date</th><th>Number of Days Past RED</th></tr>';
      for (Opportunity recOpp : listOppData) {
        emailhtmlBody +=
          '<tr><td>' +
          '<a href=' +
          baseURL +
          '/' +
          recOpp.Id +
          '>' +
          recOpp.Name +
          '</a>' +
          '</td><td>' +
          recOpp.Description +
          '</td><td>' +
          recOpp.Account.Name +
          '</td><td>' +
          recOpp.StageName +
          '</td><td>' +
          recOpp.Net_ARR__c +
          '</td><td>' +
          (recOpp.Decision_Date__c != null
            ? recOpp.Decision_Date__c.format()
            : '') +
          '</td><td>' +
          (recOpp.Decision_Date__c != null
            ? String.valueof(recOpp.Decision_Date__c.daysBetween(Date.Today()))
            : '') +
          '</td><td>' +
          (recOpp.CloseDate != null ? recOpp.CloseDate.format() : '') +
          '</td><td>' +
          (recOpp.CloseDate != null
            ? String.valueof(recOpp.CloseDate.daysBetween(Date.Today()))
            : '') +
          '</td>';
      }
      emailhtmlBody += '</table><br/><br/>';
      emailhtmlBody += 'If you need assistance, please consult with your manager, or contact me if you need one-on-one help. If you are experiencing technical issues with Salesforce, please email SalesforceSupport@teladochealth.com <br/><br/><br/>Thank you, <br/><br/> <b> Robin Remmel</b><br/>Sales Operations Analyst <br/>Teladoc Health, Inc.  <br/> <br/><b> C: </b>(262) 749-4381 ';
      email.setHtmlBody(emailhtmlBody);
      listEmails.add(email);
    }
    if (listEmails != null && listEmails.size() > 0)
      if (!Test.isRunningTest()) {
        Messaging.sendEmail(listEmails);
      }
    //Added by Venu for SCDEV-1155
    if (Date.today().day() == 21 || Test.isRunningTest()) {
      Date date180 = date.today().addMonths(3);
      List<Opportunity> opplist = new List<opportunity>(
        [
          SELECT
            id,
            StageName,
            Sub_Channel__c,
            owner.email,
            owner.Manager.email,
            owner.id,
            owner.Manager.id,
            owner.UserRole.name,
            owner.Manager.UserRole.name
          FROM opportunity
          WHERE
            OwnerId IN :setOwnerIds
            AND (((StageName = 'Review/Negotiation'
            OR StageName = 'Contracting')
            AND Sub_Channel__c != 'Canada'
            AND Sub_Channel__c != 'DTE - Client Management'
            AND Sub_Channel__c != 'Employer - Downmarket'
            AND Sub_Channel__c != 'HHS'
            AND Sub_Channel__c != 'HSG - TPA/Reseller'
            AND Sub_Channel__c != 'Undefined')
            OR (Sub_Channel__c = 'Employer - Downmarket'
            AND OneTime_Net_Total_With_PG__c > 100000
            AND (StageName = 'Review/Negotiation'
            OR StageName = 'Contracting')))
            AND CloseDate >= TODAY
            AND CloseDate < :date180
        ]
      );
      if (opplist.size() > 0)
        sendNotification(opplist);
    }
  }
  global void finish(Database.BatchableContext BC) {
    //do nothing
  }
  public static void sendNotification(List<Opportunity> opplist) {
    if (opplist.size() > 0) {
      List<string> emailSet = new List<string>();
      List<Messaging.SingleEmailMessage> messagelist = new List<Messaging.SingleEmailMessage>();
      EmailTemplate emailTemplate = [
        SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
        FROM EmailTemplate
        WHERE DeveloperName = 'month_s_forecast_action_needed1'
      ];
      //Get templete id for set the templete.
      List<OrgWideEmailAddress> lstEmailAddress = [
        SELECT Id, DisplayName
        FROM OrgWideEmailAddress
        WHERE DisplayName = 'Robin Remmel'
        LIMIT 1
      ];

      for (opportunity opp : opplist) {
        if (
          !emailSet.contains(opp.owner.id) &&
          (opp.owner.UserRole == null ||
          (opp.owner.UserRole != null &&
          !opp.owner.UserRole.name.Contains('Canada')))
        ) {
          Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(
            emailTemplate.id,
            null,
            null
          );
          emailSet.add(opp.owner.id);
          message.toAddresses = new List<string>{ opp.owner.id };
          if (lstEmailAddress.size() > 0)
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);

          if (
            opp.owner.Manager != null &&
            (opp.owner.Manager.UserRole == null ||
            (opp.owner.Manager.UserRole != null &&
            !opp.owner.Manager.UserRole.name.Contains('Canada')))
          )
            message.ccaddresses = new List<string>{ opp.owner.Manager.id };

          message.setReplyTo('no-reply@company.com');
          message.setUseSignature(false);
          message.setBccSender(false);
          message.setSaveAsActivity(false);
          message.setTemplateID(emailTemplate.Id);

          messagelist.add(message);
        }
      }

      if (messagelist.size() > 0) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messagelist);

        if (results[0].success) {
          System.debug('The email was sent successfully.');
        } else {
          System.debug(
            'The email failed to send: ' + results[0].errors[0].message
          );
        }
      }
    }
  }
}