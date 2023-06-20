public class ContactTriggerLVHelper {
   public static void createAccountContactRel(List<Contact__c> conlist,Map<id,Contact__c> newMap ,Map<id,Contact__c> oldMap){
        Set<id> accids = new set<id>();
        Set<id> conids = new set<id>();
        List<AccountContactRelation__c> accContRelLV = new List<AccountContactRelation__c>();
        for(Contact__c contObj: conlist){
            if(contObj.Account__c != null){
                if(trigger.isafter && (trigger.isinsert || (trigger.isupdate && contObj.Account__c != oldMap.get(contObj.Id).Account__c)))
            	accContRelLV.add(new AccountContactRelation__c(Account__c=contObj.Account__c, Contact__c=contObj.id,IsActive__c =true));
                if(trigger.isafter && trigger.isupdate && contObj.Account__c != newMap.get(contObj.Id).Account__c){
                    accids.add(contObj.Account__c);
                	conids.add(contObj.Id);
                }
            }
        }
        database.insert(accContRelLV,false);
        Map<String,AccountContactRelation__c> accContRelMap = new Map<String,AccountContactRelation__c>();
        for(AccountContactRelation__c contObj : [Select Id,IsActive__c,Account__c,Contact__c from AccountContactRelation__c where Contact__c in: conids and Account__c in :accids and IsActive__c =true]){
            accContRelMap.put(contObj.Account__c+'::'+contObj.Contact__c,contObj);
        }
        for(Contact__c contObj: conlist){
            if(contObj.Account__c != null && accContRelMap.containskey(contObj.Account__c+'::'+contObj.id)){
            	accContRelMap.get(contObj.Account__c+'::'+contObj.id).IsActive__c = false;
            }
        }
            system.debug('accContRelMap.values() '+accContRelMap.values());
        
        database.update(accContRelMap.values(),false);
    }

    public static void updateName(List<Contact__c> conlist,Map<id,Contact__c> newMap ,Map<id,Contact__c> oldMap){
        for(Contact__c contObj: conlist){
            String conName='';
            if(NULL != contObj.Salutation__c)
                conName = contObj.Salutation__c;
            if(NULL != contObj.Firstname__c)
                conName+= ' '+contObj.Firstname__c;
            if(NULL != contObj.Middlename__c)
                conName+= ' '+contObj.Middlename__c;
            if(NULL != contObj.Lastname__c)
                conName+= ' '+contObj.Lastname__c;
            contObj.Name = conName;
        }
    }
    
}