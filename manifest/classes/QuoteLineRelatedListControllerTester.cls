@isTest
public class QuoteLineRelatedListControllerTester {
    
    @isTest(SeeAllData=false)    
    static void QuoteLineRelatedListControllerTester(){
        
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.Sales_Channels__c ='US Employer'; 
        q.CPQ_Pricebook__c = 'Direct';
        q.HealthPlan_Opt_In__c = 'No';
        insert q;
        
        Product2 p = new Product2();
        p.Name = 'Testing Product - Please Ignore';
        p.Family = 'Hosting Services';
        insert p;
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quantity__c = 1;
        ql.SBQQ__PriorQuantity__c = 1;
        ql.SBQQ__UpgradedQuantity__c = 1;
        ql.SBQQ__Quote__c = q.id;
        ql.SBQQ__Product__c = p.id;
        ql.SBQQ__NetPrice__c = 10;
        insert ql;
        
        PageReference newPage = Page.QuoteLinesRelatedList;
        newPage.getParameters().put('id', q.Id);
        Test.setCurrentPage(newPage);
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(q);
        QuoteLineRelatedListController controller = new QuoteLineRelatedListController(sc);       
        controller.populateRows();   
        
        controller.itemsPerPage = 1;    
        controller.doSortRows();
        
        controller.orderBy = 'OwnerId';
        controller.doSortRows();  
        controller.sortOrder = 'DESC';
        controller.doSortRows(); 
                                
        controller.nextPage();
        controller.goToLast();
        controller.prevPage();
        controller.goToFirst();            
    }
}