@IsTest
public class OppLineEnrollmenPercentBatchTest {
    
    @TestSetup
    static void testData(){
        
        
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs ( testUser ) {
            UserRole ur = new UserRole();
            ur.Name='Commercial_DTE_East_Client_Sales';
            ur.DeveloperName='Commercial_DTE_East_Client_Sales';
            insert ur;
        //}    
        System.runAs (testUser) {
        LVGO_Automation_Switch__c asw  =new LVGO_Automation_Switch__c();
        asw.Triggers__c  =true;
        asw.Flows__c  =true;
        asw.ProcessBuilders__c  =true;
        asw.Validations__c  =true; 
        asw.Workflows__c  =true;
        insert asw;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            User newUser = new User (Alias = 'standt', Email='testuser@test.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = p.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testlv.com', UserRoleId = getUserRole().Id);
            insert newUser;
            Account__c clientAccount = TestFactory.createClientAccount();
            clientAccount.Account_Name__c=clientAccount.Name;
            insert clientAccount;      
            
            Opportunity__c newBusinessOpp = TestFactory.createTypeBasedOpportunity('New Business');
            newBusinessOpp.Account__c = clientAccount.Id;
            newBusinessOpp.Name = 'Enrollment Opp';
            newBusinessOpp.Opportunity_Covered_Lives__c=10000;   
            newBusinessOpp.Opportunity_Name__c = newBusinessOpp.Name;  
            insert newBusinessOpp;
            
            
            
            Pricebook2 livongoPricebook = TestFactory.createPricebook();
            insert livongoPricebook;
            
            
            List<Product2> programsList = new List<Product2>();
            programsList.add(TestFactory.createProgramWithFamily('Livongo for Diabetes', 'Diabetes'));
            programsList.add(TestFactory.createProgramWithFamily('Livongo for Hypertension', 'Hypertension'));
            programsList.add(TestFactory.createProgramWithFamily('Livongo Diabetes Prevention Program', 'Prediabetes'));
            programsList.add(TestFactory.createProgramWithFamily('Livongo for Weight Management', 'Weight Management'));
            programsList.add(TestFactory.createProgramWithFamily('Livongo for Behavioral Health by myStrength 2.0', 'Behavioral Health'));
            programsList.add(TestFactory.createProgramWithFamily('Teladoc', 'Teladoc'));
            programsList.add(TestFactory.createProgramWithFamily('myStrength', 'Behavioral Health'));
            programsList.add(TestFactory.createProgramWithFamily('myStrength Complete', 'Behavioral Health'));
            insert programsList;
            
            Id standardPBId = Test.getStandardPricebookId();
            
            List<PricebookEntry> entriesList = new List<PricebookEntry>();
            List<PricebookEntry> livongoPBEntriesList = new List<PricebookEntry>();
            List<Pricing_Structure__c> pricingStructureList = new List<Pricing_Structure__c>();
            
            for(Product2 program: programsList) {
                entriesList.add(TestFactory.createPricebookEntry(standardPBId, program.Id));
                livongoPBEntriesList.add(TestFactory.createPricebookEntry(livongoPricebook.Id, program.Id));
                pricingStructureList.add(TestFactory.createPricingStructure(livongoPricebook.Id, program.Id));
            }        
            insert entriesList;
            insert livongoPBEntriesList;
            insert pricingStructureList;
            
            livongoPBEntriesList = [Select Id, Pricebook2ID, Product2Id, Product2.Name, UnitPrice, IsActive from PricebookEntry where Id IN:livongoPBEntriesList];
            
            List<OpportunityLineItem__c> oliList = new List<OpportunityLineItem__c>();
            
            for(PricebookEntry pbe: livongoPBEntriesList) {
                //oliList.add(TestFactory.createOpportunityLineItem(newBusinessOpp.Id, pbe.Id));
                OpportunityLineItem__c oli = TestFactory.createOpportunityLineItem(newBusinessOpp.Id, pbe.Id);
                oli.Product2__c = pbe.Product2Id;
                oli.Price_Book_ID__c = pbe.Pricebook2ID;
                oli.OpportunityProductName__c = pbe.Product2.Name;
                oliList.add(oli);
            }   
            insert oliList;
        }
    }
    
    private static UserRole getUserRole() {
        return [SELECT Id FROM UserRole WHERE DeveloperName = 'Commercial_DTE_East_Client_Sales' LIMIT 1];
    }
    
    private static List<OpportunityLineItem__c> getOppline(Id oppId, String OppProductName) {
        return [SELECT Id, Enrollment_Percentage__c, Opportunity__c,Program_Family__c, Pricing_Structure__c, Product2__c, OpportunityProductName__c FROM 
                                                 OpportunityLineItem__c WHERE Opportunity__c =: oppId and OpportunityProductName__c =: oppProductName];
    }

    private static List<Pricing_Structure__c> getPricingStructures() {
        return [SELECT Id,Name From Pricing_Structure__c];
    }
    
    private static Product2 getProducts(String programName) {
        return [Select Id, Name From Product2 WHERE Name =: programName];
    }
    static {
        List <Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTList = [SELECT Id, MasterLabel, DeveloperName, Opp_Owner_Role__c, Estimated_Enrollment__c, Program_Family__c FROM Estimated_Enrollment_Mapping__mdt];
        Map <String, Estimated_Enrollment_Mapping__mdt> estimatedEnrollementMDTMap = new Map < String, Estimated_Enrollment_Mapping__mdt > ();
        if (!estimatedEnrollementMDTList.isEmpty()) {
            for (Estimated_Enrollment_Mapping__mdt enr : estimatedEnrollementMDTList) {
                estimatedEnrollementMDTMap.put(enr.Opp_Owner_Role__c + '' + enr.Program_Family__c, enr);
            }
        }    
    }
    
    @istest
   static void calEnrollmentPercentageForHypertension() {
       
        User user = [SELECT Id, UserRoleId FROM User WHERE UserName='testuser@testlv.com' LIMIT 1];
        Opportunity__c opp = [SELECT Id, Source__c, Opp_Owner_Role__c FROM Opportunity__c WHERE Name = 'Enrollment Opp' LIMIT 1];
        opp.Owner__c = user.Id;
        update opp;
        List<OpportunityLineItem__c> oppLineList = getOppline(opp.Id, 'Livongo for Hypertension');
        //List<Pricing_structure__c> pricingStructureList = getPricingStructures();
        Product2 productHP = getProducts('Livongo for Hypertension');
        Test.startTest();
        OppLineEnrollmentPercentUpdateBatch OppLineBatch = new OppLineEnrollmentPercentUpdateBatch();
        Id batchId = Database.executeBatch(OppLineBatch);
        Test.stopTest();
        System.assertEquals(10.00, [SELECT Id, Enrollment_Percentage__c FROM OpportunityLineItem__c WHERE OpportunityProductName__c = 'Livongo for Hypertension' LIMIT 1].Enrollment_Percentage__c);
    } 
    
    @istest
    static void calEnrollmentPercentageForMystrength() {
    
        User user = [SELECT Id, UserRoleId FROM User WHERE UserName='testuser@testlv.com' LIMIT 1];
        Opportunity__c opp = [SELECT Id,Source__c, Opp_Owner_Role__c FROM Opportunity__c WHERE Name = 'Enrollment Opp' LIMIT 1];
        opp.Owner__c = user.Id;
        update opp;
        List<OpportunityLineItem__c> oppLineList = getOppline(opp.Id, 'myStrength Complete');
        PriceBook2 priceBook = [SELECT Id, Name FROM PriceBook2 WHERE Name = 'Livongo'];
        Product2 product = getProducts('myStrength Complete');
        Pricing_Structure__c ps = new Pricing_Structure__c(Name = 'Broker PPPM', Price_Book__c = priceBook.Id, Program__c = product.Id, IsActive__c = true, List_Price__c = 65);
        insert ps;
        oppLineList[0].Pricing_structure__c =ps.Id;
        oppLineList[0].Price_Book_ID__c = priceBook.Id; 
        update oppLineList;
        Test.startTest();
        OppLineEnrollmentPercentUpdateBatch OppLineBatch = new OppLineEnrollmentPercentUpdateBatch();
        Id batchId = Database.executeBatch(OppLineBatch);
        Test.stopTest();
        System.assertEquals(5.00, [SELECT Id, Enrollment_Percentage__c FROM OpportunityLineItem__c WHERE OpportunityProductName__c = 'myStrength Complete' LIMIT 1].Enrollment_Percentage__c);
    }
}