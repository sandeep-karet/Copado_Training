/*************************************************************************     
* @description This class is used as TestDataUtility for APTS_SetConsultFeeTestClass
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class APTS_TestDataUtility_Test {
 //Fetching standard Pricebook Id
    public static Id pricebookId = Test.getStandardPricebookId();
  
    /**
* @description To create test accounts
* @param isInsert control for insert
* @param count number of accounts
* @return List of Accounts
*/
    public static List<Account> createAccount(Boolean isInsert, Integer count) {
        List<Account> accountList = new List<Account>();
        
        for(Integer obj = 0; obj < count; obj++){
            accountList.add(new Account(Name = 'Test_Customer'+obj,BillingCity='city',BillingCountry='United States',
                                        BillingStreet='street',BillingState='California',BillingPostalCode='postalCode',
                                        ShippingCity='city',ShippingCountry='United States',ShippingStreet='street', 
                                        ShippingState='California',ShippingPostalCode='postalCode'));                 
        }
        //insert record
        if(isInsert && !accountList.isEmpty()) {
            insert accountList;
        }
        
        return accountList;
    }
    
    /**
* @description To create test opportunities
* @param isInsert control for insert
* @param accountList list of accounts
* @return List of Opportunities
*/
    public static List<Opportunity> createOpportunity(Boolean isInsert, List<Account> accountList) {
        List<Opportunity> opportunityList = new List<Opportunity>();
      for(Integer obj = 0; obj < accountList.size(); obj++){
            opportunityList.add(new Opportunity(Name='Test_Opportunity'+obj,Type='New Business',StageName='Prospect',
                                                CloseDate=Date.today()+1,AccountId=accountList[obj].Id, Pricebook2Id = pricebookId,
                                                L2O_Subtype__c = 'Initial Sale', 
                                                L2O_Contract_Path__c = 'Direct',
                                                L2O_Contract_Path_Sub_type__c = 'None',
                                                L2O_Channel_Segment__c ='Employer',
                                                L2O_Initial_of_Lives__c=2300,
                                                L2O_Sub_Channel_Segment__c='ASO'));                
        }
        //insert record
        if(isInsert && !opportunityList.isEmpty()) {
            insert opportunityList;
        }
        
        return opportunityList;
    }
    
    /**
* @description To create test contacts
* @param isInsert control for insert
* @param accountList list of accounts
* @return List of Contact
*/
    public static List<Contact> createContact(Boolean isInsert, List<Account> accountList) {
        List<Contact> contactList = new List<Contact>();
        
        for(Integer obj = 0; obj < accountList.size(); obj++){
            ContactList.add(new Contact(LastName='Test_Contact'+obj, AccountId = accountList[obj].Id));                
        }
        //insert record
        if(isInsert && !contactList.isEmpty()) {
            insert contactList;
        }
        return contactList;
    }
    
    /**
* @description To create contactRoles
* @param isInsert control for insert
* @param opportunityList list of opportunity
* @param contactId to pass contactId
* @return List of ContactRole records
*/
    public static List<OpportunityContactRole> createContactRoles(Boolean isInsert, List<Opportunity> opportunityList,Id contactId) {
        List<OpportunityContactRole> oppConList = new List<OpportunityContactRole>();
        
        for(Integer obj = 0; obj < opportunityList.size(); obj++){
            OpportunityContactRole oppConRole = new OpportunityContactRole();
            oppConRole.ContactId = contactId;
            oppConRole.OpportunityId = opportunityList[obj].id;
            oppConList.add(oppConRole);
        }
        //insert record
        if(isInsert && !oppConList.isEmpty()) {
            insert oppConList;
        }
        return oppConList;
        
    }
    
    /**
* @description To create test quote
* @param isInsert control for insert
* @param oppportunityList list of Opportunities
* @return List of Quotes
*/
    public static List<SBQQ__Quote__c> createQuote(Boolean isInsert, List<Opportunity> oppportunityList) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Integer months = 12;
        for(Integer obj = 0; obj < oppportunityList.size(); obj++){
            quoteList.add(new SBQQ__Quote__c(SBQQ__StartDate__c=Date.today(),SBQQ__Opportunity2__c=oppportunityList[obj].Id, 
                                             SBQQ__Account__c=oppportunityList[obj].AccountId,SBQQ__SubscriptionTerm__c =months,SBQQ__Status__c = 'Draft'));
            oppportunityList[obj].Pricebook2Id = pricebookId;
            oppList.add(oppportunityList[obj]);
            }
        if(!oppList.isEmpty()){
            update oppList;
        }
       //insert record
        if(isInsert && !quoteList.isEmpty()) {
            insert quoteList;
        }
        return quoteList; 
    }
    
/**
* @description To create test products 
* @return List of created product records for TestClass
*/
   public static List<Product2> createtestproducts()
   {
	List<Product2> testproducts=new List<Product2>();
	Product2 testparentproduct=new Product2();
	testparentproduct.Name='Mental Health Care (US)';
	testparentproduct.ProductCode='BH';
	testproducts.add(testparentproduct);
    Product2 testchildproduct1=new Product2();
	testchildproduct1.Name='Psychiatry Initial Visit Fee';
	testchildproduct1.ProductCode='BHP1T';
	Product2 testchildproduct2=new Product2();
	testchildproduct2.Name='Psychiatry Ongoing Visit Fee';
	testchildproduct2.ProductCode='BHPOT';  
	Product2 testchildproduct3=new Product2();
	testchildproduct3.Name='Psychologist Ongoing Visit Fee';
	testchildproduct3.ProductCode='BHPOOT'; 
	testproducts.add(testchildproduct1);
	testproducts.add(testchildproduct2);
	testproducts.add(testchildproduct3);
	insert testproducts;
	return testproducts;    
   }
   
       /**
* @description To create test productoption records
* @param testparentproduct is ParentProduct record which will be mapped as Configured SKU on each record
* @param childproducts is a List of OptionalProducts which will be mapped as OptionalSKU on each record
* @return List of created productoption records
*/
    public static List<SBQQ__ProductOption__c> createproductoptions(Product2 testparentproduct,List<Product2> childproducts)
   {
   List<SBQQ__ProductOption__c> testproductoptions=new List<SBQQ__ProductOption__c>();
	Double order=0;
	for(Product2 prodrec:childproducts)
	{
 	SBQQ__ProductOption__c prodoptrec=new SBQQ__ProductOption__c();
 	prodoptrec.SBQQ__ConfiguredSKU__c=testparentproduct.Id;
 	prodoptrec.SBQQ__OptionalSKU__c=prodrec.Id;
 	prodoptrec.SBQQ__Number__c=order;
 	testproductoptions.add(prodoptrec);
 	order=order+1;   
	} 
 	insert testproductoptions;
 	return testproductoptions;
   }
       /**
* @description To create test quotelines
* @param quoteid is QuoteId of related Quote
* @param parentProduct is Product Id of Parent Product
* @param childproducts is a List of Product Option records
* @return List of created test quotelines
*/
   public static List<SBQQ__QuoteLine__c> createquotelines(Id quoteid,Id parentProduct,List<SBQQ__ProductOption__c> childproducts)
   {
     List<SBQQ__QuoteLine__c> testquotelines=new List<SBQQ__QuoteLine__c>();
     //Create Parent product Quoteline
     SBQQ__QuoteLine__c parentql=new SBQQ__QuoteLine__c();
      parentql.SBQQ__Quote__c=quoteid;
       parentql.SBQQ__StartDate__c = system.today(); 
      parentql.SBQQ__Product__c=parentProduct;
      insert parentql;
      testquotelines.add(parentql);    
     //Create Child Product Quoteline
      for(SBQQ__ProductOption__c prodoptrec:childproducts)
      {
      SBQQ__QuoteLine__c childql=new SBQQ__QuoteLine__c();
      childql.SBQQ__Quote__c=quoteid;
      childql.SBQQ__Product__c=prodoptrec.SBQQ__OptionalSKU__c;
      childql.SBQQ__ProductOption__c=prodoptrec.Id;
          childql.SBQQ__StartDate__c = system.today();
      childql.SBQQ__RequiredBy__c=parentql.Id;
      childql.L2O_Consult_Fee__c=40;
      testquotelines.add(childql);   
      }
      upsert testquotelines;
     return testquotelines;  
   }
       /**
* @description To create a test agreement record
* @param quoteid is a Test QuoteId
* @param opportunityid is a Test OpportunityId of Opportunity related to the Quote
* @param accountid is an Account Id of Account to which the opportunity belongs
* @return a single Agreement record
*/
    public static Apttus__APTS_Agreement__c createagreement(Id quoteid,Id opportunityid,Id accountid)
    {
     Apttus__APTS_Agreement__c testagreement=new Apttus__APTS_Agreement__c();
     testagreement.APTS_Related_Quote__c=quoteid;
     testagreement.Apttus__Related_Opportunity__c=opportunityid;
     testagreement.Apttus__Account__c=accountid;
     insert testagreement;   
     return testagreement;   
    }
/**
* @description To create and insert AgreementLineItem Records
* @param agreementid of parent id
* @param testQuoteLines is list of test quotelines 
* @return List of inserted AgreementLineItem records
*/
   public static List<Apttus__AgreementLineItem__c> createagreementlineitem(Id agreementid,List<SBQQ__QuoteLine__c> testQuoteLines)
   {
     List<Apttus__AgreementLineItem__c> testagglineitemlist=new List<Apttus__AgreementLineItem__c>();
     for(SBQQ__QuoteLine__c qlrec:testQuoteLines)
     {
      Apttus__AgreementLineItem__c al=new Apttus__AgreementLineItem__c();
      al.Apttus__AgreementId__c=agreementid;
      al.APTS_Quote_Line__c=qlrec.Id;
      al.APTS_Required_By__c=qlrec.SBQQ__RequiredBy__c;
      testagglineitemlist.add(al);
     }
       insert testagglineitemlist;
       System.assertNotEquals(null, testagglineitemlist, 'Success');
       return testagglineitemlist;
   }
    
}