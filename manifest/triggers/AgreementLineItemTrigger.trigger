trigger AgreementLineItemTrigger on Apttus__AgreementLineItem__c (after insert, after delete) {
    
    ProductFamilyHandler.executeTrigger();   
}