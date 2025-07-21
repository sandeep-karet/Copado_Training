@isTest
private class Quotas_Trigger_Test {
    @testSetup 
    static void setupdata() {
        Account accObj = TestDataFactory.createAccountUMR();
  
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = TestDataFactory.createUser(p.Id);
        insert u1;
        
        Quotas__c quotas = TestDataFactory.createQuotas(u1.Id);
        insert quotas;


		//create an opportunity record
		Opportunity oppObj2 = TestDataFactory.createOpportunity(accObj.Id);
		oppObj2.LeadSource = 'Sales';
		insert oppObj2;
        
        oppObj2.OwnerId = u1.Id;
        update oppObj2;
    }
    
    @isTest 
    static void createNewQuotas() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'jimbo'];
        try{  
            Quotas__c quotas = TestDataFactory.createQuotas(u1.Id);
            insert quotas;
            
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Quoats Period is overalpping for the quotas owner with same role') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        } 
        
        try{  
            Quotas__c quotas = TestDataFactory.createQuotas(u1.Id);
            insert quotas;
            
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('End date must be greater than start date') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);         
        }              
    }

}