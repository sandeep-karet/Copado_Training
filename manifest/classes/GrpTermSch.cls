global class GrpTermSch implements Schedulable {
  global void execute(SchedulableContext SC) {
    GrpTerm_Bch grpBatch = new GrpTerm_Bch();
    database.executebatch(grpBatch, 1);
  }
}