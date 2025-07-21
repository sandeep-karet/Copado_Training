/* eslint-disable no-console */
/* eslint-disable no-empty */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { loadStyle } from 'lightning/platformResourceLoader';
import customCSS from '@salesforce/resourceUrl/toastCSS';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import validateAddress from "@salesforce/apex/MDPERSONATOR.MD_PersonatorWSExt.doPersonator";

import RESULT_CODE_FIELD from '@salesforce/schema/Account.Billing_Address_Personator_Result_Codes__c';
import RESULT_CODE_STATUS_FIELD from '@salesforce/schema/Account.Billing_Address_Status_Message__c';
//(SCDEV-4587) starts
import INVOICE_FIELD from '@salesforce/schema/Account.Receives_Invoice__c';
//(SCDEV-4587) ends
const fields = [RESULT_CODE_FIELD,INVOICE_FIELD,RESULT_CODE_STATUS_FIELD];


export default class ZAccountPage extends NavigationMixin(LightningElement) {

  @api acctError
  @api recordId;
  @api conErrorList;
  @api acctRelErrorList;
  @track financialType = false;
  @track disableButton = true;
  @track spinner = false;

  @track isCSSLoaded = false;

  renderedCallback() {
    if (this.isCSSLoaded) return;
    this.isCSSLoaded = true;
    loadStyle(this, customCSS).then(() => {
        console.log('css loaded successfully');
    }).catch(error => {
        console.log('error to load css');
    });
  }

  @wire(getRecord, { recordId: '$recordId', fields })
    account;

  get resultCode() {
      return getFieldValue(this.account.data, RESULT_CODE_FIELD);
  }
  get resultCodeStatus() {
    return getFieldValue(this.account.data, RESULT_CODE_STATUS_FIELD);
}

  //(SCDEV-4587)  starts
  get invoiceValue() {
    return getFieldValue(this.account.data,INVOICE_FIELD);
  //(SCDEV-4587) ends
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

  showAcctToast() {
    const toastEvent = new ShowToastEvent({
      title: "Success",
      message: "Account info has been updated.",
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

  handleTypeChange(event) {
    if (event.target.value === "Yes") {
      this.financialType = true;
    } else {
      this.financialType = false;
    }
  }


  saveAcct(event) {     
    this.spinner = true;
    let errorCount = false;   
    try {
      if ((this.template.querySelector('[data-id="acctName"]').value === null) || (this.template.querySelector('[data-id="acctName"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="acctType"]').value === null) || (this.template.querySelector('[data-id="acctType"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="acctContact"]').value === null) || (this.template.querySelector('[data-id="acctContact"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="acctPhone"]').value === null) || (this.template.querySelector('[data-id="acctPhone"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if (this.template.querySelector('[data-id="payTerms"]').value === ""){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="acctMgr"]').value === null) || (this.template.querySelector('[data-id="acctMgr"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if (this.template.querySelector('[data-id="acctInvoice"]').value === "") {
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="street"]').value === null) || (this.template.querySelector('[data-id="street"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="city"]').value === null) || (this.template.querySelector('[data-id="city"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="state"]').value === null) || (this.template.querySelector('[data-id="state"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="zip"]').value === null) || (this.template.querySelector('[data-id="zip"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="country"]').value === null) || (this.template.querySelector('[data-id="country"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="type"]').value === null) || (this.template.querySelector('[data-id="type"]').value === "")) {
        errorCount = true;
      }
    } catch (error) {}
    try {
      if ((this.template.querySelector('[data-id="printPhone"]').value === null) || (this.template.querySelector('[data-id="printPhone"]').value === "")){
        errorCount = true;
      }
    } catch (error) {}
    try {
      if (((this.template.querySelector('[data-id="standardPrintUrl"]').value === null) || (this.template.querySelector('[data-id="standardPrintUrl"]').value === "")) &&
          ((this.template.querySelector('[data-id="customPrintUrl"]').value === null) || (this.template.querySelector('[data-id="customPrintUrl"]').value === "")) )  {
        errorCount = true;
      }
    } catch (error) {}


    if (!errorCount) {
      console.log('No error');
      event.preventDefault();
      const fields = event.detail.fields;
      this.template.querySelector('[data-id="editAccountForm"]').submit(fields);
      this.spinner = false;
    } else {
      console.log('error');
      this.showErrorToast();
      this.spinner = false;
    }
  }

  acctSuccess() {
    
      console.log('Came here after submission disabled next button and spinner');
      this.spinner = true;
      //(SCDEV-4587) starts
      console.log('Came here after submission disabled next button and spinner');
      this.disableButton = true;
      if(this.invoiceValue!='No')
      {
        console.log('Came here becoz invoice is yes');
      //(SCDEV-4587) ends
        validateAddress({recordId: this.recordId})
        .then(result => {
          refreshApex(this.account).then(()=> {
            console.log('this.resultCode :'+this.resultCode);
            console.log('this.resultCodeStatus :'+this.resultCodeStatus);
            let resCodeWithoutException = this.resultCode?.replace(/AE08|AE09|AE10|AE11/g, '');            
            if(resCodeWithoutException?.includes('AE')){
              this.showCustomToast('Personator Validation','Billing Address is not valid! \n'+this.resultCodeStatus,'error');
            }else if(this.resultCode?.includes('AS')){
              this.disableButton = false;
              this.showCustomToast('Personator Validation','Personator Address Validation done!','success');
            } else{
              this.showCustomToast('Personator Validation','Billing Address is not valid! \n'+this.resultCodeStatus,'error');            
            }       
            this.spinner = false;
          });
        })
        .catch(error => {
          this.showCustomToast('Personator Error','Personator Address Validation Failed! Please Try again.','error'); 
          this.spinner = false;
        });
      //(SCDEV-4587) starts
      }
     else
     {
      console.log('Came here as invoic eis No');
      this.disableButton = false;
      this.spinner = false;
     }
     //(SCDEV-4587) ends
  }

  
  goNext() {
    if (this.conErrorList.length > 0) {
      const pasEvt = new CustomEvent("pass", { detail: "contact" });
      this.dispatchEvent(pasEvt);
    } else if (this.acctRelErrorList.length > 0) {
        const pasEvt = new CustomEvent("pass", { detail: "acctRel"  });
        this.dispatchEvent(pasEvt);
    } else {
        const pasEvt = new CustomEvent("pass", { detail: "validate" });
        this.dispatchEvent(pasEvt);
    } 
  }

}