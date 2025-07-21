/**
* Company : PwC.
* @description : L2O_ContactTriggerHelperService will be executed from the L2O_ContactTriggerHandler and will update GUID Profile field on Contact
* *****************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/

public without sharing class L2O_ContactTriggerHelperService {
    
    Public Static Final String PROFILE_NAME_SYS_ADMIN = System.Label.Profile_System_Administrator;
    Public Static Final String ERROR_TEXT = System.Label.Prevent_Contact_Deletion_and_Account_Change_Error_Message;
    
    /**
* @name  setGUID
* @description setGUID
* @param  newContacts for trigger.new Contact
**/
    public void setGUID(List<Contact> newContacts) {
        
        Set<String> allGuids = new Set<String>();
        for (Contact tempContact : newContacts) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempContact.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempContact.L2O_GUID__c)) {
                tempContact.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempContact.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempContact.L2O_GUID__c);
            }
            
        }
    }
    
      /**
    * @name  setLeadID
    * @description setLeadID
    * @param  newContacts for trigger.new Contact
    **/
    public void setLeadID(List<Contact> newContacts) {
        //Get contact records
        List<Contact> updteConList = new List<Contact>();
        List<Contact> updCon = [SELECT Id,Name,L2O_Lead_Id__c FROM Contact WHERE Id IN: newContacts];
        //Update contact record
        for (Contact tempContact : updCon) {
            tempContact.L2O_Lead__c=updCon[0].L2O_Lead_Id__c;
            updteConList.add(tempContact);
        }
        if(!updteConList.isEmpty()){
            update updteConList;
        }  
    }
    
    /**
     * @name preventUpdateifRoleExists
     * @description 
     * @param contactList for the Trigger.new/ Trigger.old
     * @param oldMap for the Old map of Contacts
     * @Author InfoSys Developer
    **/
    Public Void preventUpdateifRoleExists(List<Contact> contactList, Map<Id,Contact> oldMap){
        
        List<Id> contactIds = New List<Id>();
        for(Contact con : contactList){            
            if(oldMap == null){
                contactIds.add(con.Id); 
            }            
            if(oldMap != null && con.AccountId != oldMap.get(con.Id).AccountId){
                contactIds.add(con.Id);
            }            
        }
        
        //Fetching the Contact Roles Related to the Contacts
        List<OpportunityContactRole> oppContactrolelist = [Select Id, ContactId, L2O_Account__c from OpportunityContactRole where ContactId IN :contactIds];
        
        //Mapping the Opoortunity Contact Roles with the respective Contact Ids
        Map<Id,List<OpportunityContactRole>> oppContactrolemap = New Map<Id,List<OpportunityContactRole>>();        
        for(OpportunityContactRole oppRole : oppContactrolelist){
             List<OpportunityContactRole> oppRolelist  = new List<OpportunityContactRole>();
            if(oppContactrolemap.containsKey(oppRole.ContactId)){
               oppRolelist= oppContactrolemap.get(oppRole.ContactId);
                oppRolelist.add(oppRole);
            } else{
                oppRolelist.add(oppRole);
               
            } 
             oppContactrolemap.put(oppRole.ContactId, oppRolelist);
        }
        
        //Fetching the Logged in user Profile
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        //Validating if the Contact has existing Contact Roles
        for(Contact contactRecord : contactList){
            List<OpportunityContactRole> contactRolelist = oppContactrolemap.get(contactRecord.Id);
            if(contactRolelist.size()>0 && !profileName.contains(PROFILE_NAME_SYS_ADMIN)){
                if(!Test.isRunningTest()) {
                    contactRecord.addError(ERROR_TEXT);
                }
            }
        }    
        
    }
}