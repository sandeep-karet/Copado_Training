public class G2LItemErrorReportEmail {
    public static void sendErrorReport(String muid) {
        // Query the error logs
        List<G2LItemLog__c> errorLogs = [
            SELECT G2LCRM_Item__r.Account_GUID__c,
            G2LCRM_Item__r.Name,
            G2LCRM_Item__r.Source_System_Name__c,
            G2LCRM_Item__r.Opp_GUId__c,
            G2LCRM_Item__r.Order_GUID__c,
            G2LCRM_Item__c,
            G2LCRM_Item__r.Processor__c,
            G2LCRM_Item__r.Action__c,
            G2LCRM_Item__r.Status__c,
            Module__c,
            Method__c,
            Parsing_Results__c
            FROM G2LItemLog__c
            WHERE MUID__c = :muid order by createdDate
        ];
        
        if (!errorLogs.isEmpty()) {          
            // Build the HTML body
            String htmlBody = '<html><head><style>' +
                'table { border-collapse: collapse; width: 100%; }' +
                'th, td { border: 1px solid #ddd; padding: 8px; }' +
                'th { font-weight: bold; background-color: #f2f2f2; }' +
                '.parsing-result { min-width: 200px; }'+
                '.headercss { font-weight: bold }'+
                '</style></head><body>';
            htmlBody += '<h2>G2LCRM Error Report</h2>';
            htmlBody += '<div class="headercss">Source System Name : '+ errorLogs[0].G2LCRM_Item__r.Source_System_Name__c +'<br/>MUID : '+muid + '<br/>Account GUID : '+ errorLogs[0].G2LCRM_Item__r.Account_GUID__c +' <br/>Opportunity GUID : '+  errorLogs[0].G2LCRM_Item__r.Opp_GUId__c+' <br/>Order GUID : '+ errorLogs[0].G2LCRM_Item__r.Order_GUID__c+'</div>';
            htmlBody += '<br/><table class="table table-striped">';
            htmlBody += '<thead><tr><th>G2LCRMItem Name</th><th>Processor</th><th>Action</th><th>Status</th><th>Module</th><th>Method</th><th class="parsing-result">Parsing Result</th></tr></thead>';
            htmlBody += '<tbody>';
            
            for (G2LItemLog__c log : errorLogs) {
                htmlBody += '<tr>';
                htmlBody += '<td>' + log.G2LCRM_Item__r.Name+ '</td>';
                htmlBody += '<td>' + log.G2LCRM_Item__r.Processor__c + '</td>';
                htmlBody += '<td>' + log.G2LCRM_Item__r.Action__c + '</td>';
                htmlBody += '<td>' + log.G2LCRM_Item__r.Status__c + '</td>';
                htmlBody += '<td>' + log.Module__c + '</td>';
                htmlBody += '<td>' + log.Method__c + '</td>';
                htmlBody += '<td class="parsing-result">' + log.Parsing_Results__c + '</td>';
                htmlBody += '</tr>';
            }
            
            htmlBody += '</tbody></table>';
            htmlBody += '</body></html>';
            
            // Create and send the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {Label.Support_Team_Email});
            email.setSubject('Error Report for G2LCRM MUID: ' + muid);
            email.setHtmlBody(htmlBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}