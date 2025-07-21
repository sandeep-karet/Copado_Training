// StaticInfo - emulates a static instance of information across a context execution
public with sharing class StaticInfo {
  private static Map<String, Account> cachedAccounts = new Map<String, Account>();
  private static Map<String, Disclaimers__c> cachedDisclaimers = new Map<String, Disclaimers__c>();
  private static Map<String, Web_URLs__c> cachedWebUrls = new Map<String, Web_URLs__c>();
  private static Map<String, Opportunity> cachedTrackingOpps = new Map<String, Opportunity>();
  public static List<Contact> msuContacts = [
    SELECT Id, Marketing_Site_Username__c
    FROM Contact
    WHERE MSU_Exists__c = 'Yes'
  ];

  public static Opportunity TrackingOppFor(string acctName) {
    if (cachedTrackingOpps.containsKey(acctName))
      return cachedTrackingOpps.get(acctName);

    List<Opportunity> tmpOpps = [
      SELECT id, name, stagename
      FROM opportunity
      WHERE
        account.name = :acctName
        AND stagename = 'Current Tracking of Licensed Sales'
    ];
    if (tmpOpps.size() == 0)
      return null;

    Opportunity tmpOpp = tmpOpps[0];
    cachedTrackingOpps.put(acctName, tmpOpp);
    return tmpOpp;
  }
  public static Web_URLs__c WebUrlFor(string urlName) {
    if (cachedWebUrls.containsKey(urlName))
      return cachedWebUrls.get(urlName);

    List<Web_URLs__c> tmpWebUrls = [
      SELECT id, name
      FROM Web_URLs__c
      WHERE name = :urlName
    ];
    if (tmpWebUrls.size() == 0)
      return null;

    Web_URLs__c tmpWebUrl = tmpWebUrls[0];
    cachedWebUrls.put(urlName, tmpWebUrl);
    return tmpWebUrl;
  }
  public static Disclaimers__c DisclaimerFor(string disclaimerName) {
    if (cachedDisclaimers.containsKey(disclaimerName))
      return cachedDisclaimers.get(disclaimerName);

    List<Disclaimers__c> tmpDisclaimers = [
      SELECT id, name
      FROM Disclaimers__c
      WHERE name = :disclaimerName
    ];
    if (tmpDisclaimers.size() == 0)
      return null;
    Disclaimers__c tmpDisclaimer = tmpDisclaimers[0];
    cachedDisclaimers.put(disclaimerName, tmpDisclaimers[0]);
    return tmpDisclaimer;
  }
  public static Account AccountInfoFor(string accountName) {
    // return the cached version if it exists
    if (cachedAccounts.containsKey(accountName)) {
      System.debug(System.LoggingLevel.FINE, 'Found cached entry.');
      return cachedAccounts.get(accountName);
    }

    // read and cache the account
    List<Account> tmpAccts = [
      SELECT
        id,
        name,
        Account_Legal_Name__c,
        (
          SELECT id, SBQQ__ProductName__c, SBQQ__StartDate__c
          FROM SBQQ__Subscriptions__r
        ),
        (
          SELECT id, name, Tracking_Start_Date__c, Tracking_End_Date__c
          FROM Opportunities
          WHERE recordtype.Name = 'Licensed Sales Tracking'
        )
      FROM Account
      WHERE Account_Legal_Name__c = :accountName
      LIMIT 1
    ];
    if (tmpAccts.size() == 0)
      return null;

    Account xAcct = tmpAccts[0];
    cachedAccounts.put(xAcct.Account_Legal_Name__c, xAcct);
    return xAcct;
  }

  // Needed when creating opp
  public static Asset createAsset(
    String assetName,
    SBQQ__Subscription__c tmpSub
  ) {
    Asset tmpAsset = new Asset(
      Name = assetName,
      Consult_Fees__c = 45.0,
      Status = 'Active',
      SBQQ__RequiredBySubscription__c = tmpSub.Id
    );
    insert tmpAsset;
    return tmpAsset;
  }
  public static Account createUmrAcct() {
    Account tmpAcct = new Account(
      Name = 'UMR',
      Account_Legal_Name__c = 'UMR',
      ExternalSysId__c = 'UMR_ACCT1234567890'
    );
    User acctOwner = fetchAcctUsr('Sales - ASO', 'Sales Rep - ASO');
    User acctMgr = fetchAcctUsr(
      'Account Manager - Teladoc',
      'AM-Small Market/Reseller'
    );
    tmpAcct.OwnerId = acctOwner.Id;
    tmpAcct.Account_Manager__c = acctMgr.Id;
    insert tmpAcct;
    return tmpAcct;
  }
  public static User fetchAcctUsr(String profileName, String roleName) {
    User tmpUsr = [
      SELECT id
      FROM User
      WHERE
        profile.Name = :profileName
        AND UserRole.Name = :roleName
        AND IsActive = TRUE
      LIMIT 1
    ];
    return tmpUsr;
  }
}