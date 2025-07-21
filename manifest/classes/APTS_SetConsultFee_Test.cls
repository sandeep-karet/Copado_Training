/*************************************************************************     
* @description This class is used as Test class for APTS_SetConsultAndFeeCode apex class
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class APTS_SetConsultFee_Test{
    public static Id pricebookId = Test.getStandardPricebookId();
    
    @testSetup
    static void createdata()
    {
        Test.startTest();
        List<Account> accountList= APTS_TestDataUtility_Test.createAccount(true,1);
        Product2 parentProduct=new Product2();
        Apttus__APTS_Agreement__c testagreementrec=new Apttus__APTS_Agreement__c();
        Account testaccount=new Account();   
        Opportunity testopportunity=new Opportunity();  
        List<Product2> childproducts=new List<Product2>(); 
        Id quoteId;
        List<Opportunity> oppList = APTS_TestDataUtility_Test.createOpportunity(true,accountList); 
        List<Contact> conList =  APTS_TestDataUtility_Test.createContact(true,accountList); 
        APTS_TestDataUtility_Test.createContactRoles(true,oppList,conList[0].id);     
        List<SBQQ__Quote__c> quotelist=APTS_TestDataUtility_Test.createQuote(true,oppList);
        for(SBQQ__Quote__c quoterec:quotelist)
        {
            quoteId=quoterec.Id;   
        }
        List<Product2> testproducts=APTS_TestDataUtility_Test.createtestproducts();
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
        List<SBQQ__ProductOption__c> testproductoptions=APTS_TestDataUtility_Test.createproductoptions(parentProduct,childproducts);
        List<SBQQ__QuoteLine__c> testQuoteLines=APTS_TestDataUtility_Test.createquotelines(quoteId,parentProduct.Id,testproductoptions);
        for(Opportunity opprec:oppList)
        {
            testopportunity=opprec;  
        }
        for(Account accrec:accountList)
        {
            testaccount=accrec;   
        }
        testagreementrec=APTS_TestDataUtility_Test.createagreement(quoteId,testopportunity.Id,testaccount.Id);
        List<Apttus__AgreementLineItem__c> testagreementlineitems=APTS_TestDataUtility_Test.createagreementlineitem(testagreementrec.Id,testQuoteLines);
        System.assertNotEquals(null, testagreementlineitems, 'Success');
        Test.stopTest();
    } 
    
    @isTest
    static void callmethod() {
        Test.startTest();
        List<Apttus__AgreementLineItem__c> testdata=[Select Id,APTS_Consult_Fee__c,APTS_Fee_Code__c,APTS_Required_By__c,Apttus__AgreementId__c,APTS_Quote_Line__c from Apttus__AgreementLineItem__c];
        List<List<Apttus__AgreementLineItem__c>> classtestdata=new List<List<Apttus__AgreementLineItem__c>>();
        classtestdata.add(testdata);
        APTS_SetConsultFeeAndFeeCode.setconsultfeefeecode(classtestdata);
        System.assertNotEquals(null, classtestdata, 'Success');
        Test.stopTest();
    }
}