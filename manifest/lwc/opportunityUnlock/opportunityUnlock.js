import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord, updateRecord} from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import PRICING_AND_PRODUCT_LOCK_FIELD from "@salesforce/schema/Opportunity.Pricing_and_Product_Lock__c";

const FIELDS = [ID_FIELD, PRICING_AND_PRODUCT_LOCK_FIELD];

export default class OpportunityUnlock extends LightningElement {

    @api recordId;
    opportunity;
    pricingAndProductLock;
    isLoading = false;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
        let message = "Unknown error";
        if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Error loading opportunity",
            message,
            variant: "error",
            }),
        );
        } else if (data) {
        this.opportunity = data;
        this.pricingAndProductLock = this.opportunity.fields.Pricing_and_Product_Lock__c.value;
        }
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleYes(){
        this.isLoading = !this.isLoading;
        const updateFields = {};
        
        updateFields[ID_FIELD.fieldApiName] = this.recordId;
        updateFields[PRICING_AND_PRODUCT_LOCK_FIELD.fieldApiName] = false;

        const recordInput = { 
            fields : updateFields 
        };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Success",
                    message: "Opportunity updated",
                    variant: "success",
                    }),
                );
                this.isLoading = !this.isLoading;
                this.dispatchEvent(new CloseActionScreenEvent());
                refreshApex(this.opportunity);
            })
            .catch((error) => {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Error updating record",
                    message: error.body.message,
                    variant: "error",
                  }),
                );
                this.isLoading = !this.isLoading;
                this.dispatchEvent(new CloseActionScreenEvent());
              });
    }
}