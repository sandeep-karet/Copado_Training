/**
* Company : PwC.
* @description : L2O_ValidateOpptyLineItemController will be executed from the L2O_ValidateOpptyLineItemController Lightning Component.
* *******************************************************************************************************************************************
* History : 
* @date 4/17/2023
* @author Neha Sheikh
*/
public without sharing class L2O_ValidateOpptyLineItemController {
    //Exception log variables
    public static String className = 'L2O_ValidateOpptyLineItemController';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;
    
    public OpportunityLineItem oppLineItem;
    public OpportunityLineItem tempOppLineItem;
    Id oppId;
     /**
    * @name  L2O_ValidateOpptyLineItemController
    * @description Contructor of the class.
    * @param  controller instance of the standardcontroller
    * @returns none.
    **/
    public L2O_ValidateOpptyLineItemController(ApexPages.standardcontroller controller) {
        this.oppLineItem = (OpportunityLineItem)controller.getRecord();
        tempOppLineItem = [SELECT id,Opportunity.Name,Product2.Name FROM OpportunityLineItem WHERE Id =:oppLineItem.Id LIMIT 1]; 
        oppId = tempOppLineItem.OpportunityId;
    }
    /**
    * @name  getUserProfile
    * @description To get the current user profile.
    * @params none
    * @return none.
    **/
    @AuraEnabled
    public static String getUserProfile() {
        methodName = 'getUserProfile';
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
                throw new AuraHandledException(System.Label.L2O_AuraHandledError);
            }
        }catch (Exception ex) {
            SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        return L2O_Utility.getUserProfileName();
    }
    /**
    * @name  profileName
    * @description To set the current user profile.
    * @params none
    * @return proflName return the Profile Name of User.
    **/
    public String profileName{
        get{
            String proflName = getUserProfile();
            return proflName;
        }set;
    }
    /**
    * @name  opptyId
    * @description To set the related opportunity ID.
    * @params none
    * @return oppId return the Id of related opportunity Id.
    **/
    public Id relatedOpptyId{
        get{
            return oppId;
        }set;
    }
    /**
    * @name  opp_productName
    * @description To set the opportunity name and product name in format "OpportunityName OpportunityProductName" .
    * @params none
    * @return oppandProdName return "OpportunityName OpportunityProductName".
    **/
    public String oppProductName{
        get{
            String oppandProdName = '"'+tempOppLineItem.Opportunity.Name+' '+tempOppLineItem.Product2.Name+'"';
            return oppandProdName;
        }set;
    }
    /**
    * @name  deleteOppLineItem
    * @description To delete the prodcessed Opportunity Product for system admins.
    * @params none
    * @return null return PageReference.
    **/
    public PageReference deleteOppLineItem(){
        if (profileName == L2O_Constants.PROFILE_SYSTEM_ADMINISTRATOR && profileName != null){
            deleteOppLineItemRecord();
           // delete oppLineItem;
        }
        return null;
    }
    /**
    * @name  deleteOppLineItemRecord
    * @description To delete the prodcessed Opportunity Product for system admins.
    * @params none
    * @returns none.
    **/
    public void deleteOppLineItemRecord(){
        delete oppLineItem;
        }    
}