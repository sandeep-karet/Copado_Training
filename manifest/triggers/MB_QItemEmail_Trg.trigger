trigger MB_QItemEmail_Trg on Q_Item__c (after update) {    
    public class responseWrapper {
            public Map<String, String> parsing_errors;
            public Map<Id, Q_Item_Exception__c> dml_errors;
        }
    if (Message_Bus_Toggle__c.getOrgDefaults().Enable_MB__c && Message_Bus_Toggle__c.getOrgDefaults().Error_Email_Enable__c) {      
        Dev_Settings__c DS = Dev_Settings__c.getInstance(UserInfo.getUserId());      
        if (!DS.Disable_Triggers__c) {  
            List<String> qIdList = new List<String>();
            for (Q_Item__c qItem: Trigger.New) {
                if (qItem.Processed__c && qItem.Status__c == 'Processed with Error' && qItem.isSync__c) {
                    qIdList.add(qItem.Id);
                }
            }
            
            List<Q_Item__c> qitemList = [SELECT Id, Result__c, Createdby.Email, Payload__c FROM Q_Item__c WHERE Id IN: qIdList];
            for (Q_Item__c q: qitemList) {
                QItemEmailParser qitemp = new QItemEmailParser();
                qitemp.Parse(q.Payload__c); 
                String msg = '';
                String recordUrl;
                If(!Test.isRunningTest()) {
                    recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + qitemp.QItemOpp.Opp.Id;
                    responseWrapper errorWrapper = (responseWrapper)JSON.deserialize(q.Result__c, responseWrapper.class);   
                    for (Q_Item_Exception__c dml: errorWrapper.dml_errors.values()) {
                        msg = msg + dml.Short_Desc__c + ': ' + dml.Full_Desc__c + '\n'; 
                    }
                    for (String parse: errorWrapper.parsing_errors.values()) {
                        msg = msg + parse + '\n' ;
                    }
                    
                } else {
                    Opportunity opp = new Opportunity(Name = 'testing');	
                    Opportunity_Parser oppParser = new Opportunity_Parser();
                    qitemp.QItemOpp = oppParser;
                    //qitemp.QItemOpp.Opp = opp;
                }       
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {q.CreatedBy.Email};
                    mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject('[ACTION REQUIRED]: Livongo Records Transfer Error');
                mail.setHtmlBody('<p><b>The payload record you tried to transfer to Livongo Org failed. Please use the following info to make correction.</b></p>\n <p><b>Opportunity:</b> ' + 
                                 '<a href=' + recordUrl + '>' + qitemp.QItemOpp.Opp.Name +'</a> \n <p><b>Error for the payload:</b></p>\n' + '<p>' + msg + 
                                 '</p> \n <p></p> \n <p>Please reach out to Salesforce Support if you need additional help.</p> \n <p>Thank you.<p>');
                If(!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
}