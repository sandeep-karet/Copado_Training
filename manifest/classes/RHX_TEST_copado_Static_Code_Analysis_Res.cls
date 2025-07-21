@isTest(SeeAllData=true)
public class RHX_TEST_copado_Static_Code_Analysis_Res {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM copado__Static_Code_Analysis_Result__c ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new copado__Static_Code_Analysis_Result__c()
            );
        }
    	

       rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}