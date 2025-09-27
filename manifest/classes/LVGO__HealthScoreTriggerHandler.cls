public class HealthScoreTriggerHandler {
    public static void handleHealthScoreBeforeInsert(List<Health_Score__c> hsList) {
        HealthScoreService.calculateScores(hsList);
    }
    public static void handleHealthScoreBeforeUpdate(List<Health_Score__c> hsList, Map<Id, Health_Score__c>oldHSMap) {
        HealthScoreService.calculateScores(hsList);
    }
}