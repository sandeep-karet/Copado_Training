@IsTest
private class msuLookupLwcControllerTest {
    @TestSetup
    static void setup(){
        Account umrAcct = TestDataFactory.createUMR();        
        Account parentAcctTest = new Account();
        parentAcctTest.Name = 'Parent Test Account';
        parentAcctTest.revenue_effective_date__c = Date.today();
        insert parentAcctTest;
        
        Account parentAcctTest2 = new Account();
        parentAcctTest2.Name = 'Parent Test Account2';
        parentAcctTest2.revenue_effective_date__c = Date.today();
        insert parentAcctTest2;
        
        Mbr_Group__c mbrGrp = new Mbr_Group__c();
        mbrGrp.Name__c = 'Test Group';
        mbrGrp.Group_Number__c = '12345';
        mbrGrp.Client_Account__c = parentAcctTest2.Id;
        mbrGrp.Termination_Date__c = system.today()+3;
        mbrGrp.Status__c = 'Active';
        insert mbrGrp;
        
        Mbr_Group__c mbrGrp2 = new Mbr_Group__c();
        mbrGrp2.Name__c = 'Test Group2';
        mbrGrp2.Group_Number__c = '12346';
        mbrGrp2.Client_Account__c = parentAcctTest.Id;
        mbrGrp2.Termination_Date__c = system.today()+3;
        mbrGrp2.Status__c = 'Active';
        insert mbrGrp2;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = parentAcctTest.Id;
        insert con;
        
        Contact con2 = new Contact();
        con2.LastName = 'test 2';
        con2.AccountId = parentAcctTest2.Id;
        con2.Marketing_Site_User__c = TRUE;
        con2.Marketing_Site_Username__c = 'test';
        con2.email ='sfdx@test.com';
        insert con2;
        
        
       
    }
    
    @IsTest
    static void findName() {
        contact con = [SELECT Id, Name FROM Contact WHERE Name ='test'];
        String name = msuLookupLwcController.recordName(con.Id);
        system.assertEquals('test', name);
        Mbr_Group__c mbrGrp = [SELECT Id, Name__c FROM Mbr_Group__c WHERE Name__c ='Test Group'];
        String name2 = msuLookupLwcController.recordName(mbrGrp.Id);
        system.assertEquals('Test Group', name2);
    }
    
    @IsTest
    static void isContact() {
        contact con = [SELECT Id, Name FROM Contact WHERE Name ='test'];
        Boolean isContact = msuLookupLwcController.sObjectType(con.Id);
        system.assertEquals(true, isContact);
        Mbr_Group__c mbrGrp = [SELECT Id, Name__c FROM Mbr_Group__c WHERE Name__c ='Test Group'];
        Boolean isContact2 = msuLookupLwcController.sObjectType(mbrGrp.Id);
        system.assertEquals(false , isContact2);
    }
    
    @IsTest
    static void checkRecord() { 
        contact con = [SELECT Id, Name FROM Contact WHERE Name ='test'];
        Mbr_Group__c mbrGrp = [SELECT Id, Name__c FROM Mbr_Group__c WHERE Name__c ='Test Group'];
        string error = msuLookupLwcController.checkRecord(con.Id);
        system.assertEquals('Contact is not a marketing site user.' , error);
        con.Marketing_Site_User__c = true; 
        con.Email ='test@email.com';
        con.Contact_Status__c = 'Company out of Business';
        update con;
        Mkt_Site_User__c mktSiteUser = new Mkt_Site_User__c();
        mktSiteUser.Contact__c = con.Id;
        mktSiteUser.Mbr_Group__c = mbrGrp.Id;
        insert mktSiteUser;
        error = msuLookupLwcController.checkRecord(con.Id);
        system.assertEquals('Contact is not active.' , error);
		con.Contact_Status__c = 'Active';
        update con;
        error = msuLookupLwcController.checkRecord(con.Id);
        system.assertEquals(null , error);
        
    }
    
    @IsTest
    static void getMsuList() { 
        contact con = [SELECT Id, Name FROM Contact WHERE Name ='test'];
        Mbr_Group__c mbrGrp = [SELECT Id, Name__c FROM Mbr_Group__c WHERE Name__c ='Test Group'];
        con.Marketing_Site_Username__c = 'test';
		con.Contact_Status__c = 'Active';
        con.Marketing_Site_User__c = true; 
        con.Email ='test@email.com';
        update con;
        Mkt_Site_User__c mktSiteUser = new Mkt_Site_User__c();
        mktSiteUser.Contact__c = con.Id;
        mktSiteUser.Mbr_Group__c = mbrGrp.Id;
        insert mktSiteUser;
        msuLookupLwcController.getMsuList(con.Id);
        msuLookupLwcController.getMsuList(mbrGrp.Id);
     
    
    }
    
    


}