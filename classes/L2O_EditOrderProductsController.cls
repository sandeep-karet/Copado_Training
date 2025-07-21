/**
* Company : PwC.
* @description : L2O_EditOrderProductsController will be used to handle Edit Order Products LWC on OrderProducts list view page.
* *******************************************************************************************************************************************
* History : 
* @date 11/23/2022
* @author Lakshitha Salian
*/

public without sharing class L2O_EditOrderProductsController {
    
    //Exception log variables
    public static String className = 'L2O_EditOrderProductsController';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;

    /**
    * @name  getOrderProducts   
    * @description This method returns list of not activated Parent/standalone Order Products
    * @param orderId for parent Order Id
    * @return List of Order Items
    **/ 
    @AuraEnabled
    public static List<OrderItem> getOrderProducts(String orderId) {
        
        methodName = 'getOrderProducts';
        List <OrderItem> lstOrderItems = new List <OrderItem>();
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
            //Fetch all the Parent/Stand alone order products which are not activated.
            //Fetch all the Parent/Stand alone order products with RequiredBy as NULL
            lstOrderItems =  [SELECT Id, OrderItemNumber, Product2.Name, Quantity, ServiceDate, 
                                SBQQ__Activated__c,L2O_Hold_Order__c,
                                L2O_Send_RMA__c,L2O_PO_Number__c,
                                SBQQ__ShippingAccount__c,
                              	Shipping_Contact__c,
                              	L2O_Shipping_Address_Text__c
                                FROM OrderItem
                                WHERE OrderId =: orderId
                                AND SBQQ__Activated__c = false 
                                AND SBQQ__RequiredBy__c= NULL];
        }catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        //Return list of not activated Parent/standalone Order Products
        return lstOrderItems;
    }
    
    /**
    * @name  saveOrderProducts   
    * @description This method returns result of updating the Order Products
    * @param records for parent Order Products to be updated
    * @return String result of updating Order Items
    **/
    @AuraEnabled
    public static String saveOrderProducts(List<OrderItem> records){
        
        methodName = 'saveOrderProducts';
        String response = '';  
        // Exception Handling
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
            if(records.size()>0 && records != null){
                List<OrderItem> updateOrderItems = new List<OrderItem>();
                List<OrderItem> updateChildOrderItems = new List<OrderItem>();
                Map<Id,OrderItem> mapParentOrderItems = new Map<Id,OrderItem>();
                Set<Id> parentOrderItems = new Set<Id>();
                
                //Prepare all the Parent/Stand alone order products to be saved.
                for(integer index = 0; index < records.size(); index++) {
                    OrderItem item = new OrderItem();
                    item.Id = records[index].Id;
                    parentOrderItems.add(item.Id);
                    item.SBQQ__Activated__c = records[index].SBQQ__Activated__c;
                    item.L2O_Hold_Order__c = records[index].L2O_Hold_Order__c;
                    item.L2O_Send_RMA__c = records[index].L2O_Send_RMA__c;
                    item.L2O_PO_Number__c = records[index].L2O_PO_Number__c;
                    item.SBQQ__ShippingAccount__c = records[index].SBQQ__ShippingAccount__c;
                    item.Shipping_Contact__c = records[index].Shipping_Contact__c;
                    mapParentOrderItems.put(item.Id,item);
                    updateOrderItems.add(item);
                }
                
                //Update child order products of the above Parent/Stand alone order products.
                //Query Child OrderItems
                updateChildOrderItems = [SELECT Id,SBQQ__RequiredBy__c,SBQQ__Activated__c,L2O_Hold_Order__c,
                                         L2O_Send_RMA__c,L2O_PO_Number__c,
                                         SBQQ__ShippingAccount__c,Shipping_Contact__c
                                        FROM OrderItem
                                        WHERE SBQQ__RequiredBy__c IN :parentOrderItems];
                
                If(updateChildOrderItems.size()>0){
                    for(OrderItem childOP : updateChildOrderItems) {
                        String parentId = childOP.SBQQ__RequiredBy__c;
                        childOP.SBQQ__Activated__c = mapParentOrderItems.get(parentId).SBQQ__Activated__c;
                        childOP.L2O_Hold_Order__c = mapParentOrderItems.get(parentId).L2O_Hold_Order__c;
                        childOP.L2O_Send_RMA__c = mapParentOrderItems.get(parentId).L2O_Send_RMA__c;
                        childOP.L2O_PO_Number__c = mapParentOrderItems.get(parentId).L2O_PO_Number__c;
                        childOP.SBQQ__ShippingAccount__c = mapParentOrderItems.get(parentId).SBQQ__ShippingAccount__c;
                        childOP.Shipping_Contact__c = mapParentOrderItems.get(parentId).Shipping_Contact__c;
                        updateOrderItems.add(childOP);
                	}
                }
                //update OrderItem
				//List of Parent/Stand alone order products along with any child order products if present.
                update updateOrderItems;
                // Set reponse to Success
           		response ='Success';
            }
            else{
                // Set reponse to No records to update
                response ='No records to update!';
            } 
         } catch (Exception ex) {
             response = ex.getMessage();
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
         } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        //Return result of updating the Order Products
      	return response;
    }
}