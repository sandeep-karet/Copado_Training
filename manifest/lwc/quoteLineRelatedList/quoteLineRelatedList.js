/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import getQteLine from "@salesforce/apex/relateListLwcController.getQteLine";

const cols = [
  {
    label: "Product Name",
    fieldName: "prodName",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Membership Fee",
    fieldName: "mbrFee",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Quantity",
    fieldName: "quantity",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Initial Utilization Cap",
    fieldName: "Initial_Utilization_Cap_Calculated__c",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Consult Fees",
    fieldName: "cFee",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Monthly Price",
    fieldName: "mMbrFee",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Required By",
    fieldName: "qleName",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  },
  {
    label: "Product Code",
    fieldName: "productCode",
    type: "text",
    sortable: true,
    cellAttribute: { alignment: "center" }
  }
];

export default class QuoteLineRelatedList extends LightningElement {
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
  @track pageSize = 20;
  @track lastField; //last sorting field Name
  @track sortDirection; //sorting direction
  @track sortedField;
  @track qlData = [];

  connectedCallback() {
    this.getQteLine();
  }
  getQteLine() {
    getQteLine({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.qlData = response;
          this.qlData.forEach(function(record) {
            if (record.SBQQ__RequiredBy__c !== undefined) {
              record.qleName = record.SBQQ__RequiredBy__r.Name;
            } else {
              record.qleName = null;
            }

            record.productCode = record.SBQQ__Product__r.ProductCode;
            record.prodName = record.SBQQ__Product__r.Name;

            if (record.Consult_Fees__c !== undefined) {
              record.cFee = "USD $" + record.Consult_Fees__c;
            } else {
              record.cFee = null;
            }
            record.mbrFee = "USD $" + record.Membership_Fee__c;
            record.mMbrFee = "USD $" + record.Monthly_Price__c;
            record.quantity = record.SBQQ__Quantity__c.toString();
          });
          this.page = 1;
          this.items = this.qlData;
          this.totalRecountCount = this.qlData.length;
          if (this.totalRecountCount < this.pageSize) {
            this.pageSize = this.totalRecountCount;
          } else {
            this.pageSize = 20;
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
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;
    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;
    this.data = this.items.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;
  }
}