/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Mbr_Group_RoleTest {
  @IsTest
  private static void testTrigger() {
    // Force the dlrs_Mbr_Group_RoleTrigger to be invoked, fails the test if org config or other Apex code prevents this.
    dlrs.RollupService.testHandler(new Mbr_Group_Role__c());
  }
}