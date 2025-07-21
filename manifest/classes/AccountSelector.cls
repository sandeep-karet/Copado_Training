/**
 * Selector class for Account object, can be extended by adding generic Selector class and extending this one
 */
public with sharing class AccountSelector {
  List<AccountWrapper> accountWrapperAccounts;

  // Basic Constructor
  public AccountSelector() {
    accountWrapperAccounts = new List<AccountWrapper>();
  }

  // Get the list of Accounts via AccountWrapper by a set of Account Ids.
  public List<AccountWrapper> selectById(Set<Id> idSet) {
    assertIsAccessible();

    String query = String.format(
      'Select {0} from {1} where Id in :idSet order by {2}',
      new List<String>{
        SchemaHelper.getSObjectFields('Account'),
        'Account',
        'Name'
      }
    );
    List<Account> accounts = Database.query(query);
    for (Account acc : accounts) {
      AccountWrapper accWrap = new AccountWrapper();
      accWrap.theAccount = acc;
      accountWrapperAccounts.add(accWrap);
    }

    return accountWrapperAccounts;
  }

  // Get the list of Accounts via AccountWrapper by a String search.
  public List<AccountWrapper> selectByName(String accountName) {
    return selectByName(accountName, false); // Do a fuzzy logic search
  }

  // Get the list of Accounts via AccountWrapper by a String Search and tell if its an exact match
  public List<AccountWrapper> selectByName(
    String accountName,
    Boolean isExactMatch
  ) {
    assertIsAccessible();
    String searchquery;
    if (isExactMatch != null && isExactMatch)
      searchquery =
        'FIND \'' +
        String.escapeSingleQuotes(accountName) +
        '\' IN NAME FIELDS RETURNING Account(' +
        SchemaHelper.getSObjectStandardFields('Account') +
        ')';
    else
      searchquery =
        'FIND \'' +
        String.escapeSingleQuotes(accountName) +
        '*\' IN NAME FIELDS RETURNING Account(' +
        SchemaHelper.getSObjectStandardFields('Account') +
        ')';

    system.debug('**searchquery**');
    system.debug(searchquery);

    List<List<SObject>> searchList = search.query(searchquery);
    for (Account acc : (List<Account>) searchList[0]) {
      AccountWrapper accWrap = new AccountWrapper();
      accWrap.theAccount = acc;
      accountWrapperAccounts.add(accWrap);
    }

    return accountWrapperAccounts;
  }

  // Assert to see if the Account is accessible by the user
  public void assertIsAccessible() {
    if (!Account.SobjectType.getDescribe().isAccessible())
      throw new AccountSelectorException(
        'Permission to access Account denied.'
      );
  }

  // Custom Exception class.
  public class AccountSelectorException extends Exception {
  }
}