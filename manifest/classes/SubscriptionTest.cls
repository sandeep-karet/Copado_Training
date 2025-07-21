/**
* Created by amruthakommuri on 2019-11-04.
*/

@isTest
public with sharing class SubscriptionTest {
    //Defined test dataset
    @testSetup
    static void setupdata() {
        Test.startTest() ;
        Account umrAcct = TestDataFactory.createUMR();
        //create an account record
        Account accObj = TestDataFactory.createAccountUMR();
        
        //Create Account Relationships
        List<Acct_Rel__c> accRelList = new List<Acct_Rel__c>();
        
        Acct_Rel__c acctRel1 = TestDataFactory.createAccRel(accObj.Id);
        accRelList.add(acctRel1);
        
        //create an opportunity record
        Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
        oppObj2.LeadSource = 'Sales';
        oppObj2.Pricebook2Id = Test.getStandardPricebookId();
        insert oppObj2;
        
        List<SBQQ__Quote__c> quoList = new List<SBQQ__Quote__c>();
        
        //Create 2 quote records
        SBQQ__Quote__c quoObj1 = TestDataFactory.createQuote(oppObj2.Id);
        insert quoObj1;
        
        list<Product2> prodlist = new List<Product2>();
        
        //create TD Standard Bundle product
        Product2 prod2 = TestDataFactory.createSingleProduct(
            'TD Bundle - Standard',
            'Teladoc',
            'TD-STD'
        );
        prodlist.add(Prod2);
        
        //create Gen Med product
        Product2 prod3 = TestDataFactory.createSingleProduct(
            'General Medical',
            'General Medical',
            'GM'
        );
        prodlist.add(Prod3);
        
        insert prodlist;
        Test.stopTest() ;
        //Create quote lines for the primary quote
        SBQQ__QuoteLine__c quoline1 = TestDataFactory.createQuoteLine(
            quoObj1.Id,
            prod2.Id
        );
        insert quoline1;
        
        SBQQ__QuoteLine__c quoline2 = TestDataFactory.createQuoteLine(
            quoObj1.Id,
            prod3.Id
        );
        insert quoline2;
        
        //create a contract record 2
        Contract conObj2 = TestDataFactory.createContract(
            accObj.Id,
            oppObj2.Id,
            null
        );
        //insert conObj2;
        
        //Create a Member Group
        Mbr_Group__c mbr1 = TestDataFactory.createMbrGroup(accObj.Id)[0];
        
        //Create a Subscription record
        SBQQ__Subscription__c subs1 = TestDataFactory.createSub(
            accObj.Id,
            conObj2.Id
        )[0];
        
        //Create a psf record
        Plan_Specific_Fees__c psf1 = TestDataFactory.createPlanSpecificFees(
            null,
            mbr1.Id,
            subs1.Id
        );
        psf1.Product_Start_Date__c = Date.Today();
        insert psf1;
        
    }
    
    //Try to delete the subscription without deleting psf record
    @isTest
    static void delSubscription() {
        SBQQ__Subscription__c sub1 = [SELECT id FROM SBQQ__Subscription__c];
        
        Test.startTest();
        try {
            delete sub1;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage()
                .contains('1 PSF associated to this subscription.')
                ? true
                : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }
    
    //deleting psf will allow deletion of subscription
    @isTest
    static void delpsfBeforeSubscrpition() {
        PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
            SetupOwnerId = UserInfo.getUserId(),
            User_Permission__c = true
        );
        insert objDS;
        Test.startTest();
        List<Plan_Specific_Fees__c> psf = [
            SELECT id, IsDeleted
            FROM Plan_Specific_Fees__c
        ];
        List<SBQQ__Subscription__c> sub1 = [
            SELECT id, IsDeleted
            FROM SBQQ__Subscription__c
        ];
        delete psf;
        system.debug('Is psf deleted?' + psf.size());
        delete sub1;
        System.debug('Is subscription deleted?' + sub1.size());
        //System.assertEquals(true,sub1.isEmpty());
        System.debug('sub list size' + sub1.size());
        Test.stopTest();
    }
}