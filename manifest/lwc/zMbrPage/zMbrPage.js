/* eslint-disable no-useless-concat */
/* eslint-disable @lwc/lwc/valid-api */
/* eslint-disable array-callback-return */
/* eslint-disable consistent-return */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api } from "lwc";
import searchMbr from "@salesforce/apex/Mg2_AccountSetupLwcController.filterMbrGroup";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


const columns = [
    { label: "GROUP NAME", fieldName: "Name__c", type: "text", sortable: true, cellAttribute: { alignment: "left" } },
    { label: "LEGACY ID", fieldName: "Group_Number__c", type: "text", sortable: true, cellAttribute: { alignment: "left" } },
    { label: "STATUS", fieldName: "Status__c", type: "text", sortable: true, cellAttribute: { alignment: "left" } },
    { label: "LAST MODIFIED DATW", fieldName: "LastModifiedDate", type: "date", sortable: true, cellAttribute: { alignment: "left" },
      typeAttributes: { day: 'numeric', month: 'short', year: 'numeric',hour: '2-digit', minute: '2-digit',second: '2-digit',hour12: true }, },
    { label: "CREATED DATE", fieldName: "CreatedDate", type: 'date', sortable: true, cellAttribute: { alignment: "left" }, 
      typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }, }
  ];


export default class ZMbrPage extends NavigationMixin(LightningElement) {
  @api recordId;
  @track columns = columns; //holds column info
  @track data = []; //data to be display in the table
  @track items = []; //it contains all the records.
  @track endingRecord = 0; //end record position per page
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records
  @track recordCnt = 0; //total count for selected member group
  @track statusDefault = "";
  @api allList; //list of all the selected memeber group
  @track oldList = []; //list of all selected member group without current view page record
  @track preSelectedRows = []; //preselected row for member group checkbox
  @track page = 1; //this is initialize for 1st page
  @track startingRecord = 1; //start record position per page
  @track pageSize = 20; //default value we are assigning
  @track timeoutId; //keyup delay
  @track searchString; //name/Id search string
  @track statusString; //status search option
  @track isSamePage = true; //boolean for current member group selection is same page from last handleSelect 
  @track lastField; //last sorting field Name
  @track sortDirection; //sorting direction
  @track sortedField //sort by field name
  // [SCDEV-4368 Update to check if member groups have PSF records]
  @track hasPSF = true;

  connectedCallback() {
    this.Search();
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
  
  showCustomToast(title, msg, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvent);
  }

  SearchKeyDelay() {
    clearTimeout(this.timeoutId); // no-op if invalid id
    this.timeoutId = setTimeout(this.Search.bind(this), 500); // Adjust as necessary
  }

  get statusOptions() {
    return [
      { label: "Active", value: "Active" },
      { label: "Pending", value: "Pending" },
      { label: "Termed", value: "Termed" },
      { label: "None", value: "" }
    ];
  }

  Search() {
    try {
      this.searchString = this.template.querySelector(
        '[data-id="searchInput"]'
      ).value;
    } catch (error) {
      this.searchString = "";
    }
    try {
      this.statusString = this.template.querySelector(
        '[data-id="select"]'
      ).value;
    } catch (error) {
      this.statusString = "";
    }
    searchMbr({
      recordId: this.recordId,
      searchStr: this.searchString,
      statusStr: this.statusString
    })
      .then(response => {
        if (response) {
          this.isSamePage = false;
          this.page = 1;
          this.items = response;
          this.totalRecountCount = response.length;
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
          this.handleRowSelect();
          this.isSamePage = false;
        }
      })
      .catch(error => {
        console.error("there is error: ");
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
    this.isSamePage = false;
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
    this.handleRowSelect();
    this.isSamePage = false;
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

  handleRowSelect(event) {
    if (this.isSamePage) {
      let selRows = event.detail.selectedRows;
      // [SCDEV-4368 Update to check if member groups have PSF records]
      
      //psf error test
      this.hasPSF = true; // Added for 5831

      for (let i = 0; i < selRows.length; i++) {
        if(selRows[i].PSF_Count__c == 0){
          this.hasPSF = false;
        } 
        
      }
      
      let newList = selRows.map(r => r.Id);
      let newListFiltered = newList.filter(function(el) {
        return el != null;
      });
      let oldListiltered = this.oldList.filter(function(el) {
        return el != null;
      });
      this.oldList = oldListiltered;
      this.allList = this.oldList.concat(newListFiltered);
      this.preSelectedRows = newListFiltered;
    } else {
      this.oldList = this.allList;
      let preSelect = this.data.map(d => {
        const index = this.oldList.indexOf(d.Id);
        if (index > -1) {
          this.oldList.splice(index, 1);
          return d.Id;
        }
      });
      let preSelectFiltered = preSelect.filter(function(el) {
        return el != null;
      });
      let oldListiltered = this.oldList.filter(function(el) {
        return el != null;
      });
      this.oldList = oldListiltered;
      this.preSelectedRows = preSelectFiltered;
      this.allList = this.oldList.concat(preSelectFiltered);
    }
    this.isSamePage = true;
    this.recordCnt = this.allList.length;
  }

  previousHandler() {
    if (this.page > 1) {
      this.isSamePage = false;
      this.page = this.page - 1;
      this.displayRecordPerPage(this.page);
      this.handleRowSelect();
      this.isSamePage = false;
    }
  }

  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.isSamePage = false;
      this.page = this.page + 1;
      this.displayRecordPerPage(this.page);
      this.handleRowSelect();
      this.isSamePage = false;
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

  getSelectedRecords() {
    // [SCDEV-4368 Update to check if member groups have PSF records]
    if(this.allList.length>0){
      if(this.hasPSF){
        const pasEvt = new CustomEvent("pass", { detail: this.allList  });
        this.dispatchEvent(pasEvt);
      }else{
        console.error('One or more of the selected group(s) do not have any PSF record(s)');
        this.showCustomToast('Member Group Validation','One or more of the selected group(s) do not have any PSF record(s).','error');             
      }
    }else{
      this.showCustomToast('Member Group Validation','Please select atleast one Member Group','warning'); 
    }
  }
}