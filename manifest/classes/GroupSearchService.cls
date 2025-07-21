@RestResource(urlMapping='/GroupSearchService/*')
global with sharing class GroupSearchService {
  //EEM: Uses NASF Controller for responsive group-searches
  //Web service to filter Group list results - used by the NASFGroupSelection page
  @HttpPost
  global static GroupInfo getGroupInfo(
    Id accountId,
    String searchString,
    String statusString
  ) {
    GroupInfo gi = new GroupInfo();
    //TODO: Make sure this is right, use code, confirm there will always be one GM
    String grpquery = 'SELECT Id, Name, Name__c, Group_Number__c, Status__c, LastModifiedBy.Name, LastModifiedDate, CreatedDate, ';
    // Get the first (should be only) General Medical group value for fees
    grpquery += '(select Id,Name,Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c FROM Plan_Specific_Fees_By_Product__r where Product__c = \'General Medical\' LIMIT 1) ';
    grpquery +=
      'FROM Mbr_Group__c WHERE Client_Account__c = \'' +
      accountId +
      '\' ';

    String grpnumber = searchString.replaceAll('\\s+', '');
    set<string> grpnumbers = new Set<string>(grpnumber.split(','));
    //grpnumbers.add('');

    // Filter by searchString
    if (searchString != null && searchString.length() >= 2) {
      grpquery +=
        ' and ( LastModifiedBy.Name like \'%' +
        searchString +
        '%\'' +
        ' or name__c like \'%' +
        searchString +
        '%\')';
    }

    // Filter by status
    if (!String.isBlank(statusString)) {
      grpquery += ' and Status__c = \'' + statusString + '\' ';
    }

    grpquery += ' order by LastModifiedDate desc limit 100';
    if (accountId != null) {
      gi.grps = Database.query(grpquery);
    }
    return gi;
  }

  global class GroupInfo {
    global List<Mbr_Group__c> grps { get; set; }
  }
}