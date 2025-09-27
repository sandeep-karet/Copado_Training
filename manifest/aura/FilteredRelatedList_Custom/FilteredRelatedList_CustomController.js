({
	//Called upon initialization of component
	init : function(component, event, helper) {
		helper.buildColumns(component, event, helper);
		helper.buildFilters(component, event, helper);
		helper.initMetadata(component, event, helper);
	},

	//Called upon clicking of "New" button
	createRecord : function(component, event, helper) {
		helper.createNewRecord(component, event, helper);
	},

	//Called upon sort action of a specific column
	updateColumnSorting : function(component, event, helper) {
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
		component.set('v.sortedBy', fieldName);
		component.set('v.sortedDirection', sortDirection);
        helper.sortData(component, fieldName, sortDirection);
	},

	//Called when the "open" button of a specific row is clicked;
	//Opens the record in a new tab 
	handleRowAction : function(component, event, helper) {
		helper.goToRecord(component, event, helper);
	}
})