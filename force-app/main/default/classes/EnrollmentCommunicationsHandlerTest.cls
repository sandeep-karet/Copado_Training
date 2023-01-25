@isTest
public class EnrollmentCommunicationsHandlerTest {
    public static final Id CO_RECORDTYPEID = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId();
    public static final Id PO_RECORDTYPEID = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId();
    public static final Id ACC_RECORDTYPEID = Schema.SObjectType.Account__c.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
    
    Public static testMethod void doTestContract_CO_PO(){
        List<String> livPrograms = new List<String>{'Diabetes', 'Hypertension', 'Prediabetes', 'Weight Management',
            'Behavioral Health'};
                List<Account__c> accList = new List<Account__c>();
        for(integer i=0; i<2; i++){
            Account__c acc = new Account__c();
            acc.RecordTypeId = ACC_RECORDTYPEID;
            acc.Name = 'Test Account'+i;
            acc.Type__c = 'TPA';
            accList.add(acc);
        }
        insert accList;
        List<Enrollment_Communications_Survey__c> envList = new List<Enrollment_Communications_Survey__c>();
        for(integer j=0; j<2; j++){
            Enrollment_Communications_Survey__c envSurvey = new Enrollment_Communications_Survey__c();
            envSurvey.Account__c = accList.get(j).Id;
            envSurvey.Survey_Status__c = 'Sent';
            envList.add(envSurvey);
        }
        insert envList;
        
        for(Enrollment_Communications_Survey__c env:envList){
            env.Survey_Status__c = 'Completed';
            env.Client_able_to_send_HR_Comms__c = 'Yes';
            env.Disclaimer__c = 'NA';
            env.Diabetes_Eligibility_Sentence__c = 'Diabetes Eligibility';
            env.Hypertension_Eligibility_Sentence__c = 'Hypertension Eligibility';
            env.Prediabetes_Eligibility_Sentence__c = 'Prediabetes Eligibility';
            env.Weight_Management_Eligibility_Sentence__c = 'Weight Management Eligibility';
            env.General_Eligibility_Sentence__c = 'General';
            env.Employee_Title__c = 'Employees';
            env.Marketing_Name__c = 'ABC Inc';
            env.OE_Month_Start__c = 'January';
            env.OE_Month_End__c = 'February';
            env.OE_Period_Length__c = '2 weeks';
            DescribeFieldResult describe = Enrollment_Communications_Survey__c.Livongo_programs__c.getDescribe();
            List<PicklistEntry> avl = describe.getPicklistValues();
            string fgh =avl[0].value+';'+avl[4].value+';'+avl[3].value+';'+avl[2].value+';'+avl[1].value;
            env.Livongo_programs__c= fgh;
        }  
        update envList;
        
        List<contract__c> coList = New List<contract__c>();
        Contract__c cont_CO = new Contract__c();
        cont_CO.RecordTypeId = CO_RECORDTYPEID;
        cont_CO.Account__c = accList.get(1).Id;
        cont_CO.Status__c = 'Draft';
        insert cont_CO;
        
        for(integer k=0; k<5; k++){
            Contract__c cont_PO = new Contract__c();
            cont_PO.Account__c = accList.get(1).Id;
            cont_PO.RecordTypeId = PO_RECORDTYPEID;
            cont_PO.Account_Client_Overview__c = cont_CO.Id;
            cont_PO.Program_Name__c = livPrograms.get(k);
            cont_PO.Eligibility_Sentence__c = '';
            cont_PO.Status__c = 'Draft';
            coList.add(cont_PO);
        }
        insert coList;
        
        
        test.startTest();
        EnrollmentCommunicationsTriggerHandler.updateContractrecords(envList);
        test.stopTest();
        
    }
}