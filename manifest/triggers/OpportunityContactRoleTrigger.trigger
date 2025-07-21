/*
* Trigger Name: OpportunityContactRoleTrigger
* CreatedBy: Vineel Muppa

* NOTE: This is the Master Trigger for Opportunity Team Member where it handles all the events here only. No Code Should be Included Here. All code is handled in 
      OpportunityContactRoleTriggerHandler Class.
*/
trigger OpportunityContactRoleTrigger on OpportunityContactRole(before insert,after insert,before update,after update,before delete, after delete) {

    OpportunityContactRoleTriggerHandler handler = new OpportunityContactRoleTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){        
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
}