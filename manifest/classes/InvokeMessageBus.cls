public class InvokeMessageBus {
  public static boolean DisableTriggersForMBflow = false;
  @InvocableMethod(
    label='Invoke Message Bus'
    description='Returns the id list of Opportunities'
    category='Opportuinity'
  )
  public static void OppInvokeMB(List<Id> oppIds) {
    List<Id> queList = new List<Id>();
    queList = oppIds;
    MB_OppToQItemBatch msgBusBch = new MB_OppToQItemBatch(queList);
    database.executebatch(msgBusBch, 10);
  }
}