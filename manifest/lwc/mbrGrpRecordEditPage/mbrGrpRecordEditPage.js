import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchLogoDoc from "@salesforce/apex/MemberGroupV2Controller.searchLogoDoc";
import getRecordInfo from "@salesforce/apex/MemberGroupV2Controller.getRecordInfo";

export default class MbrGrpRecordEditPage extends NavigationMixin(LightningElement) {
  @api sobjectId;
  @track recordId;
  @track accountId;
  @track actDate;
  @track renderLogoT = true;
  @track renderLogo1 = true;
  @track renderLogo3 = true;
  @track renderLogo4 = true;
  @track renderLogoA1 = true;
  @track renderLogoA2 = true;
  @track Logo__c;
  @track Logo1__c;
  @track Logo3__c;
  @track Logo4__c;
  @track AltLogo1__c;
  @track AltLogo2__c;
  @track Logo1_ID;
  @track renderNew = false;
  @track isLoading = false;
  @track activeDate;
  @track disableSave = false;
  @track isHealthAssistantRequired = false;
  @track healthAssistantChecked = false;
  connectedCallback() {
    this.isLoading = true;
    this.getRecordInfo();
  }

  getRecordInfo() {
    if (this.sobjectId) {
      getRecordInfo({ objId: this.sobjectId })
      .then(response => {
        this.isLoading = false;
        if (response) {
          if (response.objType === "Mbr_Group__c") {
            this.renderNew = false;
            this.recordId = response.recordId;
            this.activeDate = response.activeDate;
            if (!response.logo) {
              this.renderLogoT = false;
            }
            if (!response.logo1) {
              this.renderLogo1 = false;
            }
            if (!response.logo3) {
              this.renderLogo3 = false;
            }
            if (!response.logo4) {
              this.renderLogo4 = false;
            }
            if (!response.altLogo1) {
              this.renderLogoA1 = false;
            }
            if (!response.altLogo2) {
              this.renderLogoA2 = false;
            }
          } else {
            this.renderNew = true;
            this.accountId = this.sobjectId;
            this.Logo1_ID = "MK_TDH_HZ_2";
            this.renderLogoT = false;
            this.renderLogo3 = false;
            this.renderLogo4 = false;
            this.renderLogoA1 = false;
            this.renderLogoA2 = false;
            this.Logo1__c = `<img src='/sfc/servlet.shepherd/document/download/${response.defaultLogo}' width="28%"/>`;
          }
        }
      })
      .catch(error => {
        this.isLoading = false;
        console.error(error);
      });
    }
  }

  changeActiveDate() {
    if (this.renderNew) {
      if (this.template.querySelector('[data-id="status"]').value === "ACTIVE") {
        let today = new Date();
        let dd = String(today.getDate()).padStart(2, "0");
        let mm = String(today.getMonth() + 1).padStart(2, "0"); 
        let yyyy = today.getFullYear();
        today = yyyy + "-" + mm + "-" + dd;
        this.template.querySelector('[data-id="activeDate"]').value = today;
      } else {
        this.template.querySelector('[data-id="activeDate"]').value = null;
      }
    } else {
      if (this.template.querySelector('[data-id="status"]').value !== "ACTIVE") {
        this.template.querySelector('[data-id="activeDate"]').value = null;
      } else {
        this.template.querySelector('[data-id="activeDate"]').value = this.activeDate;
      }  
    }
  }

  showLogoTagDelay() {
    this.template.querySelector('[data-id="logoTag"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId); 
    this.timeoutId = setTimeout(this.showLogoTag.bind(this), 800);
  }

  showLogo1Delay() {
    this.template.querySelector('[data-id="logo1"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(this.showLogo1.bind(this), 800);
  }

  showLogo3Delay() {
    this.template.querySelector('[data-id="logo3"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId); 
    this.timeoutId = setTimeout(this.showLogo3.bind(this), 800);
  }

  showLogo4Delay() {
    this.template.querySelector('[data-id="logo4"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(this.showLogo4.bind(this), 800);
  }

  showLogoA1Delay() {
    this.template.querySelector('[data-id="logoA1"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(this.showLogoA1.bind(this), 800);
  }

  showLogoA2Delay() {
    this.template.querySelector('[data-id="logoA2"]').classList.remove("slds-has-error");
    clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(this.showLogoA2.bind(this), 800);
  }

  showLogoTag() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoTag"]').value })
    .then(response => {
      if (response != null) {
        this.renderLogoT = true;
        this.Logo__c =`<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
      } else {
        if (this.template.querySelector('[data-id="logoTag"]').value !== "") {
          this.template.querySelector('[data-id="logoTag"]').classList.add("slds-has-error");
          this.showErrorToast();
        }
          this.renderLogoT = true;
          this.Logo__c = "";
          this.renderLogoT = false;
        }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  showLogo1() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo1"]').value })
    .then(response => {
        if (response != null) {
          this.renderLogo1 = true;
          this.Logo1__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
        } else {
          if (this.template.querySelector('[data-id="logo1"]').value !== "") {
            this.template.querySelector('[data-id="logo1"]').classList.add("slds-has-error");
            this.showErrorToast();
          }
          this.renderLogo1 = true;
          this.Logo1__c = "";
          this.renderLogo1 = false;
        }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  showLogo3() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo3"]').value })
    .then(response => {
      if (response != null) {
        this.renderLogo3 = true;
        this.Logo3__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
      } else {
        if (this.template.querySelector('[data-id="logo3"]').value !== "") {
          this.template.querySelector('[data-id="logo3"]').classList.add("slds-has-error");
          this.showErrorToast();
        }
        this.renderLogo3 = true;
        this.Logo1__c = "";
        this.renderLogo3 = false;
      }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  showLogo4() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo4"]').value })
    .then(response => {
      if (response != null) {
        this.renderLogo4 = true;
        this.Logo4__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
      } else {
          if (this.template.querySelector('[data-id="logo4"]').value !== "") {
            this.template.querySelector('[data-id="logo4"]').classList.add("slds-has-error");
            this.showErrorToast();
          }
          this.renderLogo4 = true;
          this.Logo4__c = "";
          this.renderLogo4 = false;
        }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
  }

  showLogoA1() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoA1"]').value })
    .then(response => {
      if (response != null) {
        this.renderLogoA1 = true;
        this.AltLogo1__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
      } else {
        if (this.template.querySelector('[data-id="logoA1"]').value !== "") {
            this.template.querySelector('[data-id="logoA1"]').classList.add("slds-has-error");
            this.showErrorToast();
        }
        this.renderLogoA1 = true;
        this.AltLogo1__c = "";
        this.renderLogoA1 = false;
      }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  showLogoA2() {
    searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoA2"]').value })
    .then(response => {
      if (response != null) {
        this.renderLogoA2 = true;
        this.AltLogo2__c =  "<img src='/sfc/servlet.shepherd/document/download/" + response.docId + '\' width="28%"/>';
      } else {
        if (this.template.querySelector('[data-id="logoA2"]').value !== "") {
          this.template.querySelector('[data-id="logoA2"]').classList.add("slds-has-error");
          this.showErrorToast();
        }
        this.renderLogoA2 = true;
        this.AltLogo2__c = "";
        this.renderLogoA2 = false;
      }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  close() {
    if (this.recordId == null) {
      if (this.accountId === undefined) {
        window.history.back();
      } else {
        this.dispatchEvent(new CustomEvent("close"));
      }
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: "Mbr_group__c",
          actionName: "view"
        }
      });
    }
  }

 isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.reportValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
  }

  saveMbrGrp(event) {
    if(this.isInputValid()){
    this.disableSave= true;
    this.isLoading = true;
    event.preventDefault();
    const fields = event.detail.fields; 
    this.template.querySelector('[data-id="mbrGrpForm"]').submit(fields);
    }
  }

  mbrGrpSuccess(event) {
    this.disableSave = false;
     this.isLoading = false;
    let payload = event.detail;
    const toastEvent = new ShowToastEvent({
      title: "Success",
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: payload.id,
        objectApiName: "Mbr_group__c",
        actionName: "view"
      }
    });
  }

  handleError(event) {
    this.disableSave = false;
     this.isLoading = false;
    let error = event.detail.detail;
    console.log(error)
    const toastEvent = new ShowToastEvent({
      title: error,
      variant: "Error",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }

  showErrorToast() {
    const toastEvent = new ShowToastEvent({
      title: "Invalid Logo Name",
      variant: "Error",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }
}