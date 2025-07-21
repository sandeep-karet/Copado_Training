import { LightningElement, wire, api, track  } from 'lwc';
import getOrderProducts from '@salesforce/apex/L2O_EditOrderProductsController.getOrderProducts';
import saveOrderProducts from '@salesforce/apex/L2O_EditOrderProductsController.saveOrderProducts';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const fields  = ['OrderItem.Id','OrderItem.OrderItemNumber',
                'OrderItem.Product2.Name','OrderItem.Quantity','OrderItem.ServiceDate','OrderItem.SBQQ__Activated__c','OrderItem.L2O_Hold_Order__c',
                'OrderItem.SBQQ__ShippingAccount__c','OrderItem.Shipping_Contact__c','OrderItem.L2O_Shipping_Address_Text__c',
                'OrderItem.L2O_Send_RMA__c','OrderItem.L2O_PO_Number__c'];

export default class editOrderProducts extends NavigationMixin(LightningElement) { 

    @api orderId;
    @track orderProductslist=[];
    @track disableSave = false;
    draftOrderProdList = []; 

    //LWC ref
    errorMsg = '';

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        
        this.orderId = this.currentPageReference?.state?.c__orderId;
        
        getOrderProducts({orderId : this.orderId})
        .then((result) => {
            if(result.length > 0){

                this.record = result;
                this.orderProductslist = this.record;
    
                this.draftOrderProdList = result.map((rec) => ({    Id: rec.Id,   
                                                                    SBQQ__Activated__c: rec.SBQQ__Activated__c,   
                                                                    L2O_Hold_Order__c: rec.L2O_Hold_Order__c, 
                                                                    L2O_Send_RMA__c: rec.L2O_Send_RMA__c,
                                                                    L2O_PO_Number__c: rec.L2O_PO_Number__c,  
                                                                    SBQQ__ShippingAccount__c: rec.SBQQ__ShippingAccount__c,
                                                                    Shipping_Contact__c: rec.Shipping_Contact__c, }));
            }
            else{
                this.disableSave = true; //Disable Save button.
                let errorMsg = 'No Deactivated Order Products Found!';
                this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
            }
            
        })
        .catch((error) => {
            let errorMsg = error;
            this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
        });

    }

    handleShipContactSelection(event) {

        let id = event.detail.selectedId;
        let uniqueKey = event.detail.key;

        //To mutate the list displayed on UI
        let element = this.orderProductslist.find(ele  => ele.Id === uniqueKey);
        element.Shipping_Contact__c = id;

        //For Draft Values to be updated
        let elementShipAccount = this.draftOrderProdList.find(el => el.Id === uniqueKey);
        elementShipAccount.Shipping_Contact__c = id;
    }

    handleShipAccountSelection(event) {

        let id = event.detail.selectedId;
        let uniqueKey = event.detail.key;

        //To mutate the list displayed on UI
        let element = this.orderProductslist.find(ele  => ele.Id === uniqueKey);
        element.SBQQ__ShippingAccount__c = id;

        //For Draft Values to be updated
        let elementShipAccount = this.draftOrderProdList.find(el => el.Id === uniqueKey);
        elementShipAccount.SBQQ__ShippingAccount__c = id;
    }

    handleChange(event){

        let fieldName = event.target.name;
    
        if (fieldName == 'activated') {

            let key = event.target.dataset.id;
            let element = this.draftOrderProdList.find(el => el.Id === key);
            element.SBQQ__Activated__c = event.target.checked;
        }
        if (fieldName == 'holdOrder') {
            let key = event.target.dataset.id;
            let element = this.draftOrderProdList.find(el => el.Id === key);
            element.L2O_Hold_Order__c = event.target.checked;
        }
        if (fieldName == 'sendRMA') {

            let key = event.target.dataset.id;
            let element = this.draftOrderProdList.find(el => el.Id === key);
            element.L2O_Send_RMA__c = event.target.checked;
        }
        if (fieldName == 'poNumber') {

            let key = event.target.dataset.id;
            let element = this.draftOrderProdList.find(el => el.Id === key);
            element.L2O_PO_Number__c = event.target.value;
        }
    }

    handleSave() {

        saveOrderProducts({records : this.draftOrderProdList})
        .then((result) => {
            if (result == 'Success') {
                this.handleCancel(); //navigate back to orderItem listview.
            } else{
                let errorMsg = result;
                this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
            }
        })
        .catch((error) => {
            let errorMsg = error;
            this.handleToastEvents(errorMsg, 'Error', 'error', 'dismissable');
        });
    }

    handleCancel(){
        
        // Navigation to Order Product related list of Order
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.orderId,
                objectApiName: 'Order',
                relationshipApiName: 'OrderItems',
                actionName: 'view'
            },
        });

    }

    /**
     * @description Fire toast events
     * @param toastMessage - The message to display in the toast.
     * @param toastTitle - The title for the message to display
     * @param toastVariant - The toast type('error' or 'success').
     * @param toastMode - The toast mode to dismiss the toast
     */
     handleToastEvents(toastMessage, toastTitle, toastVariant, toastMode) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: toastMode 
        });
        this.dispatchEvent(evt);
    }

}