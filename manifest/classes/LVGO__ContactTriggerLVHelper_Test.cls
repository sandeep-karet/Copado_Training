@isTest
public class ContactTriggerLVHelper_Test {
@isTest
    public static void testContactTrigger(){
        LVGO_Automation_Switch__c switchFlg = LVGO_Automation_Switch__c.getInstance();
        switchFlg.Triggers__c = True;
        upsert switchFlg;
        Account__c acc1 = new Account__c(name = 'acc1');
        insert acc1;
        Account__c acc2 = new Account__c(name = 'acc2');
        insert acc2;
        Contact__c con = new contact__c(LastName__c='testcont',account__c = acc1.id);
        insert con;
        con.account__c = acc2.id;
        update con;
        
    }
}