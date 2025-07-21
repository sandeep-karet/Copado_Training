public class addressValidationHelper {
  public static String getResultCodeShortDescription(String resultCode) {
    String shortDesc = '';
    Melissa_Data_Personator_Result_Code__mdt melissaData = Melissa_Data_Personator_Result_Code__mdt.getInstance(
      resultCode
    );
    if (melissaData != null) {
      shortDesc = melissaData.Short_Description__c;
    }
    return shortDesc;
  }
}