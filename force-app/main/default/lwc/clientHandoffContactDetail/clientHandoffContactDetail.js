import { LightningElement, api, wire } from 'lwc';
import getAccountContactRelationships from '@salesforce/apex/ClientHandoffSummaryController.getAccountContactRelationships';

export default class ClientHandoffContactDetail extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isLoaded = false;
    accountContactRelationships;
    error;
    finalAccountContactsRelationships;

    @wire(getAccountContactRelationships, {clientHandoffId:'$recordId'})
    wiredAccountContactRelationships({ error, data }) {
        if (data) {
            this.finalAccountContactsRelationships = data.map(function(el) {
                var ac = Object.assign({}, el);
                ac.recordUrl = '/lightning/r/Contact/'+ac.ContactId+'/view';
                ac.inculdeInCallsAndEmails = (ac.Include_in_Client_Strategy_Calls_Emails__c === true) ? 'Yes' : 'No';
                ac.initials = ((ac.Contact.FirstName) ? ac.Contact.FirstName.charAt(0) : '') +ac.Contact.LastName.charAt(0);
                ac.rolesArray = ac.Roles.split(';');
                ac.isExecutiveSponsor = ac.rolesArray.includes("Executive Sponsor");
                return ac;
              })
            this.accountContactRelationships = data;
            this.error = undefined;
            this.toggleSpinner();
        } else if (error) {
            this.error = error;
            this.accountContactRelationships = undefined;
            this.toggleSpinner();
        }
    }

    toggleSpinner() {
        this.isLoaded = !this.isLoaded;
    }
}