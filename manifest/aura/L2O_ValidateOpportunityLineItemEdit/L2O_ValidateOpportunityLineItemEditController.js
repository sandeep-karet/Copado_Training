({
    validateUser : function(component, event, helper) {
         
         helper.getUserProfileName(component, event, helper);
        
        },
    handleSuccess : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Opportunity Product was saved.",
            });
    },
})