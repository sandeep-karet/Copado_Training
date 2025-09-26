public class JiraIntegrationTest {
    public static void testJiraConnection() {
        HttpRequest req = new HttpRequest();
        String endpoint = 'callout:Jira_Integration_new/rest/api/3/myself';

        // Build request
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        // Debug request details
        System.debug('--- Jira Integration Test Started ---');
        System.debug('Endpoint: ' + endpoint);
        System.debug('HTTP Method: ' + req.getMethod());
        System.debug('Headers: ' + req.getHeader('Accept'));

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Body: ' + res.getBody());

            if(res.getStatusCode() == 200) {
                System.debug('🎉 Hey buddy, it’s success ✅ – Jira Named Credential works!');
            } else {
                System.debug('⚠️ Something went wrong. Please check the response above.');
            }
        } catch (Exception e) {
            System.debug('❌ Exception occurred: ' + e.getMessage());
        }

        System.debug('--- Jira Integration Test Finished ---');
    }
}