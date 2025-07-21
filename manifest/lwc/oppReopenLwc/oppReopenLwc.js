/* eslint-disable @lwc/lwc/valid-wire */
/* eslint-disable guard-for-in */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getContract from "@salesforce/apex/opportunityReopenLwcController.getContract";
import getSubs from "@salesforce/apex/opportunityReopenLwcController.getSubs";
import getPsf from "@salesforce/apex/opportunityReopenLwcController.getPsf";
import getAsset from "@salesforce/apex/opportunityReopenLwcController.getAsset";
import getRecordType from "@salesforce/apex/opportunityReopenLwcController.getRecordType";
import deleteChildRecord from "@salesforce/apex/opportunityReopenLwcController.deleteChildRecord";
import editOppAccountQuote from "@salesforce/apex/opportunityReopenLwcController.editOppAccountQuote";
import clearContractedField from "@salesforce/apex/opportunityReopenLwcController.clearContractedField";

const contractColumns = [
  {
    label: "Contract Number",
    fieldName: "ContractNumber",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Opportunity",
    fieldName: "linkName",
    type: "url",
    typeAttributes: { label: { fieldName: "oppName" }, target: "_blank" },
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Contract Start Date",
    fieldName: "StartDate",
    type: "date",
    cellAttribute: { alignment: "center" },
    typeAttributes: { day: "numeric", month: "short", year: "numeric" }
  },
  {
    label: "Contract End Date",
    fieldName: "EndDate",
    type: "date",
    cellAttribute: { alignment: "center" },
    typeAttributes: { day: "numeric", month: "short", year: "numeric" }
  },
  {
    label: "Status",
    fieldName: "Status",
    type: "text",
    cellAttribute: { alignment: "center" }
  }
];

const subColumns = [
  {
    label: "Subscription #",
    fieldName: "Name",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Quote Line",
    fieldName: "subLink",
    type: "url",
    typeAttributes: { label: { fieldName: "qteName" }, target: "_blank" },
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Product Name",
    fieldName: "SBQQ__ProductName__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Consult Type",
    fieldName: "Consult_Type__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Fee Type",
    fieldName: "Fee_Type__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Membership Fee",
    fieldName: "mbrFee",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Current Membership Fee",
    fieldName: "cmbrFee",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Quantity",
    fieldName: "quantity",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Start Date",
    fieldName: "SBQQ__StartDate__c",
    type: "date",
    cellAttribute: { alignment: "center" },
    typeAttributes: { day: "numeric", month: "short", year: "numeric" }
  }
];

const psfColumns = [
  {
    label: "Plan Fees ID",
    fieldName: "Name",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Product",
    fieldName: "Product__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Member Group",
    fieldName: "psfLink1",
    type: "url",
    typeAttributes: { label: { fieldName: "mbrName" }, target: "_blank" },
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Member Group Name",
    fieldName: "Member_Group_Name__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Subscription",
    fieldName: "psfLink2",
    type: "url",
    typeAttributes: { label: { fieldName: "subName" }, target: "_blank" },
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Product Start Date",
    fieldName: "Product_Start_Date__c",
    type: "date",
    cellAttribute: { alignment: "center" },
    typeAttributes: { day: "numeric", month: "short", year: "numeric" }
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date",
    cellAttribute: { alignment: "center" },
    typeAttributes: { day: "numeric", month: "short", year: "numeric" }
  }
];

const assetColumns = [
  {
    label: "Asset Name",
    fieldName: "Name",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Product Name",
    fieldName: "Product2.Name",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Required By Subscription",
    fieldName: "assetLink",
    type: "url",
    typeAttributes: { label: { fieldName: "subName" }, target: "_blank" },
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Fee Type",
    fieldName: "Fee_Type__c",
    type: "text",
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Consult Fees",
    fieldName: "conFee",
    type: "text",
    cellAttribute: { alignment: "center" }
  }
];

export default class oppReopenLwc extends NavigationMixin(LightningElement) {
  @api recordId;
  @track activeSections = ["A", "B", "C", "D"];
  @track contractCol = contractColumns; //holds column info
  @track subCol = subColumns;
  @track psfCol = psfColumns;
  @track assetCol = assetColumns;
  @track contractData;
  @track subData;
  @track psfData;
  @track assetData;
  @track recordTypeId;
  @track rtOptions = [];
  @track rtMap = [];
  @track recordTypeName;
  @track contractDataApex;
  @track subDataApex;
  @track psfDataApex;
  @track assetDataApex;
  @track probs;

  //slds-hidden
  // doInit component
  connectedCallback() {
    this.getContract();
    this.getSubs();
    this.getPsf();
    this.getAsset();
  }

  @wire(getRecordType)
  rtlist({ error, data }) {
    if (data) {
      for (const list of data) {
        const option = {
          label: list.Name,
          value: list.Id
        };
        // this.selectOptions.push(option);
        this.rtOptions = [...this.rtOptions, option];
      }
    } else if (error) {
      console.error(error);
    }
  }
  changeRt() {
    let rtName = this.template.querySelector('[data-id="combobox"]').value;
    for (let option of this.rtOptions) {
      if (option.value === rtName) {
        this.recordTypeId = option.value;
      }
    }
  }

  changeProbability() {
    let stageName = this.template.querySelector('[data-id="stage"]').value;
    if (stageName == "Prospect") {
      this.probs = 10;
    } else if (stageName == "Discovery") {
      this.probs = 20;
    } else if (stageName == "Proposal") {
      this.probs = 40;
    } else if (stageName == "Review/Negotiation") {
      this.probs = 60;
    } else if (stageName == "Contracting") {
      this.probs = 90;
    } else if (stageName == "Closed Won") {
      this.probs = 100;
    } else if (stageName == "Closed Lost") {
      this.probs = 0;
    } else {
      this.probs = null;
    }
  }

  getContract() {
    getContract({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.contractData = response;
          this.contractDataApex = this.contractData;
          this.contractData.forEach(function(record) {
            record.linkName = "/" + record.SBQQ__Opportunity__c;
            record.oppName = record.SBQQ__Opportunity__r.Name;
          });
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  getSubs() {
    getSubs({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.subData = response;
          this.subDataApex = this.subData;
          this.subData.forEach(function(record) {
            record.subLink = "/" + record.SBQQ__QuoteLine__c;
            record.qteName = record.SBQQ__QuoteLine__r.Name;
            record.mbrFee = "USD $" + record.Membership_Fee__c;
            record.cmbrFee = "USD $" + record.Current_Membership_Fee__c;
            record.quantity = record.SBQQ__Quantity__c.toString();
          });
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  getPsf() {
    getPsf({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.psfData = response;
          this.psfDataApex = this.psfData;
          this.psfData.forEach(function(record) {
            record.psfLink1 = "/" + record.Member_Group__c;
            record.mbrName = record.Member_Group__r.Name;
            record.psfLink2 = "/" + record.Subscription__c;
            record.subName = record.Subscription__r.Name;
          });
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  getAsset() {
    getAsset({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.assetData = response;
          this.assetDataApex = this.assetData;
          this.assetData.forEach(function(record) {
            record.assetLink = "/" + record.SBQQ__RequiredBySubscription__c;
            record.subName = record.SBQQ__RequiredBySubscription__r.Name;
            if (record.Consult_Fees__c) {
              record.conFee = "USD $" + record.Consult_Fees__c;
            }
          });
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  showErrorToast() {
    const toastEvent = new ShowToastEvent({
      title: "Update Error",
      message: "Please fill out record type",
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }

  saveOpp(event) {
    if (
      this.template.querySelector('[data-id="combobox"]').value === undefined
    ) {
      this.showErrorToast();
    } else {
      event.preventDefault();
      const fields = event.detail.fields;
      this.template.querySelector('[data-id="editOppForm"]').submit(fields);
    }
  }

  oppSuccess() {
    this.deleteChildRecord();
    this.editOppAccountQuote();
    clearContractedField({ recordId: this.recordId }).catch(error => {
      console.error("there is error: ", error);
    });
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Opportunity",
        actionName: "view"
      }
    });
  }

  deleteChildRecord() {
    deleteChildRecord({
      psfList: this.psfDataApex,
      contList: this.contractDataApex,
      subList: this.subDataApex,
      assetList: this.assetDataApex
    })
      .then(response => {})
      .catch(error => {
        console.error("there is error");
      });
  }

  editOppAccountQuote() {
    editOppAccountQuote({
      recordId: this.recordId,
      recordTypeId: this.recordTypeId
    })
      .then(response => {})
      .catch(error => {
        console.error("there is error");
      });
  }

  cancelDialog() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Opportunity",
        actionName: "view"
      }
    });
  }
}