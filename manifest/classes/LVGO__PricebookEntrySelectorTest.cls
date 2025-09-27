/**
* This is the test class for the PricebookEntrySelector Apex class.
* Created : 07/02/2019
* @author Connor Gallaher - Slalom
*/
@isTest
public class PricebookEntrySelectorTest {
    @TestSetup
    static void setupData() {
        Pricebook2 livongoPricebook = TestFactory.createPricebook();
        insert livongoPricebook;

        List<Product2> programs = new List<Product2>();
        Product2 program = TestFactory.createProgram('Diabetes');
        Product2 program2 = TestFactory.createProgram('Hypertension');
        Product2 program3 = TestFactory.createProgram('Behavioral Health');
        programs.add(program);
        programs.add(program2);
        programs.add(program3);
        insert programs;

        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry standardPBE1 = TestFactory.createPricebookEntry(standardPBId, program.Id);
        PricebookEntry standardPBE2 = TestFactory.createPricebookEntry(standardPBId, program2.Id);
        PricebookEntry standardPBE3 = TestFactory.createPricebookEntry(standardPBId, program3.Id);
        PricebookEntry pbe1 = TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id);
        PricebookEntry pbe2 = TestFactory.createPricebookEntry(livongoPricebook.Id, program2.Id);
        PricebookEntry pbe3 = TestFactory.createPricebookEntry(livongoPricebook.Id, program3.Id);

        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(standardPBE1);
        entries.add(standardPBE2);
        entries.add(standardPBE3);
        entries.add(pbe1);
        entries.add(pbe2);
        entries.add(pbe3);
        insert entries;
    }
    @isTest
    static void getPricebookEntriesForPricebookValidPricebookId() {
        List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2];
        System.debug(pricebooks.size());

        Test.startTest();

        List<PricebookEntry> entries = PricebookEntrySelectorCtrl.getPricebookEntriesForPricebook(pricebooks[0].Id);

        Test.stopTest();

        System.assertNotEquals(null, entries);
        System.assertEquals(true, entries.size() > 0);
    }

    @isTest
    static void getPricebookEntriesForPricebookInvalidPricebookId() {
        List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2];
        System.debug(pricebooks.size());

        Test.startTest();

        List<PricebookEntry> entries = PricebookEntrySelectorCtrl.getPricebookEntriesForPricebook(null);

        Test.stopTest();

        System.assertEquals(0, entries.size());
    }
}