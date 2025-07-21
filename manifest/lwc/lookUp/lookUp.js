import lookUp from '@salesforce/apex/L2O_LookupController.lookUp';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';

const ACCOUNT_FIELDS = ["Account.Name"];
const CONTACT_FIELDS = ["Contact.Name"];


export default class Lookup extends LightningElement {

    @api valueId;
    @api objName;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api filter = '';
    @api showLabel = false;
    @api uniqueKey;
    objLabelName;

    searchTerm;
    @track valueObj;
    href;
    @track options; //lookup values
    @track isValue;
    @track blurTimeout;

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    get fields() {
        if (this.objName === "Account") {
            return ACCOUNT_FIELDS;
        } else if(this.objName === "Contact") {
            return CONTACT_FIELDS;
        }
    }

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.options = this.record;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    //To get preselected or selected record
    @wire(getRecord, { recordId: '$valueId', fields: "$fields" }) 
    wiredOptions({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.valueObj = this.record.fields.Name.value;
            this.isValue = true;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    handleClick() {
       
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    inblur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
       
        let ele = event.currentTarget;
        let selectedId = ele.dataset.id;
       
        //sending selected value to parent and inreturn parent sends the value to @api valueId
        let key = this.uniqueKey;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key },
        });
        this.dispatchEvent(valueSelectedEvent);

        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    handleRemovePill() {
       
        this.isValue = false;
        let selectedId = '';
        let key = this.uniqueKey;

        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key },
        });
        this.dispatchEvent(valueSelectedEvent);
    }
}