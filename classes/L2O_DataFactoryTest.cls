/**************************************************************************************************
* author        : Harshita Paliwal
* date          : 07/03/2022
* Name          : TestDataFactory
* @description  : Test Data Creation. Generic class for creation of test data.
* History       :
**************************************************************************************************/
@SuppressWarnings('PMD.OperationWithLimitsInLoop')

public virtual class L2O_DataFactoryTest {
    //Fetching standard Pricebook Id
    public static Id pricebookId = Test.getStandardPricebookId();
    
    /**
    * @description To create test users
    * @param isInsert control for insert
    * @param count number of users
    * @param profileName specific Profile Name
    * @return List of Users
    */
    public static List<User> createUsers(Boolean isInsert, Integer count, String profileName) {
        
        //Get specific profile to assign to user
        Profile profile = [SELECT id FROM profile WHERE name=:profileName LIMIT 1];
        
        List<User> lstNewUsers = new List<User>();
        
        for(Integer obj = 0; obj < count; obj++){
            //Create a new user 
            String uniqueName = profileName.deleteWhitespace() + obj;
            User newUser = new User(alias = 'standt'+obj, email='TestEmail'+uniqueName+'@livongo.com',
                                    emailencodingkey='UTF-8', lastname='TestDataFactory'+uniqueName, 
                                    languagelocalekey='en_US', localesidkey='en_US', 
                                    profileid = profile.Id,
                                    timezonesidkey='America/Los_Angeles', 
                                    username='Test'+uniqueName+'@test.com'); 
            lstNewUsers.add(newUser);
            
        }
        
        //insert users
        if(isInsert && !lstNewUsers.isEmpty()) {
            insert lstNewUsers;
        }
        
        return lstNewUsers;
    }
  
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
    * @description To create test accounts
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
                                                L2O_Initial_of_Lives__c=2300,
                                                L2O_Channel_Segment__c ='Employer',
                                                L2O_Sub_Channel_Segment__c='ASO',
                                                L2O_Business_Region__c='USA',
                                                L2O_Sub_Type_Detail__c = 'Reporting Purposes Only'));                
        }
        //insert record
        if(isInsert && !opportunityList.isEmpty()) {
            insert opportunityList;
        }
        
        return opportunityList;
    }
    
    /**
* @description To create test accounts
* @param isInsert control for insert
* @param accountList list of accounts
* @return List of Contact
*/
    public static List<Contact> createContact(Boolean isInsert, List<Account> accountList) {
        List<Contact> contactList = new List<Contact>();
        
        for(Integer obj = 0; obj < accountList.size(); obj++){
            ContactList.add(new Contact(LastName='Test_Contact'+obj));                
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
* @return List of Contact
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
        
        for(Integer obj = 0; obj < oppportunityList.size(); obj++){
            quoteList.add(new SBQQ__Quote__c(SBQQ__StartDate__c=Date.today(),SBQQ__Opportunity2__c=oppportunityList[obj].Id, 
                                             SBQQ__Account__c=oppportunityList[obj].AccountId,SBQQ__SubscriptionTerm__c =1));
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
* @description To create test approval
* @param isInsert control for insert
* @param quoteList list of Quotes
* @return List of Approvals
*/
    public static List<sbaa__Approval__c> createApproval(Boolean isInsert, List<SBQQ__Quote__c> quoteList) {
        List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
        
        for(Integer obj = 0; obj < quoteList.size(); obj++){
            approvalList.add(new sbaa__Approval__c(sbaa__ApprovalStep__c=1, sbaa__Status__c ='Requested',sbaa__Archived__c=false,
                                                   Quote__c=quoteList[obj].Id,sbaa__RecordField__c='Test'));                
        }
        //insert record
        if(isInsert && !approvalList.isEmpty()) {
            insert approvalList;
        }
        return approvalList;
    }
    /**
* @description To create quote lines
* @param isInsert control for insert
* @param quoteList list of Quotes
* @param productList
* @param assetList
* @return SBQQ__Quoteline__c
*/
    public static List<SBQQ__Quoteline__c> createQuoteLines(Boolean isInsert, List<SBQQ__Quote__c> quoteList,List<Product2> productList,List<Asset> assetList) {
        List<SBQQ__Quoteline__c> qlRecList = new List<SBQQ__Quoteline__c>();
        Map<Id,Id> productPricebookIdMap = new Map<Id,Id>();
        Set<Id> productIdSet = new Set<Id>();
        for(Product2 prod : productList) {
            productIdSet.add(prod.Id);
        }
        
        for(PricebookEntry priceEntry : [SELECT Id,Product2Id FROM PricebookEntry WHERE Product2Id = :productIdSet]) {
            productPricebookIdMap.put(priceEntry.Product2Id,priceEntry.Id);   
        }
        
        for(Integer obj = 0; obj < quoteList.size(); obj++){

            SBQQ__Quoteline__c qlRec= new SBQQ__Quoteline__c(SBQQ__Quote__c=quoteList[obj].Id,
                                                             SBQQ__Product__c=productList[obj].Id, SBQQ__Quantity__c=1,
                                                             SBQQ__ListPrice__c=120,SBQQ__UpgradedAsset__c =assetList[obj].Id
                                                             ,SBQQ__PricebookEntryId__c = productPricebookIdMap.get(productList[obj].Id)); 
            qlRecList.add(qlRec);
        }
        
        //insert record
        if(isInsert && !qlRecList.isEmpty()) {
            insert qlRecList;
        }
        return qlRecList;
    }
    
    /**
* @description To create product
* @return List of Product2
*/
    public static List<Product2> createProduct(){
        List<Product2> productList = new List<Product2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        Product2 product1 = new Product2(Name='Test1',IsActive = true);
        productList.add(product1);    
        Product2 product2 = new Product2(Name='Test2',IsActive = true);
        productList.add(product2); 
        
        insert productList;
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;*/
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        pricebookEntryList.add(pbe1);
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product2.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        pricebookEntryList.add(pbe2); 
        insert pricebookEntryList;
        
        
        
        return productList;
    }
    /**
* @description To create asset
* @param isInsert control for insert
* @param accountId
* @param productList
* @return List of Asset
*/
    public static List<Asset> createAsset(Boolean isInsert,Id accountId,List<Product2>productList){
        List<Asset> assetList = new List<Asset>();
        for(Integer obj = 0; obj < 1; obj++){
            Asset asset = new Asset(Name ='Asset'+obj,AccountId =accountId,Product2Id = productList[obj].Id);
            assetList.add(asset);
        }
        
        //insert record
        if(isInsert && !assetList.isEmpty()) {
            insert assetList;
        }
        return assetList;
    }
    /**
* @description To create contract
* @param lstOpportunityRecord
* @param quoteList
* @param accountId
* @return Contract
*/
    public static Contract createContract(List<Opportunity> lstOpportunityRecord,List<SBQQ__Quote__c> quoteList,Id accountId){
        Contract contract = new Contract(Status = 'Draft', StartDate = lstOpportunityRecord[0].CloseDate, AccountId = accountId,
                                         ContractTerm = 12, SBQQ__Quote__c =  quoteList[0].Id, SBQQ__Opportunity__c = lstOpportunityRecord[0].Id);
        insert contract; 
        return contract;
    }
 //Infosys code
 
  
    
       
   
    
    /**
* @description To create test quote
* @param isInsert control for insert
* @param oppportunityList list of Opportunities
* @return List of Quotes
*/
    protected List<SBQQ__Quote__c> createSubQuote(Boolean isInsert, List<Opportunity> oppportunityList) {
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
   protected List<Product2> createtestSubproducts()
   {
    List<Product2> testproducts=new List<Product2>();
    Product2 testparentproduct=new Product2();
    testparentproduct.Name='InTouch Viewpoint Software License - Windows';
    testparentproduct.ProductCode='SW-20051';
    testparentproduct.SBQQ__SubscriptionPricing__c='Fixed Price';
    testparentproduct.SBQQ__SubscriptionType__c='Renewable';
    testproducts.add(testparentproduct);
    Product2 testchildproduct1=new Product2();
    testchildproduct1.Name='Managed Network Access';
    testchildproduct1.ProductCode='SV-20212';
    testchildproduct1.SBQQ__SubscriptionPricing__c='Percent Of Total';
    testchildproduct1.SBQQ__SubscriptionType__c='Renewable';
    Product2 testchildproduct2=new Product2();
    testchildproduct2.Name='Proactive Device Monitoring, 24/7';
    testchildproduct2.ProductCode='SV-20213'; 
    testchildproduct2.SBQQ__SubscriptionPricing__c='Percent Of Total';
    testchildproduct2.SBQQ__SubscriptionType__c='Renewable'; 
    testproducts.add(testchildproduct1);
    testproducts.add(testchildproduct2);
    insert testproducts;
    return testproducts;    
   }
    
    /**
     * @description Create PricebookEntries
     * @param pbId Pricebook Id
     * @param prdList List of Products
     * @return List of created PricebookEntries
    **/
    protected Map<id,id> createSubProdPricebookentries(id pbId, List<Product2> prdList){
        Map<id,id> prodpbeMap = New Map<id,id>();
        List<PricebookEntry> pbeList = New List<PricebookEntry>();
        for(Product2 prd: prdList){
            PricebookEntry pbe = New PricebookEntry();
            pbe.Pricebook2Id = pbId;
            pbe.Product2Id = prd.Id;
            pbe.IsActive = true;
            pbe.UnitPrice = 10;
            pbeList.add(pbe); 
        }
        insert pbeList;
        for(PricebookEntry pbe2:pbeList){
            prodpbeMap.put(pbe2.Product2Id,pbe2.Id);            
        }
        return prodpbeMap;
    }
   
       /**
* @description To create test productoption records
* @param testparentproduct is ParentProduct record which will be mapped as Configured SKU on each record
* @param childproducts is a List of OptionalProducts which will be mapped as OptionalSKU on each record
* @return List of created productoption records
*/
    protected List<SBQQ__ProductOption__c> createSubProductOptions(Product2 testparentproduct,List<Product2> childproducts)
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
   protected List<SBQQ__QuoteLine__c> createSubQuotelines(Id quoteid,Id parentProduct,List<SBQQ__ProductOption__c> childproducts)
   {
     List<SBQQ__QuoteLine__c> testquotelines=new List<SBQQ__QuoteLine__c>();
     //Create Parent product Quoteline
     SBQQ__QuoteLine__c parentql=new SBQQ__QuoteLine__c();
      parentql.SBQQ__Quote__c=quoteid;
      parentql.SBQQ__Product__c=parentProduct;
       parentql.SBQQ__StartDate__c = system.today(); 
       parentql.SBQQ__Quantity__c=1;
      insert parentql;
      testquotelines.add(parentql);    
     //Create Child Product Quoteline
      for(SBQQ__ProductOption__c prodoptrec:childproducts)
      {
      SBQQ__QuoteLine__c childql=new SBQQ__QuoteLine__c();
      childql.SBQQ__Quote__c=quoteid;
      childql.SBQQ__Product__c=prodoptrec.SBQQ__OptionalSKU__c;
      childql.SBQQ__ProductOption__c=prodoptrec.Id;
      childql.SBQQ__RequiredBy__c=parentql.Id;
      childql.L2O_Consult_Fee__c=40;
      childql.SBQQ__StartDate__c = system.today(); 
      childql.SBQQ__Quantity__c=1;   
      testquotelines.add(childql);   
      }
      upsert testquotelines;
     return testquotelines;  
   }
    
    /**
     * @description Create OpportunityLineItem
     * @param oppId Opportunity Id
     * @param quoteLines List of Quotelines
     * @param prodpbe Map of ProductId and PricebookEntry Id
     * @return oppLineitems opportunity line items
    **/
    protected List<OpportunityLineItem> createSubOpplines(Id oppId,List<SBQQ__QuoteLine__c> quoteLines, Map<Id,Id> prodpbe){
        List<OpportunityLineItem> oppLineitems = New List<OpportunityLineItem>();
        for(SBQQ__QuoteLine__c quoteLine:quoteLines){
            OpportunityLineItem oppItem = New OpportunityLineItem();
            oppItem.SBQQ__QuoteLine__c =  quoteLine.Id;
            oppItem.OpportunityId = oppId;
            oppItem.L2O_Unit_Sell_Price__c = 20;
            oppItem.Quantity = 2;
            oppItem.TotalPrice = 40;
            oppItem.Product2Id = quoteLine.SBQQ__Product__c;
            oppItem.PricebookEntryId = prodpbe.get(quoteLine.SBQQ__Product__c);
            oppLineitems.add(oppItem);            
        }
        insert oppLineitems;
        return oppLineitems;
    }
    /**
     * @description set the Subscription Quote to accepted
     * @param updatequoterecs orignal quote
     * @return updatequoterecs updated quote records
    **/   
    protected List<SBQQ__Quote__c> setSubQuoteAccept(List<SBQQ__Quote__c> updatequoterecs)
    {
        update updatequoterecs;
        return updatequoterecs;
    } 
    /**
     * @description Create Subscription records
     * @param insertsubrecs subscription records
     * @return insertsubrecs subscription records
    **/
    protected List<SBQQ__Subscription__c> createSubRecs(List<SBQQ__Subscription__c> insertsubrecs)
    {
        insert insertsubrecs;
        return insertsubrecs;
    }
    /**
     * @description Create Amendment Opportunity
     * @param orignalopps List of orignal opportunity
     * @return amendopportunityList amendment opportunity list
    **/
    protected List<Opportunity> createAmendOpp(List<Opportunity> orignalopps) {
        List<Opportunity> amendopportunityList = new List<Opportunity>();
      for(Opportunity opprec:orignalopps)
      {
      Opportunity opp=new Opportunity();
      opp.AccountId=opprec.AccountId;
      opp.Name='Test Amendment Opportunity';
      opp.Type=opprec.Type;
      opp.StageName='Discovery';
      opp.CloseDate=opprec.CloseDate;
      opp.Pricebook2Id=opprec.Pricebook2Id;
      opp.L2O_Subtype__c =opprec.L2O_Subtype__c;  
      opp.L2O_Contract_Path__c =opprec.L2O_Contract_Path__c; 
      opp.L2O_Contract_Path_Sub_type__c=opprec.L2O_Contract_Path_Sub_type__c;
      opp.L2O_Channel_Segment__c =opprec.L2O_Channel_Segment__c;
      opp.L2O_Initial_of_Lives__c=2300;
      opp.L2O_Sub_Channel_Segment__c=opprec.L2O_Sub_Channel_Segment__c;
      amendopportunityList.add(opp);
      }
        //insert record
         insert amendopportunityList;
        
    
        return amendopportunityList;
    }
    /**
     * @description Create amendmentquote
     * @param accid account Id
     * @param amoppid Id of amendment opportunity
     * @param contid Id of master contract
     * @return qurec amendment quote record
    **/
    protected SBQQ__Quote__c amendedQuote(Id accid,Id amoppid,Id contid)
    {
        SBQQ__Quote__c qurec=new SBQQ__Quote__c();
        qurec.SBQQ__Account__c=accid;
        qurec.SBQQ__Opportunity2__c=amoppid;
        qurec.SBQQ__MasterContract__c=contid;
        qurec.SBQQ__StartDate__c=system.today()+50;
        qurec.SBQQ__PricebookId__c=Test.getStandardPricebookId();
        insert qurec;
        return qurec;
    }
   /**
     * @description Create Amendment quote quoteliens
     * @param ogqls orignal quoteliens
     * @param amendqls List of amendment Quotelines
     * @param subrecs subscription records
     * @param amquote Id of amendment quote
     * @return amqls amendment quotelines
    **/
   protected List<SBQQ__QuoteLine__c> amendedQuotelines(List<SBQQ__QuoteLine__c> ogqls,List<SBQQ__QuoteLine__c> amendqls,List<SBQQ__Subscription__c> subrecs,Id amquote)
   {
    List<SBQQ__QuoteLine__c> amqls=new List<SBQQ__QuoteLine__c>();
    Integer idcounter=0;
    List<String> subids=new List<String>();
    for(SBQQ__Subscription__c sbre:subrecs)
    {
     subids.add(sbre.Id);   
    }
    for(SBQQ__QuoteLine__c ql:amendqls)
    {
      SBQQ__QuoteLine__c qlrec=new SBQQ__QuoteLine__c();
      qlrec.Id=ql.Id;
      qlrec.SBQQ__Quantity__c=0;
      qlrec.SBQQ__UpgradedSubscription__c=subids[idcounter];
      idcounter++;
      amqls.add(qlrec);  
    }
       update amqls;
     SBQQ__Quote__c amqu=new SBQQ__Quote__c();
       amqu.Id=amquote;
       amqu.SBQQ__Status__c='Accepted';
       update amqu;
    return amqls;
}    
 /**
     * @description Create test teladocaccount 
     * @return testtelaacc test teladocaccount
    **/
    public static Account createTeladocAccount()
 {
     String teladocGUID = System.Label.L2O_TD_Teladoc_Account;
     Account testtelaacc=new Account();
     testtelaacc.Name = 'TestTela_Customer';
     testtelaacc.BillingCity='city';
     testtelaacc.BillingCountry='United States';                               
     testtelaacc.BillingStreet='street';
     testtelaacc.BillingState='California';
     testtelaacc.BillingPostalCode='postalCode';
     testtelaacc.ShippingCity='city';
     testtelaacc.ShippingStreet='street';
     testtelaacc.ShippingState='California';
     testtelaacc.ShippingPostalCode='postalCode';
     testtelaacc.ShippingCountry='United States';
     testtelaacc.L2O_GUID__c=teladocGUID;
     insert testtelaacc;
     return testtelaacc;
 }
}