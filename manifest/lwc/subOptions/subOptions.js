import { LightningElement, api, track } from "lwc";
import createSubAsset from "@salesforce/apex/subOptionsController.createSubAsset";
import accountName from "@salesforce/apex/subOptionsController.accountName";

const columns = [
    { label: "Subscription ID", fieldName: "subId", type: "text", "initialWidth": 200, cellAttribute: { alignment: "left" } },
    { label: "PRODUCT CODE", fieldName: "productCode", sortable: "true", "initialWidth": 200, type: "text", cellAttribute: { alignment: "left" } },
    { label: "FEE TYPE", fieldName: "feeType", type: "text", "initialWidth": 200, cellAttribute: { alignment: "left" } },
    { label: "MEMBERSHIP FEE", fieldName: "membershipFee", type: "text", "initialWidth": 200, cellAttribute: { alignment: "left" } },
    { label: "ASSETS", fieldName: "asset", type: "text", "initialWidth": 800, cellAttribute: { alignment: "left" } },
  ];
  

export default class SubOptions extends LightningElement {
    @track parentGuid;
    @track columns = columns;
    @track data;
    @track sortBy;
    @track sortDirection;
    @track acctName;
    seasrchSubs() {
        try {
            this.parentGuid = this.template.querySelector(
              '[data-id="searchInput"]'
            ).value;
        } catch (error) {
            this.parentGuid = "";
        }
        if (this.parentGuid !== "") {
            accountName({ parentGUID: this.parentGuid })
            .then(response => {
             if (response) {
                 this.acctName = response;
             } else {
                this.acctName = null;
            }
            })
            .catch(error => {
              console.error("there is error");
         });
            createSubAsset({ parentGUID: this.parentGuid })
            .then(response => {
             if (response) {
                 this.data = response;
             } else {
                this.data = null;
            }
            })
            .catch(error => {
              console.error("there is error");
         });
        } else {
            this.data = null;
            this.acctName = null;
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }
}