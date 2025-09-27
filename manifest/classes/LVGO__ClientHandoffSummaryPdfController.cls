public class ClientHandoffSummaryPdfController {
    
    public Id clientHandoffSymmaryId {get; set;}    
    public final Id acctPartnerRecordTypeId = Schema.SObjectType.Relationship__c.getRecordTypeInfosByDeveloperName().get('Account_Partnership').getRecordTypeId();
    public static List<String> relationshipTypes{ get; set; }
    
    static {
        CHS_RelationshipType__mdt[] chsRelationshipType = [SELECT RelationshipType__c FROM CHS_RelationshipType__mdt];
        List<String> relTypeList = new List<String>();
        if(chsRelationshipType.size()>0){                 
            for(CHS_RelationshipType__mdt chsRel:chsRelationshipType){                
                relTypeList.add(chsRel.RelationshipType__c);
            }
        }
        relationshipTypes = relTypeList;        
    }
          
    public ClientHandoffSummaryPdfController() {
        clientHandoffSymmaryId = ApexPages.currentPage().getparameters().get('id'); 
    }
    public ClientHandoffSummaryWrapper theCHS
    {
        get{
            theCHS = getclientHandoffSummary();
            return theCHS;
        }
        set;
    }
    
    private ClientHandoffSummaryWrapper getclientHandoffSummary()
    {
        ClientHandoffSummaryWrapper chs = new ClientHandoffSummaryWrapper();
        chs.clientHandoffSummary = theclientHandoffSummary;
        chs.accountContactRelationships = theaccountContactRelationships;
        chs.programOverviews = theProgramOverviews;
        chs.opportunitiesForParentAccount = getOpportunitiesForParentAccount;
        chs.partnerRelationshipForParentAccount= getPartnerRelationshipForParentAccount;
        chs.contractPartnerRelationshipForParentAccount=getContractPartnerRelationshipForParentAccount;
        return chs;
    }
    private Client_Handoff_Summary__c theclientHandoffSummary {
        get{
            if(clientHandoffSymmaryId != null) {                
                theclientHandoffSummary = [SELECT Id, Client_Overview__c,Account__c,Enrollment_Marketing_Lead__c,Client_Implementation_Manager__c, 
                                           Client_Success_Manager__c,Account_Name__c,Account_Health_Score__c,Account_Health_Notes__c,Contract_Effective_Date__c,
                                           Contract_Type__c,Population_of_Coverage__c,Eligibility_Verification_Method__c,Clinical_Model__c,Clinical_Referrals__c,
                                           Clinical_Data_Sharing_and_Access__c,Additional_Details_Account_Contract__c,List_legal_documents__c,
                                           Box_Link_for_Legal_Documents__c,Livongo_Led__c,Outreach_Stratification__c,Do_we_receive_Emails__c,Launch_Assets__c,
                                           Marketing_Name__c,Livongo_Incentive_for_Automation__c,Ready_for_Automation__c,Client_Must_Approve_Assets__c,
                                           Additional_Details_Marketing__c,Recipient__c,Additional_Details_Reporting__c,
                                           How_does_Client_Define_Success__c,Call_Frequency__c,Email_Frequency__c,Business_reviews_discussed__c,
                                           Additional_Details_Account_Management__c,Additional_Details_HTN__c,Additional_Details_BH__c,Additional_Details_DM__c,
                                           Additional_Details_DPP__c,Additional_Details_WM__c  FROM Client_Handoff_Summary__c where Id=:clientHandoffSymmaryId];      //Data_Sharing_Agreement_Document__c,Account_Owner__c,Reporting_Frequency__c,Reporting_Type_Detail__c,Reporting_Method_of_Delivery__c,Reporting_Type__c,  
            }
            return theclientHandoffSummary;
        }
        private set;
    }
    private List<AccountContactRelation__c> theaccountContactRelationships {
        get{
            if(clientHandoffSymmaryId != null) {
                theaccountContactRelationships = ClientHandoffSummaryController.getAccountContactRelationships(clientHandoffSymmaryId);
            }
            return theaccountContactRelationships;
        }
        private set;
    }
    
    private List<Contract__c> theProgramOverviews {
        get{
            if(clientHandoffSymmaryId != null) {
                theProgramOverviews = [SELECT Id, Program_Name__c, Actual_Launch_Date__c,Member_Recruitment_Began__c,Initial_Targeted_Marketing__c,Contract_Term__c,ContractRenewalDate__c,Participants__c,Is_there_Lapse_Criteria__c,Lapse_Criteria__c,Lapsed_Criteria_Source__c,Consecutive_Inactive_Months_to_Lapsed__c,	Minimum_Number_of_Participants__c,Performance_Guarantees__c FROM Contract__c WHERE Client_Overview__c IN 
                                       (SELECT Client_Overview__c FROM Client_Handoff_Summary__c WHERE Id =:clientHandoffSymmaryId)];
            }
            return theProgramOverviews;
        }
        private set;
    }
    
    // Opportunities for Parent Accounts 
    private List<Opportunity__c> getOpportunitiesForParentAccount{
        get{
            if(clientHandoffSymmaryId != null) {
                getOpportunitiesForParentAccount = [SELECT Name, StageName__c, CloseDate__c,Livongo_for_Diabetes_PwDs__c,Livongo_for_Hypertension_PwHs__c 
                                                    FROM Opportunity__c WHERE Account__c IN (SELECT Account__c FROM Client_Handoff_Summary__c WHERE Id =:clientHandoffSymmaryId)];
            }
            return getOpportunitiesForParentAccount;
        }
        private set;        
    } 
    
    // Client-Level Partnerships for Parent Account
    private List<Relationship__c> getPartnerRelationshipForParentAccount{           
        get{                  
            if(clientHandoffSymmaryId != null) {
                getPartnerRelationshipForParentAccount = [SELECT Name,RelationshipType__c,Partner_Account_Text__c,Active__c 
                                                          FROM Relationship__c WHERE RecordTypeId =:acctPartnerRecordTypeId and Master_Client_Account__c IN 
                                                          (SELECT Account__c FROM Client_Handoff_Summary__c WHERE Id =:clientHandoffSymmaryId)];
            }
            return getPartnerRelationshipForParentAccount;
        }
        private set;      
    }
    
    // Contract-Level Partnerships for Parent Contract

    private List<Relationship__c> getContractPartnerRelationshipForParentAccount{
        get{
            if(clientHandoffSymmaryId != null  && relationshipTypes.size()>=0 ) {
                getContractPartnerRelationshipForParentAccount = [SELECT Name,RelationshipType__c,Partner_Account_Text__c,Active__c 
                                                                  FROM  Relationship__c WHERE RelationshipType__c IN: relationshipTypes                                                                  and Master_Contract__c IN 
                                                                  (SELECT Client_Overview__c FROM Client_Handoff_Summary__c WHERE Id =:clientHandoffSymmaryId)];
            }
            return getContractPartnerRelationshipForParentAccount;
        }
        private set;
    }
    
    public class ClientHandoffSummaryWrapper {
        public Client_Handoff_Summary__c clientHandoffSummary {get; set;}
        public List<AccountContactRelation__c> accountContactRelationships {get; set;}
        public List<Contract__c> programOverviews {get; set;}
        public List<Opportunity__c> opportunitiesForParentAccount{get;set;}
        public List<Relationship__c> partnerRelationshipForParentAccount{get;set;}
        public List<Relationship__c> contractPartnerRelationshipForParentAccount{get;set;}
        
    }
}