({
    init : function(component, event, helper) {
        helper.init(component, event, helper);
    },
    handleRowAction : function(component, event, helper) {
		helper.goToRecord(component, event, helper);
	}
})