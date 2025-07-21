public class Recursive {
  private static boolean working_acct = false;

  public static boolean isAccountWorking() {
    return working_acct;
  }
  public static void setAccountWorking() {
    working_acct = true;
  }
  public static void setAccountClosed() {
    working_acct = false;
  }
}