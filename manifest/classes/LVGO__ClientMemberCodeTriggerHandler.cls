public class ClientMemberCodeTriggerHandler {
    public static void handleCMCAfterInsert(List<ClientMemberCode__c> newContracts) {
        ClientMemberCodeService.chatterTechOps(newContracts, 'Insert');
    }
	public static void handleAfterCMCUpdate(List<ClientMemberCode__c> oldContracts) {
        ClientMemberCodeService.chatterTechOps(oldContracts, 'Delete');
    }
}