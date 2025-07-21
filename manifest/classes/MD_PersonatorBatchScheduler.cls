/*********************************************************************************
 * CLass Name    : MD_PersonatorBatchScheduler
 * CreatedDate   : 26-May-2023
 * Description   : Executing Personator Address Validation on every 4 hour
 * Author        : Elambaruthi Thanasinghu
 *
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 *SCDEV-3380     26-May-2023     Elambaruthi T      Class Created
 *SCDEV-3380     21-Jul-2023     Elambaruthi T      Updated to execute other address validation after the Mailing address validation completed.
 *SCDEV-3380		01-Aug-2023		Elambaruthi T	   Modified the code to execute only Account-Billing Address and Contact - Mailing Address
 */
global class MD_PersonatorBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    String qryAccount = 'SELECT ID FROM Account WHERE Billing_Address_Personator_Result__c = null';
    Id batchinstanceId1 = Database.executeBatch(
      new MDPERSONATOR.MD_PersonatorBatch(
        qryAccount,
        true,
        true,
        true,
        'Account - Billing Address'
      ),
      200
    );

    String qryContact1 = 'SELECT ID FROM Contact WHERE Mailing_Address_Personator_Result__c = null';
    Id batchinstanceId2 = Database.executeBatch(
      new MDPERSONATOR.MD_PersonatorBatch(
        qryContact1,
        true,
        true,
        true,
        'Contact - Mailing Address'
      ),
      200
    );
  }

  public static void startSchedule() {
    String CRON_EXP = '0 0 0,4,8,12,16,20 ? * *';
    MD_PersonatorBatchScheduler sch = new MD_PersonatorBatchScheduler();
    system.schedule('Personator Address Validation', CRON_EXP, sch);
  }
}