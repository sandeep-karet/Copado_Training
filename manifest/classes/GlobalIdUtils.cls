global class GlobalIdUtils {
  @TestVisible
  public static String generateGuid() {
    Blob generatedBlob = Crypto.GenerateAESKey(128);
    String hex = EncodingUtil.ConvertTohex(generatedBlob);
    String guid =
      hex.substring(0, 8) +
      '-' +
      hex.substring(8, 12) +
      '-' +
      hex.substring(12, 16) +
      '-' +
      hex.substring(16, 20) +
      '-' +
      hex.substring(20);
    return guid.toUppercase();
  }

  @TestVisible
  public static Boolean isGuid(String guid) {
    if (String.isBlank(guid))
      return false;

    String guidRegEx = '[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}';
    Pattern guidPattern = Pattern.compile(guidRegEx);
    Matcher guidMatcher = guidPattern.matcher(guid.toUpperCase());
    Boolean result = guidMatcher.matches();
    return result;
  }
}