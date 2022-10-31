/* eslint-disable no-console */
import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getHealthScores from '@salesforce/apex/AccountHealthScoreController.getHealthScores';
import ACC_OVERALL_ACCOUNT_SCORE_FIELD from '@salesforce/schema/Account__c.Overall_Account_Score__c';
import ACC_OVERALL_DM_SCORE_FIELD from '@salesforce/schema/Account__c.Overall_DM_Score__c';
import ACC_OVERALL_HTN_SCORE_FIELD from '@salesforce/schema/Account__c.Overall_HTN_Score__c';

export default class AccountHealthScoreDetail extends LightningElement {
    @api recordId;
    @track wiredHelathScores;
    @track accountHealthScores = [];
    @track dmHealthScores = [];
    @track htnHealthScores = [];
    @track resultMap =[];
    @track map2 =[];
    @track map3 = [];
    errors;
    @track isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields:[ACC_OVERALL_ACCOUNT_SCORE_FIELD, ACC_OVERALL_DM_SCORE_FIELD, ACC_OVERALL_HTN_SCORE_FIELD]})
    account;

    @wire(getHealthScores, {accountId: '$recordId'})
    wiredPrograms(value) {
        this.wiredHelathScores = value;
        const {data, error} = value;
        if(value.data){
            this.allHelathScores = data;
            this.accountHealthScores = data.accountScoreMap;
            this.map2 = data.dmScoreMap;
            this.map3 = data.htnScoreMap;
            this.errors = undefined;
            this.toggleSpinner();
        } 
        if (this.accountHealthScores) {
            for(let key in this.accountHealthScores) {
                if (this.accountHealthScores.hasOwnProperty(key)) {
                    this.resultMap.push({value:this.accountHealthScores[key], key:key});
                }
            }
        }

        if (this.map2) {
            for(let key in this.map2) {
                if (this.map2.hasOwnProperty(key)) { 
                   this.dmHealthScores.push({value:this.map2[key], key:key});
                }
            }
        }

        if (this.map3) {
            for(let key in this.map3) {
                if (this.map3.hasOwnProperty(key)) { 
                   this.htnHealthScores.push({value:this.map3[key], key:key});
                }
            }
        }

        if (value.error) {
            this.errors = error;
        }
        
    }

    get accountColor() {
        if (this.account.data.fields.Overall_Account_Score__c.value >= 75) {
            return 'green'
        }
        else if (this.account.data.fields.Overall_Account_Score__c.value >= 60 && this.account.data.fields.Overall_Account_Score__c.value < 75) {
            return 'yellow'
        }
        return 'red';
    }

    get programDMColor() {
        if (this.account.data.fields.Overall_DM_Score__c.value >= 75) {
            return 'green'
        }
        else if (this.account.data.fields.Overall_DM_Score__c.value >= 60 && this.account.data.fields.Overall_DM_Score__c.value < 75) {
            return 'yellow'
        }
        return 'red';
    }

    get programHTNColor() {
        if (this.account.data.fields.Overall_HTN_Score__c.value >= 75) {
            return 'green'
        }
        else if (this.account.data.fields.Overall_HTN_Score__c.value >= 60 && this.account.data.fields.Overall_HTN_Score__c.value < 75) {
            return 'yellow'
        }
        return 'red';
    }
    
    toggleSpinner() {
        this.isLoaded = !this.isLoaded;
    }
}