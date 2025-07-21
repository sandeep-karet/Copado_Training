/**
* Company : PwC.
* @description : L2O_Utility will contain all the Static methods used in Apex
* *******************************************************************************************************************************************
* History : 
* @date 02/02/2023
* @author Neha Sheikh
*/
public without sharing class L2O_Utility {
    
    
    /**
* @name  fetchOpportunityProfileStageValidationMetadata
* @description fetching metadata
* @return List<L2O_OpportunityStageProfileConfiguration__mdt>
**/
    public static Map<String,String> fetchOpportunityProfileStageValidationMetadata(){
        
        List<L2O_OpportunityStageProfileConfiguration__mdt>  oppStageProfileMetadataList = L2O_OpportunityStageProfileConfiguration__mdt.getall().values();
        Map<String,String> stageProfileMap = new Map<String,String>();
        
        for(L2O_OpportunityStageProfileConfiguration__mdt oppStage: oppStageProfileMetadataList){
            stageProfileMap.put(oppStage.Profile__c,oppStage.L2O_Stages_Allowed__c);
        }
        return stageProfileMap;
    }
    
    /**
* @name  getUserProfileName
* @description fetching logged in user profile name
* @return string
**/
    public static String getUserProfileName(){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile WHERE Id=:profileId].Name;
        return profileName;
        
    }
     /**
* @name  getClosedWonEmailTemplate
* @description fetching EmailTemplate, used in 'L2O_sendEmailOnOppClosedWon' class.
* @return string
**/
    public static EmailTemplate getClosedWonEmailTemplate(){
         String emailTemplateName = System.Label.L2O_New_Contract_signed_Email_template;
         EmailTemplate emailtmplate=[SELECT id,Markup FROM EmailTemplate WHERE name = :emailTemplateName limit 1];
        return emailtmplate;
        
    }


}