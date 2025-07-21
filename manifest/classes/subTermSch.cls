global class subTermSch implements Schedulable {
  global void execute(SchedulableContext SC) {
    subTerm_Bch subBatch = new subTerm_Bch();
    database.executebatch(subBatch, 1);
  }
}