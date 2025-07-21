@RestResource(urlMapping='/F1BspInfo/v1/*')
global class F1BspInfo {
  @HttpGet
  global static String fetchStatus() {
    RestRequest request = RestContext.request;
    // grab the caseId from the end of the URL
    String GUID = request.requestURI.substring(
      request.requestURI.lastIndexOf('/') + 1
    );
    Map<String, List<SObject>> infoNeeded = new Map<String, List<SObject>>();
    // 28B90FAF-3315-D249-299D-7BDE3EE7AD57
    List<Account> bspAccounts = [
      SELECT
        id,
        Report_Recipient_Emails__c,
        Members__c,
        Total_US_Employees_Benefits_Enrolled__c,
        Special_Instructions_for_Implementatio__c
      FROM Account
      WHERE GUID__c = :GUID
    ];
    Set<String> tmpEmails = new Set<String>();
    if (bspAccounts.size() > 0) {
      infoNeeded.put('BSP', bspAccounts);
      if (bspAccounts[0].Report_Recipient_Emails__c != null) {
        List<String> reportingEmails = bspAccounts[0]
          .Report_Recipient_Emails__c.Split(',');

        for (String tmpEmail : reportingEmails) {
          tmpEmails.add(tmpEmail.trim());
        }
      }
      if (tmpEmails.size() > 0) {
        List<Contact> reportingContacts = [
          SELECT id, FirstName, LastName, Email, Phone
          FROM Contact
          WHERE email IN :tmpEmails
        ];
        if (reportingContacts.size() > 0)
          infoNeeded.put('Reporting', reportingContacts);
      }
      List<Contact> bspContacts = [
        SELECT id, FirstName, LastName, Email, Phone
        FROM contact
        WHERE Account.GUID__C = :GUID AND Marketing_Site_User__c = TRUE
      ];
      infoNeeded.put('Marketing', bspContacts);
      List<Mbr_Group_Role__c> allGroups = [
        SELECT
          id,
          name,
          mbr_group__r.guid__c,
          mbr_group__r.WK_Template__c,
          Source_Account__r.guid__c,
          Source_Account__r.name,
          mbr_group__r.client_account__r.GUID__c,
          mbr_group__r.client_account__r.name
        FROM Mbr_Group_Role__c
        WHERE
          Role_Type__c = 'Benefit Sponsor'
          AND Source_Account__r.guid__c = :GUID
      ];
      infoNeeded.put('Groups', allGroups);
    }

    return JSON.serializePretty(infoNeeded);
  }
}