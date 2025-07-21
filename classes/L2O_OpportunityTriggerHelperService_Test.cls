/**
* Company : PwC.
* @description : Test Class for L2O_OpportunityTriggerHelperService
* ************************************************************************************************************************************
* History : 
* @date 14/06/2022
* @author Harshita Paliwal
*/
@isTest
public class L2O_OpportunityTriggerHelperService_Test {
    // String field variables
    public static String strAccepted = 'Accepted';
    public static Id pricebookId = Test.getStandardPricebookId();
    @testSetup
    /**
* @name  testSetup()
* @description Sets up Test Data for the Class
* @params  none
*/ 
     static void testSetup() {
         List<Account> accountList= L2O_DataFactoryTest.createAccount(true,2);
         List<Contact> conList =  L2O_DataFactoryTest.createContact(true,accountList); 
         List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList); 
         L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
         List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);    
         L2O_DataFactoryTest.createContract(oppList,QuoteList,accountList[0].id);  
        L2O_DataFactoryTest.createTeladocAccount();
        }
    
    /**
* @name testUpdateCancelRipOpptyToContracted()
* @description Tests whether cancelled rip opportunity stage is closed won or not
* @params  none
*/ 
     @isTest static void testUpdateCancelRipOpptyToContracted() { 
        Test.startTest();
        //create a contract record
        Contract contractRec = [SELECT Id,contractnumber FROM Contract WHERE ContractTerm = 12 LIMIT 1]; 
        //create quote list
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec : [SELECT Id,SBQQ__Status__c,SBQQ__Primary__c
                                     FROM SBQQ__Quote__c 
                                      WHERE  SBQQ__Status__c != null] ){
               quoteRec.SBQQ__Status__c = strAccepted ;
               quoteRec.SBQQ__Primary__c = true;                           
                lstQuote.add(quoteRec);
            }
         update lstQuote;
       //create opportunity list
       List<Opportunity> lstOppty = [SELECT Id,Name,stageName,SBQQ__PrimaryQuote__c 
                                     FROM Opportunity 
                                     WHERE Name != null];
         for(integer count = 0;count<lstOppty.size();count++){
             lstOppty[count].SBQQ__PrimaryQuote__c = lstQuote[count].Id; 
             if(count == 0){
                 
                 lstOppty[count].Name = L2O_Constants.RIP_REPLACE_OPPTY_PREFIX_NAME+contractRec.contractnumber+'-'+DateTime.now();
                 lstOppty[count].stageName = L2O_Constants.OPPTY_STAGE_CLOSED_OWN;
              }
         }
        update lstOppty;
        //fetching opportunity and cancelled opportunity
        Opportunity rNrOpportunity=[SELECT Id,SBQQ__Contracted__c,StageName,Name,SBQQ__PrimaryQuote__c 
                                                    FROM Opportunity 
                                                    WHERE Name LIKE 'Rip And Replace- contract%' LIMIT 1];
         Opportunity cancelledOpportunity = [SELECT Id,SBQQ__Contracted__c,StageName 
                                                    FROM Opportunity 
                                                    WHERE Id =:rNrOpportunity.Id OR SBQQ__PrimaryQuote__r.L2O_Replacement_Quote__c =:rNrOpportunity.SBQQ__PrimaryQuote__c LIMIT 1];
         System.assertEquals(rNrOpportunity.StageName,cancelledOpportunity.StageName,'Cancelled opportunity is closed won!');
        Test.stopTest();     
     }
    
    /**
* @name testupdateAmendOpptyFrmContract()
* @description Tests whether amend opportunity subtype is getting populated from contract 
* @params  none
*/ 
    @isTest static void testupdateAmendOpptyFrmContract(){
         Test.startTest();
         //create contract
         Contract contractRec = [SELECT Id,contractnumber,L2O_Amendment_Opportunity_SubType__c,AccountId FROM Contract WHERE ContractTerm = 12 LIMIT 1];
         contractRec.L2O_Amendment_Opportunity_SubType__c = 'Change Order';
         //update contract 
         update contractRec;
         //create amendment opportunity and insert it
         Opportunity amendOpp=new Opportunity(Name='Amendment',
                                AccountId=contractRec.AccountId,
                                Type='Existing Business',
                                stageName='Discovery',
                                CloseDate=date.today().addMonths(2),
                                SBQQ__AmendedContract__c=contractRec.Id,
                                L2O_Initial_of_Lives__c=2300,
                                Pricebook2Id = pricebookId,
                                L2O_Contract_Path__c = 'Direct',
                                L2O_Contract_Path_Sub_type__c = 'None',
                                L2O_Channel_Segment__c ='Employer',
                                L2O_Subtype__c = 'Change Order',
                                L2O_Client_Line_of_Business__c = 'Commercial FI');
         insert amendOpp;
        //fetch and the same opportunity 
         Opportunity opptyRecAfterSubTypeSet = [SELECT Id,Type,Name,stageName,L2O_Subtype__c,SBQQ__AmendedContract__c
                                                  FROM Opportunity 
                                                  WHERE Id =:amendOpp.Id LIMIT 1];
         System.assertEquals(opptyRecAfterSubTypeSet.L2O_Subtype__c,contractRec.L2O_Amendment_Opportunity_SubType__c,'amend opportunity subtype verified');
         Test.stopTest();   
    }
     /**
* @name testupdateOpptyFromAccount()
* @description Tests whether opportunity subtype and business region is getting populated from account 
* @params  none
*/ 
    @isTest static void testupdateOpptyFromAccount(){ 
        Id accId;
        Test.startTest();
        // update Account
        List<Account> accountList=[SELECT Id, L2O_Business_Region__c,L2O_Amendment_Opportunity_SubType__c, Name FROM Account WHERE Name != null];
        accId = accountList[0].Id;
        accountList[0].L2O_Amendment_Opportunity_SubType__c = 'Change Order';
        update accountList;
        
        //create Opportunity
        Opportunity opp=new Opportunity(Name='Opportunity',
            Type='Existing Business',
            L2O_Subtype__c='Change Order',
            L2O_Initial_of_Lives__c=2300,
            Pricebook2Id = pricebookId,
            L2O_Contract_Path__c = 'Direct',
            L2O_Contract_Path_Sub_type__c = 'None',
            L2O_Channel_Segment__c ='Employer',
            stageName='Discovery',
            CloseDate=date.today().addMonths(2),
            L2O_Client_Line_of_Business__c = 'Commercial FI');
        Opp.L2O_IsAccountAmendAssets__c = TRUE;
        
        opp.AccountId=accId;
        opp.Name=System.Label.L2O_AmendOppDefaultName;
        insert opp;
        List<Account> accUpdtList = [SELECT Id, L2O_Business_Region__c,L2O_Amendment_Opportunity_SubType__c, Name FROM Account WHERE Id =:accId];
        List<Opportunity> oppUpdtList = [SELECT Id, L2O_Subtype__c,L2O_Business_Region__c, Name FROM Opportunity WHERE id=: opp.id];
        System.assertEquals(oppUpdtList[0].L2O_Business_Region__c,accUpdtList[0].L2O_Business_Region__c,'opportunity business region verified');
        System.assertEquals(oppUpdtList[0].L2O_Subtype__c,accUpdtList[0].L2O_Amendment_Opportunity_SubType__c,'opportunity subtype verified');
        Test.stopTest();   
    }
    /**
* @name testupdateOpportunity()
* @description Tests whether opportunity is getting contracted checked after stagename='closed won'
* @params  none
*/ 
    @isTest static void testupdateOpportunity(){
        Test.startTest();
        //create opportunity list
        List<Opportunity> lstOppty=[SELECT Id,Name,stageName,L2O_Business_Region__c,L2O_Subtype__c,SBQQ__Contracted__c,SBQQ__PrimaryQuote__c
                                     FROM Opportunity 
                                     WHERE (Name != null AND StageName!='Closed Won' AND SBQQ__Contracted__c = FALSE AND (NOT Name LIKE '%Rip And Replace- contract%'))];
        //create quote list
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        // fetch quote asscociated to opportunity and accept it and add to quote list
        for(SBQQ__Quote__c quoteRec : [SELECT Id,SBQQ__Status__c,SBQQ__Primary__c,SBQQ__Opportunity2__c
                                     FROM SBQQ__Quote__c 
                                      WHERE  SBQQ__Status__c != null AND SBQQ__Opportunity2__c =:lstOppty[0].Id LIMIT 1] ){
               quoteRec.SBQQ__Status__c = strAccepted ;                      
              
               quoteRec.SBQQ__Primary__c = true;                           
               lstQuote.add(quoteRec);
            }
        //update quote list
        update lstQuote;
        //fetch opportunity record where SBQQ__PrimaryQuote__c =:lstQuote[0].Id and close won it
        Opportunity oppRec = [SELECT Id,Name,stageName,L2O_Business_Region__c,L2O_Subtype__c,SBQQ__Contracted__c,SBQQ__PrimaryQuote__c
                                     FROM Opportunity 
                                     WHERE SBQQ__PrimaryQuote__c =:lstQuote[0].Id];
       oppRec.stageName='Closed Won';
       //update opportunity record
       update oppRec;
       //fetch the opportunity 
       Opportunity oppRecTest = [SELECT Id,Name,stageName,L2O_Business_Region__c,L2O_Subtype__c,SBQQ__Contracted__c,SBQQ__PrimaryQuote__c
                                     FROM Opportunity 
                                     WHERE Id =:oppRec.Id];
       System.assertEquals(oppRecTest.SBQQ__Contracted__c,TRUE,'Contracted is true');
       Test.stopTest();   
        
    }
     /**
* @name testupdateRenewalOpptyFrmOriginalOppty()
* @description Tests whether renewal opportunity subtype is getting populated from original opportunity
* @params  none
*/ 
    @isTest static void testupdateRenewalOpptyFrmOriginalOppty(){
       Test.startTest();
       //fetch contract
       Contract contractRec = [SELECT Id,AccountId,contractNumber,SBQQ__Opportunity__r.L2O_Subtype__c,SBQQ__Opportunity__r.OwnerId,SBQQ__Opportunity__c  FROM Contract WHERE ContractTerm = 12 LIMIT 1];
       // fetch opportunity record and make subtype=pilot and update it
       Opportunity oppRec = [SELECT Id,L2O_Subtype__c FROM Opportunity WHERE Id =: contractRec.SBQQ__Opportunity__r.Id LIMIT 1];
       oppRec.L2O_Subtype__c =  L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_PILOT;
       update oppRec;
        //create renewal opportunity and insert it
       Opportunity renewalOpp=new Opportunity(Name='Renewal',
       AccountId=contractRec.AccountId,Type='New Business',
       stageName='Discovery',CloseDate=date.today().addMonths(2),
       L2O_Subtype__c='Initial Sale',
       L2O_Initial_of_Lives__c=2300,
       Pricebook2Id = pricebookId,
       L2O_Contract_Path__c = 'Direct',
       L2O_Contract_Path_Sub_type__c = 'None',
       L2O_Channel_Segment__c ='Employer',                       
       SBQQ__Renewal__c=TRUE,
       SBQQ__RenewedContract__c=contractRec.Id); 
       insert renewalOpp;
       //fetch renewal opportunity 
       Opportunity renewalOppTest=[SELECT Id,L2O_Subtype__c FROM Opportunity WHERE Id =:renewalOpp.Id LIMIT 1];
       System.assertEquals(L2O_Constants.RENEWAL_OPPTY_SUB_TYPE_PILOT_EXT,renewalOppTest.L2O_Subtype__c,'renewal opportunity subtype is Pilot Extension'); 
       Test.stopTest();
    }
    
    /**
* @name testupdatePrimaryQuote()
* @description Tests whether quote's business region is getting populated from opportunity
* @params  none
*/ 
      @isTest static void testupdatePrimaryQuote(){ //done
        Test.startTest();
        //create opportunity list
        List<Account> acclist=[Select Id from Account];
        List<Opportunity> lstOppty=[SELECT Id,Name,stageName,L2O_Business_Region__c,L2O_Subtype__c,AccountId,L2O_Contracting_Account__c
                                     FROM Opportunity WHERE Name LIKE '%Test_Opportunity%'];
         //system.debug(lstOppty);
         List<SBQQ__Quote__c> setprimaryquotes=new List<SBQQ__Quote__c>();
         for(SBQQ__Quote__c qre:[SELECT Id,SBQQ__Opportunity2__c,L2O_Business_Region__c FROM SBQQ__Quote__c where SBQQ__Opportunity2__c=:lstOppty[0].Id limit 1])
         {
           SBQQ__Quote__c qrec=new SBQQ__Quote__c(Id=qre.Id,SBQQ__Primary__c=true);
            setprimaryquotes.add(qrec); 
         }
         update setprimaryquotes;  
        //create a set of opportunity Id's
        Set<Id> lstOpptyId= new Set<Id>();
          for(Opportunity  opp: lstOppty){
              lstOpptyId.add(opp.Id);
          }
        //change the business region
        lstOppty[0].L2O_Business_Region__c='USA';
        //Change account
        lstOppty[0].AccountId=acclist[1].Id;
        //Change contracting account
        lstOppty[0].L2O_Contracting_Account__c=acclist[1].Id;  
        update lstOppty[0]; 
                   
        //create list of primary quotes
        List<SBQQ__Quote__c> lstPrimaryQuotes = [SELECT Id, SBQQ__Opportunity2__c,L2O_Business_Region__c FROM SBQQ__Quote__c  
                                                     WHERE SBQQ__Primary__c = TRUE
                                                     AND SBQQ__Opportunity2__c IN :lstOpptyId];
         
         If(!lstPrimaryQuotes.isEmpty()){
                
                for(SBQQ__Quote__c quote: lstPrimaryQuotes){
                    System.assertEquals(quote.L2O_Business_Region__c ,lstOppty[0].L2O_Business_Region__c,'quote business region verified'); 
                }
               
            }
        Test.stopTest();
      }
    
     
    /**
* @name testSendEmailOnInternlOppClosedWon()
* @description Tests whether International Email sent on Opportunity closedwon
* @params  none
*/ 
   @isTest static void testSendEmailOnInternlOppClosedWon(){ 
        Id accId;
        List<Account> accountList= [SELECT Id, L2O_Business_Region__c, Name FROM Account WHERE Name != null LIMIT 1];
        accId = accountList[0].Id;
        accountList[0].L2O_Business_Region__c = 'Canada';
        update accountList;
        List<Account> updtAccList = [SELECT Id, L2O_Business_Region__c, Name FROM Account WHERE Id =:accId LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact WHERE LastName != NULL LIMIT 1];
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList);
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList);
       List<Product2> prodList = L2O_DataFactoryTest.createProduct();
       List<Asset> asstList = L2O_DataFactoryTest.createAsset(true,accId,prodList);
       List<SBQQ__Quoteline__c> quoteLineList =  L2O_DataFactoryTest.createQuoteLines(true,quoteList,prodList,asstList); 
        
        //Update quote list
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec : quoteList){
                                           quoteRec.SBQQ__Status__c = strAccepted ;
                                           quoteRec.SBQQ__Primary__c = true;                           
                                           lstQuote.add(quoteRec);
                                       }
        if(!lstQuote.isEmpty()){
            update lstQuote;
        }
       List<SBQQ__Quoteline__c> quotLIList = new List<SBQQ__Quoteline__c>();
        FOR(SBQQ__Quoteline__c tempQli : quoteLineList) {
            tempQli.L2O_Service_Platform__c = 'INTL';
            tempQli.L2O_Business_Region_rev__c = 'Canada';
            quotLIList.add(tempQli);
        }
        if(!quotLIList.isEmpty()){
            update quotLIList;
        }
        
        //Update opportunity list
        Test.startTest();
        List<Opportunity> lstOppty = [SELECT Id,Name,stageName,SBQQ__PrimaryQuote__c,SBQQ__Ordered__c,L2O_Business_Region__c
                                      FROM Opportunity 
                                      WHERE Id=:oppList[0].Id];
        
        lstOppty[0].SBQQ__PrimaryQuote__c = lstQuote[0].Id; 
        lstOppty[0].stageName = L2O_Constants.OPPTY_STAGE_CLOSED_OWN;
        update lstOppty;
         System.assertEquals(updtAccList[0].L2O_Business_Region__c,'Canada','');
        Test.stopTest();
        
    }
    /**
* @name testSendEmailOnUSAOppClosedWon()
* @description Tests whether USA Email sent on Opportunity closedwon
* @params  none
*/ 
    @isTest static void testSendEmailOnUSAOppClosedWon(){ 
        Id accId;
        
        List<Account> accountList= [SELECT Id, L2O_Business_Region__c, Name FROM Account WHERE Name != null LIMIT 1];
        accId = accountList[0].Id;
        List<Product2> prodList = L2O_DataFactoryTest.createProduct();
        List<Asset> asstList = L2O_DataFactoryTest.createAsset(true,accId,prodList);
        // update account record
        accountList[0].L2O_Business_Region__c = 'USA';
        update accountList;
        
         List<Account> updtAccList = [SELECT Id, L2O_Business_Region__c, Name FROM Account WHERE Id =:accId LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact WHERE LastName != NULL LIMIT 1];
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList);
        
        L2O_DataFactoryTest.createContactRoles(true,oppList,conList[0].id);    
        List<SBQQ__Quote__c> quoteList =  L2O_DataFactoryTest.createQuote(true,oppList); 
        List<SBQQ__Quoteline__c> quoteLineList =  L2O_DataFactoryTest.createQuoteLines(true,quoteList,prodList,asstList);
        
        //Update quote list
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec : quoteList){
                                           quoteRec.SBQQ__Status__c = strAccepted ;
                                           quoteRec.SBQQ__Primary__c = true;                           
                                           lstQuote.add(quoteRec);
                                       }
        if(!lstQuote.isEmpty() && !quoteLineList.isEmpty()){
            update lstQuote;
        }
        // update Quote Lines
        List<SBQQ__Quoteline__c> quotLIList = new List<SBQQ__Quoteline__c>();
        quoteLineList[0].L2O_Service_Platform__c = 'TDH';
        quoteLineList[0].L2O_Business_Region_rev__c = 'USA';
        quotLIList.add(quoteLineList[0]);
        if(!quotLIList.isEmpty()){
            update quotLIList;
        }
        // update Opportunity Line Item
        List<OpportunityLineItem> oppLIList = new List<OpportunityLineItem>();
        FOR(OpportunityLineItem tempoPli : [SELECT id, OpportunityId,L2O_Service_Platform__c
                                            FROM OpportunityLineItem 
                                            WHERE  OpportunityId =:oppList[0].Id]) {
                                                tempoPli.L2O_Service_Platform__c = 'HHS';
                                                oppLIList.add(tempoPli);
                                            }
        if(!oppLIList.isEmpty()){
            update oppLIList;
        }
        //Update opportunity list
        Test.startTest();
        List<Opportunity> lstOppty = [SELECT Id,Name,stageName,SBQQ__PrimaryQuote__c,SBQQ__Ordered__c,L2O_Business_Region__c
                                      FROM Opportunity 
                                      WHERE Id=:oppList[0].Id];
       lstOppty[0].stageName = L2O_Constants.OPPTY_STAGE_CLOSED_OWN;
       update lstOppty;
        System.assertEquals(updtAccList[0].L2O_Business_Region__c,lstOppty[0].L2O_Business_Region__c,'');
        Test.stopTest();
        
        
        
    }
    
    /**
    * @name testPreSalePlatformEvent()
    * @description Tests the PreSalePlatformEvent
    * @params  none
    */ 
    @isTest static void testPreSalePlatformEvent() {
        List<Account> accountList= [SELECT Id, L2O_Business_Region__c, Name FROM Account WHERE Name != null LIMIT 1];
        List<Opportunity> oppList =  L2O_DataFactoryTest.createOpportunity(true,accountList);
        for (Opportunity opp: oppList) {
            opp.Early_Implementation__c = true;
            opp.Pricing_and_Product_Lock__c = true;
        }
        Test.startTest();
        update oppList;
        System.assertEquals(oppList[0].Early_Implementation__c, true, 'Early Implementation Checkbox');
        System.assertEquals(oppList[0].Pricing_and_Product_Lock__c, true, 'Pricing and Product Lock Checkbox');
        Test.stopTest();
    }
    }