/* eslint-disable no-useless-concat */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api } from "lwc";
import CreateCase from "@salesforce/apex/Mg2_AccountSetupLwcController.CreateCase";
import flowCheck from "@salesforce/apex/Mg2_AccountSetupLwcController.flowCheck";
import sendForm from "@salesforce/apex/Mg2_AccountSetupLwcController.sendForm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class ZPdfPage extends NavigationMixin(LightningElement) {
  @api selectString;
  @api recordId;
  @track flowMessage = false;
  @track warningMessage;
  @track vfUrl;
  @track allList = [];
  @track caseConfig = false;

  // doInit component
  connectedCallback() {
    this.allList = this.selectString.split(",");
    let url = window.location.origin;
    this.vfUrl =
      url +
      "/apex/Mg2_NASFView?aid=" +
      this.recordId +
      "&renderAs=" +
      "&Mbr_Group__c=" +
      this.selectString;
    this.checkFlow();
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

  checkFlow() {
    flowCheck({ recordId: this.recordId, mbrIdList: this.allList })
      .then(response => {
        if (response) {
          this.flowMessage = true;
          this.warningMessage = response;
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  handleLast() {
    const pasEvt = new CustomEvent("pass", { detail: "preVious" });
    this.dispatchEvent(pasEvt);
  }

  renderPDF() {
    let url = window.location.origin;
    let vfUrl =
      url +
      "/apex/Mg2_NASFView?aid=" +
      this.recordId +
      "&renderAs=PDF" +
      "&Mbr_Group__c=" +
      this.selectString;
    window.open(vfUrl);
  }

  passToConfig() {
    if (this.selectString.length > 0) {
      this.caseConfig = true;
      CreateCase({ memberGroupIds: this.allList })
        .then(response => {
          if (response) {
            const emailEvent = new ShowToastEvent({
              title: "Creating Case...",
              message: "Direct to case record now..",
              variant: "success",
              mode: "dismissable"
            });
            this.dispatchEvent(emailEvent);
            this.caseConfig = false;
            this[NavigationMixin.Navigate]({
              type: "standard__recordPage",
              attributes: {
                recordId: response,
                objectApiName: "Case",
                actionName: "view"
              }
            });
          }
        })
        .catch(error => {
          console.log(error);
          this.caseConfig = false;
          const emailEvent = new ShowToastEvent({
            title: "Error: Unable to Create",
            message: "Please reach out to your system administrator",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(emailEvent);

        });
    } else {
      const caseEvent = new ShowToastEvent({
        title: "Can not Create Case ",
        message: "Please select at least one member group",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(caseEvent);
    }
  }

  sendAcctForm() {
    if (this.selectString.length > 0) {
      sendForm({ memberGroupIds: this.allList })
        .then(response => {
          if (response) {
            const emailEvent = new ShowToastEvent({
              title: "Email Sent",
              message: "New account setup form sent to " + response,
              variant: "success",
              mode: "dismissable"
            });
            this.dispatchEvent(emailEvent);
          }
        })
        .catch(error => {
          console.error("there is error");
        });
    } else {
      const caseEvent = new ShowToastEvent({
        title: "Can not Create Case ",
        message: "Please select at least one member group",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(caseEvent);
    }
  }
}