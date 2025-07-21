/**
* Company : PwC.
* @description : Test Class for L2O_QuoteTriggerHandler apex
* ************************************************************************************************************************************
* History : 
* @date 25/02/2022
* @author Harshita Paliwal
*/
@isTest
public class L2O_QuoteTriggerHandler_Test extends L2O_DataFactoryTest{
    
    /**
    * @name  testSetup 
    * @description To create setup records for test class.
    * @params  none
    **/
    @testSetup
    static void testSetup() {
       
        List<Account> accountList= L2O_DataFactoryTest.createAccount(true,1);  
        List<Opportunity> oppList = L2O_DataFactoryTest.createOpportunity(true,accountList); 
        List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id); 
        List<User> lstSystemAdmin = L2O_DataFactoryTest.createUsers(true,1,'System Administrator');
        List<User> lstClientManager = L2O_DataFactoryTest.createUsers(true,1,'Client Success');
         L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
         List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);    
         L2O_DataFactoryTest.createContract(oppList,QuoteList,accountList[0].id); 
        
        //Make Client Manager as Manager of System Admin
        lstSystemAdmin[0].ManagerId = lstClientManager[0].Id;
        User updateAdminUser = lstSystemAdmin[0];
        update updateAdminUser;
        
    }
    
    /**
    * @name  testQuoteDefaultValues
    * @description To test the Quote default fields with automated values.
    * @params  none
    **/
    @isTest static void testQuoteDefaultValues() {
        Test.startTest();
        List<Account> account = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunity =[SELECT Id,stageName FROM Opportunity WHERE Name != null LIMIT 1];
        
        Integer months = 12;
        Date startDate = Date.today();
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c  = opportunity[0].Id, SBQQ__Account__c = account[0].Id,
                                                  SBQQ__StartDate__c = startDate,SBQQ__SubscriptionTerm__c =months,SBQQ__Status__c = 'Draft');  
        
        insert quote;
        
        //Update the Quote with Approved Status
        quote.SBQQ__Status__c = 'Approved';  
        update quote;
        
        SBQQ__Quote__c quoteTest = [SELECT SBQQ__EndDate__c,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Name != null AND Id=:quote.Id];     
        //Date testDate = startDate.addMonths(months) - 1;
        //checking assertion for EndDate which is starteDate+SubscriptionTerm
        //System.assertEquals(testDate, quoteTest.SBQQ__EndDate__c,'Quote End Date is not set.');
        //checking assertion for Quote is Primary when it is Approved Status.
        System.assertEquals(true, quoteTest.SBQQ__Primary__c,'Quote Primary is False'); 
        Test.stopTest();     
        
    }
    
    /**
    * @name  testApprovalStatusToQuoteStatus
    * @description To test the Approval Status to Quote Status mapping updates
    * @params  none
    **/
    @isTest static void testApprovalStatusToQuoteStatus() {
        Test.startTest();
        List<Account> account = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunity =[SELECT Id FROM Opportunity WHERE Name != null LIMIT 1];
        
        Integer months = 12;
        Date startDate = Date.today();
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c  = opportunity[0].Id, SBQQ__Account__c = account[0].Id,
                                                  SBQQ__StartDate__c = startDate,SBQQ__SubscriptionTerm__c =months);  
        
        insert quote;
        
        SBQQ__Quote__c quoteTest = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE id=:quote.id LIMIT 1];
        
        //Initial Quote Status = Draft
        System.assertEquals('Draft', quoteTest.SBQQ__Status__c,'Quote Status is not Draft');
        
        //Updating the Approval Status = Pending        
        quoteTest.ApprovalStatus__c = 'Pending';  
        update quoteTest;
        //SBQQ__Quote__c quoteTest1 = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE id=:quote.id LIMIT 1];
        //checking assertion for Quote Status when Approval Status = Pending.
        //System.assertEquals('In Review', quoteTest1.SBQQ__Status__c,'Quote Status did not update to Pending'); 

		//Updating the Approval Status = Approved        
        quoteTest.ApprovalStatus__c = 'Approved';  
        update quoteTest;
        //SBQQ__Quote__c quoteTest2 = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE id=:quote.id LIMIT 1];
        //checking assertion for Quote Status when Approval Status = Approved.
        //System.assertEquals('Approved', quoteTest2.SBQQ__Status__c,'Quote Status did not update to Approved'); 
        
        Test.stopTest();     
        
    }
    
    /**
    * @name  testQuoteShare
    * @description To test the Quote Share records.
    * @params  none
    **/
    @isTest static void testQuoteShare() {
        Test.startTest();
        List<Account> account = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunity =[SELECT Id FROM Opportunity WHERE Name != null LIMIT 1];
        
        User systemAdmin =[SELECT Id,lastname,ManagerId FROM User 
                            WHERE lastname LIKE 'TestDataFactory%' AND ManagerId != null AND Profile.Name = 'System Administrator' LIMIT 1];
        
    
       
        System.runAs(systemAdmin){
            Integer months = 12;
            Date startDate = Date.today();
            
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c  = opportunity[0].Id, SBQQ__Account__c = account[0].Id,
                                                      SBQQ__StartDate__c = startDate,SBQQ__SubscriptionTerm__c =months);  
            
            insert quote;
            System.assertEquals(12, quote.SBQQ__SubscriptionTerm__c,'Quote is not updated');
            
          /*  List<SBQQ__Quote__Share> lstQuoteShare = [SELECT Id,UserOrGroupId, ParentId, AccessLevel FROM SBQQ__Quote__Share 
                                                      WHERE ParentId =: quote.Id
                                                      AND UserOrGroupId =: systemAdmin.ManagerId LIMIT 50];
            
           
            //To assert the Owner's Manager has Edit access to the Quote.
        	System.assertEquals('Edit', lstQuoteShare[0].AccessLevel,'Quote is not shared with Owners Manager');
            System.assertEquals(clientManager.Id, lstQuoteShare[0].UserOrGroupId,'Quote is not shared with Owners Manager');*/
        }
        
        Test.stopTest();   
        
    }
    /**
    * @name  testQuoteShare
    * @description To test the Quote Share records.
    * @params  none
    **/
    @isTest static void testQuoteStatusChange() {
        Test.startTest();
        
        Integer months = 12;
        Date startDate = Date.today();
        List<Account> account = [SELECT Id FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> opportunity =[SELECT Id FROM Opportunity WHERE Name != null LIMIT 1];
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c  = opportunity[0].Id, SBQQ__Account__c = account[0].Id,
                                                  SBQQ__StartDate__c = startDate,SBQQ__SubscriptionTerm__c = months,SBQQ__Status__c= 'Draft',SBQQ__Primary__c = true); 
        insert quote;
        quote.SBQQ__Status__c = 'In Review';
        update quote;
        system.assert(quote.SBQQ__Status__c == 'In Review', 'the status changed');
        Test.stopTest();
    }
    /**
    * @name  testQuoteDisableRenewaCoTerm
    * @description To test If field "Disable Renewal Co-Term" is checked on the Quote, then the Renewal Quote's End Date would be blank.
    * @params  none
    **/
    @isTest static void testQuoteDisableRenewaCoTerm() {
         Test.startTest();
        //fetch Contract
        Contract contractRec = [SELECT Id,contractNumber,SBQQ__Opportunity__r.L2O_Subtype__c,SBQQ__Opportunity__r.OwnerId,SBQQ__Opportunity__c  FROM Contract WHERE ContractTerm = 12 LIMIT 1];
        // update contract to generate Renewal Quote
	   contractRec.SBQQ__RenewalQuoted__c = true;
        update contractRec;
        // Fetch Renewal Quote
        SBQQ__Quote__c quote = [SELECT Id,L2O_Disable_Renewal_Co_Term__c,SBQQ__EndDate__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Renewal' LIMIT 1];
        // update Quote
        quote.L2O_Disable_Renewal_Co_Term__c = true;
         update quote;
        // Fetch the updated Renewal Quote
       SBQQ__Quote__c updtedquote = [SELECT iD, SBQQ__EndDate__c FROM SBQQ__Quote__c WHERE Id=: quote.Id LIMIT 1];
        system.assert(updtedquote.SBQQ__EndDate__c == null, 'End Date updated to blank');
        Test.stopTest();
    }
/**
    * @name  updateLaunchStatus
    * @description To test If the launch status is updated.
    * @params  none
    **/
    @isTest static void updateLaunchStatus() 
    {
    //Creating Account record
    Product2 parentProduct=new Product2();
    Account testaccount=new Account();   
    L2O_DataFactoryTest dataFactoryClass=new L2O_DataFactoryTest();
    List<Opportunity> oppList=[SELECT Id,AccountId,CloseDate,L2O_Subtype__c,L2O_Contract_Path__c,L2O_Contract_Path_Sub_type__c,L2O_Channel_Segment__c,L2O_Sub_Channel_Segment__c,Type FROM Opportunity WHERE Name != null LIMIT 1];
    List<Contact> conList=[Select Id,LastName from Contact WHERE LastName != null LIMIT 1];    
    List<Product2> childproducts=new List<Product2>(); 
    Id quoteId;
    Id accid;
    List<SBQQ__Quote__c> quotelist=dataFactoryClass.createSubQuote(true,oppList);
    Opportunity testopportunity=new Opportunity();    
    
    for(SBQQ__Quote__c quoterec:quotelist)
    {
        quoteId=quoterec.Id;   
    }
    //Creating Product records
    List<Product2> testproducts=dataFactoryClass.createtestSubproducts();
    for(Product2 parprod:testproducts)
    {
        if(parprod.Name=='InTouch Viewpoint Software License - Windows')
        {
            parentProduct=parprod;   
        }
        else
        {
            childproducts.add(parprod);   
        }
    }
    //Creating Product Options
    List<SBQQ__ProductOption__c> testproductoptions=dataFactoryClass.createSubProductOptions(parentProduct,childproducts);
    //Creating PriceBookEntries
    dataFactoryClass.createSubProdPricebookentries(Test.getStandardPricebookId(),testproducts);
    //Creating QuoteLines
    List<SBQQ__QuoteLine__c> testQuoteLines=dataFactoryClass.createSubQuotelines(quoteId,parentProduct.Id,testproductoptions);
    for(Opportunity opprec:oppList)
    {
        testopportunity=opprec;  
    }
    for(Account accrec:[Select Id,Name from Account limit 1])
    {
        testaccount=accrec; 
        accid=accrec.Id;  
    }
    //Creating Map of Product Id and PriceBookEntry Id

    //Creating Opportnity LineItems

    //Setting the quote to accepted stage
    List<SBQQ__Quote__c> quoteupdatelist=new List<SBQQ__Quote__c>();
    for(SBQQ__Quote__C qrec:quotelist)
    {
        SBQQ__Quote__c qre=new SBQQ__Quote__c();
        qre.ApprovalStatus__c='Approved';
        qre.SBQQ__Status__c='Accepted';
        qre.Id=qrec.Id;
        qre.SBQQ__Opportunity2__c=testopportunity.Id;
        qre.SBQQ__Primary__c=true;
        quoteupdatelist.add(qre);
    }
List<SBQQ__Quote__c> updatedquotes=dataFactoryClass.setSubQuoteAccept(quoteupdatelist);
   
 //Creating a contract
Contract testcontract=L2O_DataFactoryTest.createContract(oppList,updatedquotes,accid);


//Create subscription records
List<SBQQ__Subscription__c> testsubrecs=new List<SBQQ__Subscription__c>();
    for(SBQQ__QuoteLine__c qlre:testQuoteLines)
    {
        SBQQ__Subscription__c subrec=new SBQQ__Subscription__c();
        subrec.SBQQ__Account__c=accid;
        subrec.SBQQ__Contract__c=testcontract.Id;
        subrec.SBQQ__OriginalQuoteLine__c=qlre.Id;
        subrec.SBQQ__Quantity__c=qlre.SBQQ__Quantity__c;
        subrec.SBQQ__QuoteLine__c=qlre.Id;
        testsubrecs.add(subrec);
    }
    dataFactoryClass.createSubRecs(testsubrecs);
    
    //Creating Amendment Opportunity
    List<Opportunity> orignalopp=new List<Opportunity>();
    orignalopp.add(testopportunity);
    List<Opportunity> amendopprec=dataFactoryClass.createAmendOpp(orignalopp);
   
   Id amendoppid;
   for(Opportunity opp:amendopprec)
   {
    amendoppid=opp.Id;
   }
    //Create contact roles for amended quotes
    L2O_DataFactoryTest.createContactRoles(true,amendopprec,conList[0].id);
   //Create Amendment Quotes

    SBQQ__Quote__c amenquote=dataFactoryClass.amendedQuote(accid,amendoppid,testcontract.Id);
 
    Test.startTest();
    List<SBQQ__QuoteLine__c> amendquoteQuoteLines=dataFactoryClass.createSubQuotelines(amenquote.Id,parentProduct.Id,testproductoptions);
    dataFactoryClass.amendedQuotelines(testQuoteLines,amendquoteQuoteLines,testsubrecs,amenquote.Id);
    Test.stopTest();
    
    

    
    //update amqlrecs;
     List<SBQQ__QuoteLine__c> orignalquotelines=[Select Id,Launch_Status__c,Delayed_Launch_Date__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId];
     List<SBQQ__QuoteLine__c> amendedquotelines=[Select Id,Launch_Status__c,Delayed_Launch_Date__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:amenquote.Id];
    //System.assert for validating Orignal and Amended Quotelines
    for(SBQQ__QuoteLine__c qlrec:orignalquotelines)
     {
        System.assertEquals('Did not Launch',qlrec.Launch_Status__c,'launch Status should be set to Did Not Launch');
     }
     for(SBQQ__QuoteLine__c amqlrec:amendedquotelines)
     {
        System.assertEquals('Did not Launch',amqlrec.Launch_Status__c,'launch Status should be set to Did Not Launch');
     }
    }
    /**
	* @name  testcatchException()
	* @description Tests L2O_QuoteTriggerHandler class catch block
	*/
    @istest
    public static void testcatchException() {
        Test.startTest();
        L2O_QuoteTriggerHandler helper = new L2O_QuoteTriggerHandler();
        helper.beforeInsert();
        helper.afterInsert();
        helper.beforeUpdate();
        helper.afterUpdate();
        Test.stopTest();
        SDF_LGR_Log__c errorLog = [SELECT Name, Id, Class__c, Message__c, Reference__c FROM SDF_LGR_Log__c WHERE Class__c = 'L2O_QuoteTriggerHandler' LIMIT 1];
        System.assertEquals('L2O_QuoteTriggerHandler',errorLog.Class__c,'Handler Test Successful');
    }
}