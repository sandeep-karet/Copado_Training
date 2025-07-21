import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchLogoDoc from "@salesforce/apex/MemberGroupV2Controller.searchLogoDoc";
import getRecordInfo from "@salesforce/apex/MemberGroupV2Controller.getRecordInfo";
import createMbrGroup from "@salesforce/apex/MemberGroupCloneController.createMbrGroup";


export default class MemberGroupCloneLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track actDate = null;
    @track renderLogoT = true;
    @track renderLogo1 = true;
    @track renderLogo3 = true;
    @track renderLogo4 = true;
    @track renderLogoA1 = true;
    @track renderLogoA2 = true;
    @track Logo__c;
    @track Logo1__c;
    @track Logo3__c;
    @track Logo4__c;
    @track AltLogo1__c;
    @track AltLogo2__c;
    @track Logo1_ID;
    @track isLoading = false;
  
    connectedCallback() {
      this.isLoading = true;
      this.getRecordInfo();
    }

  
    getRecordInfo() {
      if (this.recordId) {
        getRecordInfo({ objId: this.recordId })
        .then(response => {
          this.isLoading = false;
          if (response) {
            if (!response.logo) {
              this.renderLogoT = false;
            }
            if (!response.logo1) {
              this.renderLogo1 = false;
            }
            if (!response.logo3) {
              this.renderLogo3 = false;
            }
            if (!response.logo4) {
              this.renderLogo4 = false;
            }
            if (!response.altLogo1) {
              this.renderLogoA1 = false;
            }
            if (!response.altLogo2) {
              this.renderLogoA2 = false;
            }
          } 
        })
        .catch(error => {
          this.isLoading = false;
          console.error(error);
        });
      }
    }
  
  
    showLogoTagDelay() {
      this.template.querySelector('[data-id="logoTag"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId); 
      this.timeoutId = setTimeout(this.showLogoTag.bind(this), 800);
    }
  
    showLogo1Delay() {
      this.template.querySelector('[data-id="logo1"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId);
      this.timeoutId = setTimeout(this.showLogo1.bind(this), 800);
    }
  
    showLogo3Delay() {
      this.template.querySelector('[data-id="logo3"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId); 
      this.timeoutId = setTimeout(this.showLogo3.bind(this), 800);
    }
  
    showLogo4Delay() {
      this.template.querySelector('[data-id="logo4"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId);
      this.timeoutId = setTimeout(this.showLogo4.bind(this), 800);
    }
  
    showLogoA1Delay() {
      this.template.querySelector('[data-id="logoA1"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId);
      this.timeoutId = setTimeout(this.showLogoA1.bind(this), 800);
    }
  
    showLogoA2Delay() {
      this.template.querySelector('[data-id="logoA2"]').classList.remove("slds-has-error");
      clearTimeout(this.timeoutId);
      this.timeoutId = setTimeout(this.showLogoA2.bind(this), 800);
    }
  
    showLogoTag() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoTag"]').value })
      .then(response => {
        if (response != null) {
          this.renderLogoT = true;
          this.Logo__c =`<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
        } else {
          if (this.template.querySelector('[data-id="logoTag"]').value !== "") {
            this.template.querySelector('[data-id="logoTag"]').classList.add("slds-has-error");
            this.showErrorToast();
          }
            this.renderLogoT = true;
            this.Logo__c = "";
            this.renderLogoT = false;
          }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
    }
  
    showLogo1() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo1"]').value })
      .then(response => {
          if (response != null) {
            this.renderLogo1 = true;
            this.Logo1__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
          } else {
            if (this.template.querySelector('[data-id="logo1"]').value !== "") {
              this.template.querySelector('[data-id="logo1"]').classList.add("slds-has-error");
              this.showErrorToast();
            }
            this.renderLogo1 = true;
            this.Logo1__c = "";
            this.renderLogo1 = false;
          }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
    }
  
    showLogo3() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo3"]').value })
      .then(response => {
        if (response != null) {
          this.renderLogo3 = true;
          this.Logo3__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
        } else {
          if (this.template.querySelector('[data-id="logo3"]').value !== "") {
            this.template.querySelector('[data-id="logo3"]').classList.add("slds-has-error");
            this.showErrorToast();
          }
          this.renderLogo3 = true;
          this.Logo1__c = "";
          this.renderLogo3 = false;
        }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
    }
  
    showLogo4() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logo4"]').value })
      .then(response => {
        if (response != null) {
          this.renderLogo4 = true;
          this.Logo4__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
        } else {
            if (this.template.querySelector('[data-id="logo4"]').value !== "") {
              this.template.querySelector('[data-id="logo4"]').classList.add("slds-has-error");
              this.showErrorToast();
            }
            this.renderLogo4 = true;
            this.Logo4__c = "";
            this.renderLogo4 = false;
          }
        })
        .catch(error => {
          console.error("there is error " + error);
        });
    }
  
    showLogoA1() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoA1"]').value })
      .then(response => {
        if (response != null) {
          this.renderLogoA1 = true;
          this.AltLogo1__c = `<img src='/sfc/servlet.shepherd/document/download/${response.docId}' width="28%"/>`;
        } else {
          if (this.template.querySelector('[data-id="logoA1"]').value !== "") {
              this.template.querySelector('[data-id="logoA1"]').classList.add("slds-has-error");
              this.showErrorToast();
          }
          this.renderLogoA1 = true;
          this.AltLogo1__c = "";
          this.renderLogoA1 = false;
        }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
    }
  
    showLogoA2() {
      searchLogoDoc({ logoName: this.template.querySelector('[data-id="logoA2"]').value })
      .then(response => {
        if (response != null) {
          this.renderLogoA2 = true;
          this.AltLogo2__c =  "<img src='/sfc/servlet.shepherd/document/download/" + response.docId + '\' width="28%"/>';
        } else {
          if (this.template.querySelector('[data-id="logoA2"]').value !== "") {
            this.template.querySelector('[data-id="logoA2"]').classList.add("slds-has-error");
            this.showErrorToast();
          }
          this.renderLogoA2 = true;
          this.AltLogo2__c = "";
          this.renderLogoA2 = false;
        }
      })
      .catch(error => {
        console.error("there is error " + error);
      });
    }
  
    close() {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.recordId,
            objectApiName: "Mbr_group__c",
            actionName: "view"
          }
        });
    }

    changeActiveDate() {
      if (this.template.querySelector('[data-id="Status__c"]').value === "ACTIVE") {
        let today = new Date();
        let dd = String(today.getDate()).padStart(2, "0");
        let mm = String(today.getMonth() + 1).padStart(2, "0"); 
        let yyyy = today.getFullYear();
        today = yyyy + "-" + mm + "-" + dd;
        this.actDate = today;
      } else {
        this.actDate = null;
      }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }
  
    saveMbrGrp(event) {
      if(!this.isInputValid())
      {
        return;
      }
        event.preventDefault();
        let mbr = { 'sobjectType': 'Mbr_Group__c' };
        mbr.Name__c = this.template.querySelector('[data-id="Name__c"]').value;
        mbr.Group_Number__c = this.template.querySelector('[data-id="Group_Number__c"]').value;
        mbr.Client_Account__c = this.template.querySelector('[data-id="Client_Account__c"]').value;
        mbr.Status__c = this.template.querySelector('[data-id="Status__c"]').value;
        mbr.Client_Account_Manager__c = this.template.querySelector('[data-id="Client_Account_Manager__c"]').value;
        mbr.Active_Date__c = this.template.querySelector('[data-id="Active_Date__c"]').value;
        mbr.Any_Special_Instructions__c = this.template.querySelector('[data-id="Any_Special_Instructions__c"]').value;
        mbr.Termination_Date__c = this.template.querySelector('[data-id="Termination_Date__c"]').value;
        mbr.Migration_Group_Number__c = this.template.querySelector('[data-id="Migration_Group_Number__c"]').value;
        mbr.Profile_Name__c = this.template.querySelector('[data-id="Profile_Name__c"]').value;
        mbr.Is_Valid_MSU_Group__c = this.template.querySelector('[data-id="Is_Valid_MSU_Group__c"]').value;
        mbr.Client_Account_Location__c = this.template.querySelector('[data-id="Client_Account_Location__c"]').value;
        mbr.Plan_Category__c = this.template.querySelector('[data-id="Plan_Category__c"]').value;
        mbr.Admin_Line_of_Business__c = this.template.querySelector('[data-id="Admin_Line_of_Business__c"]').value;
        mbr.Registration_Enrollment_Engagement_Tier__c = this.template.querySelector('[data-id="Registration_Enrollment_Engagement_Tier__c"]').value;
        mbr.Email__c = this.template.querySelector('[data-id="Email__c"]').value;
        mbr.Direct_mail__c = this.template.querySelector('[data-id="Direct_mail__c"]').value;
        mbr.EM_Phone__c = this.template.querySelector('[data-id="EM_Phone__c"]').value;
        mbr.Text_SMS__c = this.template.querySelector('[data-id="Text_SMS__c"]').value;
        mbr.Registration_Enrollment_Journey__c = this.template.querySelector('[data-id="Registration_Enrollment_Journey__c"]').value;
        mbr.Ongoing_Registration_Enrollment_Journey__c = this.template.querySelector('[data-id="Ongoing_Registration_Enrollment_Journey__c"]').value;
        mbr.EM_Language__c = this.template.querySelector('[data-id="EM_Language__c"]').value;
        mbr.Health_Benefit_Language__c = this.template.querySelector('[data-id="Health_Benefit_Language__c"]').value;
        mbr.Testing_Permission__c = this.template.querySelector('[data-id="Testing_Permission__c"]').value;
        mbr.Modeling_Permission__c = this.template.querySelector('[data-id="Modeling_Permission__c"]').value;
        mbr.Claims_Data__c = this.template.querySelector('[data-id="Claims_Data__c"]').value;
        mbr.F1BReporting_Category__c = this.template.querySelector('[data-id="F1BReporting_Category__c"]').value;
        //Below values will be deprecated later for Contract Path LOB functionality
        //mbr.Client_Account_Relationship__c = this.template.querySelector('[data-id="Client_Account_Relationship__c"]').value;
        
        mbr.Plan_Type__c = this.template.querySelector('[data-id="Plan_Type__c"]').value;
        
        //Below values will be deprecated later for Contract Path LOB functionality
        //mbr.Line_Of_Business__c = this.template.querySelector('[data-id="Line_Of_Business__c"]').value;
       
        mbr.Eligibility_Option__c = this.template.querySelector('[data-id="Eligibility_Option__c"]').value;
        mbr.Elig_Dep_Inc_In_File__c = this.template.querySelector('[data-id="Elig_Dep_Inc_In_File__c"]').value;
        mbr.Consult_Billing_Method__c = this.template.querySelector('[data-id="Consult_Billing_Method__c"]').value;
        mbr.Elig_By_Third_Party__c = this.template.querySelector('[data-id="Elig_By_Third_Party__c"]').value;
        mbr.Eligibility_File_Source__c = this.template.querySelector('[data-id="Eligibility_File_Source__c"]').value;
        mbr.Other_Company_Names__c = this.template.querySelector('[data-id="Other_Company_Names__c"]').value;
        mbr.OneAppAccess__c = this.template.querySelector('[data-id="OneAppAccess__c"]').value;
        mbr.Cross_Billing__c = this.template.querySelector('[data-id="Cross_Billing__c"]').value;
        mbr.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="Actual_Copay_May_Be_Less__c"]').value;
        mbr.Consult_Included__c = this.template.querySelector('[data-id="Consult_Included__c"]').value;
        mbr.Allow_Conversion_to_Retail__c = this.template.querySelector('[data-id="Allow_Conversion_to_Retail__c"]').value;
        mbr.Allow_Caregiver_Program__c = this.template.querySelector('[data-id="Allow_Caregiver_Program__c"]').value;
        mbr.Purchase_Order_Required__c = this.template.querySelector('[data-id="Purchase_Order_Required__c"]').value;
        mbr.Sexual_Health_Opt_Out__c = this.template.querySelector('[data-id="Sexual_Health_Opt_Out__c"]').value;
        mbr.Purchase_Order_Number__c = this.template.querySelector('[data-id="Purchase_Order_Number__c"]').value;
        mbr.Allow_Geo_Fencing__c = this.template.querySelector('[data-id="Allow_Geo_Fencing__c"]').value;
        mbr.Card_Template__c = this.template.querySelector('[data-id="Card_Template__c"]').value;
        mbr.Teladoc_Select__c = this.template.querySelector('[data-id="Teladoc_Select__c"]').value;
        mbr.Health_Assistant__c = this.template.querySelector('[data-id="Health_Assistant__c"]').value;
        mbr.Hide_SOGI_Questions__c = this.template.querySelector('[data-id="Hide_SOGI_Questions__c"]').value;
        mbr.Service_Brand__c = this.template.querySelector('[data-id="Service_Brand__c"]').value;
        mbr.Disclaimer_Teladoc__c = this.template.querySelector('[data-id="Disclaimer_Teladoc__c"]').value;
        mbr.WK_Template__c = this.template.querySelector('[data-id="WK_Template__c"]').value;
        mbr.Disclaimer_Client__c = this.template.querySelector('[data-id="Disclaimer_Client__c"]').value;
        mbr.Card_Name__c = this.template.querySelector('[data-id="Card_Name__c"]').value;
        mbr.Disclaimer_Custom__c = this.template.querySelector('[data-id="Disclaimer_Custom__c"]').value;
        mbr.WK_Card_Includes_Logo__c = this.template.querySelector('[data-id="WK_Card_Includes_Logo__c"]').value;
        mbr.Co_Brand_with_Logo__c = this.template.querySelector('[data-id="Co_Brand_with_Logo__c"]').value;
        mbr.WK_Retroactive__c = this.template.querySelector('[data-id="WK_Retroactive__c"]').value;
        mbr.Tri_Brand_with_Logo__c = this.template.querySelector('[data-id="Tri_Brand_with_Logo__c"]').value;
        mbr.WK_Retroactive_Date__c = this.template.querySelector('[data-id="WK_Retroactive_Date__c"]').value;
        mbr.Shipping_Class__c = this.template.querySelector('[data-id="Shipping_Class__c"]').value;
        mbr.WK_Send_Card_Date__c = this.template.querySelector('[data-id="WK_Send_Card_Date__c"]').value;
        mbr.Company_Copy__c = this.template.querySelector('[data-id="Company_Copy__c"]').value;
        mbr.Consult_Message__c = this.template.querySelector('[data-id="Consult_Message__c"]').value;
        mbr.CMSCode__c = this.template.querySelector('[data-id="CMSCode__c"]').value;
        mbr.Welcome_Letter_Consult_Message__c = this.template.querySelector('[data-id="Welcome_Letter_Consult_Message__c"]').value;
        mbr.MK_Welcomemessage__c = this.template.querySelector('[data-id="MK_Welcomemessage__c"]').value;
        mbr.Consult_Message_on_WK__c = this.template.querySelector('[data-id="Consult_Message_on_WK__c"]').value;
        mbr.MK_consultarea__c = this.template.querySelector('[data-id="MK_consultarea__c"]').value;
        mbr.Communication_Mode__c = this.template.querySelector('[data-id="Communication_Mode__c"]').value;
        mbr.MK_Idcardfront1__c = this.template.querySelector('[data-id="MK_Idcardfront1__c"]').value;
        mbr.MK_Idcardfront2__c = this.template.querySelector('[data-id="MK_Idcardfront2__c"]').value;
        mbr.WK_Includes_Insert__c = this.template.querySelector('[data-id="WK_Includes_Insert__c"]').value;
        mbr.Insert_Document_Name__c = this.template.querySelector('[data-id="Insert_Document_Name__c"]').value;
        mbr.WK_Mail_to__c = this.template.querySelector('[data-id="WK_Mail_to__c"]').value;
        mbr.Client_Form_Number__c = this.template.querySelector('[data-id="Client_Form_Number__c"]').value;
        mbr.WK_Mail_to_Address__c = this.template.querySelector('[data-id="WK_Mail_to_Address__c"]').value;
        mbr.Preferred_Eligibility_Language__c = this.template.querySelector('[data-id="Preferred_Eligibility_Language__c"]').value;
        try {
            mbr.Logo_Tag_ID__c = this.template.querySelector('[data-id="logoTag"]').value;
        } catch(error) {
            mbr.Logo_Tag_ID__c = null;
        }
        try {
            mbr.Logo1_ID__c = this.template.querySelector('[data-id="logo1"]').value;
          } catch(error) {
            mbr.Logo1_ID__c = null;
        }
        try {
            mbr.Logo__c = this.template.querySelector('[data-id="Logo__c"]').value;
          } catch(error) {
            mbr.Logo__c = null;
        }
        try {
            mbr.Logo1__c = this.template.querySelector('[data-id="Logo1__c"]').value;
          } catch(error) {
            mbr.Logo1__c = null;
        }
        try {
            mbr.Logo3_ID__c = this.template.querySelector('[data-id="logo3"]').value;
          } catch(error) {
            mbr.Logo3_ID__c = null;
        } 
        try {
            mbr.Logo4_ID__c = this.template.querySelector('[data-id="logo4"]').value;
          } catch(error) {
            mbr.Logo4_ID__c = null;
        } 
        try {
            mbr.Logo3__c = this.template.querySelector('[data-id="Logo3__c"]').value;
          } catch(error) {
            mbr.Logo3__c = null;
        } 
        try {
            mbr.Logo4__c = this.template.querySelector('[data-id="Logo4__c"]').value;
          } catch(error) {
            mbr.Logo4__c = null;
        }
        try {
            mbr.AltLogo1_ID__c = this.template.querySelector('[data-id="logoA1"]').value;
          } catch(error) {
            mbr.AltLogo1_ID__c = null;
        }
        try {
            mbr.AltLogo2_ID__c = this.template.querySelector('[data-id="logoA2"]').value;
          } catch(error) {
            mbr.AltLogo2_ID__c = null;
        }
        try {
            mbr.AltLogo1__c = this.template.querySelector('[data-id="AltLogo1__c"]').value;
          } catch(error) {
            mbr.AltLogo1__c = null;
        }
        try {
            mbr.AltLogo2__c = this.template.querySelector('[data-id="AltLogo2__c"]').value;
          } catch(error) {
            mbr.AltLoAltLogo2__cgo1__c = null;
        }
        try {
            mbr.AltLogo2__c = this.template.querySelector('[data-id="AltLogo2__c"]').value;
          } catch(error) {
            mbr.AltLoAltLogo2__cgo1__c = null;
        }
        mbr.AF_Included__c = this.template.querySelector('[data-id="AF_Included__c"]').value;
        mbr.Est_MSU_Cnt__c = this.template.querySelector('[data-id="Est_MSU_Cnt__c"]').value;
        mbr.GUID__c = this.template.querySelector('[data-id="GUID__c"]').value;
        mbr.Source__c = this.template.querySelector('[data-id="Source__c"]').value;
        mbr.Source_Id__c = this.template.querySelector('[data-id="Source_Id__c"]').value;
        createMbrGroup({newRecord: mbr})
        .then(result => {
            const toastEvent = new ShowToastEvent({
                title: "Success",
                variant: "success",
                mode: "dismissable"
              });
              this.dispatchEvent(toastEvent);
              this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  recordId: result,
                  objectApiName: "Mbr_group__c",
                  actionName: "view"
                }
              });
        })
        .catch(error => {
            console.log(error.body.message);
            const toastEvent = new ShowToastEvent({
            title:  'Something went wrong..',
            message: error.body.message,
            variant: "Error",
            mode: "dismissable"
            });
            this.dispatchEvent(toastEvent);
            
        });
    }



    showErrorToast() {
      const toastEvent = new ShowToastEvent({
        title: "Invalid Logo Name",
        variant: "Error",
        mode: "dismissable"
      });
      this.dispatchEvent(toastEvent);
    }
  }