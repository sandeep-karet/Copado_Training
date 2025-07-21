/**************************************************************************************************
* author        : Elambaruthi Thanasinghu
* date          : 08/02/2024
* Name          : hierarchicalListTreeViewController_Test
* @description  : This class contains unit tests for validating the behavior of the Apex class "hierarchicalListTreeViewController".
* History       :
**************************************************************************************************/

@isTest
private class hierarchicalListTreeViewController_Test {

    @isTest
    static void myUnitTest() {
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
        
        List<Hierarchical_List_View_Configuration__mdt> hlvConfig = [SELECT Object_Name__c, Record_Id_Field__c, Self_Parent_Field__c, Self_Relationship_Name__c, Sourcing_Field_Name__c, List_View_Fields__c FROM Hierarchical_List_View_Configuration__mdt];

        Apttus__APTS_Agreement__c testagreementrec=new Apttus__APTS_Agreement__c();
        testagreementrec=APTS_TestDataUtility_Test.createagreement(quoteId,oppList[0].Id,accountList[0].Id);        
        List<Apttus__AgreementLineItem__c> testagreementlineitems=APTS_TestDataUtility_Test.createagreementlineitem(testagreementrec.Id,testQuoteLines);
        
        Test.startTest();
            hierarchicalListTreeViewController.getHierarchicalData(quoteId, 'Quote_Lines_View');
            hierarchicalListTreeViewController.getHierarchicalData(quoteId, 'Agreements_List_View');
            
            hierarchicalListTreeViewController.getHierarchicalData(quoteId, 'Agreements_Line_Item_List_View');
        Test.stopTest(); 

        
    }
}