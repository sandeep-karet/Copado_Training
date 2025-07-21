({
    getUserProfileName : function(component, event, helper) {
        var action = component.get("c.getUserProfile");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                if(result === "System Administrator"){
                    component.set("v.isSystemAdminProfile", true);
                }
                else{
                    helper.showError(component, event, helper);
                     window.history.back();
                }
                }
           });
        $A.enqueueAction(action);
      } ,
    
    showError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'You do not have permission to edit the record.',
            duration:' 1000',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },

})