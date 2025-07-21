import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRenewalQuoted from "@salesforce/apex/L2O_RenewalQuote.updateRenewalQuoted";
import successMsg from '@salesforce/label/c.L2O_Manual_Renewal_Success';
import errorMsg from '@salesforce/label/c.L2O_Manual_Renewal_Error';


export default class RenewalQuote extends LightningElement {

    @api recordId;
    @track error;
    @track result;

    // This is called on click of Renewal Button from Renewal Opportunity page , it creates a renewal quote for the renewal opportunity
    @api invoke() {
        updateRenewalQuoted({ recordId: this.recordId })
            .then((result) => {
                if (result == 'Success') {
                   this.showToastMessage('Success!',successMsg,'success');
                } else if (result == 'Error') {
                    this.showToastMessage('ERROR', errorMsg, 'error');
                }
            })
            .catch((error) => {
                this.showToastMessage('ERROR', errorMsg, 'error');
                
            });
        }
        showToastMessage(title, message, variant) {
            this.dispatchEvent(
                new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
            );
         }
 }