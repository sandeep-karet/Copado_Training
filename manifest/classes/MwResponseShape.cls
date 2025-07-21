public class MwResponseShape {
  public Account contractee = null;
  public Account bsp = null;
  public Account payer = null;
  public Acct_Rel__c contractee_rel = null;
  public Plan_Specific_Fees__c psf_bd_emp = null;
  public Plan_Specific_Fees__c psf_emo = null;
  public List<Contract> contracts = new List<Contract>();
  public List<Account> brokers = new List<Account>();
  public Mbr_Group__c member_group = null;
  public List<Plan_Specific_Fees__c> psfs = new List<Plan_Specific_Fees__c>();
  public List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
}