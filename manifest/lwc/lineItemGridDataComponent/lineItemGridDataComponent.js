import { LightningElement, wire, api, track } from "lwc";
import getPGRecords from "@salesforce/apex/PerformanceGuaranteeController.getPGRecords";
import getLineItems from "@salesforce/apex/PerformanceGuaranteeController.getLineItems";
import getPGAssociationRecords from "@salesforce/apex/PerformanceGuaranteeController.getPGAssociationRecords";
import insertAndDeleteRecords from "@salesforce/apex/PerformanceGuaranteeController.insertAndDeleteRecords";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, subscribe, MessageContext } from "lightning/messageService";
import PGUpdate_CHANNEL from "@salesforce/messageChannel/PGUpdate__c";
const COLUMNS = [
  {
    label: "Name",
    fieldName: "AgreementLineItem",
    type: "url",
    typeAttributes: { label: { fieldName: "LineItem" }, target: "_blank" }
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
    label: "Product Start Date",
    fieldName: "APTS_Product_Start_Date__c",
    type: "date"
  },
  {
    label: "Product End Date",
    fieldName: "APTS_Product_End_Date__c",
    type: "date"
  },
  {
    label: "Membership Fee",
    fieldName: "APTS_Membership_Fee__c",
    type: "currency",
    typeAttributes: {
      minimumFractionDigits: "2",
      currencyCode: {
        fieldName: "CurrencyIsoCode"
      },
      currencyDisplayAs: "code"
    }
  },
  {
    label: "Consult Fees",
    fieldName: "APTS_Consult_Fees__c",
    type: "currency",
    typeAttributes: {
      minimumFractionDigits: "2",
      currencyCode: {
        fieldName: "CurrencyIsoCode"
      },
      currencyDisplayAs: "code"
    }
  },
  {
    label: "Number Of Lives",
    fieldName: "APTS_NumberofLives__c"
  }
];

export default class LineItemGridDataComponent extends LightningElement {
  @api recordId;
  @track gridColumns;
  @track lineItemData;
  @track preselectedRows = [];
  @track pgAssociationItems = [];
  @track selectedLineItem = [];
  @track error;
  @track selectedPgItem;
  @track pGItems = [];
  @track isLoading = false;

  get options() {
    return this.pGItems;
  }

  __wiredResult;
  @wire(getLineItems, { agmtId: "$recordId" })
  wiredCallback(result) {
    this.__wiredResult = result;
    if (result.data) {
      let data = result.data;
      let agLineItemList = [];
      data.forEach((record) => {
        //console.log(JSON.stringify(record));
        let agLineItemRecord = Object.assign({}, record);
        agLineItemRecord.AgreementName = "";
        agLineItemRecord.ProductName = "";
        agLineItemRecord.Product_Name = "";
        agLineItemRecord.Agreement_Name = "";
        agLineItemRecord.AgreementLineItem = "";
        agLineItemRecord.LineItem = "";

        agLineItemRecord.AgreementLineItem = "/" + agLineItemRecord.Id;
        agLineItemRecord.LineItem = agLineItemRecord.Name;

        if (agLineItemRecord.Apttus__AgreementId__c) {
          agLineItemRecord.AgreementName =
            "/" + agLineItemRecord.Apttus__AgreementId__c;
          agLineItemRecord.Agreement_Name =
            agLineItemRecord.Apttus__AgreementId__r.Name;
        }

        if (agLineItemRecord.Apttus__ProductId__c) {
          agLineItemRecord.ProductName =
            "/" + agLineItemRecord.Apttus__ProductId__c;
          agLineItemRecord.Product_Name =
            agLineItemRecord.Apttus__ProductId__r.Name;
        }

        agLineItemList.push(agLineItemRecord);
      });
      this.lineItemData = agLineItemList;
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
    this.fetchPGRecords();
    this.subscribeToMessageChannel();
  }

  @wire(MessageContext)
  messageContext;

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
    this.updateSelectedRows();
  }

  /**Fetch Performance Guarantee details from server and prepare items for display as option*/
  fetchPGRecords() {
    getPGRecords({ agrId: this.recordId }).then((result) => {
      let returnedRecoreds = [];
      for (let i = 0; i < result.length; i++) {
        let newLabel = [];
        if (result[i].Name) {
          newLabel.push(result[i].Name);
        }
        if (result[i].PG_Status__c) {
          newLabel.push(result[i].PG_Status__c);
        }
        if (result[i].Product_Name__c) {
          newLabel.push(result[i].Product_Name__c);
        }
        if (result[i].Product_Family__c) {
          newLabel.push(result[i].Product_Family__c);
        }
        if (result[i].Guarantee_Type__c) {
          newLabel.push(result[i].Guarantee_Type__c);
        }
        returnedRecoreds.push({
          label: newLabel.join(" / "),
          value: result[i].Id
        });
      }
      this.pGItems = returnedRecoreds;
    });
  }

  /**
   * Handle Selection change in Performance Guarantee items from picklist
   * @param {*} event
   */
  handleChange(event) {
    let pgRecId;
    pgRecId = event.detail.value;
    this.selectedPgItem = pgRecId;
    this.updateSelectedRows();
  }

  /**
   * Update selected row in tabled based on selected line item .
   * @param {*} lineItemId
   * @param {*} updateSelectionOnGrid
   */
  updateSelectedRows() {
    let linkedRecords = [];
    let _selectedLineItem = [];
    this.lineItemData.forEach((item) => {
      this.pgAssociationItems.forEach((record) => {
        if (
          record.Agreement_Line_Item__c === item.Id &&
          record.Performance_Guarantee__c === this.selectedPgItem
        ) {
          linkedRecords.push(item.Id);
          _selectedLineItem.push({
            Id: item.Id,
            pg_Id: record.Performance_Guarantee__c,
            pga_Id: record.Id
          });
        }
      });
    });
    this.preselectedRows = linkedRecords;
    this.selectedLineItem = _selectedLineItem;
  }

  /**Insert or Delete Junction object(PG_Assocition) records based on seleted grid items. */
  handleClick() {
    if (this.selectedPgItem == null || this.selectedPgItem === undefined) {
      this.showToastMessageToUser({
        title: "Performance Guarantees Record Not Selected",
        message: "Please select record...",
        variant: "error"
      });
      return;
    }
    this.isLoading = true;

    let selected_Rows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    let itemsToDelete = [];
    this.selectedLineItem.forEach((record) => {
      if (selected_Rows.length > 0) {
        const recordFound = selected_Rows.find(({ Id }) => Id === record.Id);
        if (recordFound === undefined) {
          itemsToDelete.push(record.pga_Id);
        }
      } else {
        itemsToDelete.push(record.pga_Id);
      }
    });

    this.selectedLineItem.forEach((record) => {
      selected_Rows.splice(
        selected_Rows.findIndex((row) => row.Id === record.Id),
        1
      );
    });

    let itemsToCreate = [];
    if (selected_Rows.length > 0) {
      selected_Rows.forEach((searchItem) => {
        for (let currentItem of this.lineItemData) {
          if (searchItem.Id === currentItem.Id) {
            const record = {};
            record.Id = this.selectedPgItem;
            record.LineItemId = currentItem.Id;
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
        this.showToastMessageToUser({
          title: "Success",
          message: "Record successfully link to line Item.",
          variant: "success"
        });

        refreshApex(this.__wiredResultPGA);
        this.pgAssociationItems = result;
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