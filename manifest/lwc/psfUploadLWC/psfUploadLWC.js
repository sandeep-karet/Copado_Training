import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/psfUploadController.readCSVFile';
import getCSV from '@salesforce/apex/psfUploadController.getCSV';
import deleteDoc from '@salesforce/apex/psfUploadController.deleteDoc';
import { NavigationMixin } from "lightning/navigation";


const columns = [
    { label: 'PSF Id', fieldName: "psfLinkName", type: "url", typeAttributes: { label: { fieldName: "psfId" }, target: "_blank" }, cellAttribute: { alignment: "center" }},
    { label: 'Member Group ID', fieldName: "mbrLinkName", type: "url", typeAttributes: { label: { fieldName: "mbrId" }, target: "_blank" }, cellAttribute: { alignment: "center" }},
    { label: 'Product Start Date', fieldName: 'startDate' },
    { label: 'Actual Copay May Be Less', fieldName: 'coPay' },
    { label: 'Consult Fee Plan Paid', fieldName: 'planFee'}, 
    { label: 'Consult Fee Member Paid', fieldName: 'mbrFee'}, 
    { label: 'Subscription ID', fieldName: "subLink", type: "url", sortable: 'true', typeAttributes: { label: { fieldName: "subId" }, target: "_blank" }, cellAttribute: { alignment: "center" }},
    { label: 'Asset ID', fieldName: "astLink", type: "url", typeAttributes: { label: { fieldName: "astId" }, target: "_blank" }, cellAttribute: { alignment: "center" }},
    { label: 'Asset Product Code', fieldName: 'prodCode' },
    { label: 'DML Error', fieldName: 'error', type: 'text', wrapText: true }
];


export default class PsfUploadLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track columns = columns;
    @track data;
    @track tempId;
    @track sortBy;
    @track sortDirection;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    connectedCallback() {
        getCSV().then(response => {
            if (response) {
                this.tempId = response;
            }
          })
        .catch(error => {
            console.error("there is error");
        });
    }
    
    download() {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.tempId,
            objectApiName: "ContentDocument",
            actionName: "view"
          }
        });
    }



    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        readCSV({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            console.log(result);
            console.log(JSON.stringify(result))
            this.data = result;
            this.data.forEach(record => {
                record.psfLinkName = "/" + record.psf.Id;
                record.psfId = record.psf.Id;
                record.startDate = record.psf.Product_Start_Date__c;
                record.coPay = record.psf.Actual_Copay_May_Be_Less__c;
                record.planFee = record.psf.Consult_Fee_Plan_Pd__c;
                record.mbrFee = record.psf.Consult_Fee_Mbr_Pd__c;
                record.mbrLinkName = "/" + record.psf.Member_Group__c;
                record.mbrId = record.psf.Member_Group__c;
                record.subLink = "/" + record.psf.Subscription__c;
                record.subId = record.psf.Subscription__c;
                record.astLink = "/" + record.psf.Asset__c;
                record.astId = record.psf.Asset__c;
            })
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'CSV file!',
                    variant: 'success',
                }),
            );
            deleteDoc({idContentDocument : uploadedFiles[0].documentId});
        })
        .catch(error => { 
            deleteDoc({idContentDocument : uploadedFiles[0].documentId});
            let msg = JSON.stringify(error.body.message);            
            const toastEvent = new ShowToastEvent({
                title: "Something went wrong!",
                message: msg,
                variant: "error",
            });
            this.dispatchEvent(toastEvent);
            
        })

    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;

    }
}