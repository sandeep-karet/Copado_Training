/*
* ClassName: OpportunityPastDateAlerts 
* CreatedBy: Vineel Muppa
* Modified: Venu Peddu - Monthly email to SalesReps from Manager SCDEV-1155-05/12
***************************************************************
Revision History
***************************************************************

*/
global class OpportunityPastDateAlerts  implements Database.Batchable<SOBJECT>,Schedulable
{
    global  Database.QueryLocator Start(Database.BatchableContext BC)
    {
        //return Database.getQueryLocator('Select Id,ManagerId,Manager.Email from User where IsActive = true and id=\'0057g000004vMZy\'');
        return Database.getQueryLocator('Select Id,ManagerId,Manager.Email from User where IsActive = true');
    }
    global void execute(SchedulableContext sc){
        OpportunityPastDateAlerts OPA = new OpportunityPastDateAlerts();
        database.executebatch(OPA,1);
    }
    global void Execute(Database.BatchableContext BC,List<User> listUsers)
    {
        List<Report> reportList = [Select Id,Name from Report where DeveloperName='Late_Stage_Deals_By_Owner_zLN' limit 1];
        Id reportId;
        string reportName;
        for(Report rep:reportList){
            reportId = rep.Id;
            reportName = rep.Name;
        }
        Set<String> setOwnerIds=new Set<String>();
        Map<Id,User> mapUsers=new Map<Id,User>();
        for(User recUser:listUsers)
        {
            setOwnerIds.add(recUser.Id);
            mapUsers.put(recUser.Id,recUser);
        }        
        Map<Id,List<Opportunity>> mapOpportunities=new Map<Id,List<Opportunity>>();
        Integer iCntDays1 =0;
        
        for(Opportunity recOpp:[Select Id,Name,Description,Account.Name,StageName,L2O_Net_ARR__c,Owner.Email,Owner.ManagerId,CloseDate from Opportunity where (OwnerId in:setOwnerIds and IsClosed=false and CloseDate<Today)])
        {
            
            iCntDays1 = (recOpp.CloseDate!=null?recOpp.CloseDate.daysBetween(Date.Today()):0);
            if(Math.Mod(iCntDays1,3)== 0)
            {
                List<Opportunity> listTemp=mapOpportunities.get(recOpp.OwnerId);
                if(listTemp == null)
                {
                    listTemp=new List<Opportunity>();
                    mapOpportunities.put(recOpp.OwnerId,listTemp);
                }
                listTemp.add(recOpp);
            }
        }
        
        List<Messaging.SingleEmailMessage> listEmails=new List<Messaging.SingleEmailMessage>();
        String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();
        //Fetch Org-Wide Email Address  
        List<OrgWideEmailAddress> lstEmailAddress=[select Id,DisplayName from OrgWideEmailAddress Where DisplayName ='Robin Remmel' LIMIT 1];
        
        for(Id ownerId:mapOpportunities.keyset())
        {
            List<Opportunity> listOppData=mapOpportunities.get(ownerId);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>{listOppData[0].Owner.Email};
                email.setToAddresses(toAddresses); 
            List<String> ccAddresses = new List<String>();
            if(Label.Opportunity_Pas_Date_Alert_CC_Email!='N/A')
            {
                ccAddresses.addAll(Label.Opportunity_Pas_Date_Alert_CC_Email.split(','));
            }
            if(mapUsers.get(ownerId).ManagerId !=null)
            {
                ccAddresses.add(mapUsers.get(ownerId).Manager.Email);
            }
            email.setCCAddresses(ccAddresses); 
            if(lstEmailAddress.size() > 0)    
                email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            email.setSubject('Opportunity Past Date Alerts');
            String emailhtmlBody='Hello, <br/><br/> After review of the current USGH Pipeline, I have identified the following opportunities that require your attention. The Estimated Close Date that you have determined is now in the past. Please update the following opportunities as soon as possible. The suggested updates are:<br/><br/>1-Reset the Estimated Close date to a future date<br/><br/>2-Reset the Revenue Effective Date to reflect the "Go Live" date for the services(if not yet known, rule of thumb is to default to 30 days past the Estimated Close Date) <br/><br/>It is important that these dates are maintained as you progress through the selling process as this informs the business for implementation planning and forecasting. Opportunities not updated to reflect a future/ accurate date will automatically be "Closed Lost" when the Revenue Effective Date stays in the past and the Opportunity does not progress to the Contracting stage. <br/><br/>' ;
            emailhtmlBody+='<table border=\'1\' cellpadding=\'1\'><tr><th>Opportunity Name</th><th>Description</th><th>Account Name</th><th>Stage Name</th><th>Estimated ARR</th><th>Estimated CloseDate</th><th>Number of Days Past Close Date</th><th>Revenue Eff Date</th><th>Number of Days Past RED</th></tr>';
            for(Opportunity recOpp:listOppData)
            {
                emailhtmlBody+='<tr><td>'+'<a href='+baseURL+'/'+recOpp.Id+'>'+ recOpp.Name+'</a>'+'</td><td>'+recOpp.Description+'</td><td>'+recOpp.Account.Name+'</td><td>'+recOpp.StageName+'</td><td>'+recOpp.L2O_Net_ARR__c+'</td><td>'+(recOpp.CloseDate!=null?recOpp.CloseDate.format():'')+'</td><td>'+(recOpp.CloseDate!=null?String.valueof(recOpp.CloseDate.daysBetween(Date.Today())):'')+'</td><td>'+(recOpp.CloseDate!=null?recOpp.CloseDate.format():'')+'</td><td>'+(recOpp.CloseDate!=null?String.valueof(recOpp.CloseDate.daysBetween(Date.Today())):'')+'</td>';
            }
            emailhtmlBody+='</table><br/><br/>';
            emailhtmlBody+='If you need assistance, please consult with your manager, or contact me if you need one-on-one help. If you are experiencing technical issues with Salesforce, please email SalesforceSupport@teladochealth.com <br/>Report Link - <a href='+baseURL+'/'+reportId+'>'+reportName+'</a><br/><br/><br/><br/>Thank you, <br/><br/> <b> Robin Remmel</b><br/>Sales Operations Analyst <br/>Teladoc Health, Inc.  <br/> <br/><b> C: </b>(262) 749-4381 ';
            email.setHtmlBody(emailhtmlBody);
            listEmails.add(email);
        }
        if(listEmails!=null && listEmails.size()>0){
            Messaging.sendEmail(listEmails); 
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        //do nothing
    }
    
}