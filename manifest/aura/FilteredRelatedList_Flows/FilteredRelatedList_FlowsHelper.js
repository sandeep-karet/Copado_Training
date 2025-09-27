({
    //Builds an array of the columns set by the Admin
    buildColumns : function(component, event, helper) {
        let columns = component.get('v.columns');
        let currentColumn;
        for (let i = 1; i <= 6; i++) {
            currentColumn = 'v.column';
            currentColumn += i.toString();
            if (component.get(currentColumn)) {
                columns.push(component.get(currentColumn));
            }
        }
        component.set('v.columns', columns);
    },

    //Builds an array of the filters set by the Admin
    buildFilters : function(component, event, helper) {
        let currentFilter;
        let filters = component.get('v.filters');
        for (let i = 1; i <= 3; i++) {
            currentFilter = 'v.filter';
            currentFilter += i.toString();
            if (component.get(currentFilter)) {
                filters.push(component.get(currentFilter));
            }
        }
        component.set('v.filters', filters);
    },

    //Gets initial metadata/data required to build later queries;
    //this includes column metadata such as labels and field types for
    // each specified column
    initMetadata : function(component, event, helper) {
        let getColumnMetadataPromise = helper.getColumnMetadata(component, event, helper);
        getColumnMetadataPromise.then(
            $A.getCallback(function(result) {
                //result from Apex will be a map of the label for each column
                //to its corresponding data type
                component.set('v.columnLabels', Object.keys(result));
                component.set('v.columnFieldTypes', Object.values(result));
                //metadata can now be used to set each column
                //in the related list
                helper.setRelatedListColumns(component, event, helper);
                //get the Id for the specific parent sObject record
                return helper.getParentSObjectId(component, event, helper);
            })
        )
        .then(
            $A.getCallback(function(result) {
                //now set that Id, will be used in building the query
                component.set('v.parentSObjectId', result[component.get('v.lookupToParentSObject')]);
                //build the query based on the columns and filters
                helper.buildQueryString(component, event, helper);
                //now get the related data using the query you've built
                return helper.getRelatedData(component, event, helper);
            })
        )
        .then(
            $A.getCallback(function(result) {
                //set datatable data with results from Apex
                component.set('v.data', result);
                component.set('v.tableSize', result.length);
            })
        )
        //any errors will be caught here
        .catch(
            function(error) {
                helper.showToast(error, 'An unexpected error occurred.', 'error');
            }
        )
    },

    //Get the required Metadata for each Column; specifically, this will
    //be a map of the label to its data type for each column
    getColumnMetadata : function(component, event, helper) {
        let action = component.get('c.getMetadataForColumns');
        action.setParams({
            objectName: component.get('v.sObject'),
            columns: component.get('v.columns')
        });
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                let columnMetadataMap = response.getReturnValue();
                if (state === "SUCCESS") {
                    resolve(columnMetadataMap);
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

    //Sets the columns for the Lightning datatable component
    setRelatedListColumns : function(component, event, helper) {
        let columns = component.get('v.columns');
        let columnLabels = component.get('v.columnLabels');
        let columnFieldTypes = component.get('v.columnFieldTypes');
        let typeMappings = component.get('v.fieldTypeToDatatableType');
        let cols = [];
        let title = 'View record';
        //First column in the datatable will be the buttons that, when clicked,
        //will open the record of the corresponding row in a new tab
        cols.push({
            type: 'button-icon',
            initialWidth: 50,
            typeAttributes: {
                title: title,
                label: title,
                iconName: 'utility:new_window',
                variant: 'container'
            }
        });
        //Rest of the columns configured by the Admin are set here
        for (let i = 0; i < columns.length; i++) {
            cols.push({
                label:   columnLabels[i],
                fieldName:   columns[i],
                type:   typeMappings[columnFieldTypes[i]],
                sortable:   true
            });
        }
        component.set('v.columns', cols);
    },
    
    
    //Get the record Id of the parent record
    getParentSObjectId : function(component, event, helper) {
        let queryString = 'SELECT Id, ';
        queryString += component.get('v.lookupToParentSObject');
        queryString += ' FROM ';
        queryString += component.get('v.recordSObject');
        queryString += ' WHERE Id = ';
        queryString += "'";
        queryString += component.get('v.recordId');
        queryString += "'";

        let action = component.get('c.getParentSObject');
        action.setParams({
        	queryString: queryString
        });

        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                let parentSObjectId = response.getReturnValue();
                if (state === "SUCCESS") {
                    resolve(parentSObjectId);
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

    //Get the related records to be displayed in the related list;
    //Calls Apex with the query string built based on the desired
    //columns and filters; the data is then returned from Apex
	getRelatedData : function(component, event, helper) {
        let action = component.get('c.getRelated');
        action.setParams({
        	queryString: component.get('v.queryString')
        });

        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                let relatedData = response.getReturnValue();
                if (state === "SUCCESS") {
                    resolve(relatedData);
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
    
    //Dynamically builds the query based on the columns and filters
    //specified by the Admin
    buildQueryString : function(component, event, helper) {
        let queryString = 'SELECT Id';
        queryString += ', ';
        queryString += component.get('v.childRelationshipName');
        let columns = component.get('v.columns');
        //Add each column to the query
        for (let i = 1; i < columns.length; i++) {
            queryString += ', ';
            queryString += columns[i].fieldName;
        }
        queryString += ' FROM ';
        queryString += component.get('v.sObject');
        queryString += ' WHERE ';
        queryString += component.get('v.childRelationshipName');
        queryString += " = '";
        queryString += component.get('v.parentSObjectId');
        queryString += "'";
        

        let queryFilters = '';
        let filters = component.get('v.filters');
        //If there are filters, for each filter, append to query
        if (filters.length > 0) {
            for (let f = 0; f < filters.length; f++) {
                queryFilters += ' AND ';

                let filterString = filters[f];

                let field = filterString.split(' ')[0];
                let type = null;
                for (let c = 1; c < columns.length; c++) {
                    if (field === columns[c].fieldName) {
                        type = columns[c].type;
                    }
                }
                let operator = filterString.split(' ')[1];
                let like, includes = false;
                if (operator === 'LIKE') {
                    like = true;
                }
                if (operator === 'INCLUDES') {
                    includes = true;
                    queryFilters += field;
                    queryFilters += ' ';
                    queryFilters += operator;
                    queryFilters += ' (';
                }
                let value = filterString.substring((filterString.indexOf(operator)+(operator.length+1)), filterString.length);
                if (value.includes(',')) {
                    let subvalues = value.split(',');
                    for (let j = 0; j < subvalues.length; j++) {
                        if (j == 0) {
                            if (!includes) {
                                queryFilters += '(';
                            }
                        }
                        if (!includes) {
                            queryFilters += field;
                            queryFilters += ' ';
                            queryFilters += operator;
                        }
                        //Certain datatypes necessitate NO quotes surrounding the value
                        if (type == 'boolean' || type == 'date' || type == 'datetime' || type == 'number') {
                            queryFilters += " ";
                            queryFilters += subvalues[j].trim();
                            if (like) {
                                queryFilters += '%';
                            }
                            queryFilters += " ";
                        }
                        else {
                            queryFilters += " '";
                            queryFilters += subvalues[j].trim();
                            if (like) {
                                queryFilters += '%';
                            }
                            queryFilters += "'";
                        }
                        if (j != subvalues.length-1) {
                            if (!includes) {
                                queryFilters += ' OR ';
                            }
                            else {
                                queryFilters += ',';
                            }
                        }
                    }
                    queryFilters += ')';
                }
                else {
                    if (!includes) {
                        queryFilters += field;
                        queryFilters += ' ';
                        queryFilters += operator;
                    }
                    if (like) {
                        queryFilters += " '";
                        queryFilters += value;
                        queryFilters += "%'";
                    }
                    else {
                        //Certain datatypes necessitate NO quotes surrounding the value
                        if (type == 'boolean' || type == 'date' || type == 'datetime' || type == 'number') {
                            queryFilters += " ";
                            queryFilters += value;
                            queryFilters += " ";
                        }
                        else {
                            queryFilters += " '";
                            queryFilters += value;
                            queryFilters += "'";
                        }
                    }
                    if (includes) {
                        queryFilters += ')';
                    }
                } 
            }
        }
        if (queryFilters) {
            queryString += queryFilters;
        }
        //query string is finalized
        component.set('v.queryString', queryString);
    },

    //Uses the e.force:createRecord event ot create a new record
    createNewRecord : function(component, event, helper) {
        let createRecordEvent = $A.get("e.force:createRecord");
        let childRelationshipName = component.get('v.childRelationshipName');
        let recordId = component.get('v.parentSObjectId');

        createRecordEvent.setParams({
            "entityApiName": component.get('v.sObject'),
            "defaultFieldValues": {
                [childRelationshipName] : recordId
            },
        });
        createRecordEvent.fire();
    },

    //Opens the record corresponding to the row in a new tab
    goToRecord : function(component, event, helper) {
        let row = event.getParam('row');
        window.open('/' + row.Id, '_blank');
    },

    //Sorts the data of a column
    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.data");
        let reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },

    sortBy: function (field, reverse, primer) {
        let key = primer ?
            function (x) {
                return primer(x[field])
            } :
            function (x) {
                return x[field]
            };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    //Displays a toast message to the user
    showToast: function (message, title, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "dismissible"
        });
        toastEvent.fire();
    },
})