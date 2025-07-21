/* eslint-disable no-unused-vars */
/* eslint-disable no-shadow */
/* eslint-disable no-else-return */
import { LightningElement, api, track } from "lwc";
import findSub from "@salesforce/apex/MassPsfPageLwc_Controller.findSub";
import mgsName from "@salesforce/apex/MassPsfPageLwc_Controller.mgName";
import deletePSF from "@salesforce/apex/MassPsfPageLwc_Controller.deletePSF";
import getHistories from "@salesforce/apex/MassPsfPageLwc_Controller.getHistories";
import getPSF from "@salesforce/apex/MassPsfPageLwc_Controller.getPSF";
import findObjType from "@salesforce/apex/MassPsfPageLwc_Controller.findObjType";
import createPSF from "@salesforce/apex/MassPsfPageLwc_Controller.createPSF";
import updatePSF from "@salesforce/apex/MassPsfPageLwc_Controller.updatePSF";
import getMbrGrpRoles from "@salesforce/apex/MassPsfPageLwc_Controller.getMbrGrpRoles";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

const sub = {
  Id: null,
  Name: null,
  SBQQ__Product__c: null,
  SBQQ__QuoteLine__c: null,
  SBQQ__Account__c: null,
  Bundle_Type__c: null,
  Consult_Type__c: null,
  Fee_Type__c: null,
  Current_Membership_Fee__c: null,
  Sort_Order__c: null,
  Disable_Teletherapy__c: null,
  Disable_Coaching__c: null,
  SBQQ__StartDate__c: null,
  SBQQ__Product__r: {
    Name: null,
    ProductCode: null,
    Id: null,
    Promotion_Enabled__c: null            //added for SCDEV-5535
  },
  SBQQ__QuoteLine__r: {
    SBQQ__Quote__c: null,
    Id: null,
    SBQQ__Quote__r: {
      SBQQ__Opportunity2__c: null,
      Id: null,
      SBQQ__Opportunity2__r: {
        Name: null,
        Id: null
      }
    }
  },
  SBQQ__Account__r: {
    Name: null,
    Id: null
  }
};

export default class MassPsfPageLWC extends NavigationMixin(LightningElement) {
  @api recordId;
  @track groupId;
  @track psfId;
  @track mgName;
  @track proCode;
  @track subLink;
  @track oppName;
  @track subRecord = sub;
  @track subList = [];
  @track hisList = [];
  @track psfRecord = [];
  @track billingMbrGroupRoleList = [];
  @track soldToMbrGroupRoleList = [];
  @track payerMbrGroupRoleList = [];
  @track renderElse = false; // render none BH
  @track renderVPC = false;
  @track feeType; // fee type of subscription
  @track isPPPM = false; // validate if feeType is PPPM
  @track renderBH = false; // render BH
  @track renderMH = false; // render MH
  @track renderMSCOMP = false; //render MSCOMP
  @track renderFeeConstruct = false; // render fee section
  @track renderExist = false; // render psf update screen
  @track renderNew = false; // render psf creation screen
  @track isSelectSub = false; // if a sub is being checked
  @track isCreateMore = false; // if using going to create more psf
  @track vpcFee = false;
  @track MSCOMPFee = false;
  @track bhFee = false; // toggle for bh sub
  @track mhFee = false; // toggle for mh sub
  @track elseFee = false; // toggle for none bh mh sub
  @track feeError = false; // error toggle for fee
  @track isWrongFormat = false; // error message for old psf data structure
  @track selectedSubs = []; // selected subs records array during creation
  @track isNextDisable = true; // next button during psf creation
  @track renderNewTable = false; // render sub record during creation
  @track renderExistTable = false; //  render existing psf record table
  @track currentSubIndex = 0; // index for current psf index screen during creation
  @track wrapper; // wrapper data from apex
  @track genAssetCode; // aseset code for non bh mh product
  @track lastPSF = false;
  @track savePSFList = []; //final psf list
  @track coaching = false;
  @track teletherapy = false;
  @track renderFlag = false;
  @track billToAccId;
  @track soldToAccId;
  @track payerAccId;
  @track isRenderBillAcc;
  @track isRenderSoldToAcc;
  @track isRenderPayerAcc;
  @track checkBillingAcc = false;
  @track checkSoldAcc = false;
  @track checkPayerAcc = false;
//isDisableSaveNext= false; commented for SCDEV-6049
 get disabledSaveNextButton (){
    return this.feeError; // || this.isDisableSaveNext; commented for SCDEV-6049
  }
  connectedCallback() {
    findObjType({ objId: this.recordId })
      .then(response => {
        if (response === "Mbr_Group__c") {
          this.groupId = this.recordId;
          this.renderNew = true;
          this.renderNewTable = true;
          this.findSub();
          this.getMbrGrpRoles(this.recordId, null);
          this.mgsName();
        } else {
          this.psfId = this.recordId;
          this.renderExist = true;
          this.renderExistTable = true;
          this.isSelectSub = true;
          this.getPSF();
        }
      })
      .catch(() => {
        this.catchErrorToast(
          "Please reach out to your system administrator (connectedcallback)"
        );
      });
  }

  catchErrorToast(error, mode) {
    const toastEvent = new ShowToastEvent({
      title: "Something went wrong!",
      message: error,
      variant: "error",
      mode: mode
    });
    this.dispatchEvent(toastEvent);
  }

  getHistories() {
    getHistories({ mbrGrpId: this.groupId, subId: this.subRecord.Id })
      .then(response => {
        if (response) {
          this.hisList = response;
        }
      })
      .catch(() => {
        this.catchErrorToast(
          "Please reach out to your system administrator (getHistories)",
          "sticky"
        );
      });
  }

  get isGeneralMedicalProduct() {
    return this.subRecord && this.subRecord.SBQQ__Product__r.Name == 'General Medical';
  }

  get showVendorPartner() {
    return this.subRecord.Vendor_Partner__c ? this.subRecord.Vendor_Partner__c : null;
  }

  get showGLP1Model() {
    return this.subRecord && (this.subRecord.SBQQ__Product__r.ProductCode == 'ADVWM' || 
      this.subRecord.SBQQ__Product__r.ProductCode == 'COMWC' || 
      this.subRecord.SBQQ__Product__r.ProductCode == 'ADPP' || 
      this.subRecord.SBQQ__Product__r.ProductCode == 'CDPC' ||
      this.subRecord.SBQQ__Product__r.ProductCode == 'WEIGM' ||
      this.subRecord.SBQQ__Product__r.ProductCode == 'DIABP' ||
      this.subRecord.SBQQ__Product__r.ProductCode == 'DIABPCARE' ||
      this.subRecord.SBQQ__Product__r.ProductCode == 'WEIGMCARE');
  }

    //added for SCDEV-5535
    get showPromotion() {
    return this.subRecord && (this.subRecord.SBQQ__Product__r.Promotion_Enabled__c == true);
  }

  getPSF() {
    getPSF({ recordId: this.psfId })
      .then(response => {
        this.groupId = response[0].psf[0].Member_Group__r.Id;
        this.mgName = response[0].psf[0].Member_Group__r.Name__c;
        this.psfRecord = response[0].psf;
        this.subRecord = response[0].sub;
        this.subLink = "/one/one.app?#/sObject/" + this.subRecord.Id + "/view";
        this.proCode = this.subRecord.SBQQ__Product__r.ProductCode;
        this.feeType = this.subRecord.Fee_Type__c;
        this.wrapper = response[0];
        this.coaching = this.psfRecord[0].Disable_Coaching__c;
        this.teletherapy = this.psfRecord[0].Disable_Teletherapy__c;
        this.billToAccId = this.psfRecord[0].Bill_to_Account__c;
        this.soldToAccId = this.subRecord.SBQQ__Account__c;
        this.payerAccId = this.psfRecord[0].Payer_Account__c;
        if (this.proCode !== "MYSTR3" && this.proCode !== "LVBH-2.0") {
          this.renderFlag = false;
        } else {
          this.renderFlag = true;
        }
        if (response[0].isError) {
          this.isWrongFormat = true;
        }
        this.getMbrGrpRoles(this.groupId, this.psfId);
        this.getHistories();
        if (
          this.subRecord.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r
            .Name === undefined
        ) {
          this.oppName = "";
        } else {
          this.oppName = this.subRecord.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name;
        }
        if (
          response[0].psf.length === 1 &&
          this.proCode !== "BH" &&
          this.proCode !== "MH"
        ) {
          this.renderElse = true;
          this.findAsset().then(isFee => {
            if (isFee) {
              this.template.querySelector('[data-id="elseMbr"]').value = this.psfRecord[0].Consult_Fee_Mbr_Pd__c;
              this.template.querySelector('[data-id="elsePlan"]').value = this.psfRecord[0].Consult_Fee_Plan_Pd__c;
            }
          });
        } else {
          if (this.proCode === "BH") {
            this.renderBH = true;
            this.findAsset().then(isFee => {
              if (isFee) {
                this.psfRecord.forEach(psf => {
                  if (psf.Asset__c) {
                    if (psf.Asset__r.Product2.ProductCode === "BHP1T") {
                      this.template.querySelector('[data-id="bhFistMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="bhFistPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHPOT") {
                      this.template.querySelector('[data-id="bhOnMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="bhOnPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHNPT") {
                      this.template.querySelector('[data-id="bhNonMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="bhNonPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                  }
                });
              }
            });
          } else if (this.proCode === "MH") {
            this.renderMH = true;
            this.findAsset().then(isFee => {
              if (isFee) {
                this.psfRecord.forEach(psf => {
                  if (psf.Asset__c) {
                    if (psf.Asset__r.Product2.ProductCode === "BHP1T") {
                      this.template.querySelector('[data-id="psyBHP1TMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="psyBHP1TPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHPOT") {
                      this.template.querySelector('[data-id="psyBHPOTMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="psyBHPOTPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHPOOT") {
                      this.template.querySelector('[data-id="psyBHPOOTMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="psyBHPOOTPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHNPT") {
                      this.template.querySelector('[data-id="psyBHNPTMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="psyBHNPTPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                  }
                });
              }
            });
          } else if (this.proCode === "PRIM360CARE") {
            this.renderVPC = true;
            if (this.feeType != null && this.feeType === 'PPPM') {
              this.isPPPM = true;
            }


            this.findAsset().then(isFee => {
              if (isFee) {
                this.psfRecord.forEach(psf => {
                  if (psf.Asset__c) {
                    if (psf.Asset__r.Product2.ProductCode === "NEWPATCF") {
                      this.template.querySelector('[data-id="NEWPATCFMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="NEWPATCFPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                    else if (psf.Asset__r.Product2.ProductCode === "PRIMCARECF") {
                      this.template.querySelector('[data-id="PRIMCARECFMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="PRIMCARECFPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                    else if (psf.Asset__r.Product2.ProductCode === "PRIMCAREACF") {
                      this.template.querySelector('[data-id="PRIMCAREACFMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="PRIMCAREACFPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                    else if (psf.Asset__r.Product2.ProductCode === "PRIMCAREFCF" && this.wrapper.assetMap.PRIMCAREFCF) {
                      this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="PRIMCAREFCFPln"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                  }
                });

              }
            });


          } else if (
            this.proCode === "MYSTR3" &&
            this.subRecord.Disable_Teletherapy__c === "NO"
          ) {
            this.renderMSCOMP = true;
            this.findAsset().then(isFee => {
              if (isFee) {
                this.psfRecord.forEach(psf => {
                  if (psf.Asset__c) {
                    if (psf.Asset__r.Product2.ProductCode === "BHP1T") {
                      this.template.querySelector('[data-id="MyStr1stMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="MyStr1stPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHPOT") {
                      this.template.querySelector('[data-id="MyStrOnMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="MyStrOnPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    } else if (psf.Asset__r.Product2.ProductCode === "BHNPT") {
                      this.template.querySelector('[data-id="MyStrNonMbr"]').value = psf.Consult_Fee_Mbr_Pd__c;
                      this.template.querySelector('[data-id="MyStrNonPlan"]').value = psf.Consult_Fee_Plan_Pd__c;
                    }
                  }
                });
              }
            });
          }
        }
      })
      .catch(error => {
        if (error.toString().includes("Cannot read property")) {
          this.catchErrorToast(
            "PSF record might be missing one of the follow records: Opportunity, Quote, QuoteLine",
            "sticky"
          );
        } else {
          this.catchErrorToast(
            `Please reach out to your system administrator (getPSF) ${error}`,
            "sticky"
          );
        }
      });
  }

  async findAsset() {
    if (this.proCode === "BH") {
      if (!this.wrapper.assetMap || this.wrapper.assetMap.BHP1T === undefined || !this.wrapper.assetMap.BHPOT === undefined || !this.wrapper.assetMap.BHNPT === undefined ||
        this.wrapper.assetMap.BHP1T.Consult_Fees__c === undefined || this.wrapper.assetMap.BHPOT.Consult_Fees__c === undefined || this.wrapper.assetMap.BHNPT.Consult_Fees__c === undefined) {
        this.renderFeeConstruct = false;
        this.feeError = true;
        return false;
      } else {
        this.renderFeeConstruct = true;
        this.bhFee = true;
        return true;
      }
    } else if (this.proCode === "MYSTR3" && this.subRecord.Disable_Teletherapy__c === "NO") {
      if (!this.wrapper.assetMap || this.wrapper.assetMap.BHP1T === undefined || !this.wrapper.assetMap.BHPOT === undefined || !this.wrapper.assetMap.BHNPT === undefined ||
        this.wrapper.assetMap.BHP1T.Consult_Fees__c === undefined || this.wrapper.assetMap.BHPOT.Consult_Fees__c === undefined || this.wrapper.assetMap.BHNPT.Consult_Fees__c === undefined) {
        this.renderFeeConstruct = false;
        this.feeError = true;
        return false;
      } else {
        this.renderFeeConstruct = true;
        this.MSCOMPFee = true;
        return true;
      }
    } else if (this.proCode === "MH") {
      if (!this.wrapper.assetMap || this.wrapper.assetMap.BHPOT === undefined || this.wrapper.assetMap.BHPOOT === undefined || this.wrapper.assetMap.BHNPT === undefined ||
        this.wrapper.assetMap.BHP1T === undefined || this.wrapper.assetMap.BHPOT.Consult_Fees__c === undefined || this.wrapper.assetMap.BHPOOT.Consult_Fees__c === undefined ||
        this.wrapper.assetMap.BHP1T.Consult_Fees__c === undefined || this.wrapper.assetMap.BHNPT.Consult_Fees__c === undefined) {
        this.renderFeeConstruct = false;
        this.feeError = true;
        return false;
      } else {
        this.renderFeeConstruct = true;
        this.mhFee = true;
        return true;
      }
    } else if (this.proCode === "PRIM360CARE") {
      if (!this.wrapper.assetMap || this.wrapper.assetMap.NEWPATCF === undefined || this.wrapper.assetMap.PRIMCARECF === undefined || this.wrapper.assetMap.PRIMCAREACF === undefined || this.wrapper.assetMap.NEWPATCF.Consult_Fees__c === undefined ||
        this.wrapper.assetMap.PRIMCARECF.Consult_Fees__c === undefined || this.wrapper.assetMap.PRIMCAREACF.Consult_Fees__c === undefined) {
        this.renderFeeConstruct = false;
        this.feeError = true;
        return false;
      }
      else {
        this.renderFeeConstruct = true;
        this.vpcFee = true;
        return true;
      }
    }
    else if (this.proCode === "PRIM360CARE" && this.wrapper.assetMap.PRIMCAREFCF) {
      if (!this.wrapper.assetMap || this.wrapper.assetMap.PRIMCAREFCF === undefined ||
        this.wrapper.assetMap.PRIMCAREFCF.Consult_Fees__c === undefined) {
        this.renderFeeConstruct = false;
        this.feeError = true;
        return false;
      }
      else {
        this.renderFeeConstruct = true;
        this.vpcFee = true;
        return true;
      }
    }
    else {
      if (!this.wrapper.assetMap) {
        this.renderFeeConstruct = false;
        return false;
      } else {
        this.renderFeeConstruct = true;
        this.genAssetCode = Object.keys(this.wrapper.assetMap)[0];
        if (this.wrapper.assetMap[this.genAssetCode].Consult_Fees__c === undefined) {
          this.feeError = true;
          return false;
        } else {
          this.generalFee = this.wrapper.assetMap[this.genAssetCode].Consult_Fees__c;
          this.elseFee = true;
          return true;
        }
      }
    }
  }

  mgsName() {
    mgsName({ groupId: this.groupId })
      .then(response => {
        if (response) {
          this.mgName = response;
        }
      })
      .catch(() => {
        this.catchErrorToast("mgsName");
      });
  }

  findSub() {
    findSub({ groupId: this.groupId })
      .then(response => {
        if (response) {
          if (response.length > 0) {
            response.forEach(i => {
              if (i.objSub.SBQQ__QuoteLine__r === undefined) {
                i.objSub.SBQQ__QuoteLine__r = {
                  SBQQ__Quote__c: "N/A",
                  Id: "N/A",
                  SBQQ__Quote__r: {
                    SBQQ__Opportunity2__c: "N/A",
                    Id: "N/A",
                    SBQQ__Opportunity2__r: { Name: "N/A" }
                  }
                };
              }
              if (i.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r === undefined) {
                i.objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r = {
                  Name: "N/A"
                }
              }
              if (i.objSub.SBQQ__Product__r === undefined) {
                i.objSub.SBQQ__Product__r = {
                  Name: "N/A"
                }
              }
            });
            this.subList = response;
          } else {
            this.catchErrorToast(
              "No valid subscriptions found. A subscription must be created first.",
              "dismissable"
            );
          }
        }
      })
      .catch(() => {
        this.catchErrorToast(
          "Please reach out to your system administrator (findSub)",
          "sticky"
        );
      });
  }

  getMbrGrpRoles(groupId, psfRecordId) {
    getMbrGrpRoles({ mbrGrpId: groupId, psfRecordId: psfRecordId })
      .then(response => {
        response.forEach(row => {
          if (row.objMbrGrpRole.Role_Type__c === 'Billing') {
            this.billingMbrGroupRoleList.push(row);
            this.isRenderBillAcc = true;
            console.log(' billing size :' + this.billingMbrGroupRoleList.length);
          }
          else if (row.objMbrGrpRole.Role_Type__c === 'Contractee') {
            this.soldToMbrGroupRoleList.push(row);
            this.isRenderSoldToAcc = true;
          }
          else if (row.objMbrGrpRole.Role_Type__c === 'Payer') {
            this.payerMbrGroupRoleList.push(row);
            this.isRenderPayerAcc = true;
          }
        })

        if (this.billingMbrGroupRoleList.length == 1) {
          this.checkBillingAcc = true;
          this.billToAccId = this.billingMbrGroupRoleList[0].objMbrGrpRole.Source_Account__r.Id;
        }
        if (this.payerMbrGroupRoleList.length == 1) {
          this.checkPayerAcc = true;
          this.payerAccId = this.payerMbrGroupRoleList[0].objMbrGrpRole.Source_Account__r.Id;
        }

      })
      .catch(() => {
        this.catchErrorToast(
          "Please reach out to your system administrator (getMbrGrpRoles)",
          "sticky"
        );
      })
  }
  reselectSubs() {
    this.vpcFee = false;
    this.MSCOMPFee = false;
    this.bhFee = false;
    this.mhFee = false;
    this.feeError = false;
    this.elseFee = false;
    this.renderBH = false;
    this.renderElse = false;
    this.renderMH = false;
    this.renderVPC = false;
    this.isPPPM = false;
    this.renderMSCOMP = false;
    this.renderNewTable = true;
    this.renderExistTable = false;
    this.isSelectSub = false;
    this.wrapper = null;
    this.subRecord = null;
    this.proCode = null;
    this.subLink = null;
    this.selectedSubs = [];
    this.isNextDisable = true;
    this.currentSubIndex = 0;
    this.genAssetCode = null;
    this.savePSFList = [];
    this.findSub();
  }

  checkAll(event) {
    this.selectedSubs = [];
    let selectedRows = this.template.querySelectorAll("lightning-input");
    if (event.target.checked) {
      selectedRows.forEach(sub => {
        if (sub.name !== "checkAll") {
          sub.checked = event.target.checked;
          this.selectedSubs.push(this.subList[sub.value]);
        }
      });
    } else {
      this.selectedSubs = [];
      selectedRows.forEach(sub => {
        sub.checked = event.target.checked;
      });
    }
    if (this.selectedSubs.length > 0) {
      this.isNextDisable = false;
    } else {
      this.isNextDisable = true;
    }
  }

  checkBox() {
    let selectedRows = this.template.querySelectorAll("lightning-input");
    this.selectedSubs = [];
    selectedRows.forEach(sub => {
      if (sub.name !== "checkAll") {
        if (sub.checked) {
          this.selectedSubs.push(this.subList[sub.value]);
        }
      }
    });
    if (this.selectedSubs.length > 0) {
      this.isNextDisable = false;
    } else {
      this.isNextDisable = true;
    }
  }

  handleNext() {
    this.vpcFee = false;
    this.bhFee = false;
    this.MSCOMPFee = false;
    this.mhFee = false;
    this.feeError = false;
    this.elseFee = false;
    this.renderBH = false;
    this.renderMSCOMP = false;
    this.renderElse = false;
    this.renderMH = false;
    this.renderVPC = false;
    this.isPPPM = false;
    this.renderNewTable = false;
    this.renderExistTable = true;
    this.isSelectSub = true;
    this.wrapper = this.selectedSubs[this.currentSubIndex];
    this.subRecord = this.selectedSubs[this.currentSubIndex].objSub;
    this.proCode = this.subRecord.SBQQ__Product__r.ProductCode;
    this.feeType = this.subRecord.Fee_Type__c;
    this.soldToAccId = this.subRecord.SBQQ__Account__c;
    this.subLink = `/one/one.app?#/sObject/${this.subRecord.Id}/view`;
    if (this.proCode !== "MYSTR3" && this.proCode !== "LVBH-2.0") {
      this.renderFlag = false;
    } else {
      this.renderFlag = true;
    }
    if (this.subRecord.Disable_Teletherapy__c === "NO") {
      this.teletherapy = false;
    } else {
      this.teletherapy = true;
    }
    if (this.subRecord.Disable_Coaching__c === "NO") {
      this.coaching = false;
    } else {
      this.coaching = true;
    }
    if (this.selectedSubs.length - 1 === this.currentSubIndex) {
      this.lastPSF = true;
    } else {
      this.lastPSF = false;
    }

    if (this.proCode === "BH") {
      this.renderBH = true;
      this.findAsset().then(isFee => {
        if (isFee) {
          this.template.querySelector('[data-id="bhFistMbr"]').value = this.wrapper.assetMap.BHP1T.Consult_Fees__c;
          this.template.querySelector('[data-id="bhFistPlan"]').value = 0;
          this.template.querySelector('[data-id="bhOnMbr"]').value = this.wrapper.assetMap.BHPOT.Consult_Fees__c;
          this.template.querySelector('[data-id="bhOnPlan"]').value = 0;
          this.template.querySelector('[data-id="bhNonMbr"]').value = this.wrapper.assetMap.BHNPT.Consult_Fees__c;
          this.template.querySelector('[data-id="bhNonPlan"]').value = 0;
        }
      });
    } else if (
      this.proCode === "MYSTR3" &&
      this.subRecord.Disable_Teletherapy__c === "NO"
    ) {
      this.renderMSCOMP = true;
      this.findAsset().then(isFee => {
        if (isFee) {
          this.template.querySelector('[data-id="MyStr1stMbr"]').value = this.wrapper.assetMap.BHP1T.Consult_Fees__c;
          this.template.querySelector('[data-id="MyStr1stPlan"]').value = 0;
          this.template.querySelector('[data-id="MyStrOnMbr"]').value = this.wrapper.assetMap.BHPOT.Consult_Fees__c;
          this.template.querySelector('[data-id="MyStrOnPlan"]').value = 0;
          this.template.querySelector('[data-id="MyStrNonMbr"]').value = this.wrapper.assetMap.BHNPT.Consult_Fees__c;
          this.template.querySelector('[data-id="MyStrNonPlan"]').value = 0;
        }
      });
    } else if (this.proCode === "MH") {
      this.renderMH = true;
      this.findAsset().then(isFee => {
        if (isFee) {
          this.template.querySelector(
            '[data-id="psyBHP1TMbr"]'
          ).value = this.wrapper.assetMap.BHP1T.Consult_Fees__c;
          this.template.querySelector('[data-id="psyBHP1TPln"]').value = 0;
          this.template.querySelector('[data-id="psyBHPOTMbr"]').value = this.wrapper.assetMap.BHPOT.Consult_Fees__c;
          this.template.querySelector('[data-id="psyBHPOTPln"]').value = 0;
          this.template.querySelector('[data-id="psyBHPOOTMbr"]').value = this.wrapper.assetMap.BHPOOT.Consult_Fees__c;
          this.template.querySelector('[data-id="psyBHPOOTPln"]').value = 0;
          this.template.querySelector('[data-id="psyBHNPTMbr"]').value = this.wrapper.assetMap.BHNPT.Consult_Fees__c;
          this.template.querySelector('[data-id="psyBHNPTPln"]').value = 0;
        }
      });
    } else if (this.proCode === "PRIM360CARE") {
      this.renderVPC = true;
      if (this.feeType != null && this.feeType === 'PPPM') {
        this.isPPPM = true;
      }
      this.findAsset().then(isFee => {
        if (isFee) {
          if (this.template.querySelector('[data-id="NEWPATCFMbr"]')) {
            this.template.querySelector('[data-id="NEWPATCFMbr"]').value = this.wrapper.assetMap.NEWPATCF.Consult_Fees__c;
            this.template.querySelector('[data-id="NEWPATCFPln"]').value = 0;
            this.template.querySelector('[data-id="PRIMCARECFMbr"]').value = this.wrapper.assetMap.PRIMCARECF.Consult_Fees__c;
            this.template.querySelector('[data-id="PRIMCARECFPln"]').value = 0;
            this.template.querySelector('[data-id="PRIMCAREACFMbr"]').value = this.wrapper.assetMap.PRIMCAREACF.Consult_Fees__c;
            this.template.querySelector('[data-id="PRIMCAREACFPln"]').value = 0;
          }
          if (this.wrapper.assetMap.PRIMCAREFCF) {
            this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').value = this.wrapper.assetMap.PRIMCAREFCF.Consult_Fees__c;
            this.template.querySelector('[data-id="PRIMCAREFCFPln"]').value = 0;
          }
        }
      });
    } else {
      this.renderElse = true;
      this.findAsset().then(isFee => {
        if (isFee) {
          this.template.querySelector('[data-id="elseMbr"]').value = this.generalFee;
          this.template.querySelector('[data-id="elsePlan"]').value = 0;
        }
      });
    }

    this.currentSubIndex = this.currentSubIndex + 1;
  }

  async insertPsfList() {
    let errorCount = this.validateError();
    if (!errorCount) {
      if (this.proCode === "BH") {
        this.createBhPsfList().then(psfList => {
          this.savePSFList = [...this.savePSFList, ...psfList];
        });
      } else if (
        this.proCode === "MYSTR3" &&
        this.subRecord.Disable_Teletherapy__c === "NO"
      ) {
        this.createMSCOMPPsfList().then(psfList => {
          this.savePSFList = [...this.savePSFList, ...psfList];
        });
      } else if (this.proCode === "MH") {
        this.createMhPsfList().then(psfList => {
          this.savePSFList = [...this.savePSFList, ...psfList];
        });
      } else if (this.proCode === "PRIM360CARE") {
        this.createVPCPsfList().then(psfList => {
          this.savePSFList = [...this.savePSFList, ...psfList];
        });
      } else {
        this.createGeneralPSF().then(psfList => {
          this.savePSFList = [...this.savePSFList, ...psfList];
        });
      }
    }
    return errorCount;
  }

  savePSF() {
    //this.isDisableSaveNext = true;  commented for SCDEV-6049
    this.insertPsfList().then(isError => {
      if (!isError) {
        createPSF({ psfList: this.savePSFList })
          .then(response => {
            //this.isDisableSaveNext = false; commented for SCDEV-6049
            if (response.length !== 0) {
              this.savePSFList = [];
              let error = "";
              response.forEach(msg => {
                error = `${error}  ${msg}`;
              });
              const toastEvent = new ShowToastEvent({
                title: "Error during PSF creation",
                message: `There are total of ${response.length} error(s).  ${error}`,
                variant: "error",
                mode: "dismissable"
              });
              this.dispatchEvent(toastEvent);
            } else {
              const toastEvent = new ShowToastEvent({
                title: "Success",
                message: "PSF records created!",
                variant: "success",
                mode: "dismissable"
              });
              this.dispatchEvent(toastEvent);
              this.savePSFList = [];
              if (this.lastPSF) {
                this.close();
              } else {
                this.handleNext();
              }
            }
          })
          .catch(e => {
            //this.isDisableSaveNext = false; commented for SCDEV-6049
            this.catchErrorToast(
              "Please reach out to your system administrator (savePSF)",
              "sticky"
            );
          });
      }
    });
  }

  validateError() {
    let errorCount = false;
    if (this.feeError) {
      this.catchErrorToast("No Default Fee found in Assets", "dismissable");
      return true;
      // eslint-disable-next-line no-else-return
    } else {
      this.template
        .querySelector('[data-id="startDate"]')
        .classList.remove("slds-has-error");
      if (this.renderFeeConstruct) {
        if (this.proCode === "BH") {
          this.template.querySelector('[data-id="bhFistMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="bhFistPlan"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="bhOnMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="bhOnPlan"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="bhNonMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="bhNonPlan"]').classList.remove("slds-has-error");
          if (Number(this.template.querySelector('[data-id="bhFistMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="bhFistPlan"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="bhOnMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="bhOnPlan"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="bhNonMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="bhNonPlan"]').value < 0)) {
            this.catchErrorToast(
              "Fee can not be negative amount",
              "dismissable"
            );
          }
          if (Number(this.template.querySelector('[data-id="bhFistMbr"]').value) + Number(this.template.querySelector('[data-id="bhFistPlan"]').value) !== this.wrapper.assetMap.BHP1T.Consult_Fees__c) {
            this.template.querySelector('[data-id="bhFistMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="bhFistPlan"]').classList.add("slds-has-error");
            this.catchErrorToast("Psychiatry Initial Visit Fee : Sum does not equal default value", "dismissable");
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="bhOnMbr"]').value) + Number(this.template.querySelector('[data-id="bhOnPlan"]').value) !== this.wrapper.assetMap.BHPOT.Consult_Fees__c) {
            this.template.querySelector('[data-id="bhOnMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="bhOnPlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychiatry Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="bhNonMbr"]').value) + Number(this.template.querySelector('[data-id="bhNonPlan"]').value) !== this.wrapper.assetMap.BHNPT.Consult_Fees__c) {
            this.template.querySelector('[data-id="bhNonMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="bhNonPlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Therapy Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
        } else if (
          this.proCode === "MYSTR3" &&
          this.subRecord.Disable_Teletherapy__c === "NO"
        ) {
          this.template.querySelector('[data-id="MyStr1stMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="MyStr1stPlan"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="MyStrOnMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="MyStrOnPlan"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="MyStrNonMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="MyStrNonPlan"]').classList.remove("slds-has-error");
          if (Number(this.template.querySelector('[data-id="MyStr1stMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="MyStr1stPlan"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="MyStrOnMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="MyStrOnPlan"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="MyStrNonMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="MyStrNonPlan"]').value < 0)) {
            this.catchErrorToast(
              "Fee can not be negative amount",
              "dismissable"
            );
          }
          if (Number(this.template.querySelector('[data-id="MyStr1stMbr"]').value) + Number(this.template.querySelector('[data-id="MyStr1stPlan"]').value) !== this.wrapper.assetMap.BHP1T.Consult_Fees__c) {
            this.template.querySelector('[data-id="MyStr1stMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="MyStr1stPlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychiatry Initial Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="MyStrOnMbr"]').value) + Number(this.template.querySelector('[data-id="MyStrOnPlan"]').value) !== this.wrapper.assetMap.BHPOT.Consult_Fees__c) {
            this.template.querySelector('[data-id="MyStrOnMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="MyStrOnPlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychiatry Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="MyStrNonMbr"]').value) + Number(this.template.querySelector('[data-id="MyStrNonPlan"]').value) !== this.wrapper.assetMap.BHNPT.Consult_Fees__c) {
            this.template.querySelector('[data-id="MyStrNonMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="MyStrNonPlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Therapy Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
        } else if (this.proCode === "MH") {
          this.template.querySelector('[data-id="psyBHP1TMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHP1TPln"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHPOTMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHPOTPln"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHPOOTMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHPOOTPln"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHNPTMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="psyBHNPTPln"]').classList.remove("slds-has-error");
          if (Number(this.template.querySelector('[data-id="psyBHP1TMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="psyBHP1TPln"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="psyBHPOTMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="psyBHPOTPln"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="psyBHPOOTMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="psyBHPOOTPln"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="psyBHNPTMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="psyBHNPTPln"]').value) < 0) {
            this.catchErrorToast(
              "Fee can not be negative amount",
              "dismissable"
            );
          }
          if (Number(this.template.querySelector('[data-id="psyBHP1TMbr"]').value) + Number(this.template.querySelector('[data-id="psyBHP1TPln"]').value) !== this.wrapper.assetMap.BHP1T.Consult_Fees__c) {
            this.template.querySelector('[data-id="psyBHP1TMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="psyBHP1TPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychiatry Initial Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="psyBHPOTMbr"]').value) + Number(this.template.querySelector('[data-id="psyBHPOTPln"]').value) !== this.wrapper.assetMap.BHPOT.Consult_Fees__c) {
            this.template.querySelector('[data-id="psyBHPOTMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="psyBHPOTPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychiatry Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="psyBHPOOTMbr"]').value) + Number(this.template.querySelector('[data-id="psyBHPOOTPln"]').value) !== this.wrapper.assetMap.BHPOOT.Consult_Fees__c) {
            this.template.querySelector('[data-id="psyBHPOOTMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="psyBHPOOTPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Psychologist Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (
            Number(this.template.querySelector('[data-id="psyBHNPTMbr"]').value) + Number(this.template.querySelector('[data-id="psyBHNPTPln"]').value) !== this.wrapper.assetMap.BHNPT.Consult_Fees__c) {
            this.template.querySelector('[data-id="psyBHNPTMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="psyBHNPTPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Therapy Ongoing Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
        } else if (this.proCode === "PRIM360CARE") {
          this.template.querySelector('[data-id="NEWPATCFMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="NEWPATCFPln"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="PRIMCARECFMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="PRIMCARECFPln"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="PRIMCAREACFMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="PRIMCAREACFPln"]').classList.remove("slds-has-error");
          let newfee = false;
          if (this.wrapper.assetMap.PRIMCAREFCF) {
            this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').classList.remove("slds-has-error");
            this.template.querySelector('[data-id="PRIMCAREFCFPln"]').classList.remove("slds-has-error");
            newfee = (Number(this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="PRIMCAREFCFPln"]').value) < 0) ? true : false;
            if (Number(this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').value) + Number(this.template.querySelector('[data-id="PRIMCAREFCFPln"]').value) !== this.wrapper.assetMap.PRIMCAREFCF.Consult_Fees__c) {
              this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').classList.add("slds-has-error");
              this.template.querySelector('[data-id="PRIMCAREFCFPln"]').classList.add("slds-has-error");
              this.catchErrorToast(
                "New Patient Visit Fee : Sum does not equal default value",
                "dismissable"
              );
              errorCount = true;
            }
          }
          if (Number(this.template.querySelector('[data-id="NEWPATCFMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="NEWPATCFPln"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="PRIMCARECFMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="PRIMCARECFPln"]').value) < 0 ||
            Number(this.template.querySelector('[data-id="PRIMCAREACFMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="PRIMCAREACFPln"]').value) < 0 || newfee) {
            this.catchErrorToast(
              "Fee can not be negative amount",
              "dismissable"
            );
          }
          if (Number(this.template.querySelector('[data-id="NEWPATCFMbr"]').value) + Number(this.template.querySelector('[data-id="NEWPATCFPln"]').value) !== this.wrapper.assetMap.NEWPATCF.Consult_Fees__c) {
            this.template.querySelector('[data-id="NEWPATCFMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="NEWPATCFPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "New Patient Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="PRIMCARECFMbr"]').value) + Number(this.template.querySelector('[data-id="PRIMCARECFPln"]').value) !== this.wrapper.assetMap.PRIMCARECF.Consult_Fees__c) {
            this.template.querySelector('[data-id="PRIMCARECFMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="PRIMCARECFPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Primary Care Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
          if (Number(this.template.querySelector('[data-id="PRIMCAREACFMbr"]').value) + Number(this.template.querySelector('[data-id="PRIMCAREACFPln"]').value) !== this.wrapper.assetMap.PRIMCAREACF.Consult_Fees__c) {
            this.template.querySelector('[data-id="PRIMCAREACFMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="PRIMCAREACFPln"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Primary Care Annual Checkup Visit Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
        } else {
          this.template.querySelector('[data-id="elseMbr"]').classList.remove("slds-has-error");
          this.template.querySelector('[data-id="elsePlan"]').classList.remove("slds-has-error");
          if (Number(this.template.querySelector('[data-id="elseMbr"]').value) < 0 || Number(this.template.querySelector('[data-id="elsePlan"]').value) < 0) {
            this.catchErrorToast(
              "Fee can not be negative amount",
              "dismissable"
            );
          }
          if (Number(this.template.querySelector('[data-id="elseMbr"]').value) + Number(this.template.querySelector('[data-id="elsePlan"]').value) !== this.generalFee) {
            this.template.querySelector('[data-id="elseMbr"]').classList.add("slds-has-error");
            this.template.querySelector('[data-id="elsePlan"]').classList.add("slds-has-error");
            this.catchErrorToast(
              "Consult Fee : Sum does not equal default value",
              "dismissable"
            );
            errorCount = true;
          }
        }
      }
      if (this.template.querySelector('[data-id="startDate"]').value == null || this.template.querySelector('[data-id="startDate"]').value === "") {
        this.template.querySelector('[data-id="startDate"]').classList.add("slds-has-error");
        this.catchErrorToast(
          "Product Start Date: You must enter a value",
          "dismissable"
        );
        errorCount = true;
      }

      if ((this.template.querySelector('[data-id="startDate"]').value != null) && (((this.billToAccId == null || this.billToAccId == undefined) || this.billingMbrGroupRoleList.length == 0))) {
        this.catchErrorToast(
          "Please select a Bill to Account",
          "dismissable"
        );
        errorCount = true;
      }

      return errorCount;

    }
  }

  async createGeneralPSF() {
    let psfList = [];
    let psf = { sobjectType: "Plan_Specific_Fees__c" };
    psf.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psf.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psf.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    if (this.isGeneralMedicalProduct) {
      psf.USGH_APP_Opt_Out__c = this.template.querySelector('[data-id="AppOptOut"]').value;
    }
    if (this.showGLP1Model) {
      psf.GLP_1_Model__c = this.template.querySelector('[data-id="GLPModel"]').value;
    }
    if(this.showPromotion)             //added for SCDEV-5535
    {
      psf.Promotion__c = this.template.querySelector('[data-id="PromotionEnable"]').value;
    }

    psf.Member_Group__c = this.groupId;
    psf.Subscription__c = this.subRecord.Id;
    psf.CurrencyIsoCode = "USD";
    psf.Disable_Teletherapy__c = this.teletherapy;
    psf.Disable_Coaching__c = this.coaching;
    psf.PG__c = false;
    psf.GM_100_Covered__c = false;
    psf.MH_100_Covered__c = false;
    psf.DERM_100_Covered__c = false;
    psf.Bill_to_Account__c = this.billToAccId;
    psf.Sold_to_Account__c = this.soldToAccId;
    psf.Payer_Account__c = this.payerAccId;

    try {
      psf.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="elseMbr"]').value;
      psf.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="elsePlan"]').value;
    } catch (e) {
      psf.Consult_Fee_Mbr_Pd__c = null;
      psf.Consult_Fee_Plan_Pd__c = null;
    }
    if (this.wrapper.assetMap) {
      psf.Asset__c = this.wrapper.assetMap[this.genAssetCode].Id;
    } else {
      psf.Asset__c = null;
    }
    psfList.push(psf);
    return psfList;
  }

  async createBhPsfList() {
    let bhPsfList = [];
    let psfBHP1T = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHP1T.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHP1T.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHP1T.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHP1T.Member_Group__c = this.groupId;
    psfBHP1T.Subscription__c = this.subRecord.Id;
    psfBHP1T.CurrencyIsoCode = "USD";
    psfBHP1T.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="bhFistMbr"]').value;
    psfBHP1T.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="bhFistPlan"]').value;
    psfBHP1T.Asset__c = this.wrapper.assetMap.BHP1T.Id;
    psfBHP1T.PG__c = false;
    psfBHP1T.GM_100_Covered__c = false;
    psfBHP1T.MH_100_Covered__c = false;
    psfBHP1T.DERM_100_Covered__c = false;
    psfBHP1T.Bill_to_Account__c = this.billToAccId;
    psfBHP1T.Sold_to_Account__c = this.soldToAccId;
    psfBHP1T.Payer_Account__c = this.payerAccId;
    let psfBHPOT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHPOT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHPOT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHPOT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHPOT.Member_Group__c = this.groupId;
    psfBHPOT.Subscription__c = this.subRecord.Id;
    psfBHPOT.CurrencyIsoCode = "USD";
    psfBHPOT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="bhOnMbr"]').value;
    psfBHPOT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="bhOnPlan"]').value;
    psfBHPOT.Asset__c = this.wrapper.assetMap.BHPOT.Id;
    psfBHPOT.PG__c = false;
    psfBHPOT.GM_100_Covered__c = false;
    psfBHPOT.MH_100_Covered__c = false;
    psfBHPOT.DERM_100_Covered__c = false;
    psfBHPOT.Bill_to_Account__c = this.billToAccId;
    psfBHPOT.Sold_to_Account__c = this.soldToAccId;
    psfBHPOT.Payer_Account__c = this.payerAccId;
    let psfBHNPT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHNPT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHNPT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHNPT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHNPT.Member_Group__c = this.groupId;
    psfBHNPT.Subscription__c = this.subRecord.Id;
    psfBHNPT.CurrencyIsoCode = "USD";
    psfBHNPT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="bhNonMbr"]').value;
    psfBHNPT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="bhNonPlan"]').value;
    psfBHNPT.Asset__c = this.wrapper.assetMap.BHNPT.Id;
    psfBHNPT.PG__c = false;
    psfBHNPT.GM_100_Covered__c = false;
    psfBHNPT.MH_100_Covered__c = false;
    psfBHNPT.DERM_100_Covered__c = false;
    psfBHNPT.Bill_to_Account__c = this.billToAccId;
    psfBHNPT.Sold_to_Account__c = this.soldToAccId;
    psfBHNPT.Payer_Account__c = this.payerAccId;
    bhPsfList.push(psfBHP1T);
    bhPsfList.push(psfBHPOT);
    bhPsfList.push(psfBHNPT);

    return bhPsfList;
  }

  async createMSCOMPPsfList() {
    let MSCOMPPsfList = [];
    let psfBHP1T = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHP1T.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHP1T.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHP1T.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHP1T.Member_Group__c = this.groupId;
    psfBHP1T.Subscription__c = this.subRecord.Id;
    psfBHP1T.CurrencyIsoCode = "USD";
    psfBHP1T.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="MyStr1stMbr"]').value;
    psfBHP1T.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="MyStr1stPlan"]').value;
    psfBHP1T.Asset__c = this.wrapper.assetMap.BHP1T.Id;
    psfBHP1T.Disable_Coaching__c = this.coaching;
    psfBHP1T.Disable_Teletherapy__c = this.teletherapy;
    psfBHP1T.PG__c = false;
    psfBHP1T.GM_100_Covered__c = false;
    psfBHP1T.MH_100_Covered__c = false;
    psfBHP1T.DERM_100_Covered__c = false;
    psfBHP1T.Bill_to_Account__c = this.billToAccId;
    psfBHP1T.Sold_to_Account__c = this.soldToAccId;
    psfBHP1T.Payer_Account__c = this.payerAccId;
    let psfBHPOT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHPOT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHPOT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHPOT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHPOT.Member_Group__c = this.groupId;
    psfBHPOT.Subscription__c = this.subRecord.Id;
    psfBHPOT.CurrencyIsoCode = "USD";
    psfBHPOT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="MyStrOnMbr"]').value;
    psfBHPOT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="MyStrOnPlan"]').value;
    psfBHPOT.Asset__c = this.wrapper.assetMap.BHPOT.Id;
    psfBHPOT.Disable_Coaching__c = this.coaching;
    psfBHPOT.Disable_Teletherapy__c = this.teletherapy;
    psfBHPOT.PG__c = false;
    psfBHPOT.GM_100_Covered__c = false;
    psfBHPOT.MH_100_Covered__c = false;
    psfBHPOT.DERM_100_Covered__c = false;
    psfBHPOT.Bill_to_Account__c = this.billToAccId;
    psfBHPOT.Sold_to_Account__c = this.soldToAccId;
    psfBHPOT.Payer_Account__c = this.payerAccId;
    let psfBHNPT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHNPT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHNPT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHNPT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHNPT.Member_Group__c = this.groupId;
    psfBHNPT.Subscription__c = this.subRecord.Id;
    psfBHNPT.CurrencyIsoCode = "USD";
    psfBHNPT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="MyStrNonMbr"]').value;
    psfBHNPT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="MyStrNonPlan"]').value;
    psfBHNPT.Asset__c = this.wrapper.assetMap.BHNPT.Id;
    psfBHNPT.Disable_Coaching__c = this.coaching;
    psfBHNPT.Disable_Teletherapy__c = this.teletherapy;
    psfBHNPT.PG__c = false;
    psfBHNPT.GM_100_Covered__c = false;
    psfBHNPT.MH_100_Covered__c = false;
    psfBHNPT.DERM_100_Covered__c = false;
    psfBHNPT.Bill_to_Account__c = this.billToAccId;
    psfBHNPT.Sold_to_Account__c = this.soldToAccId;
    psfBHNPT.Payer_Account__c = this.payerAccId;
    MSCOMPPsfList.push(psfBHP1T);
    MSCOMPPsfList.push(psfBHPOT);
    MSCOMPPsfList.push(psfBHNPT);

    return MSCOMPPsfList;
  }

  async createMhPsfList() {
    let mhPsfList = [];
    let psfBHPOT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHPOT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHPOT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHPOT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHPOT.Member_Group__c = this.groupId;
    psfBHPOT.Subscription__c = this.subRecord.Id;
    psfBHPOT.CurrencyIsoCode = "CAD";
    psfBHPOT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="psyBHPOTMbr"]').value;
    psfBHPOT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="psyBHPOTPln"]').value;
    psfBHPOT.Asset__c = this.wrapper.assetMap.BHPOT.Id;
    psfBHPOT.PG__c = false;
    psfBHPOT.GM_100_Covered__c = false;
    psfBHPOT.MH_100_Covered__c = false;
    psfBHPOT.DERM_100_Covered__c = false;
    psfBHPOT.Bill_to_Account__c = this.billToAccId;
    psfBHPOT.Sold_to_Account__c = this.soldToAccId;
    psfBHPOT.Payer_Account__c = this.payerAccId;
    let psfBHPOOT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHPOOT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHPOOT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHPOOT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHPOOT.Member_Group__c = this.groupId;
    psfBHPOOT.Subscription__c = this.subRecord.Id;
    psfBHPOOT.CurrencyIsoCode = "CAD";
    psfBHPOOT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="psyBHPOOTMbr"]').value;
    psfBHPOOT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="psyBHPOOTPln"]').value;
    psfBHPOOT.Asset__c = this.wrapper.assetMap.BHPOOT.Id;
    psfBHPOOT.PG__c = false;
    psfBHPOOT.GM_100_Covered__c = false;
    psfBHPOOT.MH_100_Covered__c = false;
    psfBHPOOT.DERM_100_Covered__c = false;
    psfBHPOOT.Bill_to_Account__c = this.billToAccId;
    psfBHPOOT.Sold_to_Account__c = this.soldToAccId;
    psfBHPOOT.Payer_Account__c = this.payerAccId;
    let psfBHNPT = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHNPT.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHNPT.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHNPT.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHNPT.Member_Group__c = this.groupId;
    psfBHNPT.Subscription__c = this.subRecord.Id;
    psfBHNPT.CurrencyIsoCode = "CAD";
    psfBHNPT.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="psyBHNPTMbr"]').value;
    psfBHNPT.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="psyBHNPTPln"]').value;
    psfBHNPT.Asset__c = this.wrapper.assetMap.BHNPT.Id;
    psfBHNPT.PG__c = false;
    psfBHNPT.GM_100_Covered__c = false;
    psfBHNPT.MH_100_Covered__c = false;
    psfBHNPT.DERM_100_Covered__c = false;
    let psfBHP1T = { sobjectType: "Plan_Specific_Fees__c" };
    psfBHP1T.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfBHP1T.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfBHP1T.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfBHP1T.Member_Group__c = this.groupId;
    psfBHP1T.Subscription__c = this.subRecord.Id;
    psfBHP1T.CurrencyIsoCode = "CAD";
    psfBHP1T.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="psyBHP1TMbr"]').value;
    psfBHP1T.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="psyBHP1TPln"]').value;
    psfBHP1T.Asset__c = this.wrapper.assetMap.BHP1T.Id;
    psfBHP1T.PG__c = false;
    psfBHP1T.GM_100_Covered__c = false;
    psfBHP1T.MH_100_Covered__c = false;
    psfBHP1T.DERM_100_Covered__c = false;
    psfBHNPT.Bill_to_Account__c = this.billToAccId;
    psfBHNPT.Sold_to_Account__c = this.soldToAccId;
    psfBHNPT.Payer_Account__c = this.payerAccId;
    mhPsfList.push(psfBHP1T);
    mhPsfList.push(psfBHPOT);
    mhPsfList.push(psfBHNPT);
    mhPsfList.push(psfBHPOOT);

    return mhPsfList;
  }

  async createVPCPsfList() {
    let vpcPsfList = [];
    let psfNEWPATCF = { sobjectType: "Plan_Specific_Fees__c" };
    psfNEWPATCF.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfNEWPATCF.PG__c = this.template.querySelector('[data-id="pg"]').value;
    psfNEWPATCF.GM_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="gm"]').value : false;
    psfNEWPATCF.MH_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="mh"]').value : false;
    psfNEWPATCF.DERM_100_Covered__c = false;
    psfNEWPATCF.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfNEWPATCF.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfNEWPATCF.Member_Group__c = this.groupId;
    psfNEWPATCF.Subscription__c = this.subRecord.Id;
    psfNEWPATCF.CurrencyIsoCode = "USD";
    psfNEWPATCF.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="NEWPATCFMbr"]').value;
    psfNEWPATCF.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="NEWPATCFPln"]').value;
    psfNEWPATCF.Asset__c = this.wrapper.assetMap.NEWPATCF.Id;
    psfNEWPATCF.Bill_to_Account__c = this.billToAccId;
    psfNEWPATCF.Sold_to_Account__c = this.soldToAccId;
    psfNEWPATCF.Payer_Account__c = this.payerAccId;
    let psfPRIMCARECF = { sobjectType: "Plan_Specific_Fees__c" };
    psfPRIMCARECF.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfPRIMCARECF.PG__c = this.template.querySelector('[data-id="pg"]').value;
    psfPRIMCARECF.GM_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="gm"]').value : false;
    psfPRIMCARECF.MH_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="mh"]').value : false;
    psfPRIMCARECF.DERM_100_Covered__c = false;
    psfPRIMCARECF.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfPRIMCARECF.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfPRIMCARECF.Member_Group__c = this.groupId;
    psfPRIMCARECF.Subscription__c = this.subRecord.Id;
    psfPRIMCARECF.CurrencyIsoCode = "USD";
    psfPRIMCARECF.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="PRIMCARECFMbr"]').value;
    psfPRIMCARECF.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="PRIMCARECFPln"]').value;
    psfPRIMCARECF.Asset__c = this.wrapper.assetMap.PRIMCARECF.Id;
    psfPRIMCARECF.Bill_to_Account__c = this.billToAccId;
    psfPRIMCARECF.Sold_to_Account__c = this.soldToAccId;
    psfPRIMCARECF.Payer_Account__c = this.payerAccId;
    let psfPRIMCAREACF = { sobjectType: "Plan_Specific_Fees__c" };
    psfPRIMCAREACF.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
    psfPRIMCAREACF.PG__c = this.template.querySelector('[data-id="pg"]').value;
    psfPRIMCAREACF.GM_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="gm"]').value : false;
    psfPRIMCAREACF.MH_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="mh"]').value : false;
    psfPRIMCAREACF.DERM_100_Covered__c = false;
    psfPRIMCAREACF.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
    psfPRIMCAREACF.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
    psfPRIMCAREACF.Member_Group__c = this.groupId;
    psfPRIMCAREACF.Subscription__c = this.subRecord.Id;
    psfPRIMCAREACF.CurrencyIsoCode = "USD";
    psfPRIMCAREACF.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="PRIMCAREACFMbr"]').value;
    psfPRIMCAREACF.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="PRIMCAREACFPln"]').value;
    psfPRIMCAREACF.Asset__c = this.wrapper.assetMap.PRIMCAREACF.Id;
    psfPRIMCAREACF.Bill_to_Account__c = this.billToAccId;
    psfPRIMCAREACF.Sold_to_Account__c = this.soldToAccId;
    psfPRIMCAREACF.Payer_Account__c = this.payerAccId;

    if (this.wrapper.assetMap && this.wrapper.assetMap.PRIMCAREFCF) {
      let psfPRIMCAREFCF = { sobjectType: "Plan_Specific_Fees__c" };
      psfPRIMCAREFCF.Actual_Copay_May_Be_Less__c = this.template.querySelector('[data-id="ActualCoPay"]').value;
      psfPRIMCAREFCF.PG__c = this.template.querySelector('[data-id="pg"]').value;
      psfPRIMCAREFCF.GM_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="gm"]').value : false;
      psfPRIMCAREFCF.MH_100_Covered__c = this.isPPPM ? this.template.querySelector('[data-id="mh"]').value : false;
      psfPRIMCAREFCF.DERM_100_Covered__c = false;
      psfPRIMCAREFCF.Product_Start_Date__c = this.template.querySelector('[data-id="startDate"]').value;
      psfPRIMCAREFCF.Product_End_Date__c = this.template.querySelector('[data-id="endDate"]').value;
      psfPRIMCAREFCF.Member_Group__c = this.groupId;
      psfPRIMCAREFCF.Subscription__c = this.subRecord.Id;
      psfPRIMCAREFCF.CurrencyIsoCode = "USD";
      psfPRIMCAREFCF.Consult_Fee_Mbr_Pd__c = this.template.querySelector('[data-id="PRIMCAREFCFMbr"]').value;
      psfPRIMCAREFCF.Consult_Fee_Plan_Pd__c = this.template.querySelector('[data-id="PRIMCAREFCFPln"]').value;
      psfPRIMCAREFCF.Asset__c = this.wrapper.assetMap.PRIMCAREFCF.Id;
      psfPRIMCAREFCF.Bill_to_Account__c = this.billToAccId;
      psfPRIMCAREFCF.Sold_to_Account__c = this.soldToAccId;
      psfPRIMCAREFCF.Payer_Account__c = this.payerAccId;
      vpcPsfList.push(psfPRIMCAREFCF);
    }
    vpcPsfList.push(psfNEWPATCF);
    vpcPsfList.push(psfPRIMCARECF);
    vpcPsfList.push(psfPRIMCAREACF);

    return vpcPsfList;
  }

  deletePSF() {
    deletePSF({ mbrGrpId: this.groupId, subId: this.subRecord.Id })
      .then(response => {
        if (response !== null) {
          const toastEvent = new ShowToastEvent({
            title: "Error: unable to delete PSF",
            message: response,
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(toastEvent);
        } else {
          const toastEvent = new ShowToastEvent({
            title: "Success",
            message: "PSF records deleted!",
            variant: "success",
            mode: "dismissable"
          });
          this.dispatchEvent(toastEvent);
          this.close();
        }
      })
      .catch(() => {
        this.catchErrorToast(
          "Please reach out to your system administrator (deleteBH)",
          "sticky"
        );
      });
  }

  updatePSF() {
    this.insertPsfList().then(isError => {
      if (!isError) {
        updatePSF({
          recordId: this.psfId,
          psfList: this.savePSFList,
          mbrGrpId: this.groupId,
          subId: this.subRecord.Id
        })
          .then(response => {
            if (response !== null) {
              const toastEvent = new ShowToastEvent({
                title: "Error: unable to update PSF",
                message: response,
                variant: "error",
                mode: "dismissable"
              });
              this.dispatchEvent(toastEvent);
            } else {
              this.savePSFList = [];
              const toastEvent = new ShowToastEvent({
                title: "Success",
                message: "PSF records updated!",
                variant: "success",
                mode: "dismissable"
              });
              this.dispatchEvent(toastEvent);
            }
          })
          .catch(() => {
            this.catchErrorToast(
              "Please reach out to your system administrator (updatePSF)",
              "sticky"
            );
          });
      }
    });
  }

  close() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.groupId,
        objectApiName: "Mbr_Group__c",
        actionName: "view"
      }
    });
  }

  handleBillToRadio(event) {
    this.billToAccId = event.currentTarget.dataset.id;
  }

  handlePayerRadio(event) {
    this.payerAccId = event.currentTarget.dataset.id;
  }
}