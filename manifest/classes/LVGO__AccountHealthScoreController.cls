public with sharing class AccountHealthScoreController {

    public static Map<String,List<AccountHealthScoreHelper>> accMap = new Map<String,List<AccountHealthScoreHelper>>();
    public static Map<String, List<AccountHealthScoreHelper>> dmMap = new Map<String,List<AccountHealthScoreHelper>>();
    public static Map<String, List<AccountHealthScoreHelper>> htnMap = new Map<String,List<AccountHealthScoreHelper>>();

    @AuraEnabled(cacheable=true)
    public static accountHealthScoreWrapper getHealthScores(Id accountId) {

        List<Health_Score__c> healthScoresList = [SELECT Id, Account__c, Program__c, Actual_Result__c, Score__c, CSM_Action_Steps__c, Element_Section__c, Health_Segment__c, 
                                                    Recommended_Action_Steps__c, RecordType.Name, Display_Fields__c FROM Health_Score__c WHERE Account__c = :accountId Order By Sort_Order__c ASC];

        for(Health_Score__c hs: healthScoresList) {
            if(hs.RecordType.Name == 'Account Health Score') {
                generateMap(hs,accMap);
            }
            else if (hs.RecordType.Name == 'Program Health Score') {
                if(hs.Program__c == 'Diabetes') {
                    generateMap(hs, dmMap);
                }
                else if(hs.Program__c == 'Hypertension') {
                    generateMap(hs, htnMap);
                }
            }
        }
        AccountHealthScoreWrapper accountHealthScoreWrapper = new AccountHealthScoreWrapper();
        accountHealthScoreWrapper.accountScoreMap = accMap;
        accountHealthScoreWrapper.dmScoreMap = dmMap;
        accountHealthScoreWrapper.htnScoreMap = htnMap;

        return accountHealthScoreWrapper;
    }

    public static void generateMap(Health_Score__c hsRecord, Map<String, List<AccountHealthScoreHelper>> healthMap) {
        if(healthMap.containsKey(hsRecord.Element_Section__c)) {
            List<AccountHealthScoreHelper> hsList = healthMap.get(hsRecord.Element_Section__c);
            AccountHealthScoreHelper hsHelper;
            hsHelper = new AccountHealthScoreHelper(hsRecord);
            hsList.add(hsHelper);
            healthMap.put(hsRecord.Element_Section__c, hsList);
        }
        else {
            AccountHealthScoreHelper hsHelper1;
            hsHelper1 = new AccountHealthScoreHelper(hsRecord);
            healthMap.put(hsRecord.Element_Section__c, new List<AccountHealthScoreHelper> {hsHelper1});
        }
    } 

    public class accountHealthScoreWrapper{
        @AuraEnabled
        public Map<String,List<AccountHealthScoreHelper>> accountScoreMap {get; set;}
        @AuraEnabled
        public Map<String,List<AccountHealthScoreHelper>> dmScoreMap {get; set;}
        @AuraEnabled
        public Map<String,List<AccountHealthScoreHelper>> htnScoreMap {get; set;}
    }

    public class AccountHealthScoreHelper {
        @AuraEnabled public Id hsId {get; set;}
        @AuraEnabled public Decimal score {get; set;}
        @AuraEnabled public String hsSegement {get; set;}
        @AuraEnabled public List<String> displayFields {get; set;} 

        public AccountHealthScoreHelper(Health_Score__c hs){
            this.hsId = hs.Id;
            this.score = hs.Score__c;
            this.hsSegement = hs.Health_Segment__c;
            if(hs.Display_Fields__c != null) {
                this.displayFields = hs.Display_Fields__c.split(',');
            }
        }
    }
}