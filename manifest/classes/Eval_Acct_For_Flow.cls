public class Eval_Acct_For_Flow {
  public static List<Account> Process(List<Account> target_accts) {
    List<Id> dce = new List<Id>(); // Ids of Direct Contractee Employers
    Map<Id, Account> mapped_accts = new Map<Id, Account>();
    for (Account tmpAcct : target_accts) {
      // Eventually we want to be smart about which accounts we evaluate but for now do all
      dce.add(tmpAcct.Id);
      mapped_accts.put(tmpAcct.Id, tmpAcct);
    }
    // DCE relationships found
    List<Acct_Rel__c> dce_rels = [
      SELECT svc_acct__c
      FROM acct_rel__c
      WHERE
        svc_acct__c IN :mapped_accts.keyset()
        AND Relationship_Type__c = 'Contractee'
        AND Contract_Type__c = 'Direct'
    ];
    Set<Id> dce_ids = new Set<Id>();
    for (Acct_Rel__c tmpAr : dce_rels) {
      dce_ids.add(tmpAr.svc_acct__c);
    }
    // Flow1a - Only flag account with Account_Type__c = 'Employer'
    for (Account tmpAcct : target_accts) {
      if (
        dce_ids.contains(tmpAcct.Id) && tmpAcct.Account_Type__c == 'Employer'
      ) {
        tmpAcct.Allow_Flow__c = true;
      } else {
        tmpAcct.Allow_Flow__c = false;
      }
    }
    return target_accts;
  }
}