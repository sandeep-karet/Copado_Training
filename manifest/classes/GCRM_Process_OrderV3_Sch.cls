global class GCRM_Process_OrderV3_Sch implements Schedulable, Database.stateful {
  private String orderMUID { get; set; }
  global GCRM_Process_OrderV3_Sch(String MUID) {
    orderMUID = MUID;
  }
  global void execute(SchedulableContext sc) {
    GCRM_Process_V3_Bch gpab = new GCRM_Process_V3_Bch(orderMUID, false);
    String batchId = Database.executeBatch(gpab);
    System.debug('executing GCRM_Process_V3_Bch with id: ' + batchId);
  }
}