@isTest
public class FilteredRelatedListCtrlTest {
    @TestSetup
    static void setupFilteredRelatedListCtrl() {

        Account__c acc = new Account__c();
        acc.Name = 'Test Account';

        insert acc;

        List<Contact__c> contacts = new List<Contact__c>();

        Contact__c c1 = new Contact__c();
        c1.FirstName__c = 'Test';
        c1.LastName__c = 'A';
        c1.Account__c = acc.Id;
        contacts.add(c1);

        Contact__c c2 = new Contact__c();
        c2.FirstName__c = 'Test';
        c2.LastName__c = 'B';
        c2.Account__c = acc.Id;
        contacts.add(c2);

        Contact__c c3 = new Contact__c();
        c3.FirstName__c = 'Test';
        c3.LastName__c = 'C';
        c3.Account__c = acc.Id;
        contacts.add(c3);
        
        insert contacts;
    }

    @isTest
    static void getParentSObjectIdTest() {
        String queryString = 'SELECT Id, Name FROM Account__c';

        Test.startTest();

        Account__c a = (Account__c) FilteredRelatedListCtrl.getParentSObject(queryString);

        Test.stopTest();

        System.assertNotEquals(null, a);
        System.assertNotEquals(null, a.Id);
        System.assertEquals('Test Account', a.Name);
    }

    @isTest
    static void getRelatedTest() {
        Account__c acc = [SELECT Id, Name FROM Account__c WHERE Name = 'Test Account'];
        Id accountId = acc.Id;
        String queryString = 'SELECT Id, FirstName__c, LastName__c, Account__c FROM Contact__c WHERE Account__c = ';
        queryString +=  '\'' + String.escapeSingleQuotes(accountId) + '\'';
                
        Test.startTest();

        List<Contact__c> contacts = FilteredRelatedListCtrl.getRelated(queryString);

        Test.stopTest();

        System.assertEquals(false, contacts.isEmpty());
        System.assertEquals(3, contacts.size());
    }
    
    @isTest
    static void getMetadataForColumnsTest() {
        List<String> columns = new List<String>();
        columns.add('FirstName__c');
        columns.add('MobilePhone__c');
        columns.add('LastCURequestDate__c');
        columns.add('LeadSource__c');

        Test.startTest();

        Map<String, String> metadataForColumns = FilteredRelatedListCtrl.getMetadataForColumns('Contact__c', columns);

        Test.stopTest();

        System.assertEquals(4, metadataForColumns.keySet().size());
        for (String label : metadataForColumns.keySet()) {
            if (label.equals('First Name')) {
                System.assertEquals('First Name', label);
            }
            else if (label.equals('Mobile Phone')) {
                System.assertEquals('Mobile Phone', label);
            }
            else if (label.equals('Last Stay-in-Touch Request Date')) {
                System.assertEquals('Last Stay-in-Touch Request Date', label);
            }
            else if (label.equals('Lead Source')) {
                System.assertEquals('Lead Source', label);
            }
        }
        for (String fieldType : metadataForColumns.values()) {
            if (fieldType.equals('STRING')) {
                System.assertEquals('STRING', fieldType);
            }
            else if (fieldType.equals('DATETIME')) {
                System.assertEquals('DATETIME', fieldType);
            }
            else if (fieldType.equals('PHONE')) {
                System.assertEquals('PHONE', fieldType);
            }
            else if (fieldType.equals('PICKLIST')) {
                System.assertEquals('PICKLIST', fieldType);
            }
        }
    }
}