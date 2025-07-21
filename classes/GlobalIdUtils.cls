/*************************************************************************     
* @description This class is used to generate GUID and match its pattern 
* @param NA
* @Author InfoSys Developer
**************************************************************************/
public class GlobalIdUtils {
/*************************************************************************     
* @description This class is used to generate GUID and return the generated guid 
* @return guid
**************************************************************************/
    @TestVisible
    public static String generateGuid(){
        Blob generatedBlob = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(generatedBlob);
        String guid = hex.substring(0, 8)
                + '-' + hex.substring(8, 12)
                + '-' + hex.substring(12, 16)
                + '-' + hex.substring(16, 20)
                + '-' + hex.substring(20);
        return guid.toUppercase();
    }
/*************************************************************************     
* @description This class is used to match guid's pattern with a valid format 
* @param guid which is guid no passed from calling class
* @return result of guid pattern matcher
**************************************************************************/
    @TestVisible
    public static Boolean isGuid(String guid) {
        if(String.isBlank(guid)) 
        {
            return false;
        }
        else
        {
        String guidRegEx = '[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}';
        Pattern guidPattern = Pattern.compile(guidRegEx);
        Matcher guidMatcher = guidPattern.matcher(guid.toUpperCase());
        Boolean result = guidMatcher.matches();
        return result;
        }
    }
}