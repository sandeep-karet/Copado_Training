/**
* Company : PwC.
* @description : L2O_AccountTriggerHelperService will be executed from the L2O_AccountTriggerHandler and will update GUID Profile field on Account
* *****************************************************************************************************************************************
* History : 
* @date 03/06/2022
* @author Aviral Dhodi
*/

public without sharing class L2O_AccountTriggerHelperService {
    
	/**
	* @name  setGUID
	* @description setGUID
	* @param  newAccounts for trigger.new Accounts
	**/
    
    public void setGUID(List<Account> newAccounts) {
        
        Set<String> allGuids = new Set<String>();
        for (Account tempAccount : newAccounts) {
            
            // Create new GUID if account is new or has invalid GUID
            
            if (String.isBlank(tempAccount.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempAccount.L2O_GUID__c)) {
                
                tempAccount.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempAccount.L2O_GUID__c);
                
            }
            
            else {
                
                allGuids.add(tempAccount.L2O_GUID__c);
                
            }
            
        }
    }
   	/**
    * @name  setLeadID
    * @description setLeadID
    * @param  newAccounts for trigger.new Account
    **/
    public void setLeadID(List<Account> newAccounts) {
        //Get Account records
        List<Account> updteAccList = new List<Account>();
        List<Account> updAcc = [SELECT Id,Name,L2O_Lead_Id__c FROM Account WHERE Id IN: newAccounts];
        //Update Account record
        for (Account tempAccount : updAcc) {
            tempAccount.L2O_Lead__c=updAcc[0].L2O_Lead_Id__c;
            updteAccList.add(tempAccount);
        }
        if(!updteAccList.isEmpty()){
            update updteAccList;
        }  
    }
    /**
	* @name  publishClientBroadcastPlatformEvent
	* @description Publish Platform Event ''Account Broadcast''
	* @param  updatedAccounts for trigger.new Accounts
	* @param  oldAccounts for trigger.oldMap Accounts
	**/
    public void publishClientBroadcastPlatformEvent (List<Account> updatedAccounts, Map<Id,sObject> oldAccounts) {
        
        List<Id> accIdList = new List<Id>();
        List<Account> updAccList = new List<Account>();
        List<String> resultObjGUIDList = new List<String>();
        Map<String,List<String>> mapQryIndicator = new Map<String,List<String>>();
        Map<String,String> mapPltfmEntIndct = new Map<String,String>();
        String strObjName = 'Account';
        String strPltfromEvntName = System.Label.L2O_Account_Platform_Event;
        String strPltfmEntIndct = '';
             
        // Calling L2O_PlatformEvent_MetadataHandler class to check if the Platform Event is Active
        L2O_PlatformEvent_MetadataHandler getmethodIns = new L2O_PlatformEvent_MetadataHandler();
        if(!getmethodIns.getMetadataPlatformEvents(strPltfromEvntName)){
            return;
        }         
        for (Account tempAccount : updatedAccounts) {
            if(tempAccount.L2O_Account_Status__c == 'Client' && tempAccount.L2O_Broadcast_Message__c){
                strPltfmEntIndct = setIndicators(tempAccount, oldAccounts, mapQryIndicator);
                if(!String.isEmpty(strPltfmEntIndct)){
                    accIdList.add(tempAccount.Id);
                    mapPltfmEntIndct.put(tempAccount.L2O_GUID__c,strPltfmEntIndct);
                   }
              }
        }
        if(!accIdList.isEmpty()){
           L2O_PlatFormEvent_Ctrl helper = new L2O_PlatFormEvent_Ctrl();
            resultObjGUIDList = helper.publishPlatFormEvents(strObjName,strPltfromEvntName,accIdList,mapQryIndicator,mapPltfmEntIndct);
            if(resultObjGUIDList.size()>0){
                for(Account tempAccount : [SELECT Id, L2O_Last_Integration_Date__c FROM Account WHERE L2O_GUID__c =: resultObjGUIDList]){
                    tempAccount.L2O_Last_Integration_Date__c = DateTime.now();
                    updAccList.add(tempAccount);
                }
            }
            //update Account
            if(!updAccList.isEmpty()){
                update updAccList;
            }
            
        }
        
    }
    /**
	* @name  setIndicators
	* @description This method will set the indicator fields for platform event
	* @param  tempAccount will hold the current account record
    * @param  oldAccounts for trigger.old Accounts
    * @param mapQryIndicator this will hold the map of current record GUID as key and the repective indicator
    * @return will return the String of platform Event Indicators
	**/
    public String setIndicators(Account tempAccount, Map<Id,sObject> oldAccounts,Map<String,List<String>> mapQryIndicator){
                                  String strPltfmEntIndct = '';
                                  if(tempAccount.Name != oldAccounts.get(tempAccount.Id).get('Name')){
                                      mapQryIndicator.put(tempAccount.L2O_GUID__c, new List<String>());
                                      mapQryIndicator.get(tempAccount.L2O_GUID__c).add('Name');
                                      strPltfmEntIndct += 'OI-U,';
                                      }
                                  if(tempAccount.BillingCity != oldAccounts.get(tempAccount.Id).get('BillingCity') || 
                                     tempAccount.BillingCountry != oldAccounts.get(tempAccount.Id).get('BillingCountry') || 
                                     tempAccount.BillingState != oldAccounts.get(tempAccount.Id).get('BillingState') || 
                                     tempAccount.BillingStreet != oldAccounts.get(tempAccount.Id).get('BillingStreet') || 
                                     tempAccount.BillingPostalCode != oldAccounts.get(tempAccount.Id).get('BillingPostalCode')){
                                         if(!mapQryIndicator.containsKey(tempAccount.L2O_GUID__c)){
                                             mapQryIndicator.put(tempAccount.L2O_GUID__c, new List<String>());
                                         }
                                         mapQryIndicator.get(tempAccount.L2O_GUID__c).add('BA');
                                         strPltfmEntIndct += 'BA-U,OI-U,';
                                         }
                                  if(tempAccount.ShippingCity != oldAccounts.get(tempAccount.Id).get('ShippingCity') || 
                                     tempAccount.ShippingCountry != oldAccounts.get(tempAccount.Id).get('ShippingCountry') || 
                                     tempAccount.ShippingState != oldAccounts.get(tempAccount.Id).get('ShippingState') || 
                                     tempAccount.ShippingStreet != oldAccounts.get(tempAccount.Id).get('ShippingStreet') || 
                                     tempAccount.ShippingPostalCode != oldAccounts.get(tempAccount.Id).get('ShippingPostalCode')){
                                         if(!mapQryIndicator.containsKey(tempAccount.L2O_GUID__c)){
                                             mapQryIndicator.put(tempAccount.L2O_GUID__c, new List<String>());
                                         }
                                         mapQryIndicator.get(tempAccount.L2O_GUID__c).add('SA');
                                         strPltfmEntIndct += 'SA-U,OI-U,';
                                         }
        return strPltfmEntIndct;
                                 }
    
	/**
	* @name  setGUID
	* @description setGUID
	* @param  newAccounts for trigger.new Accounts
    * @param  oldAccounts for trigger.old Accounts
	**/
    
    public void updateClientStatusDate(List<Account> newAccounts,Map<Id,sObject> oldAccounts) {
        
     
        for (Account tempAccount : newAccounts) {                       
            if (oldAccounts.get(tempAccount.Id).get('L2O_Account_Status__c') != tempAccount.L2O_Account_Status__c && tempAccount.L2O_Account_Status__c == 'Client') {                
               tempAccount.L2O_Client_status_date__c = date.today();
          
            }                                   
        }
       
    }
    
  /*****************************************************
    /* Method Name        : keepAccountTeamMembers
    /* CreatedDate   	  : 27-12-2023
    /* Author             : Preethi
    /* Method Description : To retain the Account team members if the owner of the account record changed.
    /* Jira Ticket		  : SCDEV-4598
    /* Method Parameters  : updatedAccounts for trigger.new Accounts
	                        oldAccounts for trigger.oldMap Accounts
  ******************************************************/
    public void keepAccountTeamMembers(List<Account> newAccounts,Map<Id,sObject> oldAccounts)
    {
        List<AccountTeamMember>accteam=new List<AccountTeamMember>();
        Map<String,AccountTeamMember>accteamMap=new Map<String,AccountTeamMember>();
        List<AccountTeamMember>reinsertaccteam=new List<AccountTeamMember>();
        for(Account acc:newAccounts)
        {
            if(acc.OwnerId != oldAccounts.get(acc.Id).get('OwnerId'))
            {
               for(AccountTeamMember team:[Select Id,User.Name,AccountId,TeamMemberRole from AccountTeamMember where AccountId=:acc.Id ALL ROWS])
                {
                    reinsertaccteam.add(team.clone(false, false, false, false));
                }
                Database.insert(reinsertaccteam,false); 
             } 
         }
                       
     }

    
}