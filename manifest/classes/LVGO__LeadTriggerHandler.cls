public class LeadTriggerHandler {
	public static void leadStatusChange(List<Lead__c> leads, Map<Id,Lead__c> oldMap) {
        for (Lead__c l : leads){
            if(oldMap == null){
                l.Last_Status__c = l.Status__c;
                l.Last_Status_Date__c = Datetime.now();
            }else if(l.Status__c != oldMap.get(l.id).Status__c){
                l.Last_Status__c = oldMap.get(l.id).Status__c;
                l.Last_Status_Date__c = Datetime.now();
            } 
        }
    }
}