({
	doInit : function(component, event, helper) {
		var url = "/apex/ClientHandoffSummaryPdf?id=" + component.get("v.recordId");
        window.open(url);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();       
        $A.get('e.force:refreshView').fire();      
	}
})