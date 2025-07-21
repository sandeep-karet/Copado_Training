import { LightningElement, wire, api, track } from "lwc";
import getPGRecords from "@salesforce/apex/PerformanceGuaranteeController.getPGRecords";
import getPGAssociationRecords from "@salesforce/apex/PerformanceGuaranteeController.getPGAssociationRecords";
import insertAndDeleteRecords from "@salesforce/apex/PerformanceGuaranteeController.insertAndDeleteRecords";
import getLineItems from "@salesforce/apex/PerformanceGuaranteeController.getLineItems";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, subscribe, MessageContext } from "lightning/messageService";
import PGUpdate_CHANNEL from "@salesforce/messageChannel/PGUpdate__c";
const COLUMNS = [
  {
    label: "Name",
    fieldName: "PgName",
    type: "url",
    typeAttributes: { label: { fieldName: "Pg_Name" }, target: "_blank" }
  },
  {
    label: "Product",
    fieldName: "ProductName",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Product_Name" },
      target: "_blank"
    }
  },
  {
    label: "Guarantee Type",
    fieldName: "Guarantee_Type__c"
  },
  {
    label: "Guarantee SubType",
    fieldName: "Guarantee_Subtype__c"
  },
  {
    label: "PG Start Date",
    fieldName: "PG_Start_Date__c",
    type: "date"
  },
  {
    label: "PG Status",
    fieldName: "PG_Status__c"
  }
];

export default class PerformanceGuarantee extends LightningElement {
  @api recordId;
  @track gridColumns;
  @track performanceGuranteeList;
  @track preselectedRows = [];
  @track selectedRows = [];
  @track value = "";
  @track agreementLineItems = [];
  @track selectedAgreementLineItem;
  @track error;
  @track pgAssociationItems = [];
  @track selectedPGAssociationItems = [];
  @track isLoading = false;

  @wire(MessageContext)
  messageContext;

  get options() {
    return this.agreementLineItems;
  }

  /**
   * Subscribe PGUdate message channgel on component load.
   */
  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      PGUpdate_CHANNEL,
      (message) => this.handleMessage(message)
    );
  }

  /**
   * Handle input message received through message Chaneel.
   * @param {*} message
   */
  handleMessage(message) {
    if (message.data) {
      this.pgAssociationItems = message.data;
    }
    this.updateSelectedRows(this.selectedAgreementLineItem, true);
  }

  __wiredResult;
  @wire(getPGRecords, { agrId: "$recordId" })
  wiredCallback(result) {
    this.__wiredResult = result;
    if (result.data) {
      let data = result.data;
      let performanceGuranteeItems = [];
      data.forEach((record) => {
        let performanceGuranteeItem = Object.assign({}, record);
        performanceGuranteeItem.AgreementName = "";
        performanceGuranteeItem.PgName = "";
        performanceGuranteeItem.Pg_Name = "";
        performanceGuranteeItem.Agreement_Name = "";
        performanceGuranteeItem.AgreementLineItem = "";
        performanceGuranteeItem.LineItem = "";

        performanceGuranteeItem.PgName = "/" + performanceGuranteeItem.Id;
        performanceGuranteeItem.Pg_Name = performanceGuranteeItem.Name;

        if ( performanceGuranteeItem.Product_Name__c) {
          performanceGuranteeItem.ProductName = "/" + performanceGuranteeItem.Id;
          performanceGuranteeItem.Product_Name = performanceGuranteeItem.Product_Name__c;
        }
        if (performanceGuranteeItem.Agreement__c) {
          performanceGuranteeItem.AgreementName ="/" + performanceGuranteeItem.Agreement__c;
          performanceGuranteeItem.Agreement_Name = performanceGuranteeItem.Agreement__r.Name;
        }
        if (performanceGuranteeItem.Agreement_Line_Item__c) {
          performanceGuranteeItem.AgreementLineItem = "/" + performanceGuranteeItem.Agreement_Line_Item__c;
          performanceGuranteeItem.LineItem = performanceGuranteeItem.Agreement_Line_Item__r.Name;
        }
        performanceGuranteeItems.push(performanceGuranteeItem);
      });
      this.performanceGuranteeList = performanceGuranteeItems;
    }
    if (result.error) {
      this.error = result.error;
    }
  }

  __wiredResultPGA;
  @wire(getPGAssociationRecords, { agmtId: "$recordId" })
  pgaCallback(result) {
    this.__wiredResultPGA = result;
    if (result.data) {
      let data = result.data;
      this.pgAssociationItems = data;
    }
    if (result.error) {
      this.error = result.error;
    }
  }

  connectedCallback() {
    this.gridColumns = COLUMNS;
    // fetch line items records
    this.fetchAgreementLineItems();
    this.subscribeToMessageChannel();
  }

  /**Fetch Line Items details from server and prepare line item for display as option*/
  fetchAgreementLineItems() {
    getLineItems({ agmtId: this.recordId }).then((result) => {
      let items = [];
      for (let i = 0; i < result.length; i++) {
        let newLabel = [];
        if (result[i].Name) {
          newLabel.push(result[i].Name);
        }
        if (result[i].Apttus__ProductId__r) {
          newLabel.push(result[i].Apttus__ProductId__r.Name);
        }
        if (result[i].APTS_Product_Family__c) {
          newLabel.push(result[i].APTS_Product_Family__c);
        }
        if (result[i].APTS_Membership_Fee__c) {
          newLabel.push(result[i].APTS_Membership_Fee__c);
        }
        if (result[i].APTS_Consult_Fees__c) {
          newLabel.push(result[i].APTS_Consult_Fees__c);
        }
        if (result[i].APTS_NumberofLives__c) {
          newLabel.push(result[i].APTS_NumberofLives__c);
        }

        items.push({ label: newLabel.join(" / "), value: result[i].Id });
      }
      this.agreementLineItems = items;
    });
  }

  /**
   * Handle Selection change in Agreement line items from picklist
   * @param {*} event
   */
  handleChange(event) {
    let lineItemRecId;
    lineItemRecId = event.detail.value;
    this.selectedAgreementLineItem = lineItemRecId;
    this.updateSelectedRows(this.selectedAgreementLineItem, true);
  }

  /**
   * Update selected row in tabled based on selected line item .
   * @param {*} lineItemId
   * @param {*} updateSelectionOnGrid
   */
  updateSelectedRows(lineItemId, updateSelectionOnGrid) {
    let linkedRecords = [];
    let _selectedPG = [];
    this.performanceGuranteeList.forEach((item) => {
      this.pgAssociationItems.forEach((record) => {
        if (
          record.Performance_Guarantee__c === item.Id &&
          record.Agreement_Line_Item__c === lineItemId
        ) {
          linkedRecords.push(item.Id);
          _selectedPG.push({
            Id: item.Id,
            line_item_Id: record.Agreement_Line_Item__c,
            pga_Id: record.Id
          });
        }
      });
    });
    if (updateSelectionOnGrid) this.preselectedRows = linkedRecords;

    this.selectedPGAssociationItems = _selectedPG;
  }

  finalselectedItems = [];

  /**Insert or Delete Junction object(PG_Assocition) records based on seleted grid items. */
  handleClick() {
    if (
      this.selectedAgreementLineItem === null ||
      this.selectedAgreementLineItem === undefined
    ) {
      this.showToastMessageToUser({
        title: "Line Item Not Selected",
        message: "Please select agreement line item...",
        variant: "error"
      });
      return;
    }
    this.isLoading = true;
    let selected_Rows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    let itemsToDelete = [];
    this.selectedPGAssociationItems.forEach((record) => {
      if (selected_Rows.length > 0) {
        const recordFound = selected_Rows.find(({ Id }) => Id === record.Id);
        if (recordFound === undefined) {
          itemsToDelete.push(record.pga_Id);
        }
      } else {
        itemsToDelete.push(record.pga_Id);
      }
    });

    this.selectedPGAssociationItems.forEach((record) => {
      selected_Rows.splice(
        selected_Rows.findIndex((row) => row.Id === record.Id),
        1
      );
    });

    let itemsToCreate = [];
    if (selected_Rows.length > 0) {
      selected_Rows.forEach((searchItem) => {
        for (let currentItem of this.performanceGuranteeList) {
          if (searchItem.Id === currentItem.Id) {
            const record = {};
            record.Id = currentItem.Id;
            record.LineItemId = this.selectedAgreementLineItem;
            itemsToCreate.push(record);
          }
        }
      });
    }
    const recordInputs = itemsToCreate;
    const recordOutput = itemsToDelete;

    //console.log(JSON.stringify(itemsToCreate));
    //console.log(JSON.stringify(itemsToDelete));

    insertAndDeleteRecords({
      pgrList: recordInputs,
      itemsList: recordOutput,
      agmtId: this.recordId
    })
      .then((result) => {
        this.pgAssociationItems = result;
        this.showToastMessageToUser({
          title: "Success",
          message: "Record successfully link to line Item.",
          variant: "success"
        });
        refreshApex(this.__wiredResultPGA);
        const payload = { value: true, data: result };
        publish(this.messageContext, PGUpdate_CHANNEL, payload);
        this.isLoading = false;
      })
      .catch((error) => {
        this.isLoading = false;
        this.showToastMessageToUser({
          title: "Error updating record",
          message: error.body.message,
          variant: "error"
        });
      });
  }

  /**Show Toast Message to User  */
  showToastMessageToUser({ title, message, variant }) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}