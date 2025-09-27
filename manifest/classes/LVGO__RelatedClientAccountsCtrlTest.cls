@isTest
public class RelatedClientAccountsCtrlTest {

    public static final Id PARTNER_ACCOUNT_RT_ID = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
    public static final Id CLIENT_ACCOUNT_RT_ID = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
    public static final Id CONTRACT_PARTNERSHIP_RT_ID = Schema.SObjectType.Relationship__c.getRecordTypeInfosByDeveloperName().get('Contract_Partnership').getRecordTypeId();


    public static Account__c getPartnerAccount() {
        Id partnerAccountRTId = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
        return [SELECT Id, RecordTypeId, Name FROM Account__c WHERE RecordTypeId = :PARTNER_ACCOUNT_RT_ID LIMIT 1];
    }

    @TestSetup
    static void setupData() {
        Account__c partnerAccount = TestFactory.createPartnerAccount();
        insert partnerAccount;
        
        Contract__c co = TestFactory.createClientOverview();
        co.Account__c = partnerAccount.Id;
        insert co;
        
        List<Relationship__c> allRelationships = new List<Relationship__c>();
        Relationship__c rel1 = TestFactory.createRelationship('Contract Path');
        rel1.RecordtypeId=CONTRACT_PARTNERSHIP_RT_ID; 
        allRelationships.add(rel1);    
        insert allRelationships; 
    }

    @isTest
    static void getRelatedClientAccountsRelationshipsLinkedToPartnerAccountTest() {
        Account__c partnerAccount = getPartnerAccount();
        
        List<Relationship__c> relationships = [SELECT Id, Name, RecordTypeId, Master_Account__c, Master_Client_Account__c FROM Relationship__c WHERE RecordTypeId = :CONTRACT_PARTNERSHIP_RT_ID];
        for (Relationship__c rel : relationships) {
            rel.Master_Account__c = partnerAccount.Id;
        }
        
        update relationships;

        Test.startTest();

        List<Relationship__c> rels  = RelatedClientAccountsCtrl.getRelatedClientAccounts(partnerAccount.Id);

        Test.stopTest();
        
        //Should be multiple Relationships created
        System.assertNotEquals(0, rels.size());
        for (Relationship__c rel : rels) {
            //Each Relationship should be associated with the Partner Account
            System.assertEquals(partnerAccount.Id, rel.Master_Account__c);
            //Each Relationship should have the Contract Partnership Record Type
            System.assertEquals(CONTRACT_PARTNERSHIP_RT_ID, rel.RecordTypeId);
        }
    }

    @isTest
    static void getRelatedClientAccountsRelationshipsNotLinkedToPartnerAccountTest() {
        Account__c partnerAccount = getPartnerAccount();

        Test.startTest();
        
        List<Relationship__c> rels = RelatedClientAccountsCtrl.getRelatedClientAccounts(partnerAccount.Id);

        Test.stopTest();

        //No Relationships should be returned as they were never associated with a Partner Account
        System.assertEquals(0, rels.size());
    }
}