({
    doInit : function(component, event, helper) {
        var action2 = component.get("c.checkAmendOpp");
        action2.setParams({
            recordId : component.get("v.recordId")
        });        
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state==="SUCCESS") {
                var details = response.getReturnValue();
                if (details) {
                    component.set("v.isLoading", false);
                    if (details.length > 0) {
                        component.set("v.disclaimer", true);
                        component.set("v.oppList", details);
                        
                    }
                    else {
                        console.log('no contract'); 
                        component.set("v.disclaimer", false);
                    }     
                }
            }
        });
        $A.enqueueAction(action2);
        var action = component.get("c.checkOppReady");
        action.setParams({
            recordId : component.get("v.recordId")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state==="SUCCESS") {
                var details = response.getReturnValue();
                if (details != null) {
                    component.set("v.oppRdy", false);
                    component.set("v.ErrorMsg", details);
                } else {
                    component.set("v.oppRdy", true);
                }
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    cancel : function(component){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    proceed : function (component) {
        component.set("v.disclaimer", false);
    }
    
})