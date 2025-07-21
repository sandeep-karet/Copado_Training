/**
* Company : PwC.
* @description : L2O_GlobalIdUtils generates GUID in required format for Accounts and Oppportunity Records.
* *****************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/

@SuppressWarnings('PMD.AvoidGlobalModifier')

global class L2O_GlobalIdUtils {
    
    /**
	* @name  L2O_GlobalIdUtils
	* @description	Constructor to make class Singleton
	**/
    private L2O_GlobalIdUtils(){
        return;
    }
    
    @TestVisible
    
    /**
	* @name  generateGuid
	* @description Generates GUID
	* @return GUID
	**/
    
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
    
    @TestVisible
    
    /**
	* @name  isGuid
	* @description Checks if GUID is Valid
	* @param  guid to check
	* @return result true or false
	**/
    
    public static Boolean isGuid(String guid) {
        if(String.isBlank(guid)){ 
            return false;
        }
        
        String guidRegEx = '[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}';
        Pattern guidPattern = Pattern.compile(guidRegEx);
        Matcher guidMatcher = guidPattern.matcher(guid.toUpperCase());
        Boolean isValid = guidMatcher.matches();
        return isValid;
    }
}