({
    init : function(component, event, helper) {
        component.set('v.columns', [
                {
                    type: 'button-icon',
                    initialWidth: 50,
                    typeAttributes: {
                        title: 'test',
                        label: 'test',
                        iconName: 'utility:new_window',
                        variant: 'container'
                    }
                },
                {   
                    label: 'Contact Name', 
                    fieldName: 'ContactName', 
                    type: 'text'
                },
                {
                    label: 'Roles',
                    fieldName: 'Role',
                    type: 'text'
                }
            ]
        );

        let getOpportunityContactRolesPromise = helper.getOpportunityContactRoles(component, event, helper);
        getOpportunityContactRolesPromise.then(
            $A.getCallback(function(result) {
                helper.transformResult(component, result);
            })
        )
    },
    
    getOpportunityContactRoles : function(component, event, helper) {
        let action = component.get('c.getOpportunityContactRoles');
        action.setParams({
            oppId: component.get('v.opportunityId')
        });
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                let opportunityContactRoles = response.getReturnValue();
                if (state === "SUCCESS") {
                    resolve(opportunityContactRoles);
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

    transformResult : function(component, result) {
        for (let i in result) {
            result[i]['ContactName'] = result[i]['Contact']['Name'];
        }
        //Contact Name(s) extracted from nested JSON, set data attribute.
        component.set('v.data', result);
        component.set('v.tableSize', result.length);
    },

    goToRecord : function(component, event, helper) {
        let row = event.getParam('row');
        window.open('/' + row.Id, '_blank');
    },
})