/**
* This class serves as a handler for the Contract trigger.
* Created : 05/13/2019
* @author Connor Gallaher - Slalom
*/

public class ContractTriggerHandler {
    public static final Id CLIENT_OVERVIEW_RT =  Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId(); 
    public static final Id PROGRAM_OVERVIEW_RT = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId();
    
    public static void handleContractAfterInsert(List<Contract__c> newContracts) {
        if (!Test.isRunningTest()){}
            //ContractService.chatterTechOps(null, newContracts, null, 'Insert');
    }
    
    public static void handleContractBeforeInsert(List<Contract__c> newContracts) { 
        List<Contract__c> conList = new List<Contract__c>();
        for(Contract__c con : newContracts) {
            if(con.RecordTypeId == PROGRAM_OVERVIEW_RT && !String.IsBlank(con.Client_Overview__c)) {
                conList.add(con);
            }
        }
        if(!conList.isEmpty()) {
            ContractService.getDetailsFromCoToPo(conList);
        }
    }
    public static void handleContractUpdate(Map<Id, Contract__c> oldContracts, List<Contract__c> newContracts) {
        List<Contract__c> initialContractsToRenew = new List<Contract__c>();
        List<Contract__c> programsToUpdateHS = new List<Contract__c>();
        List<Contract__c> coWithCampaignFieldUpdates = new List<Contract__c>();
        //Iterate through contracts to find the POs which are marked complete (TRUE)
        //AND which used to be marked incomplete previously (FALSE)
        //Note: This is because the SpringCM workflow unchecks (FALSE) the Complete Per Legal field at the beginning of the workflow
        //and rechecks (TRUE) the Complete Per Legal field at the end of the workflow
        for (Contract__c c : newContracts) {
            if (c.Complete_Per_Legal__c && (c.Complete_Per_Legal__c != oldContracts.get(c.Id).Complete_Per_Legal__c)) {
                initialContractsToRenew.add(c);
            }
            
            if (c.RecordTypeId == PROGRAM_OVERVIEW_RT && c.Actual_Launch_Date__c != null && c.Actual_Launch_Date__c != oldContracts.get(c.Id).Actual_Launch_Date__c ||
                c.Outreach_Stratification__c != null && c.Outreach_Stratification__c != oldContracts.get(c.Id).Outreach_Stratification__c) {
                    programsToUpdateHS.add(c);
            }
            
            if(c.RecordTypeId == CLIENT_OVERVIEW_RT && 
               ((!String.IsBlank(c.Campaign_Lifecycle_Participation__c) && c.Campaign_Lifecycle_Participation__c != oldContracts.get(c.Id).Campaign_Lifecycle_Participation__c) ||
                (!String.IsBlank(c.Campaign_Type__c) && c.Campaign_Type__c != oldContracts.get(c.Id).Campaign_Type__c) || 
                (!String.IsBlank(c.Custom_Campaign__c) && c.Custom_Campaign__c != oldContracts.get(c.Id).Custom_Campaign__c) ||
                (!String.IsBlank(c.Phone_Campaign__c) && c.Phone_Campaign__c != oldContracts.get(c.Id).Phone_Campaign__c) || 
                (c.Enrollment_on_Autopilot__c != oldContracts.get(c.Id).Enrollment_on_Autopilot__c) && c.Enrollment_on_Autopilot__c == true )) {
                coWithCampaignFieldUpdates.add(c);                                           
            }
        }
        //Pass list of changed Contracts to ContractService class
        if (!initialContractsToRenew.isEmpty()) {
            //ContractService.autoCreateRenewalOpportunities(initialContractsToRenew);
        }
        
        //Tracking Fields and notifying TechOps Chatter Group
        final List<Schema.FieldSetMember> contractTrackedFields = SObjectType.Contract__c.FieldSets.HistoryTracking.getFields();
        if (!contractTrackedFields.isEmpty()) {
            if (!Test.isRunningTest()){}
                //ContractService.chatterTechOps(oldContracts, newContracts, contractTrackedFields, 'Update');    
        }
        
        if (!programsToUpdateHS.isEmpty()) {
            ContractService.updateHealthScores(programsToUpdateHS);
        }
        
        if(!coWithCampaignFieldUpdates.isEmpty()) {
            ContractService.copyCoDetailsToPOs(oldContracts,coWithCampaignFieldUpdates);
        }
    }
    //JENGA-1304 Users will not be able to delete the Client Overviews if there are any Program Overviews associated
    public static void handleContractDelete(List<Contract__c> oldContracts) {
        List<Contract__c> programOverviewList = [SELECT Id From Contract__c WHERE Client_Overview__c IN :oldContracts];
        for (Contract__c c: oldContracts) {
            Id contractRecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId();
            if (c.RecordTypeId == contractRecordTypeId && programOverviewList.Size() > 0) {
                c.addError(System.Label.ClientOverviewDeleteMessage);
            }   
        }
    }
    public static void handleContractAfterDelete(Map<Id, Contract__c> oldContracts) {
        if (!Test.isRunningTest()){}
            //ContractService.chatterTechOps(oldContracts, null, null, 'Delete');
    }
}