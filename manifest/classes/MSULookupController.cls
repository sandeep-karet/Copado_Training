public with sharing class MSULookupController {
  // Calculated MSUs for display on the page
  public transient List<MSUWrapper> calcMSUs { get; set; }

  // Group search properties
  public String searchGroupName { get; set; }
  public String selGroupId { get; set; }
  public Mbr_Group__c selGroup { get; set; }
  public transient List<Mbr_Group__c> groupSearchResults { get; set; }

  // Contact search properties
  public String searchContactName { get; set; }
  public Contact selContact { get; set; }
  public transient List<Contact> contactSearchResults { get; set; }
  public String selContactId { get; set; }

  // Rendering hints
  public Boolean showCharMin { get; set; }
  public Boolean showGroupResults { get; set; }
  public Boolean showContactResults { get; set; }
  public Boolean showNoResults { get; set; }
  public Boolean showMSUs { get; set; }
  public Boolean showSelectedGroup { get; set; }
  public Boolean showSelectedContact { get; set; }
  public Boolean showSearch { get; set; }

  public MSULookupController() {
    System.debug('Initializing msu controller.');

    // Set default rendering
    selGroup = null;
    showCharMin = true;
    showGroupResults = false;
    showContactResults = false;
    showNoResults = false;
    showMSUs = false;
    showSelectedGroup = false;
    showSelectedContact = false;
    showSearch = true;

    // Load odd ducks and keep them cached for the search.
    // Cache of odd duck Ids will be refreshed every time a search is started
    try {
      Id conId = ApexPages.currentPage().getParameters().get('cid');
      if (conId != null) {
        // Make sure contact is valid.
        Contact c = [
          SELECT
            Id,
            Contact_Status__c,
            Marketing_Site_User__c,
            Marketing_Site_Username__c,
            Account.Name
          FROM Contact
          WHERE Id = :conId
        ];
        System.debug('Contact set: ' + c);
        if (
          c != null &&
          c.Contact_Status__c == 'ACTIVE' &&
          c.Marketing_Site_User__c &&
          c.Marketing_Site_Username__c != null &&
          c.Marketing_Site_Username__c.trim() != ''
        ) {
          // A contact has been passed in the url, and it's a valid marketing user, so this is a popup.  Go straight to the contact.
          // It may be a good idea to hide the search here since a specific contact was requested.
          selContactId = conId;
          contactSelected();
          System.debug('contact set:' + selContactId);
          showSearch = true;
        } else {
          System.debug('Contact does not meet criteria.');
          if (c == null) {
            ApexPages.addMessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Contact not found.'
              )
            );
            showSearch = false;
          } else {
            if (!c.Marketing_Site_User__c) {
              ApexPages.addMessage(
                new ApexPages.Message(
                  ApexPages.Severity.ERROR,
                  'Contact is not a marketing site user.'
                )
              );
              showSearch = false;
            } else if (c.Contact_Status__c != 'Active') {
              ApexPages.addMessage(
                new ApexPages.Message(
                  ApexPages.Severity.ERROR,
                  'Contact is not active.'
                )
              );
              showSearch = false;
            }
          }
        }
      } else {
        // A group has been passed in the url, so this is a popup.  Go straight to the group.
        // It may be a good idea to hide the search here since a specific group was requested.
        Id grpId = ApexPages.currentPage().getParameters().get('gid');
        if (grpId != null) {
          selGroupId = grpId;
          groupSelected();
        } else {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Unable to display page.  MSU Lookup can only be accessed from a Group or Contact record.'
            )
          );
          showSearch = false;
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to display page.  MSU Lookup can only be accessed from a Group or Contact record.'
        )
      );
      showSearch = false;
      // URL parameters aren't valid so don't pre-select anything
      selContactId = null;
      selGroupId = null;
    }
  }

  // Filter group results
  public PageReference filterGroups() {
    // reset results
    calcResultsByContact();
    //now filter...
    List<MSUWrapper> filteredMSUs = new List<MSUWrapper>();
    for (MSUWrapper mw : calcMSUs) {
      if (mw.msu.Mbr_Group__r.Name.containsIgnoreCase(searchGroupName)) {
        filteredMSUs.add(mw);
      }
    }
    calcMSUs = filteredMSUs;
    showNoResults = (calcMSUs.size() == 0);
    return null;
  }

  // Filter contact results
  public PageReference filterContacts() {
    // reset results
    calcResultsByGroup();
    //now filter...
    List<MSUWrapper> filteredMSUs = new List<MSUWrapper>();
    for (MSUWrapper mw : calcMSUs) {
      if (mw.msu.Contact__r.Name.containsIgnoreCase(searchContactName)) {
        filteredMSUs.add(mw);
      }
    }
    calcMSUs = filteredMSUs;
    showNoResults = (calcMSUs.size() == 0);
    return null;
  }

  // A group was selected, calc MSUs, update rendering and odd duck cache
  public PageReference groupSelected() {
    showMSUs = true;
    showGroupResults = false;
    showCharMin = false;
    showNoResults = false;
    showSelectedGroup = true;
    showSelectedContact = false;
    calcResultsByGroup();
    //cacheOddDuckContacts();
    return null;
  }

  // A contact was selected, calc MSUs, update rendering and odd duck cache
  public PageReference contactSelected() {
    showMSUs = true;
    showContactResults = false;
    showCharMin = false;
    showNoResults = false;
    showSelectedGroup = false;
    showSelectedContact = true;
    calcResultsByContact();
    //cacheOddDuckContacts();
    return null;
  }

  // This is the MSU calculation given a contact.
  // 1) Find relevant odd ducks
  // 2) Calculate MSUs
  public void calcResultsByContact() {
    System.debug('selconid:' + selContactId);
    selContact = [
      SELECT Id, Name, AccountId, Account.Name
      FROM Contact
      WHERE Id = :selContactId
    ];
    calcMSUs = new List<MSUWrapper>();
    // Start with odd ducks
    List<Mkt_Site_User__c> oddDucks = [
      SELECT
        Id,
        Name,
        Contact__r.Name,
        Mbr_Group__r.Name,
        Contact__c,
        Mbr_Group__c,
        Mbr_Group__r.Status__c,
        Contact__r.AccountId,
        Contact__r.Account.Name,
        Mbr_Group__r.Group_Number__c,
        Mbr_Group__r.Client_Account__r.Name,
        Mbr_Group__r.Client_Account__c,
        Mbr_Group__r.Name__c
      FROM Mkt_Site_User__c
      WHERE
        Contact__c = :selContact.Id
        AND Contact__r.Contact_Status__c = 'ACTIVE'
        AND Contact__r.Marketing_Site_User__c = TRUE
        AND Contact__r.Marketing_Site_Username__c != ''
        AND Mbr_Group__r.Status__c = 'ACTIVE'
    ];
    if (oddDucks != null) {
      for (Mkt_Site_User__c msu : oddDucks) {
        calcMSUs.add(new MSUWrapper(msu));
      }
    }

    // now figure it out
    List<Mbr_Group__c> baseGroups = [
      SELECT
        Id,
        Name,
        Client_Account__r.Name,
        Client_Account__c,
        Group_Number__c,
        Name__c,
        Status__c
      FROM Mbr_Group__c
      WHERE
        Status__c IN ('ACTIVE')
        AND Client_account__c = :selContact.AccountId
    ];
    List<Mbr_Group__c> validGroups = [
      SELECT
        Id,
        Name,
        Client_Account__r.Name,
        Client_Account__c,
        Group_Number__c,
        Name__c,
        Status__c
      FROM Mbr_Group__c
      WHERE
        Status__c IN ('ACTIVE')
        AND Id IN (
          SELECT Mbr_Group__c
          FROM Mbr_Group_Role__c
          WHERE
            Source_Account__c = :selContact.AccountId
            AND Role_Type__c IN ('Payer', 'Benefit Sponsor', 'MSU Access')
        )
    ];

    validGroups.addAll(baseGroups);
    if (validGroups != null) {
      for (Mbr_Group__c g : validGroups) {
        calcMSUs.add(new MSUWrapper(g, selContact));
      }
    }
  }

  // This is the MSU calculation given a group.
  // 1) Find relevant odd ducks
  // 2) Calculate MSUs
  public void calcResultsByGroup() {
    System.debug(selGroupId);

    //TODO: Should active group be enforced here?  Or get the group, and show error that it's not active?
    selGroup = [
      SELECT
        Id,
        Name,
        Group_Number__c,
        Name__c,
        Client_Account__c,
        Client_Account__r.Name,
        Status__c
      FROM Mbr_Group__c
      WHERE Id = :selGroupId
    ];
    calcMSUs = new List<MSUWrapper>();
    // Start with odd ducks
    List<Mkt_Site_User__c> oddDucks = [
      SELECT
        Id,
        Name,
        Contact__r.Name,
        Mbr_Group__r.Name,
        Mbr_Group__r.Status__c,
        Contact__c,
        Mbr_Group__c,
        Mbr_Group__r.Client_Account__c,
        Mbr_Group__r.Client_Account__r.Name,
        Contact__r.AccountId,
        Contact__r.Account.Name,
        Mbr_Group__r.Group_Number__c,
        Mbr_Group__r.Name__c
      FROM Mkt_Site_User__c
      WHERE
        Mbr_Group__c = :selGroup.Id
        AND Contact__r.Contact_Status__c = 'ACTIVE'
        AND Contact__r.Marketing_Site_User__c = TRUE
        AND Contact__r.Marketing_Site_Username__c != ''
        AND Mbr_Group__r.Status__c = 'ACTIVE'
    ];
    if (oddDucks != null) {
      for (Mkt_Site_User__c msu : oddDucks) {
        calcMSUs.add(new MSUWrapper(msu));
      }
    }

    // now get valid calculated contacts from group->roles->account->contact
    List<Contact> baseContacts = [
      SELECT Id, Name, AccountId, Account.Name
      FROM Contact
      WHERE
        Marketing_Site_User__c = TRUE
        AND Marketing_Site_Username__c != ''
        AND AccountId = :selGroup.Client_Account__c
    ];
    List<Contact> validContacts = [
      SELECT Id, Name, AccountId, Account.Name
      FROM Contact
      WHERE
        Marketing_Site_User__c = TRUE
        AND Marketing_Site_Username__c != ''
        AND AccountId IN (
          SELECT Source_Account__c
          FROM Mbr_Group_Role__c
          WHERE
            Mbr_Group__c = :selGroup.Id
            AND Role_Type__c IN ('Payer', 'Benefit Sponsor', 'MSU Access')
        )
    ];

    validContacts.addAll(baseContacts);
    if (validContacts != null) {
      for (Contact c : validContacts) {
        calcMSUs.add(new MSUWrapper(selGroup, c));
      }
    }
  }

  // Wrapper around MSU which allows for display of names and pass through MSU formulas
  public class MSUWrapper {
    // this can only be called with odd ducks containing the correct soql fields
    public MSUWrapper(Mkt_Site_User__c oddDuckMSU) {
      msu = oddDuckMSU;
      oddDuck = true;
      groupName = msu.Mbr_Group__r.Name__c;
    }

    public MSUWrapper(Mbr_Group__c grp, Contact con) {
      msu = new Mkt_Site_User__c();
      msu.Mbr_Group__c = grp.Id;
      msu.Contact__c = con.Id;
      msu.Contact__r = con;
      msu.Mbr_Group__r = grp;
      oddDuck = false;
      groupName = grp.Name__c;
    }
    public String groupName { get; set; }
    public Boolean oddDuck { get; set; }
    public Mkt_Site_User__c msu { get; set; }
  }
}