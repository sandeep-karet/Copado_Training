import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import EARLY_IMPLEMENTATION_FIELD from "@salesforce/schema/Opportunity.Early_Implementation__c";
import PRICING_AND_PRODUCT_LOCK_FIELD from "@salesforce/schema/Opportunity.Pricing_and_Product_Lock__c";
import PAYLOAD_ACTION_FIELD from "@salesforce/schema/Opportunity.Payload_Action__c";
import BROADCAST_MESSAGE_FIELD from "@salesforce/schema/Opportunity.L2O_Broadcast_Message__c";

const FIELDS = [ID_FIELD, EARLY_IMPLEMENTATION_FIELD, PRICING_AND_PRODUCT_LOCK_FIELD, PAYLOAD_ACTION_FIELD, BROADCAST_MESSAGE_FIELD];

export default class EarlyImplementation extends LightningElement {

    @api recordId;
    opportunity;
    earlyImplementation;
    pricingAndProductLock;
    payloadAction;
    broadcastMessage;
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
        this.earlyImplementation = this.opportunity.fields.Early_Implementation__c.value;
        this.pricingAndProductLock = this.opportunity.fields.Pricing_and_Product_Lock__c.value;
        this.payloadAction = this.opportunity.fields.Payload_Action__c.value;
        this.broadcastMessage = this.opportunity.fields.L2O_Broadcast_Message__c.value;
        }
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleYes(){
        this.isLoading = !this.isLoading;
        const updateFields = {};
        
        updateFields[ID_FIELD.fieldApiName] = this.recordId;
        updateFields[EARLY_IMPLEMENTATION_FIELD.fieldApiName] = true;
        updateFields[PRICING_AND_PRODUCT_LOCK_FIELD.fieldApiName] = true;
        updateFields[BROADCAST_MESSAGE_FIELD.fieldApiName] = false;
        if (this.payloadAction == undefined || this.payloadAction == null) {
            updateFields[PAYLOAD_ACTION_FIELD.fieldApiName] = 'create';
        }
        else {
            updateFields[PAYLOAD_ACTION_FIELD.fieldApiName] = 'update';
        }

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