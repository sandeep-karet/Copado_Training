import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPrograms from '@salesforce/apex/ClientHandoffSummaryController.getPrograms';
import PROGRAM_INITIAL_LAUNCH_DATE_FIELD from '@salesforce/schema/Contract__c.Actual_Launch_Date__c';
import PROGRAM_INITIAL_MEMBER_RECRUITMENT_FIELD from '@salesforce/schema/Contract__c.Member_Recruitment_Began__c';
import PROGRAM_INITIAL_TARGETED_MARKETING_FIELD from '@salesforce/schema/Contract__c.Initial_Targeted_Marketing__c';
import PROGRAM_CONTRACT_TERM_FIELD from '@salesforce/schema/Contract__c.Contract_Term__c';
import PROGRAM_RENEWAL_NOTICE_DATE_FIELD from '@salesforce/schema/Contract__c.ContractRenewalDate__c';
import PROGRAM_PARTICIPANTS_FIELD from '@salesforce/schema/Contract__c.Participants__c';
import PROGRAM_IS_THERE_LAPSE_CRITERIA_FIELD from '@salesforce/schema/Contract__c.Is_there_Lapse_Criteria__c';
import PROGRAM_LAPSE_CRITERIA_FIELD from '@salesforce/schema/Contract__c.Lapse_Criteria__c';
import PROGRAM_LAPSED_CRITERIA_SOURCE_FIELD from '@salesforce/schema/Contract__c.Lapsed_Criteria_Source__c';
import PROGRAM_CONSECUTIVE_INACTIVE_MONTHS_TO_LAPSED_FIELD from '@salesforce/schema/Contract__c.Consecutive_Inactive_Months_to_Lapsed__c';
import PROGRAM_MINIMUM_NUMBER_OF_PARTICIPANTS_FIELD from '@salesforce/schema/Contract__c.Minimum_Number_of_Participants__c';
import PROGRAM_PERFORMANCE_GUARANTEES_FIELD from '@salesforce/schema/Contract__c.Performance_Guarantees__c';

export default class ClientHandoffProgramDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api isLoaded = false;
    programs;
    error;
    finalPrograms;

    progarmFields = [PROGRAM_INITIAL_LAUNCH_DATE_FIELD,
        PROGRAM_INITIAL_MEMBER_RECRUITMENT_FIELD,
        PROGRAM_INITIAL_TARGETED_MARKETING_FIELD,
        PROGRAM_CONTRACT_TERM_FIELD,
        PROGRAM_RENEWAL_NOTICE_DATE_FIELD,
        PROGRAM_PARTICIPANTS_FIELD,
        PROGRAM_IS_THERE_LAPSE_CRITERIA_FIELD,
        PROGRAM_LAPSE_CRITERIA_FIELD,
        PROGRAM_LAPSED_CRITERIA_SOURCE_FIELD,
        PROGRAM_CONSECUTIVE_INACTIVE_MONTHS_TO_LAPSED_FIELD,
        PROGRAM_MINIMUM_NUMBER_OF_PARTICIPANTS_FIELD,
        PROGRAM_PERFORMANCE_GUARANTEES_FIELD];

    @wire(getPrograms, {clientHandoffId:'$recordId'})
    wiredPrograms({ error, data }) {
        if (data) {
            this.finalPrograms = data.map(function(el) {
                var o = Object.assign({}, el);
                switch (o.Program_Name__c) {
                    case 'Diabetes':
                        o.isDMProgram = true;
                        break;
                    case 'Hypertension':
                        o.isHTNProgram = true;
                        break;
                    case 'Prediabetes':
                        o.isDPPProgram = true;
                        break;
                    case 'Weight Management':
                        o.isWMProgram = true;
                        break;
                    case 'Behavioral Health':
                        o.isBHProgram = true;
                        break;
                    default:
                }
                return o;
              })
            this.programs = data;
            this.error = undefined;
            this.toggleSpinner();
        } else if (error) {
            this.error = error;
            this.programs = undefined;
            this.toggleSpinner();
        }
    }

    navigateToRecordViewPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Contract__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    toggleSpinner() {
        this.isLoaded = !this.isLoaded;
    }
}