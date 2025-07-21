/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import { LightningElement } from "lwc";
import getQItem from "@salesforce/apex/MsgBusErrorReporting_Controller.getQItem";

const columns = [
    { label: "Opportuntiy Id", fieldName: "oppId", sortable: "true", type: "text",  cellAttribute: { alignment: "left" } },
    { label: "Account Id", fieldName: "acctId", sortable: "true",  type: "text", cellAttribute: { alignment: "left" } },
    { label: "CreatedBy", fieldName: "createdBy", sortable: "true", type: "text",  cellAttribute: { alignment: "left" } },
    { label: "CreatedDate", fieldName: "createdDate",  sortable: "true", type: "datetime",  cellAttribute: { alignment: "left" } },
    { label: "Status", fieldName: "status", type: "text",  cellAttribute: { alignment: "left" } },
    { label: "Result", fieldName: "result", type: "richText",  cellAttribute: { alignment: "left" } },
  ];
  

export default class MsgBuserrorReporting extends LightningElement {
    oppId;
    startDate;
    endDate;
    columns = columns;
    data;
    sortBy;
    sortDirection;
    isSamePage = true;
    page = 0;
    items = [];
    totalRecountCount = 0;
    pageSize = 20;
    startingRecord = 0;
    endingRecord = 0
    totalPage = 0;
    spinner = false;
    createdBy;

    reset() {
        this.template.querySelector('[data-id="oppId"]').value = null;
        this.createdBy = this.template.querySelector('[data-id="createdBy"]').value = null;
        this.template.querySelector('[data-id="startDate"]').value = null;
        this.template.querySelector('[data-id="endDate"]').value = null;
        this.data = null;
        this.page = 0;
        this.items = [];
        this.totalRecountCount = 0;
        this.startingRecord = 0;
        this.endingRecord = 0;
        this.totalPage = 0;
    }
    search() {
        this.spinner = true
        try {
            this.oppId = this.template.querySelector('[data-id="oppId"]').value;
        } catch (error) {
            this.oppId = null;
        }
        try {
            this.createdBy = this.template.querySelector('[data-id="createdBy"]').value;
        } catch (error) {
            this.createdBy = null;
        }
        try {
            this.startDate = this.template.querySelector('[data-id="startDate"]').value === '' ? null : this.template.querySelector('[data-id="startDate"]').value;
        } catch (error) {
            this.startDate = null;
        }
        try {
            this.endDate = this.template.querySelector('[data-id="endDate"]').value === '' ? null : this.template.querySelector('[data-id="endDate"]').value;
        } catch (error) {
            this.endDate = null;
        }

        getQItem({ oppId: this.oppId, startDate: this.startDate, endDate: this.endDate, createdBy: this.createdBy })
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
                    this.isSamePage = false;
                }   
                this.spinner = false;  
            })
            .catch(error => {
              console.log(`there is error: ${JSON.stringify(error)}`);
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

    previousHandler() {
        if (this.page > 1) {
          this.isSamePage = false;
          this.page = this.page - 1;
          this.displayRecordPerPage(this.page);
          this.isSamePage = false;
        }
    }
    
      nextHandler() {
        if (this.page < this.totalPage && this.page !== this.totalPage) {
          this.isSamePage = false;
          this.page = this.page + 1;
          this.displayRecordPerPage(this.page);
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

    exportToCSV() {   
        let columnHeader = ["Opportunity Id", "Account Id", "CreatedBy", "CreatedDate", "Status", "Result"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["oppId", "acctId", "createdBy", "createdDate", "status", "result"]; // This array holds the keys in the json data  
        var jsonRecordsData = this.items;  
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter;  
        for (let i = 0; i < jsonRecordsData.length; i++) {  
            let counter = 0;  
          for (let iteratorObj in jsonKeys) {  
            let dataKey = jsonKeys[iteratorObj];  
            if (counter > 0) {  csvIterativeData += csvSeperator;  }  
            if (  jsonRecordsData[i][dataKey] !== null && jsonRecordsData[i][dataKey] !== undefined) {  
                csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
            } else {  
                csvIterativeData += '""';  
            }  
            counter++;  
          }  
          csvIterativeData += newLineCharacter;  
        }  
       let downloadElement = document.createElement('a');
       downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvIterativeData);
       downloadElement.target = '_self';
       downloadElement.download = 'Error Records.csv';
       document.body.appendChild(downloadElement);
       downloadElement.click();   
    }

    get disableButton() {
        return (this.items.length === 0 );
    }
}