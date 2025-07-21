/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import papaparse from "@salesforce/resourceUrl/papaparse";
import submitData from "@salesforce/apex/UmrUploadService.submitData";
import umr_E2E from "@salesforce/apex/UmrUploadService.umr_E2E";
import { loadScript } from "lightning/platformResourceLoader";

export default class CustomFileUploader2 extends LightningElement {
  @track employeeFileName = "";
  @track planFileName = "";
  @track defaultFileName = "";
  @track UploadFile = "Upload File";
  @track isTrue = false;
  @track employee;
  @track plan;
  @track newEmployee =[];
  @track newPlan =[];
  @track employeeFilesUploaded;
  @track planFilesUploaded;
  @track defaultFilesUploaded;
  @track file;  
  @track renderButton = false;


  renderedCallback() {
    Promise.all([loadScript(this, papaparse)])
      .then(() => {
        this.error = undefined;
        // Call back function if scripts loaded successfully
      })
      .catch(error => {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: error.message,
            variant: "error"
          })
        );
      });
  }

  runBatch(){
    umr_E2E()
      .then(response => {
        if (response) {
            console.log(response)
            alert(response);
            /*
            const toastEvent = new ShowToastEvent({
              title: response,
              variant: "success",
              mode: "dismissable"
            });
            this.dispatchEvent(toastEvent);  
            */
        }
      })
      .catch(error => {
          alert("Please Contact Your Salesforce Administrator:  " + error)     
          /* 
          const toastEvent = new ShowToastEvent({
            title: "Something Went Wrong",
            message: "Please Contact Your Salesforce Administrator:  " + error,
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(toastEvent); 
          */           
      });
  }
  
  handleEmployeeFilesChange(event){
    if (event.target.files.length > 0) {
      this.employeeFilesUploaded = event.target.files[0];
      this.employeeFileName = event.target.files[0].name;  
    }
    if (this.employeeFilesUploaded !== undefined &&  this.planFilesUploaded !== undefined && this.defaultFilesUploaded !== undefined) {
      this.renderButton = true;
    }
  }

  handlePlanFilesChange(event) {
    if (event.target.files.length > 0) {
      this.planFilesUploaded = event.target.files[0];
      this.planFileName = event.target.files[0].name;  
    }
    if (this.employeeFilesUploaded !== undefined &&  this.planFilesUploaded !== undefined && this.defaultFilesUploaded !== undefined) {
      this.renderButton = true;
    }
  }

  handleDefaultFilesChange(event){
    if (event.target.files.length > 0) {
      this.defaultFilesUploaded = event.target.files[0];
      this.defaultFileName = event.target.files[0].name;  
    }
    if (this.employeeFilesUploaded !== undefined &&  this.planFilesUploaded !== undefined && this.defaultFilesUploaded !== undefined) {
      this.renderButton = true;
    }
  }  

  mergeFile() {
    var csvFiles =  [this.employeeFilesUploaded, this.planFilesUploaded, this.defaultFilesUploaded]
    Promise.all(//pass array of promises to Promise.all
      csvFiles//you have an array of csvFiles
      .map(//map csvFiles to promises created with parse
        csv=>
          new Promise(//create one promise
            (resolve,reject)=>
            Papa.parse(csv, {
              header: true,
              complete: resolve,//resolve the promise when complete
              error:reject//reject the promise if there is an error
            })
          )
      )
    )
    .then(
      function (results) {
        let isAcct = false;
        let isGroup = false;
        // result for account info csv parsing data here
        let employeeResult = []
        employeeResult = results[0].data;
        let newList = [] ;
        for (let x = 0; x < employeeResult.length; x++) {
          let upperCase = {};
          for (let i in employeeResult[x]) {
              upperCase[i.toUpperCase()] = employeeResult[x][i];
          }
          newList.push(upperCase);
        } 
        let employee = newList;
        if (employee[0].hasOwnProperty("UMR GROUP #")){
          for ( let i = 0; i < employee.length; i++) {           
            if (employee[i]["UMR GROUP #"] == null || employee[i]["UMR GROUP #"] == ""){
                employee.splice(i, 1);
            }
          } 
          console.log(employee);
          isAcct = true;
        } else {
          alert('This is not the correct Account Info CSV File, Please refresh your page and retry');
        }

        // result for group info csv parsing data here
        let planResult = []
        planResult = results[1].data;
        newList = [] ;
        for (let x = 0; x < planResult.length; x++) {
        let upperCase = {};
          for (let i in planResult[x]) {
              upperCase[i.toUpperCase()] = planResult[x][i];
          }
          newList.push(upperCase);
        } 
        let plan = newList;
        if (plan[0].hasOwnProperty("UMR_GROUP__")){
          for ( let i = 0; i < plan.length; i++) {          
            if (plan[i]["UMR_GROUP__"] == null || plan[i]["UMR_GROUP__"] == ""){
              plan.splice(i, 1);
            }
          }  
          console.log(plan);
          isGroup = true;
        } else {

          alert('This is not the correct Group Info CSV File, Please refresh your page and retry')
        }

        let defaultResult = []
        defaultResult = results[2].data; 
        console.log(JSON.stringify(defaultResult))  
        newList = [] ;
        for (let x = 0; x < defaultResult.length; x++) {
        let upperCase = {};
          for (let i in defaultResult[x]) {
              upperCase[i.toUpperCase()] = defaultResult[x][i];
          }
          newList.push(upperCase);
        } 
        let defaultFile = newList[0];
        console.log('default ' + defaultFile)
        let defaultFileJson = JSON.stringify(defaultFile);
        console.log(defaultFileJson);
      
        if( isGroup && isAcct){
          let agcpiList = [];
          for ( let i = 0; i < employee.length; i++) {  
            for ( let x = 0; x < plan.length; x++) {  
                if (employee[i]["UMR GROUP #"] == plan[x]["UMR_GROUP__"] ) {
                        let acgpiData = '[{"groupInfo":' +  JSON.stringify(plan[x]) + ',"groupId": ' + JSON.stringify(plan[x]["LEGACY_GROUP_ID"]) + ',"accountInfo":' 
                        + JSON.stringify(employee[i]) + '}]';
                        agcpiList.push(acgpiData);
                }
            }
          }
          console.log(agcpiList);
          
          for ( let i = 0; i < agcpiList.length; i++) { 
            submitData({ incomingData: agcpiList[i], fieldDefaultData: defaultFileJson })
            .then(response => {
              if (response) {
                console.log( 'Total record: ' + agcpiList.length + ' | Record Id Number: ' + (i))
                if (i + 1 == agcpiList.length ) {
                  alert("Upload Completed")
                }
              }
            })
            .catch(error => {
              console.error("there is error: " + error);
              alert('There is error, Please Contact Your Salesforce Administrator: ' + error)
            });
          }  
        }
      }    
    )
    .catch(//log the error
      err=> {
        alert("Please Contact Your Salesforce Administrator:  " + err);
        console.warn("Something went wrong:",err)
        alert()
      }
    )
    this.renderButton = false;
  }
}