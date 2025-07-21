({
	save : function(component, event) {
		var action = component.get("c.startImplementation");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state == "SUCCESS") {
                resultsToast.setParams({
                    "type":"success",
                    "title": "Save Success!",
                    "message": "Opportunity has been Updated!"
                });
                resultsToast.fire();
            }else{
                var message = "Opportunity Update Failed!";
                var errors = action.getError();
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = errors[0].message;
                }
                resultsToast.setParams({
                    "type":"error",
                    "title": "Failed!",
                    "message": message
                });
                resultsToast.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
	},
    cancel:function(component){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})