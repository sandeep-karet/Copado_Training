global class Contact_Grp_Zero_sch implements Schedulable {
  global void execute(SchedulableContext SC) {
    Contact_Grp_Zero_Bch conGrpZeroBatch = new Contact_Grp_Zero_Bch(null);
    database.executebatch(conGrpZeroBatch, 1);
  }
}