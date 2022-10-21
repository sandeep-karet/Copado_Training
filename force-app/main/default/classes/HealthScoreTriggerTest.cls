@isTest
public class HealthScoreTriggerTest {
    public static final Id ACCOUNT_HEALTH_SCORE_RT = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Account_Health_Score').getRecordTypeId();
    public static final Id PROGRAM_HEALTH_SCORE_RT = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Program_Health_Score').getRecordTypeId();
    
    @TestSetup
    static void setupData() {
        Account__c clientAccount = TestFactory.createClientAccount();
        insert clientAccount;
    }
    
    private static Account__c getAccount() {
        return [SELECT Id FROM Account__c LIMIT 1];
    }
    
    private static List<Health_Score__c> getHealthScores(Id accId) {
        return [SELECT Id, Actual_Result__c, Health_Segment__c, Program__c, Cross_Sells_Expansions__c, RecordTypeId, 
                Client_NPS__c, Client_Business_Health__c, Interaction_Cadence__c, Executive_Sponsor_Interaction_Engagement__c,
                Contract_Path_Status__c, Issues__c, Competitor_w_in_account__c, Immediate_Action_Needed__c, Member_Satisfaction__c, 
                Participating_in_any_optimized_campaigns__c, Population_Refresh__c, eHba1c_Reduction__c, ROI_Status_DM__c, Systolic_BP_Reduction__c, 
                Diastolic_BP_Reduction__c, ROI_Status_HTN__c FROM Health_Score__c WHERE Account__c = :accId];
    }
    
    @isTest
    static void healthScoreUpdateTest1() {
        Account__c acc = getAccount();
        List<Health_Score__c> hsList = getHealthScores(acc.Id);
        for (Health_Score__c hs : hsList) {
            if (hs.RecordTypeId == ACCOUNT_HEALTH_SCORE_RT) {
                switch on hs.Health_Segment__c {
                    when 'Program Score' {
                        hs.Actual_Result__c = '80';
                    }
                    when 'Renewal Timing' {
                        hs.Actual_Result__c = '>1 year';
                    }
                    when 'Cross Sells/Expansions'{
                        hs.Cross_Sells_Expansions__c = 'Expansion/cross sell opp/no additional programs to sell';
                    }
                    when 'Client NPS' {
                        hs.Client_NPS__c = 60;
                    }
                    when 'Client Business Health' {
                        hs.Client_Business_Health__c = 'Growing';
                    }
                    when 'Interaction Cadence' {
                        hs.Interaction_Cadence__c = 'Meeting established cadence';
                    }
                    when 'Executive Sponsor Interaction/Engagement' {
                        hs.Executive_Sponsor_Interaction_Engagement__c = 'Seat at executive sponsor table';
                    }
                    when 'Contract Path/Partner Relationship/Status' {
                        hs.Contract_Path_Status__c = 'Green Partner';
                    }
                    when 'Issues' {
                        hs.Issues__c = 'Marketing Issues';
                    }
                    when 'Competitor w/in account' {
                        hs.Competitor_w_in_account__c = 'Yes';
                    }
                    when 'Immediate Action Needed' {
                        hs.Immediate_Action_Needed__c = 'Merger';
                    }
                }
            }
            else if (hs.RecordTypeId == PROGRAM_HEALTH_SCORE_RT) {
                if (hs.Program__c == 'Diabetes') {
                    switch on hs.Health_Segment__c {
                        when 'Member Satisfaction' {
                            hs.Member_Satisfaction__c = 75;
                        }
                        when 'Enrollment' {
                            hs.Actual_Result__c = '40';
                        }
                        when 'Activation' {
                            hs.Actual_Result__c = '80';
                        }
                        when 'Active 30' {
                            hs.Actual_Result__c = '90';
                        }
                        when 'Marketing Type (Outreach Stratification)' {
                            hs.Actual_Result__c = 'A';
                            hs.Participating_in_any_optimized_campaigns__c = true;
                        }
                        when 'Email Coverage' {
                            hs.Actual_Result__c = '50';
                        }
                        when 'Population Refresh' {
                            hs.Population_Refresh__c = 'within 3 months';
                        }
                        when 'eHba1c Reduction' {
                            hs.eHba1c_Reduction__c = 0.6;
                        }
                        when 'ROI Status' {
                            hs.ROI_Status_DM__c = 'Client <1.25 years on program or partnership doesn\'t allow ROI';
                        }
                    }
                }
                else if (hs.Program__c == 'Hypertension') {
                    switch on hs.Health_Segment__c {
                        when 'Member Satisfaction' {
                            hs.Member_Satisfaction__c = 80;
                        }
                        when 'Enrollment' {
                            hs.Actual_Result__c = '30';
                        }
                        when 'Activation' {
                            hs.Actual_Result__c = '75';
                        }
                        when 'Active 30' {
                            hs.Actual_Result__c = '80';
                        }
                        when 'Marketing Type (Outreach Stratification)' {
                            hs.Actual_Result__c = 'A';
                            hs.Participating_in_any_optimized_campaigns__c = true;
                        }
                        when 'Email Coverage' {
                            hs.Actual_Result__c = '40';
                        }
                        when 'Population Refresh' {
                            hs.Population_Refresh__c = 'within 3 months';
                        }
                        when 'Systolic BP Reduction' {
                            hs.Systolic_BP_Reduction__c = 8;
                        }
                        when 'Diastolic BP Reduction' {
                            hs.Diastolic_BP_Reduction__c = 5;
                        }
                        when 'ROI Status' {
                            hs.ROI_Status_HTN__c = 'Client <1.25 years on program or partnership doesn\'t allow ROI';
                        }
                    }
                }
            }
        }
        Test.startTest();
        update hsList;
        Test.stopTest();
        for (Health_Score__c hs : hsList) {
            if (hs.RecordTypeId == ACCOUNT_HEALTH_SCORE_RT) {
                switch on hs.Health_Segment__c {
                    when 'Program Score' {
                        System.assertEquals('80', hs.Actual_Result__c);
                    }
                    when 'Renewal Timing' {
                        System.assertEquals('>1 year', hs.Actual_Result__c);
                    }
                }
            }
        }
    }
    
    @isTest
    static void healthScoreUpdateTest2() {
        Account__c acc = getAccount();
        List<Health_Score__c> hsList = getHealthScores(acc.Id);
        for (Health_Score__c hs : hsList) {
            if (hs.RecordTypeId == ACCOUNT_HEALTH_SCORE_RT) {
                switch on hs.Health_Segment__c {
                    when 'Program Score' {
                        hs.Actual_Result__c = '65';
                    }
                    when 'Renewal Timing' {
                        hs.Actual_Result__c = '6 months - 1 year';
                    }
                    when 'Cross Sells/Expansions'{
                        hs.Cross_Sells_Expansions__c = 'On path to discussion';
                    }
                    when 'Client NPS' {
                        hs.Client_NPS__c = 45;
                    }
                    when 'Client Business Health' {
                        hs.Client_Business_Health__c = 'Stable';
                    }
                    when 'Interaction Cadence' {
                        hs.Interaction_Cadence__c = 'No meeting cadence/consistently cancels';
                    }
                    when 'Executive Sponsor Interaction/Engagement' {
                        hs.Executive_Sponsor_Interaction_Engagement__c = 'Livongo executive relationship';
                    }
                    when 'Contract Path/Partner Relationship/Status' {
                        hs.Contract_Path_Status__c = 'Yellow partner';
                    }
                    when 'Issues' {
                        hs.Issues__c = 'Marketing Issues';
                    }
                    when 'Competitor w/in account' {
                        hs.Competitor_w_in_account__c = 'No';
                    }
                    when 'Immediate Action Needed' {
                        hs.Immediate_Action_Needed__c = 'Merger';
                    }
                }
            }
            else if (hs.RecordTypeId == PROGRAM_HEALTH_SCORE_RT) {
                if (hs.Program__c == 'Diabetes') {
                    switch on hs.Health_Segment__c {
                        when 'Member Satisfaction' {
                            hs.Member_Satisfaction__c = 45;
                        }
                        when 'Enrollment' {
                            hs.Actual_Result__c = '25';
                        }
                        when 'Activation' {
                            hs.Actual_Result__c = '68';
                        }
                        when 'Active 30' {
                            hs.Actual_Result__c = '68';
                        }
                        when 'Marketing Type (Outreach Stratification)' {
                            hs.Actual_Result__c = 'B';
                            hs.Participating_in_any_optimized_campaigns__c = true;
                        }
                        when 'Email Coverage' {
                            hs.Actual_Result__c = '25';
                        }
                        when 'Population Refresh' {
                            hs.Population_Refresh__c = '> 3 months ago';
                        }
                        when 'eHba1c Reduction' {
                            hs.eHba1c_Reduction__c = 0.4;
                        }
                        when 'ROI Status' {
                            hs.ROI_Status_DM__c = 'Client >1.25 with 100 activated, fitch mode or BOB';
                        }
                    }
                }
                else if (hs.Program__c == 'Hypertension') {
                    switch on hs.Health_Segment__c {
                        when 'Member Satisfaction' {
                            hs.Member_Satisfaction__c = 45;
                        }
                        when 'Enrollment' {
                            hs.Actual_Result__c = '15';
                        }
                        when 'Activation' {
                            hs.Actual_Result__c = '65';
                        }
                        when 'Active 30' {
                            hs.Actual_Result__c = '65';
                        }
                        when 'Marketing Type (Outreach Stratification)' {
                            hs.Actual_Result__c = 'B';
                            hs.Participating_in_any_optimized_campaigns__c = true;
                        }
                        when 'Email Coverage' {
                            hs.Actual_Result__c = '25';
                        }
                        when 'Population Refresh' {
                            hs.Population_Refresh__c = '> 3 months ago';
                        }
                        when 'Systolic BP Reduction' {
                            hs.Systolic_BP_Reduction__c = 4;
                        }
                        when 'Diastolic BP Reduction' {
                            hs.Diastolic_BP_Reduction__c = 4;
                        }
                        when 'ROI Status' {
                            hs.ROI_Status_HTN__c = 'Client >1.25 years with no ROI completed';
                        }
                    }
                }
            }
        }
        Test.startTest();
        update hsList;
        Test.stopTest();
        for (Health_Score__c hs : hsList) {
            if (hs.RecordTypeId == ACCOUNT_HEALTH_SCORE_RT) {
                switch on hs.Health_Segment__c {
                    when 'Program Score' {
                        System.assertEquals('65', hs.Actual_Result__c);
                    }
                    when 'Renewal Timing' {
                        System.assertEquals('6 months - 1 year', hs.Actual_Result__c);
                    }
                }
            }
        }
    }
}