/*************************************************************************     
* @description This class is used as TestDataUtility for APTS_SetConsultFeeTestClass
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class GCRM_TestDataFactory_Test {
  /**
* @description To create test Leads
* @param numLeads
* @return List of leads
*/   
    public static List<Lead> createLeads(Integer numLeads) {
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < numLeads; i++) {
            Lead lead = new Lead(LastName = 'Test LastName '+ i, Company = 'Test Company '+i);
            leads.add(lead);
        }
        insert leads;
        return leads;
    }
   
    
}