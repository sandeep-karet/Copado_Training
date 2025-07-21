/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, track } from "lwc";
import findSub from "@salesforce/apex/PSFByProductController.findSub";
import mgsName from "@salesforce/apex/PSFByProductController.mgName";
import getAsset from "@salesforce/apex/PSFByProductController.getAsset";
import deletePSF from "@salesforce/apex/PSFByProductController.deletePSF";
import getHistories from "@salesforce/apex/PSFByProductController.getHistories";
import getPSF from "@salesforce/apex/PSFByProductController.getPSF";
import findObjType from "@salesforce/apex/PSFByProductController.findObjType";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class PsfPageLwc extends NavigationMixin(LightningElement) {
  @api recordId;
  @track groupId;
  @track psfId;
  @track subList = [];
  @track hisList = [];
  @track subName;
  @track subId;
  @track mgName;
  @track proCode;
  @track feeDetail;
  @track subProductName;
  @track renderElse = false;
  @track renderBH = false;
  @track renderDERM = false;
  @track renderTC = false;
  @track renderFeeConstruct = true;
  @track renderBHprice = false;
  @track renderNew;
  @track renderFee = false;
  @track renderNoFee;
  @track psfRecord;
  @track oldPsf;
  @track subLink;
  @track renderExist = false;
  @track acctName;
  @track oppName;
  @track subStatus;
  @track conType;
  @track cmFee;
  @track startDate;
  @track feeType;
  @track noSub = false;

  connectedCallback() {
    console.log("record Id: " + this.recordId);
    findObjType({ objId: this.recordId })
      .then(response => {
        if (response) {
          if (response === "Mbr_Group__c") {
            this.groupId = this.recordId;
          } else {
            this.psfId = this.recordId;
          }
          console.log("group id : " + this.groupId);
          console.log("psf id : " + this.psfId);

          if (this.psfId == null) {
            this.renderNew = true;
          } else {
            this.renderNew = false;
            this.renderExist = true;
            this.getPSF();
            this.getHistories();
            this.noSub = true;
          }
          if (this.groupId != null && this.psfId == null) {
            this.findSub();
            this.mgsName();
          }
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  getHistories() {
    getHistories({ recordId: this.psfId })
      .then(response => {
        if (response) {
          this.hisList = response;
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  getPSF() {
    getPSF({ recordId: this.psfId })
      .then(response => {
        if (response) {
          this.oldPsf = response;
          this.groupId = response.Member_Group__r.Id;
          this.mgName = response.Member_Group__r.Name__c;
          this.subId = response.Subscription__r.Id;
          this.subLink = "/one/one.app?#/sObject/" + this.subId + "/view";
          this.subName = response.Subscription__r.Name;
          this.subProductName = response.Subscription__r.SBQQ__Product__r.Name;
          this.proCode = response.Subscription__r.SBQQ__Product__r.ProductCode;
          this.acctName = response.Subscription__r.SBQQ__Account__r.Name;
          if (
            response.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r
              .SBQQ__Opportunity2__r.Name === undefined
          )
            this.oppName = "";
          else
            this.oppName =
              response.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name;
          this.subStatus = response.Subscription__r.Status__c;
          this.conType = response.Subscription__r.Consult_Type__c;
          this.cmFee = response.Subscription__r.Current_Membership_Fee__c;
          this.startDate = response.Subscription__r.SBQQ__StartDate__c;
          this.feeType = response.Subscription__r.Fee_Type__c;
          this.renderFeeConstruct = true;
          this.renderElse = false;
          this.renderBH = false;
          this.renderDERM = false;
          this.renderTC = false;
          if (this.proCode === "DERM") {
            this.renderDERM = true;
          } else if (this.proCode === "BH") {
            this.renderBH = true;
          } else if (this.proCode === "TC") {
            this.renderTC = true;
          } else {
            this.renderElse = true;
          }
          getAsset({ subId: this.subId, productCode: this.proCode })
            .then(detail => {
              if (detail) {
                if (detail.isFee === false) {
                  this.renderFee = false;
                  this.renderFeeConstruct = false;
                } else {
                  this.renderFee = true;
                  this.renderFeeConstruct = true;
                  this.feeDetail = detail;

                  if (this.proCode !== "BH") {
                    if (detail.cfMbr == null) {
                      this.renderNoFee = true;
                      this.renderBHprice = false;
                    } else {
                      this.renderBHprice = false;
                      this.renderNoFee = false;
                    }
                  } else {
                    if (
                      detail.bhFistMbr == null ||
                      detail.bhOnMbr == null ||
                      detail.bhNonMbr == null
                    ) {
                      this.renderBHprice = false;
                      this.renderNoFee = true;
                    } else {
                      this.renderBHprice = true;
                      this.renderNoFee = false;
                    }
                  }

                  if (this.proCode === "DERM") {
                    this.template.querySelector('[data-id="dermMbr"]').value =
                      response.DERMConsult_Fee_Mbr_Pd__c;
                    this.template.querySelector('[data-id="dermPlan"]').value =
                      response.DERMConsult_Fee_Plan_Pd__c;
                  } else if (this.proCode === "BH") {
                    this.template.querySelector('[data-id="bhFistMbr"]').value =
                      response.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c;
                    this.template.querySelector(
                      '[data-id="bhFistPlan"]'
                    ).value =
                      response.Consult_Fee_Initial_Diagnostic_Plan_Pd__c;
                    this.template.querySelector('[data-id="bhOnMbr"]').value =
                      response.Consult_Fee_Ongoing_MD_Mbr_Pd__c;
                    this.template.querySelector('[data-id="bhOnPlan"]').value =
                      response.Consult_Fee_Ongoing_MD_Plan_Pd__c;
                    this.template.querySelector('[data-id="bhNonMbr"]').value =
                      response.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c;
                    this.template.querySelector('[data-id="bhNonPlan"]').value =
                      response.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c;
                  } else if (this.proCode === "TC") {
                    this.template.querySelector('[data-id="tcMbr"]').value =
                      response.TC_Mbr_Case_Rate_Fee__c;
                    this.template.querySelector('[data-id="tcPlan"]').value =
                      response.TC_Client_Case_Rate_Fee__c;
                  } else {
                    this.template.querySelector('[data-id="elseMbr"]').value =
                      response.Consult_Fee_Mbr_Pd__c;
                    this.template.querySelector('[data-id="elsePlan"]').value =
                      response.Consult_Fee_Plan_Pd__c;
                  }
                }
              }
            })
            .catch(error => {
              console.error(error);
            });
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  getExistPsf() {}

  getAsset() {
    getAsset({ subId: this.subId, productCode: this.proCode })
      .then(response => {
        if (response) {
          console.log(response);
          if (response.isFee === false) {
            this.renderFee = false;
            this.renderFeeConstruct = false;
          } else {
            this.renderFee = true;
            this.renderFeeConstruct = true;
            this.feeDetail = response;

            if (this.proCode !== "BH") {
              if (response.cfMbr == null) {
                this.renderNoFee = true;
                this.renderBHprice = false;
              } else {
                this.renderBHprice = false;
                this.renderNoFee = false;
              }
            } else {
              if (
                response.bhFistMbr == null ||
                response.bhOnMbr == null ||
                response.bhNonMbr == null
              ) {
                this.renderBHprice = false;
                this.renderNoFee = true;
              } else {
                this.renderBHprice = true;
                this.renderNoFee = false;
              }
            }

            if (this.proCode === "DERM") {
              if (response.cfMbr) {
                this.template.querySelector('[data-id="dermMbr"]').value =
                  response.cfMbr;
              } else {
                this.template.querySelector('[data-id="dermMbr"]').value = 0;
              }
            } else if (this.proCode === "BH") {
              if (response.bhFistMbr) {
                this.template.querySelector('[data-id="bhFistMbr"]').value =
                  response.bhFistMbr;
              } else {
                this.template.querySelector('[data-id="bhFistMbr"]').value = 0;
              }
              if (response.bhOnMbr) {
                this.template.querySelector('[data-id="bhOnMbr"]').value =
                  response.bhOnMbr;
              } else {
                this.template.querySelector('[data-id="bhOnMbr"]').value = 0;
              }
              if (response.bhNonMbr) {
                this.template.querySelector('[data-id="bhNonMbr"]').value =
                  response.bhNonMbr;
              } else {
                this.template.querySelector('[data-id="bhNonMbr"]').value = 0;
              }
            } else if (this.proCode === "TC") {
              if (response.cfMbr) {
                this.template.querySelector('[data-id="tcMbr"]').value =
                  response.cfMbr;
              } else {
                this.template.querySelector('[data-id="tcMbr"]').value = 0;
              }
            } else {
              if (response.cfMbr) {
                this.template.querySelector('[data-id="elseMbr"]').value =
                  response.cfMbr;
              } else {
                this.template.querySelector('[data-id="elseMbr"]').value = 0;
              }
            }
          }
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  mgsName() {
    mgsName({ groupId: this.groupId })
      .then(response => {
        if (response) {
          this.mgName = response;
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  findSub() {
    findSub({ groupId: this.groupId })
      .then(response => {
        if (response) {
          if (response.length > 0) {
            response.forEach(i => {
              if (i.objSub.SBQQ__QuoteLine__r === undefined) {
                i.objSub.SBQQ__QuoteLine__r = {
                  SBQQ__Quote__c: "N/A",
                  Id: "N/A",
                  SBQQ__Quote__r: {
                    SBQQ__Opportunity2__c: "N/A",
                    Id: "N/A",
                    SBQQ__Opportunity2__r: {
                      Name: "N/A"
                    }
                  }
                };
              }
            });
            this.subList = response;
            this.noSub = true;
          } else {
            const toastEvent = new ShowToastEvent({
              title: "Error",
              message:
                "No valid subscriptions found. A subscription must be created first.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(toastEvent);
            this.noSub = false;
          }
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  checkBox(event) {
    this.renderFeeConstruct = true;
    this.renderElse = false;
    this.renderBH = false;
    this.renderDERM = false;
    this.renderTC = false;
    let currIndex = event.target.dataset.index;
    let selectedRows = this.template.querySelectorAll("lightning-input");
    for (let i = 0; i < selectedRows.length; i++) {
      if (
        selectedRows[i].type === "checkbox" &&
        selectedRows[i].value !== event.target.value
      ) {
        selectedRows[i].checked = event.target.unchecked;
      }
    }
    this.proCode = this.subList[currIndex].objSub.SBQQ__Product__r.ProductCode;
    this.subName = this.subList[currIndex].objSub.Name;
    this.subId = this.subList[currIndex].objSub.Id;
    this.subLink = "/one/one.app?#/sObject/" + this.subId + "/view";
    if (this.proCode === "DERM") {
      this.renderDERM = true;
    } else if (this.proCode === "BH") {
      this.renderBH = true;
    } else if (this.proCode === "TC") {
      this.renderTC = true;
    } else {
      this.renderElse = true;
    }
    this.subProductName = this.subList[currIndex].objSub.SBQQ__Product__r.Name;
    this.timeoutId = setTimeout(this.getAsset.bind(this), 300);
  }

  handleSubmit(event) {
    let errorCount = false;
    if (this.renderNoFee) {
      const toastEvent = new ShowToastEvent({
        title: "Error",
        message: "No Default Fee found in Assets",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(toastEvent);
    } else {
      this.template
        .querySelector('[data-id="startDate"]')
        .classList.remove("slds-has-error");
      if (this.renderFeeConstruct) {
        if (this.proCode === "BH") {
          this.template
            .querySelector('[data-id="bhFistMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="bhFistPlan"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="bhOnMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="bhOnPlan"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="bhNonMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="bhNonPlan"]')
            .classList.remove("slds-has-error");
          if (
            Number(this.template.querySelector('[data-id="bhFistMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="bhFistPlan"]').value
              ) !==
            this.feeDetail.bhFistMbr
          ) {
            this.template
              .querySelector('[data-id="bhFistMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="bhFistPlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message:
                "Consult Fee- Psych/MD-1stvisitonly-MbrPd : Sum does not equal default value",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }

          if (
            Number(this.template.querySelector('[data-id="bhOnMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="bhOnPlan"]').value
              ) !==
            this.feeDetail.bhOnMbr
          ) {
            this.template
              .querySelector('[data-id="bhOnMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="bhOnPlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message:
                "Consult Fee- Psych/MD-ONGOINGvisit : Sum does not equal default value.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }

          if (
            Number(this.template.querySelector('[data-id="bhNonMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="bhNonPlan"]').value
              ) !==
            this.feeDetail.bhNonMbr
          ) {
            this.template
              .querySelector('[data-id="bhNonMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="bhNonPlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message:
                "Consult Fee- Non-Psychiatrist : Sum does not equal default value",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }
        } else if (this.proCode === "DERM") {
          this.template
            .querySelector('[data-id="dermMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="dermPlan"]')
            .classList.remove("slds-has-error");
          if (
            Number(this.template.querySelector('[data-id="dermMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="dermPlan"]').value
              ) !==
            this.feeDetail.cfMbr
          ) {
            this.template
              .querySelector('[data-id="dermMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="dermPlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message: "DERMConsult Fee : Sum does not equal default value.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }
        } else if (this.proCode === "TC") {
          this.template
            .querySelector('[data-id="tcMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="tcPlan"]')
            .classList.remove("slds-has-error");
          if (
            Number(this.template.querySelector('[data-id="tcMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="tcPlan"]').value
              ) !==
            this.feeDetail.cfMbr
          ) {
            this.template
              .querySelector('[data-id="tcMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="tcPlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message:
                "Mbr Case Rate Fee and Client Case Rate Fee : Sum does not equal default value.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }
        } else {
          this.template
            .querySelector('[data-id="elseMbr"]')
            .classList.remove("slds-has-error");
          this.template
            .querySelector('[data-id="elsePlan"]')
            .classList.remove("slds-has-error");
          if (
            Number(this.template.querySelector('[data-id="elseMbr"]').value) +
              Number(
                this.template.querySelector('[data-id="elsePlan"]').value
              ) !==
            this.feeDetail.cfMbr
          ) {
            this.template
              .querySelector('[data-id="elseMbr"]')
              .classList.add("slds-has-error");
            this.template
              .querySelector('[data-id="elsePlan"]')
              .classList.add("slds-has-error");
            const bhtEvent = new ShowToastEvent({
              title: "Error",
              message: "Consult Fee : Sum does not equal default value.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(bhtEvent);
            errorCount = true;
          }
        }
      }
      if (
        this.template.querySelector('[data-id="startDate"]').value == null ||
        this.template.querySelector('[data-id="startDate"]').value === ""
      ) {
        this.template
          .querySelector('[data-id="startDate"]')
          .classList.add("slds-has-error");
        const bhtEvent = new ShowToastEvent({
          title: "Error",
          message: "Product Start Date: You must enter a value",
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(bhtEvent);
        errorCount = true;
      }

      if (!errorCount) {
        // submit
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('[data-id="createPSFForm"]').submit(fields);
      }
    }
  }

  handleSuccess(event) {
    let payload = event.detail;
    const psfEvent = new ShowToastEvent({
      title: "Created",
      message: "PSF record is created",
      variant: "Success",
      mode: "dismissable"
    });
    this.dispatchEvent(psfEvent);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: payload.id,
        objectApiName: "Plan_Specific_Fees__c",
        actionName: "view"
      }
    });
  }

  handleError(event) {
    const psfEvent = new ShowToastEvent({
      title: "Error",
      message:
        `Unable to create PSF record: ${event.detail.detail}`,
      variant: "Error",
      mode: "dismissable"
    });
    this.dispatchEvent(psfEvent);
  }

  close() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.groupId,
        objectApiName: "Mbr_Group__c",
        actionName: "view"
      }
    });
  }

  deleteRecord() {
    deletePSF({ recordId: this.psfId })
      .then(response => {
        const toastEvent = new ShowToastEvent({
          title: "PSF Record Deleted",
          message: "",
          variant: "Success",
          mode: "dismissable"
        });
        this.dispatchEvent(toastEvent);
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.groupId,
            objectApiName: "Mbr_Group__c",
            actionName: "view"
          }
        });
      })
      .catch(error => {
        const toastEvent = new ShowToastEvent({
          title: "Something wnet wrong",
          message: "please contact your administrator.",
          variant: "Error",
          mode: "dismissable"
        });
        this.dispatchEvent(toastEvent);
      });
  }
}