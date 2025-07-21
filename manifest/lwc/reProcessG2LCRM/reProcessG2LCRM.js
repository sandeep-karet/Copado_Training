import { LightningElement,api,wire, track } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import MUID_FIELD from "@salesforce/schema/G2LCRM_Item__c.MUID__c";
import getJobDetails from '@salesforce/apex/GCRMHelper.getJobDetails';
import executeBatch from '@salesforce/apex/GCRMHelper.executeBatch';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ReProcessG2LCRM extends LightningElement {
    @api recordId;

    @track isProcessed = false;
    @track isRendered = true;
    @track statusMsg;
    @track parsedResults;
    @track isBatchCompleted;
    @track batchJobId;
    @track _interval;
    @track _title;
    @track variant;
    @track isExecuting = false;
    _recordId;
    set recordId(recordId) {
      if (recordId !== this._recordId) {
        this._recordId = recordId;
      }
    }

    @api 
    async invoke(recordId){
        if (this.isExecuting) {
            return;
        }
        this.isExecuting = true;
        const record = await this.parsedResults;
        this.reProcessItems();
    }

    reProcessItems(){
        console.log('data resp' + JSON.stringify(this.parsedResults));
        console.log('MUID '+JSON.stringify(this.parsedResults.fields.MUID__c.value));
        if (this.parsedResults && typeof this.parsedResults != 'undefined') {
          executeBatch({thisMUID: this.parsedResults.fields.MUID__c.value})
            .then((response) => {
                this.statusMsg = 'Records Successfully Submitted for Re-Processing.';
                this.batchJobId = response;
                this.variant = "success";
                this._title = 'Records Submitted';
                this.showNotification();
            })
            .catch((exception) => {
                this.statusMsg = 'Error in submitting the records for re-processing';
                this.variant = "error";
                this._title = 'Records Failed to Submit';
                this.showNotification();
            });
            this.refreshBatchOnInterval()
        }
    }
    @wire(getRecord, { recordId: "$recordId", fields: [MUID_FIELD] })
    record( {error , data}){
        if(data){
            this.parsedResults = data;        

        }
        if(error){
            this.statusMsg = 'Error in submitting the records for re-processing';
            this._title = 'Records Failed to Submit';
            this.variant = 'error';
            this.showNotification();
        }
        
    }
    refreshBatchOnInterval() {
        this.isProcessed = true;
        this._interval = setInterval(() => {
            if (this.isBatchCompleted) {
                this.statusMsg = 'Batch Processing Completed. Check the Log for results';
                this.variant = "success";
                this._title = 'Batch Processed';
                clearInterval(this._interval);
                this.isProcessed = false;
                this.showNotification();
                this.isExecuting = false;
            } else {
                this.getBatchStatus();
            }
        }, 10000); //refersh view every time
        console.log('interval id' + this._interval);
    }

    getBatchStatus() {
        getJobDetails({ jobId: this.batchJobId }).then(res => {
            console.log('response => ', res);
            if (res[0]) {
                if (res[0].TotalJobItems == res[0].JobItemsProcessed) {
                    this.isBatchCompleted = true;
                }
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }

    showNotification() {
        const evt = new ShowToastEvent({
          title: this._title,
          message: this.statusMsg,
          variant: this.variant,
        });
        this.dispatchEvent(evt);
    }  

}