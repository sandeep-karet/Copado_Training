/**
* Company : PwC.
* @description : L2O_OperationOnAmmendedOpportunity will be executed from the L2O_OpportunityTriggerHandler and will extend the L2O_TriggerHandler class .
* ************************************************************************************************************************************
* History : 
* @date 07/04/2022
* @author Neha Sharma
*/
public without sharing class L2O_OperationOnAmmendedOpportunity {
    /**
* @name  createContactRoleOnAmmendedOpportunity
* @description mapping quote status to opportunity stage
* @params none
*/  
    public void createContactRoleOnAmmendedOpportunity(){
        List<Opportunity> newOpportunityList = Trigger.New;
        List<Opportunity> ammendedOpportunityList = new List<Opportunity>();
        Map<String,String> ammendedFromAccountOpportunityMap = new  Map<String,String>();
        List<OpportunityContactRole> insertContactRoleList = new List<OpportunityContactRole>();
        Map<Id,Id> contractOppMap = new Map<Id,Id>();
        Set<Id> contractIdSet = new Set<Id>();
        for(Opportunity opp: newOpportunityList){
            if(opp.SBQQ__AmendedContract__c != null){
                ammendedOpportunityList.add(opp);
                contractIdSet.add(opp.SBQQ__AmendedContract__c);
                contractOppMap.put(opp.SBQQ__AmendedContract__c,opp.id);
            }
            if(opp.L2O_IsAccountAmendAssets__c){
               
                ammendedFromAccountOpportunityMap.put(opp.Id,opp.L2O_Amend_Asset_Contact__c);
                
            }
            
        }
        if(!ammendedOpportunityList.isEmpty() || !ammendedFromAccountOpportunityMap.isEmpty()){
            insertContactRoleList = getContactRolesToInsert(contractIdSet,contractOppMap,ammendedFromAccountOpportunityMap);
            
        }
        
        // Insert OpportunityContactRole
        if(!insertContactRoleList.isEmpty()){
            Database.insert(insertContactRoleList,true);
        }
        
    }
    /**
* @name  getContactRolesToInsert
* @description calculating the contact roles to be attached
* @param  contractIdSet to pass the new values
* @param  contractOppCurrentMapp to pass the amended 
* @param  amendFromAssetContactRoleMap to pass the amended 
* @return List<OpportunityContactRole>
**/
    public List<OpportunityContactRole> getContactRolesToInsert(Set<Id> contractIdSet,Map<Id,Id> contractOppCurrentMapp,Map<String,String> amendFromAssetContactRoleMap){
        Set<Id> oppIdSet = new Set<Id>(); 
        Map<Id,Id> contractRenewOppMap = new Map<Id,Id>(); 
        Map<Id,Id> contractOppMap = new Map<Id,Id>(); 
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> oppContactRoletoInsertList = new List<OpportunityContactRole>();
        
        for(Contract con: [SELECT id,SBQQ__RenewalOpportunity__c,SBQQ__Opportunity__c 
                               FROM Contract 
                               WHERE Id IN :contractIdSet]){
                oppIdSet.add(con.SBQQ__Opportunity__c); 
                contractOppMap.put(con.SBQQ__Opportunity__c,con.id);
                contractRenewOppMap.put(con.id,con.SBQQ__RenewalOpportunity__c);
            }
            
            //getting contactroles for existing opportunities
            if(!oppIdSet.isEmpty()){
            for(Opportunity opp : [SELECT id,
                                   (SELECT id,Role,OpportunityId,IsPrimary,ContactId,L2O_Broker_Flat_Rate__c,
                                    L2O_Broker_Percentage__c,L2O_Chronic_Care_Flat_Rate__c,L2O_Chronic_Care_Percentage__c
                                   FROM OpportunityContactRoles) 
                                   FROM Opportunity 
                                   WHERE ID IN: oppIdSet]){
                for(OpportunityContactRole oppCon: opp.OpportunityContactRoles){
                    oppContactRoleList.add(oppCon);
                }
             } 
        }
            if(!oppContactRoleList.isEmpty()){
               
                oppContactRoletoInsertList = getContactRoleValues(oppContactRoleList,contractOppCurrentMapp,contractOppMap);
            } 
        //getting contactroles for existing opportunities for ammend asset functionality
        if(!amendFromAssetContactRoleMap.isEmpty()){
            for (String key : amendFromAssetContactRoleMap.keySet()) {
                OpportunityContactRole oppConRole = new OpportunityContactRole();
                 oppConRole.OpportunityId =  key ;
                 oppConRole.ContactId = amendFromAssetContactRoleMap.get(key);
                 oppContactRoletoInsertList.add(oppConRole);
            }
            
        }
        // Return list of OpportunityContactRole
        return oppContactRoletoInsertList;  
    }
    /**
* @name  getContactRoleValues
* @description calculating the contact roles to be attached
* @param  existingRolesList to pass the new values
* @param  contractOppCurrentMapp to pass the amended 
* @param  contractOppMap to pass the amended 
* @return List<OpportunityContactRole>
**/   
    public List<OpportunityContactRole> getContactRoleValues(List<OpportunityContactRole> existingRolesList,Map<Id,Id> contractOppCurrentMapp,Map<Id,Id> contractOppMap){
        List<OpportunityContactRole> oppContactRoletoInsertList = new List<OpportunityContactRole>();
        for(OpportunityContactRole oppCon: existingRolesList){
                      String contractId = contractOppMap.get(oppCon.OpportunityId);
                   
                    //check if the contract is not null and existing opportunity has comments
                    if(contractId != null && contractOppCurrentMapp.get(contractId) != null){
                        OpportunityContactRole oppConRole = new OpportunityContactRole();
                        oppConRole.Role = oppCon.role;
                        oppConRole.IsPrimary = oppCon.IsPrimary;
                        oppConRole.OpportunityId =  contractOppCurrentMapp.get(contractId);
                        oppConRole.ContactId = oppCon.ContactId;
                        oppContactRoletoInsertList.add(oppConRole);
                        // Populate the Role and Commission Rate fields #169948
                            if(oppCon.Role == L2O_Constants.OPPCON_ROLE_BROKER || oppCon.Role == L2O_Constants.OPPCON_ROLE_BENEFIT_CONSULTANT || oppCon.Role == L2O_Constants.OPPCON_ROLE_GENERAL_AGENCY){
                                oppConRole.L2O_Broker_Flat_Rate__c = oppCon.L2O_Broker_Flat_Rate__c;
                                oppConRole.L2O_Broker_Percentage__c = oppCon.L2O_Broker_Percentage__c;
                                oppConRole.L2O_Chronic_Care_Flat_Rate__c = oppCon.L2O_Chronic_Care_Flat_Rate__c;
                                oppConRole.L2O_Chronic_Care_Percentage__c = oppCon.L2O_Chronic_Care_Percentage__c;
                            }
                        
                    }
                }
        // Return list of OpportunityContactRole
        return oppContactRoletoInsertList;
        
    }   
    
}