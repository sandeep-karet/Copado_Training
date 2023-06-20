({
	doInit : function(component, event, helper) {
		var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "LVGO__Contact__c",
            "defaultFieldValues": {
                'Name' : 'XYZ'
            }
        });
        createRecordEvent.fire();
    }
})