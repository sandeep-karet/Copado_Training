global class OppCloseSch implements Schedulable {
  global void execute(SchedulableContext SC) {
    OppCloseBatch oppBatch = new OppCloseBatch();
    database.executebatch(oppBatch);
  }
}