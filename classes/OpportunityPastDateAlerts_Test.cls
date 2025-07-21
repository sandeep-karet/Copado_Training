@isTest
private class OpportunityPastDateAlerts_Test {
    public static Id pricebookId = Test.getStandardPricebookId();
    @isTest
    public static void test1(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            
        );
        insert u;
        List<Account> accountList= APTS_TestDataUtility_Test.createAccount(true,1);
        Product2 parentProduct=new Product2();
        Id quoteId;
        Id oppId;
        List<Product2> childproducts=new List<Product2>();
        List<Opportunity> oppList = APTS_TestDataUtility_Test.createOpportunity(false,accountList);
        oppList[0].CloseDate = Date.today().adddays(-3);
        oppList[0].OwnerId = u.Id;
        oppList[0].Type = 'Existing Business';
          oppList[0].L2O_Subtype__c = 'Change Order';
       upsert oppList;
               
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
        
        //Must have products in Review/Negotiation, Contracting, and Closed Won stages.
        Test.startTest();
        //SchedulableMonthlyEmail s=new SchedulableMonthlyEmail();
        //s.execute(null) ;
         OpportunityPastDateAlerts objPDA= new OpportunityPastDateAlerts ();
            Database.BatchableContext bc;
            SchedulableContext sc;
            objPDA.start(bc);
            objPDA.execute(bc,[Select Id,ManagerId,Manager.Email from User where id=:u.id]);
            objPDA.finish(bc);
           
        Test.stopTest();
    }
}