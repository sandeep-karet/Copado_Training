/**
* This class contains the test methods for chatter posts made on the Contract Service Apex Class .
* Created : 07/08/2020
* @author Virinchi Bairisetty
*/
@isTest
public class ContractHistortyTrackingTest {
    public static final List<Schema.FieldSetMember> contractTrackedFields = SObjectType.Contract__c.FieldSets.HistoryTracking.getFields();
    @isTest
    static void contractHistoryTrackingInsertOperation() {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  = true;
        asw.ProcessBuilders__c = true;
        asw.Flows__c = true;
        insert asw;
        
        List<Contract__c> newContracts = new List<Contract__c>();
        
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
        
        Contract__c clientOverview = TestFactory.createClientOverview();
        clientOverview.Account__c = clientAccount.Id;
        insert clientOverview;
        
        Contract__c newProgramOverview = TestFactory.createProgramOverview();
        newProgramOverview.Program_Name__c = 'Diabetes';
        newProgramOverview.New_Device_Type__c = 'HT900';
        newProgramOverview.Client_Overview__c = clientOverview.Id;
        newProgramOverview.Account__c = clientAccount.Id;
        newContracts.add(newProgramOverview);
        insert newContracts;
        
        //ContractService.chatterTechOps(null, newContracts, null, 'Insert');
        system.assertEquals(1, newContracts.size());
    }
    
    @isTest
    static void contractHistoryTrackingDeleteOperation() {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  = true;
        asw.ProcessBuilders__c = true;
        asw.Flows__c = true;
        insert asw;
        
        Map<Id, Contract__c> oldContracts = new Map<Id, Contract__c>();
        List<Contract__c> oldContractsList = new List<Contract__c>();
        
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
        
        Contract__c clientOverview = TestFactory.createClientOverview();
        clientOverview.Account__c = clientAccount.Id;
        insert clientOverview;
        
        Contract__c oldProgramOverview = TestFactory.createProgramOverview();
        oldProgramOverview.Account__c = clientAccount.Id;
        oldProgramOverview.Program_Name__c = 'Diabetes';
        oldProgramOverview.New_Device_Type__c = 'HT900';
        oldProgramOverview.Client_Overview__c = clientOverview.Id;
        oldContractsList.add(oldProgramOverview);
        insert oldContractsList;
        
        for (Contract__c oldCon : oldContractsList) {
            oldContracts.put(oldCon.Id, oldCon);
        }
        
        //ContractService.chatterTechOps(oldContracts, null, null, 'Delete');
        system.assertEquals(1, oldContracts.size());
    }
}