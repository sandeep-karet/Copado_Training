/* eslint-disable no-console */
/* eslint-disable no-empty */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import validateAddress from "@salesforce/apex/MDPERSONATOR.MD_PersonatorWSExt.doPersonator";

import MAILING_RESULT_CODE_FIELD from '@salesforce/schema/Contact.Mailing_Address_Personator_Result_Codes__c';
import MAILING_RESULTCODE_STATUS_FIELD from '@salesforce/schema/Contact.Mailing_Address_Status_Message__c';

const fields = [MAILING_RESULT_CODE_FIELD, MAILING_RESULTCODE_STATUS_FIELD];

export default class ZContactpage extends NavigationMixin(LightningElement) {

  @api recordId;
  @api contactId;
  @api conError;
  @api acctRelErrorList;
  @track financialType = false;
  @track disableButton = true;
  @track spinner = false;

  
  @wire(getRecord, { recordId: '$contactId', fields })
    contact;

  get mailingResultCode() {
      return getFieldValue(this.contact.data, MAILING_RESULT_CODE_FIELD);
  }
  get mailingResultCodeStatus() {
    return getFieldValue(this.contact.data, MAILING_RESULTCODE_STATUS_FIELD);
  }
  showCustomToast(title, msg, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }
  

  showErrorToast() {
    const toastEvent = new ShowToastEvent({
      title: "Update Error",
      message: "Please fill out all fields",
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }

  showConToast() {
    const toastEvent = new ShowToastEvent({
      title: "Success",
      message: "Contact info has been updated.",
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }

  cancelDialog() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Account",
        actionName: "view"
      }
    });
  }

  saveCont(event) {
    this.spinner = true;
    let errorCount = false;
    try {
      if ((this.template.querySelector('[data-id="emailCon"]').value === null) || (this.template.querySelector('[data-id="emailCon"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="streetCon"]').value === null) || (this.template.querySelector('[data-id="streetCon"]').value === "")){
        errorCount = true;      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="cityCon"]').value === null) || (this.template.querySelector('[data-id="cityCon"]').value === "")){
        errorCount = true;      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="stateCon"]').value === null) || (this.template.querySelector('[data-id="stateCon"]').value === "")){
        errorCount = true;      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="zipCon"]').value === null) || (this.template.querySelector('[data-id="zipCon"]').value === "")){
        errorCount = true;      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="countryCon"]').value === null) || (this.template.querySelector('[data-id="countryCon"]').value === "")){
        errorCount = true;      }
    } catch (error) {}

    if (!errorCount) {
      event.preventDefault();
      const fields = event.detail.fields;
      this.template.querySelector('[data-id="editContactForm"]').submit(fields);
      this.spinner = false;
    } else {
      this.showErrorToast();
      this.spinner = false;
    }
  }

  contSuccess() {
   
    this.spinner = true;
    validateAddress({recordId: this.contactId})
        .then(result => {
          refreshApex(this.contact).then(()=> {
            let resCodeWithoutException = this.mailingResultCode?.replace(/AE08|AE09|AE10|AE11/g, '');
            if(resCodeWithoutException?.includes('AE')){
              this.showCustomToast('Personator Validation','Address is not valid! \n'+this.mailingResultCodeStatus,'error');
            }else if(this.mailingResultCode?.includes('AS')){
              this.disableButton = false;
              this.showCustomToast('Personator Validation','Personator Address Validation done!','success');
            } else{
              this.showCustomToast('Personator Validation','Address is not valid! \n'+this.mailingResultCodeStatus,'error');            
            }       
            this.spinner = false;
          });
        })
        .catch(error => {
          this.showCustomToast('Personator Error','Personator Address Validation Failed! Please Try again.','error'); 
          this.spinner = false;
        });

  }

  
  goNext() {
    if (this.acctRelErrorList.length > 0) {
        const pasEvt = new CustomEvent("pass", { detail: "acctRel"  });
        this.dispatchEvent(pasEvt);
    } else {
        const pasEvt = new CustomEvent("pass", { detail: "validate" });
        this.dispatchEvent(pasEvt);
    }
  }
}