public with sharing class NASFGroupSelectController {
  //EEM: Group selection.  Formerly AccountController.

  public Id accountId { get; private set; }
  public String searchString { get; set; }
  public Boolean allChecked { get; set; }
  public List<GroupWrapper> allGroups { get; set; }
  public Mbr_Group__c filterGroup { get; set; }
  public Set<Id> selectedGroupIds { get; set; }
  public Boolean has100 { get; set; }
  public Boolean showGroupSelect { get; set; }

  private Account selAccount { get; set; }

  public void clearStatus() {
    filterGroup.Status__c = '';
  }

  // Controller for Group Selection
  public NASFGroupSelectController() {
    // First time setup
    filterGroup = new Mbr_Group__c();
    // override status default (Pending)

    PageReference page = System.currentPageReference();
    accountId = page.getParameters().get('aid');
    showGroupSelect = true;
    has100 = false;
    selAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId];

    //NASFHelper object is a single object containing all info for a new account.
    //It's designed for reuse and external web service calls
    NASFHelper.NASFInfo rawNASFInfo = NASFHelper.getNasfInfoByAccountId(
      accountId,
      new Set<Id>()
    );
    if (rawNASFInfo.errors != null) {
      System.debug('ALL ERRORS: ' + rawNASFInfo.errors);
      for (NASFHelper.valError e : rawNASFInfo.errors) {
        System.debug('Validation Error: ' + e.error_msg);
        if (e.field_name == null) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Missing Information: ' + e.error_msg
            )
          );
        } else {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Missing Required Account Value: ' +
                e.field_name +
                ' [' +
                e.field_label +
                ']'
            )
          );
        }
      }
      showGroupSelect = false;
    } else {
      // Setup for group selection
      allGroups = new List<GroupWrapper>();
      allGroups = getGroups(accountId, '');
      has100 = (allGroups.size() >= 100);
      allChecked = false;
    }
  }

  // Refresh groups from Web Service based on filter settings
  private List<GroupWrapper> getGroups(String accountID, String searchString) {
    //allGroups.clear();
    System.debug('getGroups(): ' + allGroups.size());
    List<GroupWrapper> grpWrappers = new List<GroupWrapper>();
    GroupSearchService.GroupInfo gi = GroupSearchService.getGroupInfo(
      accountID,
      searchString,
      filterGroup.Status__c
    );

    for (Mbr_Group__c groups : gi.grps) {
      grpWrappers.add(new GroupWrapper(groups));
    }
    return grpWrappers;
  }

  private String getSelectedIds() {
    selectedGroupIds = new Set<Id>();
    for (GroupWrapper gw : allGroups) {
      if (gw.selected) {
        selectedGroupIds.add(gw.grp.Id);
      }
    }
    List<Id> listIds = new List<Id>(selectedGroupIds);
    String selIds = String.join(listIds, ',');
    return selIds;
  }

  public void search() {
    allGroups = new List<GroupWrapper>();
    allChecked = false;
    System.debug('Search(): ' + allGroups.size());
    for (
      Mbr_Group__c groups : GroupSearchService.getGroupInfo(
          accountId,
          searchString,
          filterGroup.Status__c
        )
        .grps
    ) {
      allGroups.add(new GroupWrapper(groups));
    }
    has100 = (allGroups.size() >= 100);
  }

  public PageReference cancelAcctForm() {
    PageReference callPage = new PageReference('/' + accountId)
      .setRedirect(true);
    return callPage;
  }

  public PageReference CheckAll() {
    for (GroupWrapper groups : allGroups) {
      groups.selected = allChecked;
    }
    return null;
  }

  public PageReference generatePreview() {
    //EEM: Passes account id and cookie
    String selIds = getSelectedIds();
    // selected IDs expire in 8 hours
    PageReference callPage = Page.NASFPreview;
    callPage.getParameters().put('aid', accountId);
    Cookie cook = new Cookie('g:' + accountId, selIds, null, 28800, true);
    callPage.setCookies(new List<Cookie>{ cook });
    callPage.setRedirect(true);
    return callPage;
  }

  // Store all groups, selector property, and logic for rendering here.
  public class GroupWrapper {
    public Mbr_Group__c grp { get; set; }
    public Boolean selected { get; set; }
    public String mbrFee { get; set; }
    public String planFee { get; set; }
    public String feeName { get; set; }

    public GroupWrapper(Mbr_Group__c g) {
      grp = g;
      selected = false;
      feeName = g.Name;
      mbrFee = ' ';
      planFee = ' ';
      Plan_Specific_Fees__c firstPS = GetFirstPSF(g);
      if (firstPS != null) {
        if (firstPS.Consult_Fee_Mbr_Pd__c != null) {
          mbrFee = '$' + String.valueOf(firstPS.Consult_Fee_Mbr_Pd__c);
        }
        if (firstPS.Consult_Fee_Plan_Pd__c != null) {
          planFee = '$' + String.valueOf(firstPS.Consult_Fee_Plan_Pd__c);
        }
      }
    }

    // Pulls first product from each group - taken from subquery
    private Plan_Specific_Fees__c GetFirstPSF(Mbr_Group__c grp) {
      if (grp != null && grp.Plan_Specific_Fees_By_Product__r.size() > 0) {
        return grp.Plan_Specific_Fees_By_Product__r[0];
      } else {
        return null;
      }
    }
  }
}