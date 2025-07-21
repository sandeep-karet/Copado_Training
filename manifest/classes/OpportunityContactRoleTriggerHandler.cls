/*
ClassName: OpportunityContactRoleTriggerHandler
* CreatedBy: Vineel Muppa
* CalledFrom: OpportunityContactRoleTrigger
* Description: This class is Responsible for handling all Trigger Events on Opportunity Contact Role
*
* NOTE: No Code Should be Written Here, If any thing should be written please choose your trigger Event and then Create a class for your logic
*   and Please Call that class in corresponding event i.,e onBeforInsert or OnAfterDelete etc
*   
* ---------------------------------------
* Revision History
* 
*/
public class OpportunityContactRoleTriggerHandler {
  public void OnBeforeInsert(OpportunityContactRole[] newOCRs) {
  }
  public void OnAfterInsert(
    OpportunityContactRole[] newOCRs,
    Map<Id, OpportunityContactRole> newMap
  ) {
    OpportunityContactRoleHelper.createAccouintRelationship(newOCRs);
  }
  public void OnBeforeUpdate(
    OpportunityContactRole[] updatedOCRs,
    Map<ID, OpportunityContactRole> newOCRMap,
    OpportunityContactRole[] oldOCRs,
    Map<ID, OpportunityContactRole> oldOCRMap
  ) {
  }
  public void OnAfterUpdate(
    OpportunityContactRole[] updatedOCRs,
    Map<ID, OpportunityContactRole> newOCRMap,
    OpportunityContactRole[] oldOCRs,
    Map<ID, OpportunityContactRole> oldOCRMap
  ) {
  }
  public void OnBeforeDelete(
    OpportunityContactRole[] OCRToDelete,
    Map<ID, OpportunityContactRole> OCRDelMap
  ) {
  }
  public void OnAfterDelete(
    OpportunityContactRole[] OCRToDelete,
    Map<ID, OpportunityContactRole> OCRDelMap
  ) {
  }
}