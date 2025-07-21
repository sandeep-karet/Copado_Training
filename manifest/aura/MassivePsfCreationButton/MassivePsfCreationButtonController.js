({
    doInit: function(component, event, helper) {
        var action = component.get("c.doCount");
        action.setParams({
            recordId : component.get("v.recordId")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state==="SUCCESS") {
                var details = response.getReturnValue();
                component.set("v.count", details); 
            }
        });
        $A.enqueueAction(action);
    },
    
    send : function (component) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        var action = component.get("c.callMassiveCreation");
        action.setParams({
            recordId : component.get("v.recordId")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            dismissActionPanel.fire();
            
        });
        $A.enqueueAction(action); 
    }, 
    
    cancel : function(component){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})