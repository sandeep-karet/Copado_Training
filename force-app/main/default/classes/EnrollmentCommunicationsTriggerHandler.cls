public class EnrollmentCommunicationsTriggerHandler {
    
    public static final String DIABETES = System.Label.Diabetes;
    public static final String HYPERTENSION = System.Label.Hypertension;
    public static final String PREDIABETES = System.Label.Prediabetes;
    public static final String WEIGHTMGMT = System.Label.Weight_Management;
    public static final String BEHAVIORAL_HEALTH = System.Label.Behavioral_Health;
    public static final Id CO_RECORDTYPEID = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Client_Overview').getRecordTypeId();
    public static final Id PO_RECORDTYPEID = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Program_Overview').getRecordTypeId();
    
    Public Static void updateContractrecords(List<Enrollment_Communications_Survey__c> enrolSurveyList){
        //Retrieving the Account Ids//
        Set<Id> accountIds = new Set<Id>();
        for(Enrollment_Communications_Survey__c survey:enrolSurveyList){
            accountIds.add(survey.account__c);
        }
        
        List<Id> contactRecordTypes = new List<Id>{CO_RECORDTYPEID,PO_RECORDTYPEID};

        //Fetching the respective Contracts//
        List<contract__c> contractList = [SELECT Id,Account__c, RecordTypeId, Status__c, Program_Name__c, Eligibility_Sentence__c,
                                       Account_Client_Overview__c,  Marketing_Name__c, General_Eligibility_Sentence__c,
                                       Employee_Title__c, Client_Able_to_Send_HR_Comms__c, OE_Month_Start__c,
                                       OE_Month_End__c, OE_Period_Length__c, Disclaimer__c from contract__c
                                       WHERE Account__c In :accountIds and RecordTypeId IN :contactRecordTypes and 
                                       (Status__c =: 'Active' or Status__c =: 'Draft')];
        
        List<contract__c> contractListToUpdate = New List<contract__c>();
        for(Enrollment_Communications_Survey__c enrollComms : enrolSurveyList){            
            for(Contract__c co : contractList){
                if(co.Account__c == enrollComms.Account__c){   //Checking for Client Overview records//                    
                    if(co.recordTypeId  == co_RecordTypeId){
                        co.Marketing_Name__c =enrollComms.Marketing_Name__c ;
                        co.Employee_Title__c =enrollComms.Employee_Title__c ;
                        co.OE_Month_Start__c = enrollComms.OE_Month_Start__c ;
                        co.OE_Month_End__c = enrollComms.OE_Month_End__c;
                        co.OE_Period_Length__c = enrollComms.OE_Period_Length__c ;
                        if(enrollComms.Client_able_to_send_HR_comms__c == 'Yes'){
                            co.Client_Able_to_Send_HR_Comms__c = true;
                            if(string.isNotBlank(enrollComms.General_Eligibility_Sentence__c)){
                                co.General_Eligibility_Sentence__c = enrollComms.General_Eligibility_Sentence__c; 
                                co.Disclaimer__c = enrollComms.Disclaimer__c;
                            }
                            contractListToUpdate.add(co);
                        }
                    }
                    else if(co.recordTypeId  == po_RecordTypeId) {  //Checking for Program Overview records//
                        if((co.Account__c  == enrollComms.Account__c)&&(enrollComms.Livongo_programs__c.contains(co.Program_Name__c))){ 
                            co.Disclaimer__c = enrollComms.Disclaimer__c;
                            if(co.Program_Name__c == DIABETES){
                                co.Eligibility_Sentence__c = enrollComms.Diabetes_Eligibility_Sentence__c;                                
                            }
                            else if(co.Program_Name__c == HYPERTENSION){
                                co.Eligibility_Sentence__c = enrollComms.Hypertension_Eligibility_Sentence__c;
                            }
                            else if(co.Program_Name__c == PREDIABETES){
                                co.Eligibility_Sentence__c = enrollComms.Prediabetes_Eligibility_Sentence__c; co.Disclaimer__c = enrollComms.Disclaimer__c;
                            }
                            Else if(co.Program_Name__c == WEIGHTMGMT){
                                co.Eligibility_Sentence__c = enrollComms.Weight_Management_Eligibility_Sentence__c;co.Disclaimer__c = enrollComms.Disclaimer__c;
                            }
                            else if(co.Program_Name__c == BEHAVIORAL_HEALTH){
                                co.Eligibility_Sentence__c = enrollComms.Behavioral_Health_Eligibility_Sentence__c;co.Disclaimer__c = enrollComms.Disclaimer__c;
                            }                               
                        }
                        contractListToUpdate.add(co);
                    }
                }
                try{
                    if(!contractListToUpdate .isEmpty()){
                        update contractListToUpdate;
                    }  
                }catch(DmlException e){
                    system.debug('The Following Exception occured - '+e.getMessage());  
                }
                
            }
        }
    }
}