/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import fetchAcctRel from "@salesforce/apex/PrimaryCarrierLookupLWC_Controller.fetchAcctRel";
import updateOpp from "@salesforce/apex/PrimaryCarrierLookupLWC_Controller.updateOpp";
import fetchCurrnetCarrier from "@salesforce/apex/PrimaryCarrierLookupLWC_Controller.fetchCurrnetCarrier";
import validatePC from "@salesforce/apex/PrimaryCarrierLookupLWC_Controller.validatePC";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


const cols = [
    {
        label: "Servicing Account",
        fieldName: "linkPcName",
        type: "url",
        wrapText: true,
        sortable: true,
        typeAttributes: { label: { fieldName: "PcName" }, target: "_blank" },
        cellAttribute: { alignment: "center" }
    },
    {
        label: "Contract Type",
        fieldName: "contractType",
        type: "text",
        wrapText: true,
        sortable: true,
        typeAttributes: { label: { fieldName: "contractType" }, target: "_blank" },
        cellAttribute: { alignment: "center" }
    },
    {
        label: "Account Role",
        fieldName: "accRole",
        type: "text",
        wrapText: true,
        sortable: true,
        typeAttributes: { label: { fieldName: "accRole" }, target: "_blank" },
        cellAttribute: { alignment: "center" }
    },
    {
        label: "Line of Business",
        fieldName: "LineOfBusiness",
        type: "text",
        wrapText: true,
        sortable: true,
        typeAttributes: { label: { fieldName: "LineOfBusiness" }, target: "_blank" },
        cellAttribute: { alignment: "center" }
    },
    {
      label: "Account Relationship Name",
      fieldName: "linkRelationName",
      type: "url",
      wrapText: true,
      sortable: true,
      typeAttributes: { label: { fieldName: "relationName" }, target: "_blank" },
      cellAttribute: { alignment: "center" }
  }
];

export default class PrimaryCarrierLookupLWC extends LightningElement {
  @api recordId;
  @track col = cols;
  @track data = []; //data to be display in the table
  @track items = []; //it contains all the records.
  @track endingRecord = 0; //end record position per page
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records
  @track recordCnt = 0;
  @track page = 1; //this is initialize for 1st page
  @track startingRecord = 1; //start record position per page
  @track pageSize = 5;
  @track lastField; //last sorting field Name
  @track sortDirection; //sorting direction
  @track sortedField;
  @track acctRelData = [];
  @track acctRel; 
  @track acctLink;
  @track acctName;
  @track isButtonDisabled = true;
  @track preSelectedRows = [];
  @track currentId;
  @track showWarning = false;

  connectedCallback() {
    this.fetchARecord();
    this.fetchCurrnetCarrier();
    this.validatePC();
  }

  validatePC(){
      validatePC({ recordId: this.recordId })
          .then(response => {
              if (response !== null && response.Primary_Carrier__c == null) {
                  const toastValidPCEvent = new ShowToastEvent({
                      title: "This is a Health Plan Opportunity, Please set the Primary Carrier",
                      variant: "warning",
                      mode: "sticky"
                  });
                  this.dispatchEvent(toastValidPCEvent);
              }
          });
  }
  fetchCurrnetCarrier() {
    fetchCurrnetCarrier({ recordId: this.recordId })
    .then(response => {
      if (response !== null) {
         this.acctName = response.Svc_Acct__r.Name;
         this.acctLink = "/one/one.app?#/sObject/" + response.Svc_Acct__c + "/view";
         let ids = [];
         ids.push(response.Id);
         this.preSelectedRows = ids;
         this.currentId = response.Id;
      }else{
          this.showWarning = true;
      }
    })
    .catch(error => {
      console.error("there is error " + error);
    });
  }

  fetchARecord() {
    fetchAcctRel({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.acctRelData = response;
          this.acctRelData.forEach(function(record) {
            record.linkPcName = "/" + record.Svc_Acct__c;
            record.PcName = record.Svc_Acct__r.Name;
            record.accRole = record.Relationship_Type__c;
            record.contractType = record.Contract_Type__c;
            record.LineOfBusiness = record.Line_of_Business__c;
            record.relationName = record.Name;
            record.linkRelationName = "/" + record.Id;
          });
          this.page = 1;
          this.items = this.acctRelData;
          this.totalRecountCount = this.acctRelData.length;
          if (this.totalRecountCount < this.pageSize) {
            this.pageSize = this.totalRecountCount;
          } else {
            this.pageSize = 5;
          }
          if (this.totalRecountCount === 0) {
            this.startingRecord = 0;
            this.totalPage = 1;
          } else {
            this.startingRecord = 1;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
          }
          this.data = this.items.slice(0, this.pageSize);
          this.endingRecord = this.pageSize;
          this.error = undefined;
        }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
  }

  handleSort(event) {
    this.page = 1;
    if (this.totalRecountCount === 0) {
      this.startingRecord = 0;
    } else {
      this.startingRecord = 1;
    }
    this.endingRecord = this.pageSize;
    let preField = this.lastField;
    if (preField === event.detail.fieldName) {
      if (this.sortDirection === "desc") {
        this.sortDirection = "asc";
      } else {
        this.sortDirection = "desc";
      }
    } else {
      this.sortDirection = "asc";
    }
    this.sortedField = event.detail.fieldName;
    this.lastField = this.sortedField;
    this.sortData(this.sortedField, this.sortDirection);
  }

  sortData(fieldName, sortDirection) {
    let newOrderData = JSON.parse(JSON.stringify(this.items));
    let key = a => a[fieldName];
    let reverse = sortDirection === "asc" ? 1 : -1;
    newOrderData.sort((a, b) => {
      let valueA = key(a) ? key(a).toLowerCase() : "";
      let valueB = key(b) ? key(b).toLowerCase() : "";
      return reverse * ((valueA > valueB) - (valueB > valueA));
    });
    this.items = newOrderData;
    this.data = newOrderData.slice(0, this.pageSize);
  }

  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1;
      this.displayRecordPerPage(this.page);
    }
  }

  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1;
      this.displayRecordPerPage(this.page);
    }
  }

  displayRecordPerPage(page) {
    try {
      this.preSelectedRows = [];
      this.preSelectedRows.push(this.currentId);
    } catch (error) {}
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;
    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;
    this.data = this.items.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;
  }

  handleRowSelect(event) {
    let selRow = event.detail.selectedRows;
    try {
      this.acctRel = selRow[0];
    } catch (error) {
      this.acctRel = null;
    }
    if (this.acctRel !== null) {
      this.isButtonDisabled = false;
    }
  }

  SubmitPC() {
    updateOpp({recordId: this.recordId, acctRelId: this.acctRel.Id})
        .then(result => {
            const toastEvent = new ShowToastEvent({
                title: "Contract Path has updated successfully",
                variant: "success",
                mode: "dismissable"
            });
            this.dispatchEvent(toastEvent);
            this.acctName = this.acctRel.Name;
            this.acctLink = "/one/one.app?#/sObject/" + this.acctRel.Id + "/view";
            this.currentId = this.acctRel.Id;
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
            //title:  error.body.fieldErrors.Primary_Carrier__c[0].message,
            variant: "Error",
            mode: "dismissable"
            });
            this.dispatchEvent(toastEvent);
        }
        );
  }
}