import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createExperienceContact from "@salesforce/apex/ClientExperienceContactController.createExperienceContact";

export default class ClientExperienceContactLWC extends LightningElement {
    @api recordId;
    @track isContact = true;
    @track contactId;
    @track newConId;
    @track isInteral = false;
    @track existingNew = false;

    yesContact(event){
        event.preventDefault();
        this.template.querySelector('.yesBtn').classList.add('dynamicCSS'); 
        this.template.querySelector('.noBtn').classList.remove('dynamicCSS');
        this.isContact = true;
        this.isInteral = false;
    }


    noContact(event){
        event.preventDefault();       
        this.template.querySelector('.noBtn').classList.add('dynamicCSS');
        this.template.querySelector('.yesBtn').classList.remove('dynamicCSS');
        this.isInteral = true;
        this.isContact = false;
    }

    close() {    
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    saveExistingContact(event) {
      event.preventDefault();
      const fields = event.detail.fields;
      this.template.querySelector('[data-id="ContactForm"]').submit(fields);
    }

    saveAndNewExisting(event) {
      this.existingNew = true;
      this.saveExistingContact(event);
    }

    contactSuccess() {
        const toastEvent = new ShowToastEvent({
            title: "Success",
            message: "Client Experience Contact Record Created",
            variant: "success",
          });
        this.dispatchEvent(toastEvent);

        if (this.existingNew) {
          this.existingNew = false;
          this.contactId = null;
          const inputFields = this.template.querySelectorAll('lightning-input-field');
          if (inputFields) {
            inputFields.forEach(field => {
                  field.reset();
            });
          }
          this.template.querySelector('[data-id="briefingId"]').value = (this.recordId);
          console.log(this.recordId);
        } else {
          const closeQA = new CustomEvent('close');
          this.dispatchEvent(closeQA);
        }
    }

    handleError(event) {        
        let error = event.detail.detail;
        const toastEvent = new ShowToastEvent({
          title: error,
          variant: "Error",
          mode: "dismissable"
        });
        this.dispatchEvent(toastEvent);
    }

    saveNewTdContact(event) {
      event.preventDefault();
      const fields = event.detail.fields;
      this.template.querySelector('[data-id="newContact"]').submit(fields);
    }

    saveAndNew(event) {
      this.existingNew = true;
      this.saveNewTdContact(event);
    }

    handleConError(event) {        
      let error = event.detail.detail;
      const toastEvent = new ShowToastEvent({
        title: error,
        variant: "Error",
        mode: "dismissable"
      });
      this.dispatchEvent(toastEvent);
    }

    newConSuccess(event) {
      const isAttend = this.template.querySelector('lightning-input');
      let payload = event.detail;
      createExperienceContact({ contactId: payload.id, parentId: this.recordId, isAttend: isAttend.checked})
      .then(response => {
        const toastEvent = new ShowToastEvent({
          title: "Success",
          message: "Contact and Client Experience Contact Record Created",
          variant: "success",
        });
        this.dispatchEvent(toastEvent);
        if (this.existingNew) {
          this.existingNew = false;
          this.newConId = null;
          const inputFields = this.template.querySelectorAll('lightning-input-field');
          if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
          }
        } else {
          const closeQA = new CustomEvent('close');
          this.dispatchEvent(closeQA);
        }
      })
      .catch(error => {
        console.error(error);
      });
    }
}