public class BypassClass {
  @InvocableMethod(
    label='Bypass Trigger'
    description='Provides apex action to stop process builder from completing normal logic.'
  )
  public static void bypassTrigger(List<String> params) {
    String source = params[0];
    System.debug(System.LoggingLevel.FINE, 'Bypassed: ' + source);
  }
}