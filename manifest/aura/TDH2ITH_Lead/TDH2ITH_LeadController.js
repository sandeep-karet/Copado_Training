({
    doInit : function(component, event, helper) {
        component.set("v.errorMsg", "UNABLE TO TRANSFER LEAD : \n LastName, FirstName, Company, Phone, Email are required fields \n Status must be AQL or MQL \n");
        var action = component.get("c.getLead");
        action.setParams({
            recordId : component.get("v.recordId")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state==="SUCCESS") {
                var details = response.getReturnValue();
                if (details) {
                    component.set("v.lead", details);
                    if (details.Allow_ITH_Transfer__c) {
                    	component.set("v.isAllow", true);
                    } else {
                        component.set("v.showError", true);
                    }
                    component.set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    send : function (component) {
        component.set("v.isAllow", false);
        var action = component.get("c.sendRecord");
        action.setParams({
            ld : component.get("v.lead")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state==="SUCCESS") {
                var details = response.getReturnValue();
                if (details) {
                    if (details.isInsert == 'true') {    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "title": "Success!",
                            "message": details.result
                        });
                        toastEvent.fire();
                    } else {
                        if (details.result.includes("internal error")) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "title": 'Please Try to Submit Lead Record Again',
                                "message": details.result,
                                "mode": "sticky"
                            });
                            toastEvent.fire();
                        } else if (details.result == "DUPLICATE_VALUE") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "title": 'Duplicate record in ITH',
                                "message": 'This record already exists in ITH',
                                "mode": "sticky"
                            });
                            toastEvent.fire();
                        } else { 
                            var errorMsg;
                            if (details.result.includes("FIELD_INTEGRITY_EXCEPTION")) {
                                errorMsg = details.result.substring(details.result.indexOf("FIELD_INTEGRITY_EXCEPTION") + 26);
                            } else {
                                errorMsg = details.result;
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "title": "Something Went Wrong...",
                                "message": 'Please show the error message to your system admin: ' + errorMsg,
                                "mode": "sticky"
                            });
                            toastEvent.fire();
                        }
                    }
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
})