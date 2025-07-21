/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api } from "lwc";
import sObjectType from "@salesforce/apex/msuLookupLwcController.sObjectType";
import checkRecord from "@salesforce/apex/msuLookupLwcController.checkRecord";
import recordName from "@salesforce/apex/msuLookupLwcController.recordName";
import getMsuList from "@salesforce/apex/msuLookupLwcController.getMsuList";

export default class MsuLookup extends LightningElement {
  @api recordId;
  @track isError;
  @track isContact;
  @track errorMeg;
  @track Name;
  @track page = 1;
  @track totalRecountCount = 0;
  @track pageSize = 15;
  @track startingRecord = 1;
  @track totalPage = 0;
  @track endingRecord = 0;
  @track data = [];
  @track msuList = [];
  @track displayList = [];

  connectedCallback() {
    this.sObjectType();
    this.checkRecord();
    this.recordName();
    this.getMsuList();
  }

  recordName() {
    recordName({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.Name = response;
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  sObjectType() {
    sObjectType({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.isContact = response;
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  checkRecord() {
    checkRecord({ recordId: this.recordId })
      .then(response => {
        if (response) {
          if (response == null) {
            this.isError = false;
          } else {
            this.isError = true;
          }
          this.errorMeg = response;
        }
      })
      .catch(error => {
        console.error("there is error");
      });
  }

  getMsuList() {
    getMsuList({ recordId: this.recordId })
      .then(response => {
        if (response) {
          this.msuList = response;
          this.displayList = this.msuList;

          this.page = 1;
          this.totalRecountCount = response.length;
          if (this.totalRecountCount < this.pageSize) {
            this.pageSize = this.totalRecountCount;
          } else {
            this.pageSize = 15;
          }
          if (this.totalRecountCount === 0) {
            this.startingRecord = 0;
            this.totalPage = 1;
          } else {
            this.startingRecord = 1;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
          }
          this.data = this.displayList.slice(0, this.pageSize);
          this.endingRecord = this.pageSize;
        }
      })
      .catch(error => {
        console.error("there is error");
      });
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
    this.data = this.displayList.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;
  }

  groupFilter() {
    this.displayList = [];
    let searchKey = this.template.querySelector('[data-id="group"]').value;
    if (searchKey == null || searchKey === "") {
      this.displayList = this.msuList;
      this.page = 1;
      this.totalRecountCount = this.displayList.length;
      if (this.totalRecountCount <= this.pageSize) {
        this.pageSize = this.totalRecountCount;
      } else {
        this.pageSize = 15;
      }
      if (this.totalRecountCount === 0) {
        this.startingRecord = 0;
        this.totalPage = 1;
      } else {
        this.startingRecord = 1;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
      }
      this.data = this.displayList.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
    } else {
      this.msuList.forEach(record => {
        if (record.groupName.toLowerCase().includes(searchKey.toLowerCase())) {
          this.displayList.push(record);
        }
      });
      this.page = 1;
      this.totalRecountCount = this.displayList.length;
      if (this.totalRecountCount <= this.pageSize) {
        this.pageSize = this.totalRecountCount;
      } else {
        this.pageSize = 15;
      }
      if (this.totalRecountCount === 0) {
        this.startingRecord = 0;
        this.totalPage = 1;
      } else {
        this.startingRecord = 1;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
      }
      this.data = this.displayList.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
    }
  }

  contactFilter() {
    this.displayList = [];
    let searchKey = this.template.querySelector('[data-id="contact"]').value;
    if (searchKey == null || searchKey === "") {
      this.displayList = this.msuList;
      this.page = 1;
      this.totalRecountCount = this.displayList.length;
      if (this.totalRecountCount < this.pageSize) {
        this.pageSize = this.totalRecountCount;
      } else {
        this.pageSize = 15;
      }
      if (this.totalRecountCount === 0) {
        this.startingRecord = 0;
        this.totalPage = 1;
      } else {
        this.startingRecord = 1;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
      }
      this.data = this.displayList.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
    } else {
      this.msuList.forEach(record => {
        if ( record.msu.Contact__r.Name.toLowerCase().includes(searchKey.toLowerCase())) {
          this.displayList.push(record);
        }
      });
      this.page = 1;
      this.totalRecountCount = this.displayList.length;
      if (this.totalRecountCount < this.pageSize) {
        this.pageSize = this.totalRecountCount;
      } else {
        this.pageSize = 15;
      }
      if (this.totalRecountCount === 0) {
        this.startingRecord = 0;
        this.totalPage = 1;
      } else {
        this.startingRecord = 1;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
      }
      this.data = this.displayList.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
    }
  }
}