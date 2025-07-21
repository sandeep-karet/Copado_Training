({
	doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.errorCheck");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });          
        action.setCallback(this, function(response) {
            var state = response.getState();                     
            if(state === "SUCCESS") {
                var details = response.getReturnValue();
                if(details == null){
                    var url = window.location.origin;  
                    var vfURL = url + "/apex/LaunchTinderbox?Id=" + recordId + "&bid=proposal";    
                    component.set("v.vfURL", vfURL);
                } else {
                    console.log(details);
                    component.set("v.error", details);
                    component.set("v.renderError", true);
                }
            }   
        });
        $A.enqueueAction(action);
    },
})