import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord,updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import getContracts from '@salesforce/apex/L2O_GenerateOrder_Controller.getContracts';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import ORDERED_FIELD from '@salesforce/schema/Opportunity.SBQQ__Ordered__c';
import AMENDED_CONTRACT from '@salesforce/schema/Opportunity.SBQQ__AmendedContract__c';
import RENEWAL_CONTRACT from '@salesforce/schema/Opportunity.SBQQ__RenewedContract__c';


import { refreshApex } from '@salesforce/apex';
import successMsg from '@salesforce/label/c.L2O_GenerateOrderSuccess';
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { getRelatedListCount } from 'lightning/uiRelatedListApi';

const fields = [ORDERED_FIELD,AMENDED_CONTRACT,RENEWAL_CONTRACT];


export default class GenerateOrder extends LightningElement {

    @api recordId;
    @track error;
    @track result;
    @track contractRecords;

    @wire(getRecord, { recordId: '$recordId', fields })
    opportunity; 

    @wire(getContracts,{oppId:'$recordId'})
    wiredContracts({data,error}){
        if(data){
            this.contractRecords = JSON.stringify(data);
            console.log('contractRecords - '+JSON.stringify(data));
        }
        if(error){
            this.error = error;
        }
    }
    
    // Called on click of Generate Order Button from Opportunity page, it checks the Ordered checkbox on opportunity
    @api invoke() {

        var orderedFlag = getFieldValue(this.opportunity.data, ORDERED_FIELD);
        //console.log('recordcount - '+recordcount);

        if(this.contractRecords > 0 && orderedFlag == false){

            // Create the recordInput object
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[ORDERED_FIELD.fieldApiName] = true;

            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    this.showToastMessage('Success!',successMsg,'success');

                    // Refresh Opp Detail Page with related list views
                    eval("$A.get('e.force:refreshView').fire();");
                })
                .catch(error => {
                    
                    let errors = this.reduceErrors(error); // passing error here
                    let errorMsg = errors.join('; ');
                    
                    this.showToastMessage('ERROR!', errorMsg, 'error'); 
                });
        }
        else{
            this.showToastMessage('ERROR!', 'Please verify the Opportunity has a Contract tied to it before generating the order. ', 'error');
        }
        
    };
        
    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

    reduceErrors(errors) {

        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }
 }