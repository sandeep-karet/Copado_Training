import { LightningElement, api, track} from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
export default class customFileUploadForSurveys extends LightningElement {
    @api myRecordId;
    @api label;
    @api fileHeader;
    @api acceptedFormats;
    @api allowMultipleFiles;

    @api
    get uploadedFiles() {
        return this.finalUploadedFiles;
    }

    set uploadedFiles(uploadedFiles = []) {
        this.finalUploadedFiles = [...uploadedFiles];
    }

    @track finalUploadedFiles = [];
    error;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        for (let i = 0; i < uploadedFiles.length; i++) {
            this.finalUploadedFiles.push(uploadedFiles[i].name);
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('uploadedFiles', this.finalUploadedFiles);
        this.dispatchEvent(attributeChangeEvent);
    }

    get filesExist(){
        return this.finalUploadedFiles.length > 0 ? true : false;
    }
}