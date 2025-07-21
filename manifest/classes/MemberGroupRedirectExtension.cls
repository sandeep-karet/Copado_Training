public with sharing class MemberGroupRedirectExtension {
  private Mbr_Group_Role__c selGrp;

  // When a role is edited, this overrides the standard role edit screen by redirecting to Member Groups/Role section.
  // This will enforce rules and limits for creating roles.
  public MemberGroupRedirectExtension(ApexPages.StandardController stdCntrl) {
    selGrp = (Mbr_Group_Role__c) stdCntrl.getRecord();
  }

  public PageReference redirect() {
    // Find the parent member group and redirect
    List<Mbr_Group_Role__c> mgrs = [
      SELECT Id, Mbr_Group__c
      FROM Mbr_Group_Role__c
      WHERE Id = :selGrp.Id
      LIMIT 1
    ];
    if (mgrs.size() == 1) {
      PageReference pg = new PageReference('/apex/MemberGroup#r');
      pg.getParameters().put('id', mgrs[0].Mbr_Group__c);
      return pg;
    } else {
      return null;
    }
  }
}