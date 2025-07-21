import { LightningElement, track, api, wire} from "lwc";
 import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
 import { updateRecord, getRecord, getFieldValue} from 'lightning/uiRecordApi';
 import { ShowToastEvent} from 'lightning/platformShowToastEvent';
 import { refreshApex } from '@salesforce/apex';
 
 /* -- Importing Apex methods -- */
 import getMetaDataSettings from '@salesforce/apex/L2O_ContractPathController.getMetaDataSettings'; 
 import getValidPricingModel from '@salesforce/apex/L2O_ContractPathController.getFilteredPricingModel'; 
 import findTeladocAccount from '@salesforce/apex/L2O_ContractPathController.findTeladocAccount';
 
 /* -- Importing Custom Labels --*/
 import Teladoc_Account from '@salesforce/label/c.L2O_TD_Teladoc_Account';
 

 /* -- Importing Obj schema & fields --*/  
 import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
 import ID_FIELD from '@salesforce/schema/Opportunity.Id';
 import DIRECT_CONTRACT from '@salesforce/schema/Opportunity.L2O_DirectTDHContract__c';
 import DIRECT_EMP_BUSINESS from '@salesforce/schema/Opportunity.L2O_DirectEmployerBusiness__c';
 import CONTRACT_PATH from '@salesforce/schema/Opportunity.L2O_Contract_Path__c';
 import CONTRACT_PATH_SUBTYPE from '@salesforce/schema/Opportunity.L2O_Contract_Path_Sub_type__c';
 import PRICING_MODEL from '@salesforce/schema/Opportunity.L2O_Pricing_Model__c';
 import LINE_OF_BUSINESS from '@salesforce/schema/Opportunity.L2O_Client_Line_of_Business__c';
 import SUB_TYPE from '@salesforce/schema/Opportunity.L2O_Subtype__c';
 import CONTRACTING_ACCOUNT from '@salesforce/schema/Opportunity.L2O_Contracting_Account__c';
 import PARENT_ACCOUNT from '@salesforce/schema/Opportunity.AccountId';
 
 const fields  = [ID_FIELD,DIRECT_CONTRACT,DIRECT_EMP_BUSINESS,
                CONTRACT_PATH,CONTRACT_PATH_SUBTYPE,
                PRICING_MODEL,LINE_OF_BUSINESS,SUB_TYPE,
                CONTRACTING_ACCOUNT,PARENT_ACCOUNT];
 const DELAY = 300; // delay apex callout timing in miliseconds 


 export default class ContractPath extends LightningElement {
     @api recordId;
     @api error;
     @track accountId;

     //flags for show hide sections & button on UI
     boolVisible = false;
     boolUpdateVisible = true;
     isLobNull = true; //To display the Client Line of Business conditionally
     clickedButtonLabel = 'Update Contract Path';
     isLoaded = true;
     isPricingModelReq = true;
     teladocAccountId = '';
   
     //flags to show hide fields on UI
     showContractPath = false;
     showPricingModel = false;
     showLOB = false;
     showContractingAccount = false;
     isButtonDisabled = true;
     
     //contains the values to be updated
     directcontVal = '';
     employerBusinessVal = '';
     contPathVal = '';
     contPathSubTypeVal = '';
     pricingModelVal = null;
     lobVal = null;
     accountVal;
     @track selectedContractAccountId;
     parentAccount;
     validPricingModelOptionSet; //144806
     
     //dynamic options
     DirectEmpBusinessOptions = [];
     contractPathOptions = [];
     contractPathFieldData;
     @track pricingModelOptions = [];
     pricingModelFieldData;
     lobOptions = [];
     lobFieldData;
     
     //opp data
     oppSubType = '';

     //Dynamic options from Metadata
     metadataSettings = [];
     options_DirectContYes_EmpBsnYes = [];
     options_DirectContYes_EmpBsnNo = [];
     options_DirectContNo_EmpBsnNo = [];

     //Get Picklist values
     directContract;

     //LWC ref
     errorMsg = '';

     //check below fields
     //contractPath;
     stageName;


    @api objectName;
    @api fieldName;
    @api value;
    @api iconName; //= 'standard:opportunity';
    @api label; //= 'custom lookup label: Parent Opportunity';
    @api placeholder; //= 'search...'; 
    @api className;
    @api required = false;
    delayTimeout;

    isSearchLoading = false; // to control loading spinner      
    
    /* Expose schema objects/fields to the template. */
    oppObject = OPPORTUNITY_OBJECT;

    /* Get Opp record data */
    @wire(getRecord, { recordId: '$recordId',fields})
    wiredOpportunity({data,error}){
        if(data){
            this.oppSubType = getFieldValue(data, SUB_TYPE);
            this.accountVal = getFieldValue(data, CONTRACTING_ACCOUNT);
            this.contPathVal = getFieldValue(data, CONTRACT_PATH);
            this.parentAccount = getFieldValue(data, PARENT_ACCOUNT);
            this.lobVal = getFieldValue(data, LINE_OF_BUSINESS);
            if(this.lobVal != null || this.lobVal == ''){
                this.isLobNull=false;
            }else{
                this.isLobNull=true;
            }
        }
        if(error){
            this.error = error;
        }
    }
    //record;
 
    //Default Opportunity Object
    @wire(getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT})
    opportunityObjectdata;

    getValidPricingModelOptions(){
        //Default Contracting Account to Pricing Model mappings //144806
        getValidPricingModel({ contractingAccId: this.selectedContractAccountId})
        .then((result) => {
            if(result != null){
                this.validPricingModelOptionSet = result;
                //144806 To further filter options based on custom metadata.
                this.showPricingModel = false;
                this.pricingModelOptions = this.pricingModelOptions.filter(opt => this.validPricingModelOptionSet.includes(opt.value)); 
                this.showPricingModel = true;
            }
            else{
                //144806 To revert back the filter options. assigning valid controlled values for pricing model as per Contract path
                this.showPricingModel = false;
                let key = this.pricingModelFieldData.controllerValues[this.contPathVal];
                
                this.pricingModelOptions = this.pricingModelFieldData.values.filter(opt => opt.validFor.includes(key));
                this.showPricingModel = true;
            }
            
        }).catch((error) => {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error fetching valid pricing model options for selected Contract Account.',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            
        });

    }
    
    //Start: Fetch the picklist values for each picklist field
    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: DIRECT_CONTRACT
    })
    directContract;

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: DIRECT_EMP_BUSINESS
    })
    DirectEmpBusinesses({
        data,
        error
    }) {
        if (data) {
            this.DirectEmpBusiness = data;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: CONTRACT_PATH
    })
    ContractPaths({
        data,
        error
    }) {
        if (data) this.contractPathFieldData = data;
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: PRICING_MODEL
    })
    PricingModels({
        data,
        error
    }) {
        if (data) this.pricingModelFieldData = data;
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityObjectdata.data.defaultRecordTypeId',
        fieldApiName: LINE_OF_BUSINESS
    })
    LOBs({
        data,
        error
    }) {
        if (data) this.lobFieldData = data;
    }
    //End: Fetch the picklist values for each picklist field

    //Fetch Metadata settings
    connectedCallback() {

        /* Dynamic Text from custom metadata */
        getMetaDataSettings()
        .then(result => {

            this.metadataSettings = result[0];
            this.options_DirectContYes_EmpBsnYes = this.metadataSettings.L2O_DirectContYes_EmpBsnYes__c;
            this.options_DirectContYes_EmpBsnNo = this.metadataSettings.L2O_DirectContYes_EmpBsnNo__c;
            this.options_DirectContNo_EmpBsnNo = this.metadataSettings.L2O_DirectContNo_EmpBsnNo__c;
                       
        }).catch((error) => {
            let errorMsg = error.body.message; // passing error here
            this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
        });

        /* Fetch Teladoc Health Account ID */
        findTeladocAccount()
        .then(result => {
            this.teladocAccountId = result;
            console.log('check the teladoc health inc account id'+this.teladocAccountId);
            
        }).catch((error) => {
            let errorMsg = error.body.message; // passing error here
            this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
        });
    
    }

     /**
     * @description Update contract button click functionality
     * @param event field name and value to set
     */
    handleClick(event) {
        
        const label = event.target.label;
        if (label === 'Update Contract Path') {
            this.clickedButtonLabel = 'Cancel';
            this.boolVisible = true;
            this.boolUpdateVisible = false;
            this.directcontVal = '';
            this.employerBusinessVal = '';
            this.accountVal = '';
        } else if (label === 'Cancel') {
            this.clickedButtonLabel = 'Update Contract Path';
            this.boolVisible = false;
            this.boolUpdateVisible = true;

            //reset all the Flags & Values
            this.resetFlags();

            this.accountVal = '';
            this.contPathVal = '';
            this.contPathSubTypeVal = '';
            this.pricingModelVal = null;
            this.lobVal = null;
            
        }
       
    }

    handleDirectcontractChange(event) {

        this.directcontVal = event.target.value;
        let key = this.DirectEmpBusiness.controllerValues[event.target.value];
        this.DirectEmpBusinessOptions = this.DirectEmpBusiness.values.filter(opt => opt.validFor.includes(key));

        //reset all the Flags & Values
        this.resetFlags();

        if (this.directcontVal == 'NO') {
            this.accountVal = '';
            this.showContractingAccount = true;

            //reset values
            this.employerBusinessVal = '';

        } else if (this.directcontVal == 'YES') {
            this.showContractingAccount = false;
            this.accountVal = this.teladocAccountId;
            //reset values
            this.employerBusinessVal = '';
        }
        
    }

    handleDirectEmployerBusinessChange(event) {
        this.employerBusinessVal = event.target.value;
        this.showContractPath = false;

        //reset the values
        this.pricingModelVal = null;
        this.lobVal = null;
        
        if (this.employerBusinessVal == 'NO') {
            //reset value
            this.contPathVal = '';
            this.showContractPath = true;
            if(this.directcontVal == 'YES'){
                this.contractPathOptions = this.contractPathFieldData.values.filter(opt => this.options_DirectContYes_EmpBsnNo.includes(opt.value));
            }
            else if(this.directcontVal == 'NO'){
                this.contractPathOptions = this.contractPathFieldData.values.filter(opt => this.options_DirectContNo_EmpBsnNo.includes(opt.value));
            }
            
            this.isButtonDisabled = true; //Enable the Save Button
        } 
        else if(this.directcontVal == 'YES' && this.employerBusinessVal == 'YES'){
            this.contPathVal = 'Direct';
            this.contPathSubTypeVal = 'None';
            this.showContractPath = false;
            this.isButtonDisabled = false; //Enable the Save Button
        }
        else if(this.employerBusinessVal != null){
            this.isButtonDisabled = false; //Enable the Save Button
        }
    }

    handleAccountChange(event) {
        this.accountVal = event.target.value;
        this.accountId = event.target.value;
        this.selectedContractAccountId = this.accountId;

        //get the valid pricing model options as per contracting acc name
        if(this.selectedContractAccountId!= null && this.selectedContractAccountId!= undefined &&
            this.directcontVal == 'NO' && this.employerBusinessVal == 'NO' && (this.contPathVal == 'US Health Plan' || this.contPathVal == 'Intl Insurer')){
            
            this.getValidPricingModelOptions();
        }

    }


    contractPathChange(event) {
       
        this.isButtonDisabled = true; //Disable the Save Button
        this.contPathVal = event.target.value;

        //reset the flags
        this.showPricingModel = false;
        this.showLOB = false;

        //reset the values
        this.pricingModelVal = null;
        this.lobVal = null;
        
        if(this.contPathVal == 'US Health Plan') {
            this.isButtonDisabled = true; //Disable the Save Button
            if(this.directcontVal == 'NO'){
                this.showLOB = true;
                this.lobOptions = this.lobFieldData.values;
                this.showPricingModel = true;
                let key = this.pricingModelFieldData.controllerValues[this.contPathVal];
                this.pricingModelOptions = this.pricingModelFieldData.values.filter(opt => opt.validFor.includes(key));
                this.isPricingModelReq = false;
                this.contPathSubTypeVal = 'Contracted Pricing';
            }
            else if(this.directcontVal == 'YES'){
                this.showLOB = true;
                this.showPricingModel = false;
                this.lobOptions = this.lobFieldData.values;
                this.contPathSubTypeVal = 'New Pricing';
            }
            
        }
        
        else if(this.contPathVal == 'TPA/Reseller'){
            if(this.directcontVal == 'NO'){
                this.showLOB = false;
                this.showPricingModel = true;
                let key = this.pricingModelFieldData.controllerValues[this.contPathVal];
                this.pricingModelOptions = this.pricingModelFieldData.values.filter(opt => opt.validFor.includes(key));
                this.isPricingModelReq = false;
                this.contPathSubTypeVal = 'None';
            }
            else if(this.directcontVal == 'YES'){
                this.showLOB = false;
                this.showPricingModel = false;
                this.contPathSubTypeVal = 'None';                
            }
            this.isButtonDisabled = false; //Enable the Save Button
        }
        else if(this.contPathVal == 'Intl Insurer'){
            if(this.directcontVal == 'NO'){
                this.contPathSubTypeVal = 'Contracted Pricing';
                this.showLOB = false;
                this.showPricingModel = true;
                let key = this.pricingModelFieldData.controllerValues[this.contPathVal];
                this.pricingModelOptions = this.pricingModelFieldData.values.filter(opt => opt.validFor.includes(key));
                this.isPricingModelReq = false;
            }
            else if(this.directcontVal == 'YES'){
                this.showLOB = false;
                this.showPricingModel = false;
                this.contPathSubTypeVal = 'New Pricing';                
            }
            this.isButtonDisabled = false; //Enable the Save Button
        }
        else if(this.contPathVal == 'Hospital & Health Systems'){
            this.contPathSubTypeVal = 'None';
            this.showLOB = false;
            this.showPricingModel = false;
            this.isButtonDisabled = false; //Enable the Save Button
        }
        else {
            //Hide fields
            this.showPricingModel = false;
            this.showLOB = false;
        }
        this.selectedContractAccountId = this.accountId;

        //get the valid pricing model options as per contracting acc name
        if(this.selectedContractAccountId!= null && this.selectedContractAccountId!= undefined &&
            this.directcontVal == 'NO' && this.employerBusinessVal == 'NO' && (this.contPathVal == 'US Health Plan' || this.contPathVal == 'Intl Insurer')){
            
            this.getValidPricingModelOptions();
        }

    }

    pricingModelChange(event) {
        this.pricingModelVal = event.target.value;
        this.isButtonDisabled = false; //Disable the Save Button 
    }

    lineOfBusinessChange(event) {
        this.lobVal = event.target.value;
        this.isButtonDisabled = true; //Disable the Save Button

        if(this.lobVal != null){
            this.isButtonDisabled = false; //Enable the Save Button
        }
    }

    async saveContractPath() {  

        if ( (this.directcontVal == null || this.directcontVal == '' || this.employerBusinessVal == '' || this.employerBusinessVal == '')) {
            this.handleToastEvents(' Direct TDH Contract & Direct Employer Business is required.', 'Error', 'error', 'dismissable');
        }  
        else if ((this.directcontVal != '') && (this.accountVal == '' || this.accountVal == null)) {
            this.handleToastEvents(' Contracting Account is required if this is an indirect TDH Contract.', 'Error', 'error', 'dismissable');
        }
        else if (this.directcontVal == 'NO' && (this.accountVal == this.teladocAccountId || this.accountVal == this.parentAccount)) {
            this.handleToastEvents(' Contracting Account cannot be Teladoc Health / current Opportunity Parent Account. ', 'Error', 'error', 'dismissable');
        }
           
        //Ref TDUAT Validation errors
        else if (this.errorMsg != '') {
            this.handleToastEvents(this.errorMsg, 'Error', 'error', 'dismissable');
        }  else {

            this.isLoaded = !this.isLoaded;

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[DIRECT_CONTRACT.fieldApiName] = this.directcontVal;
            fields[DIRECT_EMP_BUSINESS.fieldApiName] = this.employerBusinessVal;
            fields[CONTRACT_PATH.fieldApiName] = this.contPathVal;
            fields[CONTRACT_PATH_SUBTYPE.fieldApiName] = this.contPathSubTypeVal;
            fields[PRICING_MODEL.fieldApiName] = this.pricingModelVal;
            fields[LINE_OF_BUSINESS.fieldApiName] = this.lobVal;
            fields[CONTRACTING_ACCOUNT.fieldApiName] = this.accountVal;
            
            const recordInput = { fields };

            updateRecord(recordInput)
            
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
                    refreshApex(this.wiredOpportunity);
                    eval("$A.get('e.force:refreshView').fire();");

                    this.resetFlags();

                })
                .catch(error => {

                    let errors = this.reduceErrors(error); // passing error here
                    let errorMsg = errors.join('; ');

                    this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
                    this.clickedButtonLabel = 'Update Contract Path';
                    
                    //restart the flow
                    this.boolUpdateVisible = true;
                    this.boolVisible = false;
                    this.resetFlags();
                    
                    this.isLoaded = !this.isLoaded;
                    
                });
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

    reduceErrors(errors) {

        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }

    resetFlags(){
        //To reset the flags to show the fields & Save button
        this.showContractPath = false;
        this.showPricingModel = false;
        this.showLOB = false;
        this.showContractingAccount = false;
        this.isButtonDisabled = true;
    }
 }