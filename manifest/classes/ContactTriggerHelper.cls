public class ContactTriggerHelper {
  public static void setGUID(List<Contact> contacts) {
    for (Contact contact : contacts) {
      if (
        String.isBlank(contact.GUID__c) ||
        !GlobalIdUtils.isGuid(contact.GUID__c)
      ) {
        contact.GUID__c = GlobalIdUtils.generateGuid();
      }
    }
  }
  public static void setMarketingSiteInfo(
    List<Contact> newItems,
    Map<Id, Contact> oldMap,
    Boolean isUpdate,
    Boolean isInsert
  ) {
    Set<String> usernameFilter = new Set<String>();
    Map<String, Integer> maxVals = new Map<String, Integer>();
    List<Contact> usersToUpdate = new List<Contact>();
    // store names in bulk

    System.debug('Num of Items: ' + newItems.size());
    // First pass: build a set of distinct, normalized usernames to look for from trigger items
    for (Contact c : newItems) {
      // generate base username for ALL inserts/updates and add it for reference
      String firstInitial = '';
      if (c.FirstName != null && c.FirstName.length() > 0) {
        firstInitial = c.FirstName.left(1);
      }
      String normalizedUsername = firstInitial + c.LastName;
      normalizedUsername = normalizedUsername.replaceAll('[^a-zA-Z]', '')
        .toLowerCase();

      Boolean isMSU = false;

      if (isUpdate) {
        // Stamp the date if Marketing Site User status has switched
        Boolean checkChanged = (oldMap.get(c.Id).Marketing_Site_User__c !=
        c.Marketing_Site_User__c);
        Boolean usernameChanged = (oldMap.get(c.Id)
          .Marketing_Site_Username__c != c.Marketing_Site_Username__c);
        Boolean activeChanged = (oldMap.get(c.Id).Contact_Status__c !=
        c.Contact_Status__c &&
        c.Contact_Status__c == 'ACTIVE' ||
        oldMap.get(c.Id).Contact_Status__c == 'ACTIVE');
        if (
          checkChanged ||
          usernameChanged ||
          (activeChanged &&
          c.Marketing_Site_User__c &&
          String.isNotBlank(c.Marketing_Site_Username__c))
        ) {
          c.Marketing_Site_Date_Status_Updated__c = Date.today();
        }

        // only process username updates if the user switches from false to true
        // 2019061_EEM:  Simplifying logic to generate username if msu is checked and username is blank
        isMSU = (c.Marketing_Site_User__c == true &&
        String.isBlank(c.Marketing_Site_Username__c));
        //&& checkChanged && String.isBlank(c.Marketing_Site_Username__c));
      } else if (isInsert) {
        System.debug(
          'Insert user: ' + c.FirstName + '/' + c.Marketing_Site_User__c
        );
        isMSU = (c.Marketing_Site_User__c == true);
        c.Marketing_Site_Date_Status_Updated__c = Date.today();
      }

      if (isMSU) {
        usernameFilter.add(normalizedUsername + '%');
        // store temp username
        c.Marketing_Site_Username__c = normalizedUsername;
        // Marked once - only the first time the user is set to MSU user
        if (c.First_Group__c == null) {
          c.First_Group__c = Date.today();
        }
        usersToUpdate.add(c);
      }
    }

    // Calculate max int by username
    // Note: Existing users with these usernames do NOT need to be active OR flagged as marketing site users.
    // This will pull back all names that have been used, which will prevent any duplicates.
    List<Contact> mktContacts = [
      SELECT Id, Marketing_Site_Username__c
      FROM Contact
      WHERE Marketing_Site_Username__c LIKE :usernameFilter
      FOR UPDATE
    ];

    for (Contact c : mktContacts) {
      System.debug('checking name: ' + c.Marketing_Site_Username__c);
      String intval = c.Marketing_Site_Username__c.replaceAll('[^0-9]', '');

      System.debug('got intval: ' + intval);
      String baseUsername = c.Marketing_Site_Username__c.replaceAll(
          '[^a-zA-Z]',
          ''
        )
        .toLowerCase();

      System.debug('got base: ' + baseUsername);
      // always start with 2.  No number is equivalent to a username followed by a 1.
      Integer firstNumber = 2;
      if (intval.isNumeric()) {
        Integer currentVal = Integer.valueOf(intval);
        Integer nextVal = currentVal + 1;
        System.debug('got curval: ' + currentVal);
        Integer currentMaxVal = maxVals.get(baseUsername);
        if (currentMaxVal == null) {
          System.debug('putting: ' + nextVal);
          maxVals.put(baseUsername, nextVal);
        } else {
          System.debug(
            'currentIntegerVal vs max:' + nextVal + ' -> ' + currentMaxVal
          );
          if (nextVal > currentMaxVal) {
            maxVals.put(baseUsername, nextVal);
          }
        }
      } else if (!maxVals.containsKey(baseUsername)) {
        System.debug(
          'putting first time:' +
            firstNumber +
            ' for base name: ' +
            baseUsername
        );
        maxVals.put(baseUsername, firstNumber);
      }
    }

    System.debug('Updating Users:' + usersToUpdate.size());
    for (Contact c : usersToUpdate) {
      String normalizedUsername = c.Marketing_Site_Username__c;
      Integer nextValue = maxVals.get(normalizedUsername);
      if (nextValue == null) {
        System.debug('noval for ' + c.Marketing_Site_Username__c);
        maxVals.put(normalizedUsername, 2);
        nextValue = 2;
        c.Marketing_Site_Username__c = c.Marketing_Site_Username__c + 2;
      } else {
        System.debug(
          'gotval for ' + normalizedUsername + ' Next val: ' + nextValue
        );
        c.Marketing_Site_Username__c = normalizedUsername + nextValue;
        nextValue++;
        System.debug(
          'The new username shall be: ' + normalizedUsername + nextValue
        );
        maxVals.put(normalizedUsername, nextValue);
      }
    }
  }
}