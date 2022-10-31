({
    init : function(component, event, helper) {
        helper.init(component, event, helper);
    },

    handleSelection : function(component, event, helper) {
        helper.updateSelectedRows(component, event, helper);
    }
})