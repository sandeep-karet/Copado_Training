/*************************************************************************     
* @description This class is used for test Data
* @param NA
* @Author InfoSys Developer
**************************************************************************/  
@isTest
public class TestDataFactoryForPG_Test {
/*************************************************************************     
* @description This metod is used for the Account object record
* @param name : Name of the Account
  @return accObj : Account object record id
* @Author InfoSys Developer
**************************************************************************/      
    public static Account createAccount(String name){
        Account accObj = new Account();
        accObj.Name = name;
        accObj.CurrencyIsoCode = 'USD';
        accObj.BillingStreet = 'test road test state';
        accObj.BillingStreet = '1 Infinite Test';
        accObj.BillingCity = 'Cupertino';
        accObj.BillingState = 'Alabama';
        accObj.BillingPostalCode = '90210';
        accObj.BillingCountry = 'United States';
        accObj.Phone = '1-800-838-8282';
        insert accObj;
        return accObj;
    }
/*************************************************************************     
* @description This metod is used for the Opportunity object record
* @param accId : Account ID
  @return oppObj : Opportunity record ID
* @Author InfoSys Developer
**************************************************************************/      
    public static Opportunity createOpportunity(Id accId){
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'Test Factory Opp';
        oppObj.AccountId = accId;
        oppObj.Type = 'New Business';
        oppObj.CurrencyIsoCode = 'USD';
        oppObj.StageName = 'Prospect';
        oppObj.Probability = 10;
        oppObj.CloseDate = Date.Today();
        oppObj.LeadSource='Marketing';
        oppObj.L2O_Subtype__c = 'Initial Sale'; 
        oppObj.L2O_Contract_Path__c = 'Direct';
        oppObj.L2O_Contract_Path_Sub_type__c = 'None';
        oppObj.L2O_Channel_Segment__c ='Employer';
        oppObj.L2O_Initial_of_Lives__c=2300;
        oppObj.Pricebook2Id = Test.getStandardPricebookId();
        return oppObj;
    }  
    
}