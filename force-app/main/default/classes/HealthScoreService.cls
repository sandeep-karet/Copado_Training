public class HealthScoreService {
    public static final Id ACCOUNT_HEALTH_SCORE_RT = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Account_Health_Score').getRecordTypeId();
    public static final Id PROGRAM_HEALTH_SCORE_RT = Schema.SObjectType.Health_Score__c.getRecordTypeInfosByDeveloperName().get('Program_Health_Score').getRecordTypeId();
    
    public static void calculateScores(List<Health_Score__c> hsList) {
        List<Health_Score__c> accountHealthScoresToUpdate = new List<Health_Score__c>();
        List<Health_Score__c> dmHealthScoresToUpdate = new List<Health_Score__c>();
        List<Health_Score__c> htnHealthScoresToUpdate = new List<Health_Score__c>();
        for (Health_Score__c hs: hsList) {
            if (hs.RecordTypeId == ACCOUNT_HEALTH_SCORE_RT) {
                accountHealthScoresToUpdate.add(hs);
            }
            else if (hs.RecordTypeId == PROGRAM_HEALTH_SCORE_RT && hs.Program__c != Null && hs.Program__c == 'Diabetes') {
                dmHealthScoresToUpdate.add(hs);
            }
            else if (hs.RecordTypeId == PROGRAM_HEALTH_SCORE_RT && hs.Program__c != Null && hs.Program__c == 'Hypertension') {
                htnHealthScoresToUpdate.add(hs);
            }
        }
        if (!accountHealthScoresToUpdate.isEmpty()) {
            updateAccountScores(accountHealthScoresToUpdate);
        }
        if (!dmHealthScoresToUpdate.isEmpty()) {
            updateDMScores(dmHealthScoresToUpdate);
        }
        if (!htnHealthScoresToUpdate.isEmpty()) {
            updateHTNScores(htnHealthScoresToUpdate);
        }
    }
   
    public static void updateAccountScores(List<Health_Score__c> listOfHealthScores) {
        for (Health_Score__c hs : listOfHealthScores) {
            String healthSegment = hs.Health_Segment__c;
            switch on healthSegment {
                when 'Program Score' {
                    if (String.IsNotBlank(hs.Actual_Result__c)) {
                        Decimal programScore = Decimal.valueOf(hs.Actual_Result__c);
                        if (programScore >= 75) {
                            hs.Score__c = 25;
                        }
                        else if (programScore >= 60 && programScore <= 74) {
                            hs.Score__c = 15;
                        }
                        else {
                            hs.Score__c = 0;
                        }
                    }
                }
                when 'Renewal Timing' {
                   hs.Score__c = 15;
                }
                when 'Cross Sells/Expansions'{
                    if (hs.Cross_Sells_Expansions__c == 'Expansion/cross sell opp/no additional programs to sell') {
                        hs.Score__c = 10;
                    }
                    else if (hs.Cross_Sells_Expansions__c == 'On path to discussion') {
                        hs.Score__c = 5;
                    }
                    else if(hs.Cross_Sells_Expansions__c == 'Partnership does not allow expansion') {
                        hs.Score__c = 0;
                    }
                    else if (hs.Cross_Sells_Expansions__c == 'Client declined discussion') {
                        hs.Score__c = -10;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Client NPS' {
                    if (hs.Client_doesn_t_complete_survey__c) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Client_NPS__c > 55) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Client_NPS__c >= 40 && hs.Client_NPS__c <= 55) {
                        hs.Score__c = 2;
                    }
                    else if (hs.Client_NPS__c < 40) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Client Business Health' {
                    if (hs.Client_Business_Health__c == 'Growing') {
                        hs.Score__c = 15;
                    }
                    else if (hs.Client_Business_Health__c == 'Stable') {
                        hs.Score__c = 10;
                    }
                    else if (hs.Client_Business_Health__c == 'Declining') {
                        hs.Score__c = -10;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Interaction Cadence' {
                    if (hs.Interaction_Cadence__c == 'Meeting established cadence') {
                        hs.Score__c = 10;
                    }
                    else if (hs.Interaction_Cadence__c == 'No meeting cadence/consistently cancels') {
                        hs.Score__c = -10;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Executive Sponsor Interaction/Engagement' {
                    String exeSpnsrIntrctnEngmnt = hs.Executive_Sponsor_Interaction_Engagement__c;
                    if (String.isNotBlank(exeSpnsrIntrctnEngmnt)) {
                        List<String> exeSpnsrIntrctnEngmntList = exeSpnsrIntrctnEngmnt.split(';');
                        if (exeSpnsrIntrctnEngmntList.size() > 0) {
                            hs.Score__c = 3 * exeSpnsrIntrctnEngmntList.size();
                        }
                        else {
                            hs.Score__c = 0;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                
                when 'Contract Path/Partner Relationship/Status' {
                    if (hs.Contract_Path_Status__c == 'Green Partner') {
                        hs.Score__c = 5;
                    }
                    else if (hs.Contract_Path_Status__c == 'Yellow partner') {
                        hs.Score__c = 2;
                    }
                    else if (hs.Contract_Path_Status__c == 'Red/black partner') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Issues' {
                    String issues = hs.Issues__c;
                    if (String.isNotBlank(issues)) {
                        List<String> issueList = issues.split(';');
                        if (issueList.size() > 0) {
                            hs.Score__c = -15;
                        }
                        else {
                            hs.Score__c = 0;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Competitor w/in account' {
                    if (hs.Competitor_w_in_account__c == 'Yes') {
                        hs.Score__c = -15;
                    }
                    else if (hs.Competitor_w_in_account__c == 'No') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Immediate Action Needed' {
                    String imActionNeeded = hs.Immediate_Action_Needed__c;
                    if (String.isNotBlank(imActionNeeded)) {
                        List<String> imActionNeededList = imActionNeeded.split(';');
                        if (imActionNeededList.size() > 0) {
                            hs.Score__c = -20;
                        }
                        else {
                            hs.Score__c = 0;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
            }   
        }
    }
    
    public static void updateDMScores(List<Health_Score__c> listOfHealthScores) {
        for (Health_Score__c hs : listOfHealthScores) {
            String healthSegment = hs.Health_Segment__c;
            switch on healthSegment {
                when 'Member Satisfaction' {
                    if (hs.Member_Satisfaction__c > 60) {
                        hs.Score__c = 10;
                    }
                    else if (hs.Member_Satisfaction__c >= 40 && hs.Member_Satisfaction__c <= 60) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Member_Satisfaction__c < 40) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Enrollment' {
                    if (String.isNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue >= 30) {
                            hs.Score__c = 20;
                        }
                        else if (actualResultValue >= 20 && actualResultValue <= 29) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue < 20) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Activation' {
                    if (String.isNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 75) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 65 && actualResultValue <= 75) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 65) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Active 30' {
                    if(String.isNotBlank(hs.Actual_Result__c)){
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 75) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 65 && actualResultValue <= 75) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 65) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Marketing Type (Outreach Stratification)' {
                    if (hs.Actual_Result__c == 'A') {
                        hs.Score__c = 5;
                    }
                    else if (hs.Actual_Result__c == 'B') {
                        hs.Score__c = 2;
                    }
                    else if (hs.Actual_Result__c == 'C') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                    if (hs.Participating_in_any_optimized_campaigns__c) {
                        hs.Score__c += 5;
                    }
                }
                when 'Email Coverage' {
                    if (hs.Client_does_not_allow_email_marketing__c == true) {
                        hs.Score__c = 0;
                    }
                    else if (String.IsNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 40) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 20 && actualResultValue <= 40) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 20 && actualResultValue > 0) {
                            hs.Score__c = 2;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Population Refresh' {
                    if (hs.Population_Refresh__c == 'within 3 months') {
                        hs.Score__c = 10;
                    }
                    else if (hs.Population_Refresh__c == '> 3 months ago') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'eHba1c Reduction' {
                    if (hs.eHba1c_Reduction__c > 0.5) {
                        hs.Score__c = 15;
                    }
                    else if (hs.eHba1c_Reduction__c >= 0.3 && hs.eHba1c_Reduction__c <= 0.5) {
                        hs.Score__c = 10;
                    }
                    else if (hs.eHba1c_Reduction__c >= 0 && hs.eHba1c_Reduction__c <= 0.29) {
                        hs.Score__c = 5;
                    }
                    else if (hs.eHba1c_Reduction__c < 0) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'ROI Status' {
                    if (hs.ROI_Status_DM__c == 'Client <1.25 years on program or partnership doesn\'t allow ROI' ||
                        hs.ROI_Status_DM__c == 'Client >1.25 with 100 activated, claims based completed') {
                            hs.Score__c = 5;
                       }
                    else if (hs.ROI_Status_DM__c == 'Client >1.25 with 100 activated, fitch mode or BOB') {
                        hs.Score__c = 3;
                    }
                    else if (hs.ROI_Status_DM__c == 'Client >1.25 years with no ROI completed') {
                        hs.Score__c = -10;
                    }
                    else if (hs.ROI_Status_DM__c == 'Client ROI completed but results were negative') {
                        hs.Score__c = -20;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
            }
        }
    }
    
    public static void updateHTNScores(List<Health_Score__c> listOfHealthScores){
        for (Health_Score__c hs : listOfHealthScores) {
            String healthSegment = hs.Health_Segment__c;
            switch on healthSegment {
                when 'Member Satisfaction' {
                    if (hs.Member_Satisfaction__c > 60) {
                        hs.Score__c = 10;
                    }
                    else if (hs.Member_Satisfaction__c >= 40 && hs.Member_Satisfaction__c <= 60) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Member_Satisfaction__c < 40) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Enrollment' {
                    if(String.isNotBlank(hs.Actual_Result__c)){
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue >= 20) {
                            hs.Score__c = 20;
                        }
                        else if (actualResultValue >= 10 && actualResultValue <= 20) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue < 10) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Activation' {
                    if (String.isNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 70) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 60 && actualResultValue <= 70) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 60) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Active 30' {
                    if (String.isNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 70) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 60 && actualResultValue <= 70) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 60) {
                            hs.Score__c = -10;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Marketing Type (Outreach Stratification)' {
                    if (hs.Actual_Result__c == 'A') {
                        hs.Score__c = 5;
                    }
                    else if (hs.Actual_Result__c == 'B') {
                        hs.Score__c = 2;
                    }
                    else if (hs.Actual_Result__c == 'C') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                    if (hs.Participating_in_any_optimized_campaigns__c) {
                        hs.Score__c += 5;
                    }
                }
                when 'Email Coverage' {
                    if (hs.Client_does_not_allow_email_marketing__c == true) {
                        hs.Score__c = 0;
                    }
                    else if (String.IsNotBlank(hs.Actual_Result__c)) {
                        Decimal actualResultValue = Decimal.valueOf(hs.Actual_Result__c);
                        if (actualResultValue > 40) {
                            hs.Score__c = 10;
                        }
                        else if (actualResultValue >= 20 && actualResultValue <= 40) {
                            hs.Score__c = 5;
                        }
                        else if (actualResultValue < 20 && actualResultValue > 0) {
                            hs.Score__c = 2;
                        }
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Population Refresh' {
                    if (hs.Population_Refresh__c == 'within 3 months') {
                        hs.Score__c = 10;
                    }
                    else if (hs.Population_Refresh__c == '> 3 months ago') {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Systolic BP Reduction' {
                    if (hs.Systolic_BP_Reduction__c >= 8) {
                        hs.Score__c = 15;
                    }
                    else if (hs.Systolic_BP_Reduction__c >= 3 && hs.Systolic_BP_Reduction__c <= 7) {
                        hs.Score__c = 10;
                    }
                    else if (hs.Systolic_BP_Reduction__c >= 1 && hs.Systolic_BP_Reduction__c <= 2) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Systolic_BP_Reduction__c <= 0) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'Diastolic BP Reduction' {
                    if (hs.Diastolic_BP_Reduction__c >= 5) {
                        hs.Score__c = 15;
                    }
                    else if (hs.Diastolic_BP_Reduction__c >= 2 && hs.Diastolic_BP_Reduction__c <= 4) {
                        hs.Score__c = 10;
                    }
                    else if (hs.Diastolic_BP_Reduction__c >= 1 && hs.Diastolic_BP_Reduction__c < 2) {
                        hs.Score__c = 5;
                    }
                    else if (hs.Diastolic_BP_Reduction__c <= 0) {
                        hs.Score__c = 0;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
                when 'ROI Status' {
                    if (hs.ROI_Status_HTN__c == 'Client <1.25 years on program or partnership doesn\'t allow ROI' ||
                        hs.ROI_Status_HTN__c == 'Client >1.25 with 100 activated, claims based completed') {
                            hs.Score__c = 5;
                       }
                    else if (hs.ROI_Status_HTN__c == 'Client >1.25 years with no ROI completed') {
                        hs.Score__c = -10;
                    }
                    else if (hs.ROI_Status_HTN__c == 'Client > 1.25 years with ROI completed but negative results') {
                        hs.Score__c = -20;
                    }
                    else {
                        hs.Score__c = 0;
                    }
                }
            }
        }
    }
}