import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllContracts from '@salesforce/apex/L2O_ManageInstallBaseController.getAllContracts';
import getMetaDataSettings from '@salesforce/apex/L2O_ManageInstallBaseController.getMetaDataSettings'; 
import updateContract from "@salesforce/apex/L2O_ManageInstallBaseController.updateContract";
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_AMENDOPTION_FIELD from '@salesforce/schema/Account.L2O_Amendment_Opportunity_SubType__c';

export default class AccountAmendAsset extends NavigationMixin(LightningElement) { 
    @api recordId;
    @api objectApiName;

    @api contractId;
    @track error = false;
    @track errorMessage;
    //All metadata settings
    metadataSettings;
    amendFlowOptionsHeader;
    amendSubTypeHeader;
    allContractsHeader;
    contractListNote;
    contractListNote2;
    //All User inputs
    @track selectedFlow;
    @track selectedAmendOption;
    @track selectedContractId;
    @track selectedContractQuoteId;
    //All Screen Flags
    @track showAmendFlowOptions = true;
    @track showAmendSubTypeOptions = false; 
    @track showUpdateContact = false;
    @track showAllContracts = false;
    @track currentStep = 1;
    @track screenValidationError = false;
    @track noValidContracts = false;
    
    //Screen Options
    @track resultContracts=[{Id:'',Name:'',OpportunityId:'',QuoteId:''}];
    @track flowOptions;
    @track amendmentOptions;
    //Fetch Metadata settings
    connectedCallback() {
        /* Dynamic Text from custom metadata */
        getMetaDataSettings()
        .then(result => {
            this.metadataSettings = result[0];
            this.amendFlowOptionsHeader = this.metadataSettings.L2O_AmendOptionHeader__c;
            this.amendSubTypeHeader = this.metadataSettings.L2O_AmendSubTypeHeader__c;
            this.allContractsHeader = this.metadataSettings.L2O_AllContractsHeader__c;
            this.contractListNote = this.metadataSettings.L2O_ContractListNote__c;
            this.contractListNote2 = this.metadataSettings.L2O_ContractListNote2__c;
            this.setFlowOptions();
            this.handleShowAllContracts();
  
        }).catch(error => {
            alert('Please contact your System Admin with this error: ' + error.body.message); 
        });
    
    }
    setFlowOptions(){
        //To determine if recordId is account or contract
        
        if(this.objectApiName == 'Account'){
            this.flowOptions = [
                { label: 'Amend Assets & Subscriptions', flag: false, value: 'Both', helptext: this.metadataSettings.L2O_AmendBothOption__c,  },
                { label: 'Amend Standalone Assets Only', flag: false, value: 'AssetsOnly' , helptext: this.metadataSettings.L2O_AmendAssetsOnly__c, },
            ];
        }
        if(this.objectApiName == 'Contract'){
            this.contractId = this.recordId;
            this.setamendmentOptions();
            this.currentStep = 2;
            this.handleScreenShow();
            //LS: Disable Back button here
            
        }
        
    }
    setamendmentOptions() {

        if(this.selectedFlow == 'Both' || this.objectApiName == 'Contract'){
            this.amendmentOptions = [
                /*{ label: 'Expansion', flag: false, value: 'Expansion',helptext: this.metadataSettings.L2O_ExpansionOption__c  },*/
                { label: 'Change Order - Sales Ops Only', flag: false, value: 'Change Order' ,helptext: this.metadataSettings.L2O_ChangeOrderOption__c },
                { label: 'Contract Path Change', flag: false, value: 'Contract Path Change' ,helptext: this.metadataSettings.L2O_ContractPathChangeOption__c },
            ];
        }
        if(this.selectedFlow == 'AssetsOnly' && this.objectApiName == 'Account'){
            this.amendmentOptions = [
                /*{ label: 'Expansion', flag: false, value: 'Expansion' ,helptext: this.metadataSettings.L2O_ExpansionOption__c },*/
                { label: 'Change Order - Sales Ops Only', flag: false, value: 'Change Order',helptext: this.metadataSettings.L2O_ChangeOrderOption__c  },
            ];
        }
        
    }
    handleScreenShow(){
        this.error = false;
        if(this.currentStep == 1){
            this.showAmendFlowOptions = true;
            this.showAmendSubTypeOptions = false;
            this.showUpdateContact = false;
            this.showAllContracts = false;
        }
        if(this.currentStep == 2){
            this.showAmendFlowOptions = false;
            this.showAmendSubTypeOptions = true;
            this.showUpdateContact = false;
            this.showAllContracts = false;
        }
        if(this.currentStep == 3 && this.selectedFlow == 'AssetsOnly'){
            this.showAmendFlowOptions = false;
            this.showAmendSubTypeOptions = false;
            this.showUpdateContact = true;
            this.showAllContracts = false;
            this.updateAccountAmendOption();
        }
        if(this.currentStep == 3 && this.selectedFlow == 'Both'){
            this.showAmendFlowOptions = false;
            this.showAmendSubTypeOptions = false;
            this.showUpdateContact = false;
            this.showAllContracts = true;
        }
        if(this.currentStep == 3 && this.objectApiName == 'Contract'){
            this.showAmendFlowOptions = false;
            this.showAmendSubTypeOptions = false;
            this.showUpdateContact = false;
            this.showAllContracts = false;
            this.selectedContractId = this.contractId;
            this.updateContractAmendOption();
        }
        
        if(this.currentStep == 4 && this.selectedFlow == 'Both' ){
            this.handleNavigateToAmendCPQ();
        }
        if(this.currentStep == 4 && this.selectedFlow == 'AssetsOnly' ){
            this.handleNavigateToAmendCPQ();
        }
        
    }
    updateAccountAmendOption(){
        const fields = {};
        fields[ACCOUNT_ID_FIELD.fieldApiName] = this.recordId;
        fields[ACCOUNT_AMENDOPTION_FIELD.fieldApiName] = this.selectedAmendOption;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating selected amend option on Account record.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    updateContractAmendOption(){
    
        updateContract({ contractId: this.selectedContractId, subtype: this.selectedAmendOption })
        .then((result) => {
            if (result == 'Success') {
              
                let urlLink =  this.metadataSettings.L2O_CpqContractAmendURL__c + this.selectedContractId;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: urlLink
                    }
                });
              
            } else if (result == 'Error') {
             
                this.error = true;
                this.currentStep = 3;
                this.errorMessage = 'Error encountered while updating Contract. Please contact your System Admin.';
            }
        })
        .catch((error) => {
           
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating selected amend option on Contract record.',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    handleShowAllContracts(){
        
        getAllContracts({ accountId : this.recordId})
        .then((result) => {
            this.resultContracts = result;
            this.resultContracts = this.resultContracts.map(item => {
                return {
                    Name: 'Contract #'+ item.ContractNumber + ' - ['+ item.SBQQ__Opportunity__r.Name + '] - StartDate ['+ item.StartDate + '] - '+ item.ContractTerm + ' Month Term',
                    Id: item.Id,
                    QuoteId: item.SBQQ__Quote__c,
                    flag: false,
                };
            });
     
            if(this.resultContracts.length == 0){ 
                this.noValidContracts = true;
            }
        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'An error has occured while fetching contracts for this account.',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    handleActionSelection(event){
        this.selectedFlow = event.target.value;
        this.flowOptions.map(item => {
            if (item.value === this.selectedFlow) {
                item.flag = true;
            } else {
                item.flag = false;
            }
        });
        this.setamendmentOptions();
    }
    handleAmendOptionSelection(event){
        this.selectedAmendOption = event.target.value;
        this.amendmentOptions.map(item => {
            if (item.value === this.selectedAmendOption) {
                item.flag = true;
            } else {
                item.flag = false;
            }
        });
    }
    handleContractChange(event){
        this.selectedContractId = event.target.value;
        this.resultContracts.map(item => {
            if (item.Id === this.selectedContractId) {
                item.flag = true;
            } else {
                item.flag = false;
            }
        });
    }
    handleNavigateToAmendCPQ(){
        if(this.selectedFlow == 'Both'){
            this.updateContractAmendOption();
        }
        if(this.selectedFlow == 'AssetsOnly'){
            let urlLink =  this.metadataSettings.L2O_CpqAccountAmendURL__c + this.recordId;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: urlLink
                }
            });
        }
    }
    //Cancel to navigate back to Account
    handleCancel(){
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                //objectApiName: 'Account',
                actionName: 'view'
            }
        });
                      
    }
    //Next to progress through screens
    handleNext() {
        this.checkValidations();
        if(this.screenValidationError == false){
            this.currentStep +=1;
            this.handleScreenShow();
        
        }
    }
    checkValidations(){
        if(this.showAmendFlowOptions == true && (this.selectedFlow == null || this.selectedFlow == undefined)){
          
            this.screenValidationError = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select action to proceed.',
                    variant: 'error',
                    mode: 'sticky',
                })
            );
        }
        else if(this.showAmendSubTypeOptions == true && (this.selectedAmendOption == null || this.selectedAmendOption == undefined)){
           
            this.screenValidationError = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Opportunity Sub Type to proceed.',
                    variant: 'error',
                    mode: 'sticky',
                })
            );
        }
        else if(this.showAllContracts == true && (this.selectedContractId == null || this.selectedContractId == undefined)){
            this.screenValidationError = true;
            if(this.noValidContracts == true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There are no Valid Activated Contracts for this Account.',
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select Contract to proceed.',
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            }
            
        }
        else if(this.error == true){
            this.screenValidationError = true;
        }
        else{
            this.screenValidationError = false;
        }
        
    }
    //Back to previous screen
    handleBack() {
        this.currentStep -=1;
        this.handleScreenShow();
    }
    //Disable Next if option not selected
    get disableNext(){
        if(this.currentStep == 1 && this.selectedFlow == null){
            return true;
        }
        if(this.currentStep == 1 && this.selectedFlow != null){
            return false;
        }
    
    }
    //Disable Back if amending from Contract
    get disableBack(){
        if(this.objectApiName == 'Contract'){
            return true;
        }
        if(this.objectApiName == 'Account'){
            return false;
        }
    
    }
    
 }