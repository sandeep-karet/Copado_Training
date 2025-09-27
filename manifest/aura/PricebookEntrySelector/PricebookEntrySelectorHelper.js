({
    init : function(component, event, helper) {
        component.set('v.columns', [
                {   
                    label: 'Name', 
                    fieldName: 'Name', 
                    type: 'text'
                }
            ]
        );

        let getPricebookEntriesPromise = helper.getPricebookEntries(component, event, helper);
        getPricebookEntriesPromise.then(
            $A.getCallback(function(result) {
                helper.parseOutExisting(component, result);
            })
        )
    },

    parseOutExisting : function(component, result) {
        let allPricebookEntries = result;
        let existingIds = component.get('v.ExistingPricebookEntryIds');
        let newPricebookEntries = [];
        for (let i = 0; i < allPricebookEntries.length; i++) {
            let addId = true;
            for (let j = 0; j < existingIds.length; j++) {
                if (allPricebookEntries[i].Id === existingIds[j]) {
                    addId = false;
                    break;
                }
            }   
            if (addId) {
                newPricebookEntries.push(allPricebookEntries[i]);
            }
        }
        component.set('v.data', newPricebookEntries);
    },

    getPricebookEntries : function(component, event, helper) {
        let action = component.get('c.getPricebookEntriesForPricebook');
        action.setParams({
            pricebookId: component.get('v.PricebookId')
        });
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                let pricebookEntries = response.getReturnValue();
                if (state === "SUCCESS") {
                    resolve(pricebookEntries);
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject("Error message: " + errors[0].message);
                        }
                    } else {
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    updateSelectedRows : function(component, event, helper) {
        let selectedRows = event.getParam('selectedRows');
        let count = selectedRows.length;
        let pricebookEntries = [];
        for (let i = 0; i < count; i++) {
            pricebookEntries.push(selectedRows[i]);
        }
        component.set('v.selectedRowsCount', count);
        component.set('v.PricebookEntryCollection', pricebookEntries);
    }
})