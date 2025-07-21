/*************************************************************************     
* @description This class is used for the product family object
* @param NA
* @Author InfoSys Developer
**************************************************************************/
public with sharing class APTS_GetFormData {
    
    Public static final String DOCUSIGNAPIACCOUNTID = system.label.Docusign_API_Account_Id;
    Public static final String LABEL_COMPANYSIGNEDBY = system.label.FormData_Company_Signed_by_1;
    Public static final String LABEL_COMPANYSIGNEDTITLE = system.label.FormData_Company_Signed_Title_1;
    Public static final String LABEL_COMPANYSIGNEDDATE = system.label.FormData_Company_Signed_Date_1;
    Public static final String LABEL_OTHERPARTYSIGNEDBY = system.label.FormData_Other_Party_Signed_by_1;
    Public static final String LABEL_OTHERPARTYSIGNEDTITLE = system.label.FormData_Other_Party_Signed_Title_1;
    Public static final String LABEL_OTHERPARTYSIGNEDDATE = system.label.FormData_Other_Party_Signed_Date_1;
    
    //Exception log variables
    public static String className = 'APTS_GetFormData';
    public static String methodName = '';
    
    /**
     * @description This is a Wrapper holding the Key and value of Formdata
     * @Author InfoSys Developer
    **/
    @SuppressWarnings('PMD.ClassNamingConventions')
    Public class formData{
        String name;
        String value;
    }   
       
    /**
     * @description This is invocable metod called in a Record Triggered Flow to fetch the form data from an envelope
     * @param envIds is a list od Docusign envelope Ids
     * @Author InfoSys Developer
    **/
    
    @InvocableMethod(label='Get FormData')
    Public static void getFormData(List<Id> envIds){
        //Fetching the respective Docusign Envelope records//
        List<Apttus_DocuApi__DocuSignEnvelope__c> envList = [Select Id, Name, Apttus_CMDSign__Agreement__c from Apttus_DocuApi__DocuSignEnvelope__c
                                                            where Id IN: envIds];
        
        //Fetching the Agreement records that are asociated with the Envelopes//
        List<Apttus__APTS_Agreement__c> agrList = [Select Id, Name, APTS_CompanySignedBy__c, Apttus__Company_Signed_Title__c, 
                                                   Apttus__Company_Signed_Date__c, APTS_OtherPartySignedBy__c,Apttus__Other_Party_Signed_Title__c,
                                                   Apttus__Other_Party_Signed_Date__c from Apttus__APTS_Agreement__c where 
                                                   Id IN (Select Apttus_CMDSign__Agreement__c from Apttus_DocuApi__DocuSignEnvelope__c
                                                          where Id IN: envList)];
        //Mapping Id vs Agreement// 
        Map<Id,Apttus__APTS_Agreement__c> agrMap = new Map<Id,Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agr:agrList){
            agrMap.put(agr.Id, agr);
        }
        //Mapping the Envelope and the Agreement records//
        Map<String,Apttus__APTS_Agreement__c> envAgrmap = New Map<String,Apttus__APTS_Agreement__c>();
        for(Apttus_DocuApi__DocuSignEnvelope__c docuEnv:envList){
            if(!envAgrmap.containsKey(docuEnv.id)){
                envAgrmap.put(docuEnv.id,agrMap.get(docuEnv.Apttus_CMDSign__Agreement__c)); 
            }
        }
        List<Apttus__APTS_Agreement__c> agmtToupdate = new List<Apttus__APTS_Agreement__c>();//List to store the Agreements to update//
        
        for(Apttus_DocuApi__DocuSignEnvelope__c envelope :envList){            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:DocuSignAuthProvider/restapi/v2.1/accounts/'+DOCUSIGNAPIACCOUNTID+'/envelopes/'+envelope.Name +'/form_data');
            HttpResponse resp = h.send(req);
            Map<String, Object> deserializedData = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            String formData = (String)JSON.serialize(deserializedData.get('formData'));
            List<formData> formData1 = (List<formData>)JSON.deserialize(formData,List<formData>.class);
            String companySignedby;
            String companySignedtitle;
            Date companySigneddate;
            String otherpartySignedby;
            String otherpartySignedtitle;
            Date otherpartySigneddate;
            for(formData form :formData1){
                if(form.name.contains(LABEL_COMPANYSIGNEDBY)){
                    companySignedby = form.value;       
                }
                else if(form.name.contains(LABEL_COMPANYSIGNEDTITLE)){
                    companySignedtitle = form.value;                
                }
                else if(form.name.contains(LABEL_COMPANYSIGNEDDATE)){
                    companySigneddate = Date.parse(form.value);               
                }
                else if(form.name.contains(LABEL_OTHERPARTYSIGNEDBY)){
                    otherpartySignedby = form.value;               
                }
                else if(form.name.contains(LABEL_OTHERPARTYSIGNEDTITLE)){
                    otherpartySignedtitle = form.value;               
                }
                else if(form.name.contains(LABEL_OTHERPARTYSIGNEDDATE)){
                    otherpartySigneddate = Date.parse(form.value);               
                }
            }

            Apttus__APTS_Agreement__c agmt = envAgrmap.get(envelope.id);
            agmt.APTS_CompanySignedBy__c = companySignedby;
            agmt.Apttus__Company_Signed_Title__c = companySignedtitle;
            agmt.Apttus__Company_Signed_Date__c = companySigneddate;
            agmt.APTS_OtherPartySignedBy__c =  otherpartySignedby;
            agmt.Apttus__Other_Party_Signed_Title__c = otherpartySignedtitle;
            agmt.Apttus__Other_Party_Signed_Date__c = otherpartySigneddate;
            agmtToupdate.add(agmt);            
        }        
        try{
            update agmtToupdate;
        }
        catch(exception e){
            
            SDF_LGR_LoggerManager.DBufLogger.error(e,className,methodName);
        }
        finally{
            SDF_LGR_LoggerManager.DBufLogger.flush();
        }        
    }    
}