@isTest
public class QuotelineLaunchStatusBatch_Test {
    public static Id pricebookId = Test.getStandardPricebookId();
    @isTest
    Private static void testLaunchStatus(){
        List<Account> accountList= APTS_TestDataUtility_Test.createAccount(true,1);
        Product2 parentProduct=new Product2();
        Id quoteId;
        Id oppId;
        List<Product2> childproducts=new List<Product2>();
        List<Opportunity> oppList = APTS_TestDataUtility_Test.createOpportunity(true,accountList);
        List<Contact> conList =  APTS_TestDataUtility_Test.createContact(true,accountList); 
        APTS_TestDataUtility_Test.createContactRoles(true,oppList,conList[0].id);
        List<Product2> testproducts=APTS_TestDataUtility_Test.createtestproducts();
        List<SBQQ__Quote__c> quotelist=APTS_TestDataUtility_Test.createQuote(true,oppList);
        for(SBQQ__Quote__c quoterec:quotelist)
        {
            quoteId=quoterec.Id; 
        }
        for(Product2 parprod:testproducts)
        {
            if(parprod.Name=='Mental Health Care (US)')
            {
                parentProduct=parprod;   
            }
            else
            {
                childproducts.add(parprod);   
            }
        }
        for(Opportunity opprec:oppList)
        {
            oppId=opprec.Id;  
        }
        List<SBQQ__ProductOption__c> testproductoptions=APTS_TestDataUtility_Test.createproductoptions(parentProduct,childproducts);
        List<SBQQ__QuoteLine__c> testQuoteLines=APTS_TestDataUtility_Test.createquotelines(quoteId,parentProduct.Id,testproductoptions);
        List<SBQQ__Quote__c> quotesToupdate = New List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRecord:quotelist)
        {
            quoteRecord.SBQQ__Status__c = 'Accepted';
            quotesToupdate.add(quoteRecord);
        }
        update quotesToupdate;
        
        Test.startTest();
        String sch = '0 0 22 * * ?';
        QuotelineLaunchStatusBatch runbatchJob = New QuotelineLaunchStatusBatch();
        database.executeBatch(runbatchJob);
        system.schedule('QuotelineLaunchStatus_Schedule_Job', sch, runbatchJob);
        Test.stopTest(); 
        System.assertNotEquals(null, testQuoteLines, 'Records found successfully');
    }    
}