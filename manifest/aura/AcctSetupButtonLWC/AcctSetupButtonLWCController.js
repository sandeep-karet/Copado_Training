({
    doInit: function(component, event, helper) {
 
    },

    handleClick: function(component, event, helper) {
       	var recordId = component.get("v.recordId");        
        var evt = $A.get("e.force:navigateToComponent");       
        evt.setParams({
            componentDef  : "c:zHomePage" ,
            isredirect : true,
            componentAttributes : {
                recordId : component.get("v.recordId"),                
            }        
        });      
        evt.fire();
    },
    
     
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire()
    }
})