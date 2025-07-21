/**
 * @description Contract Path LOB Component 
 * SCDEV-1495: TD ORG: Build NEW Contract Path/LOB Functionality
 */
import { LightningElement, track, api, wire} from "lwc";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { updateRecord} from 'lightning/uiRecordApi';
import { getFieldDisplayValue } from 'lightning/uiRecordApi';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

/* -- START: Importing Apex methods -- */
import accountValidation from "@salesforce/apex/ContractPathLOB_Controller.accountValidation";
import validateStage from "@salesforce/apex/ContractPathLOB_Controller.validateStage";
import getOppSubchannel from "@salesforce/apex/ContractPathLOB_Controller.getOppSubchannel";
/* -- END: Importing Apex methods -- */

/* -- START: Importing Custom Labels --*/
import Teladoc_Account from '@salesforce/label/c.TD_Teladoc_Account';
/* -- END: ImportingCustom Labels --*/

import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import DIRECT_CONTRACT from '@salesforce/schema/Opportunity.Direct_Contract__c';
import DIRECT_EMP_SERVICE from '@salesforce/schema/Opportunity.Direct_Employer_Service__c';
import CONTRACT_LENS from '@salesforce/schema/Opportunity.Contracting_Lens__c';
import LineofBusinessOpp from '@salesforce/schema/Opportunity.Line_of_Business_CP__c';
import updateOpp from "@salesforce/apex/ContractPathLOB_Controller.updateOpp";
import CONTRACT_PATH from '@salesforce/schema/Opportunity.Contract_Path__c';
import NAME_FIELD from '@salesforce/schema/Account.Name';

const FIELDS = [
    'Opportunity.Direct_Contract__c',
    'Opportunity.Direct_Employer_Service__c',
    'Opportunity.Contracting_Lens__c',
    'Opportunity.Line_of_Business_CP__c',
    'Opportunity.Contract_Path__r.Name',
    'Opportunity.Contract_Path__c'
];
const accFields = [NAME_FIELD];

export default class ContractPathLOB extends LightningElement {
    @api recordId;
    showAccount = false;
    showLens = false;
    showLOB = false;
    boolVisible = false;
    boolUpdateVisible = true;
    isLoaded = true;
    directContract;
    directcont = '';
    employerService = '';
    contLensVal = '';
    LOBVal = '';
    accountVal;
    lobFieldData;
    contractLen;
    accountValName;
    contractLensOptions = [];
    lobOptions = [];
    DirectEmpServicesOptions = [];
    accName = '';
    newobj = [];
    errorMsg = '';
    selectedType1;
    selectedType2;
    selectedType3;
    selectedType4;
    stageName;
    oppSubchannel;
    clickedButtonLabel = 'Update Contract Path';

    /* Expose schema objects/fields to the template. */
    oppObject = OPPORTUNITY_OBJECT;

    //Default RecordType Id of Opportunity Object
    @wire(getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT})
    opportunityObjectdata;

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: DIRECT_CONTRACT
    })
    directContract;


    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: DIRECT_EMP_SERVICE
    })
    DirectEmpServices({
        data,
        error
    }) {
        if (data) {
            this.DirectEmpService = data;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: CONTRACT_LENS
    })
    contractLens({
        data,
        error
    }) {
        if (data) {
            this.contractLen = data;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: LineofBusinessOpp
    })
    lineOfBusiness({
        data,
        error
    }) {
        if (data) this.lobFieldData = data;
    }

    /* Load Account.Name for custom rendering */
    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS
    })
    record;
    connectedCallback() {
        var accountName = this.record.data ? getFieldDisplayValue(this.record.data, CONTRACT_PATH) : '';
        this.fetchOppSubChannel();
    }

    handleDirectcontractChange(event) {
        this.directcont = event.target.value;
        let key = this.DirectEmpService.controllerValues[event.target.value];
        this.DirectEmpServicesOptions = this.DirectEmpService.values.filter(opt => opt.validFor.includes(key));
        if (this.directcont == 'NO') {
            this.accountVal = '';
            this.showAccount = true;
            this.selectedType2 = 'NO';
            this.selectedType3 = null;
            this.selectedType4 = null;
            this.contLensVal = '';
            this.employerService = 'NO';
            this.LOBVal = '';
            this.showLOB = false;
            let key2 = this.contractLen.controllerValues[event.target.value];
            this.contractLensOptions = this.contractLen.values.filter(opt => opt.validFor.includes(key2));
            this.showLens = true;

            //this.handleDirectEmployerServiceChange(event);
        } else if (this.directcont == 'YES') {
            this.showAccount = false;
            this.accountVal = Teladoc_Account;
            this.selectedType2 = '';
            this.selectedType3 = '';
            this.selectedType4 = '';
            this.contLensVal = '';
            this.employerService = '';
            this.LOBVal = '';
            this.showLens = false;
            this.showLOB = false;
        }
        this.fetchOppStage();
    }
    handleDirectEmployerServiceChange(event) {
        this.employerService = event.target.value;
        let key = this.contractLen.controllerValues[event.target.value];
        this.contractLensOptions = this.contractLen.values.filter(opt => opt.validFor.includes(key));
        if (this.employerService == 'NO') {
            this.showLens = true;

        } else if (this.employerService == 'YES') {
            this.showLens = false;
            this.showLOB = false;
            if (this.oppSubchannel != 'Canada') {
                this.LOBVal = 'Direct';
            } else {
                this.LOBVal = 'N/A';
            }
            this.contLensVal = 'Employer';
        }
    }

    contractLensChange(event) {
        let key = this.lobFieldData.controllerValues[event.target.value];
        
        if (this.oppSubchannel != 'Canada') {
            if (this.directcont == 'NO' && event.target.value == 'Health Plan/Insurance') {
                this.lobOptions = this.lobFieldData.values.filter(opt => opt.value.includes('ASO'));
                this.showLOB = true;
            } else if (this.directcont == 'YES' && event.target.value == 'Health Plan/Insurance') {
                this.lobOptions = this.lobFieldData.values.filter(opt => opt.validFor.includes(key));
                this.lobOptions = this.lobOptions.filter(opt => !opt.value.includes('N/A'));
                this.showLOB = true;
            } else if (event.target.value == 'Hospital/Health System') {
                this.LOBVal = 'N/A';
                this.showLOB = false;
            } else if (event.target.value == 'Reseller') {
                this.showLOB = false;
                this.LOBVal = 'Reseller';
            }
        } else {
            this.LOBVal = 'N/A';
            this.showLOB = false;
        }

        this.contLensVal = event.target.value;
    }
    lineOfBusinessChange(event) {
        this.LOBVal = event.target.value;
    }

    handleAccountChange(event) {

        this.accountVal = event.target.value;
        accountValidation({
                oppId: this.recordId,
                accId: this.accountVal
            })
            .then((result) => {
                let errMessage = result;
                this.errorMsg = errMessage;
                if (errMessage != '')
                    this.handleToastEvents(errMessage, 'Error', 'error', 'dismissable');

            })
            .catch((error) => {
                console.log(error);
            });
    }

    @wire(getRecord, {
        recordId: '$accountVal',
        accFields
    })
    account;

    async saveContractPath() {
        this.fetchOppStage();
        this.fetchOppSubChannel();
        if (this.oppSubchannel == 'Canada') {
            this.LOBVal = 'N/A';
            this.showLOB = false;
        }

        await validateStage({
                recordId: this.recordId
            })
            .then((result) => {
                this.stageName = result;
            })
            .catch((error) => {
                console.log(error);
            });

        if (this.stageName != 'Prospect' && (this.directcont == null || this.directcont == '')) {
            this.handleToastEvents('Direct TDH Contract is required at Discover Stage', 'Error', 'error', 'dismissable');
        } else if ((this.directcont != '') && (this.accountVal == '' || this.accountVal == null)) {
            this.handleToastEvents('Contract Path lookup field is required when there is a value in the Direct TDH Contract field.', 'Error', 'error', 'dismissable');
        } else if ((this.directcont != '') && (this.employerService == '' || this.employerService == null)) {
            this.handleToastEvents('Direct Employer Business is required when there is a value in the Direct TDH Contract field.', 'Error', 'error', 'dismissable');
        } else if ((this.directcont != '') && (this.contLensVal == '' || this.contLensVal == null)) {
            this.handleToastEvents('Contracting Lens is required when there is a value in the Direct TDH Contract field.', 'Error', 'error', 'dismissable');
        } else if (this.errorMsg != '') {
            this.handleToastEvents(this.errorMsg, 'Error', 'error', 'dismissable');
        } else if ((this.employerService != '') && (this.LOBVal == '' || this.LOBVal == null)) {
            this.handleToastEvents('Line of Business is required when there is a value in the Direct Employer Business.', 'Error', 'error', 'dismissable');
        } else {
            this.isLoaded = !this.isLoaded;
            if (this.stageName == 'Prospect') {
                this.clickedButtonLabel = 'Update Contract Path';
                this.boolVisible = false;
                this.boolUpdateVisible = true;
            }

            updateOpp({
                    recordId: this.recordId,
                    directCont: this.directcont,
                    directEmpl: this.employerService,
                    ContLens: this.contLensVal,
                    lineofBuss: this.LOBVal,
                    accountName: this.accountVal
                })
                .then(result => {
                    this.handleToastEvents('Contract Path is updated successfully', 'Success', 'success', 'dismissable');
                    this.clickedButtonLabel = 'Update Contract Path';
                    this.boolVisible = false;
                    this.boolUpdateVisible = true;

                    this.isLoaded = !this.isLoaded;
                    // Refresh Opp Detail Page
                    updateRecord({
                        fields: {
                            Id: this.recordId
                        }
                    })
                    eval("$A.get('e.force:refreshView').fire();");

                })
                .catch(error => {
                    this.isLoaded = !this.isLoaded;
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Error",
                          message: error.body.message,
                          variant: "error"
                        })
                      );                
                });
        }
    }

    /**
     * @description method to fetch Opportunity's Account name 
     * @param - accountId Opportunity's Account Id
     */
    fetchAccount(accountId) {
        //Apex controller to get the Account Name using AccountId
        getAccountName({
                recordId: accountId
            })
            .then((result) => {
                this.accName = result;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    /**
     * @description method to fetch Opportunity's stage used for validations
     * @param 
     */
    fetchOppStage() {
        validateStage({
                recordId: this.recordId
            })
            .then((result) => {
                this.stageName = result;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    /**
     * @description method to fetch Opportunity's Sub-Channel used for validations
     * @param 
     */
    fetchOppSubChannel() {
        getOppSubchannel({
                recordId: this.recordId
            })
            .then((result) => {
                this.oppSubchannel = result;
                if (this.oppSubchannel == 'Canada') {
                    this.LOBVal = 'N/A';
                    this.showLOB = false;

                }
            })
            .catch((error) => {
                console.log(error);
            });
    }


    /**
     * @description Update contract button click functionality
     * @param event field name and value to set
     */
    handleClick(event) {
        this.fetchOppSubChannel();
        const label = event.target.label;
        if (label === 'Update Contract Path') {
            this.clickedButtonLabel = 'Cancel';
            this.boolVisible = true;
            this.boolUpdateVisible = false;
            this.selectedType1 = '';
            this.selectedType2 = '';
            this.selectedType3 = '';
            this.selectedType4 = '';
            this.showAccount = false;
            this.showLens = false;
            this.showLOB = false;
            this.directcont = '';
            this.employerService = '';
            this.contLensVal = '';
            this.accountVal = '';
        } else if (label === 'Cancel') {
            this.clickedButtonLabel = 'Update Contract Path';
            this.boolVisible = false;
            this.boolUpdateVisible = true;
        }
    }

    /**
     * @description Fire toast events
     * @param toastMessage - The message to display in the toast.
     * @param toastTitle - The title for the message to display
     * @param toastVariant - The toast type('error' or 'success').
     * @param toastMode - The toast mode to dismiss the toast
     */
    handleToastEvents(toastMessage, toastTitle, toastVariant, toastMode) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: toastMode
        });
        this.dispatchEvent(evt);
    }
}