global class Contact_Grp_Rollup_Sch implements Schedulable {
  global void execute(SchedulableContext SC) {
    Contact_Grp_Rollup_Bch conGrpRollUpBatch = new Contact_Grp_Rollup_Bch(null);
    database.executebatch(conGrpRollUpBatch, 1);
  }
}