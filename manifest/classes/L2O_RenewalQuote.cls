/**
* Company : PwC.
* @description : L2O_RenewalQuote will be used to handle Manual Renewal.
* *******************************************************************************************************************************************
* History : 
* @date 27/04/2022
* @author Smarajit Mohanty
*/
public without sharing class L2O_RenewalQuote {
    
    //Exception log variables
    public static String className = '';
    public static String methodName = '';
    @TestVisible private static Boolean isErrorFlag = false;
    
    /**
    * @name  updateRenewalQuoted   
    * @description This method is called from RenewalQuote lightning component to create renewal quote
    * @param recordId for the Opportunity Id
    * @return This method returning response as String
    **/
    @AuraEnabled
    public static String updateRenewalQuoted(String recordId) {
        List<Contract> contractListUpdateTrue = new List<Contract>();
        List<Contract> contractListUpdateFalse = new List<Contract>();
        List<Account> accListUpdate = new List<Account>();
        className = 'L2O_RenewalQuote';
        methodName = 'updateRenewalQuoted';
        String response = '';                                                       
        try {
            if(isErrorFlag == true && Test.isRunningTest()) {
             	throw new AuraHandledException(System.Label.L2O_AuraHandledError);
             }
            
        for (
            Opportunity opp: [
                SELECT Id, SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c,
                AccountId,Account.SBQQ__RenewalPricingMethod__c
                FROM Opportunity
                WHERE Id = :recordId AND SBQQ__RenewedContract__c != null
            ]
        ) {
            //Checks if the opportunity has quote, if yes it unchecks the Renewal Quoted checkbox on Contract and checks it again to create a new renewal quote
            if (opp.SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c == true) {
                //If the user wants to create another renewal quote when there is an existing renewal quote, the Renewal Quoted flag is set to false and then to true. This CPQ functionality helps in creating renewal quote.
                contractListUpdateFalse = prepareContract(opp.SBQQ__RenewedContract__c, false);
                contractListUpdateTrue = prepareContract(opp.SBQQ__RenewedContract__c, true);
            }
            if (opp.SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c == false) {
                contractListUpdateTrue = prepareContract(opp.SBQQ__RenewedContract__c, true);
            }
            //For updating Account record Pricing Method
            If(opp.Account.SBQQ__RenewalPricingMethod__c == 'Same'){
                accListUpdate.add(new Account(Id=opp.AccountId,SBQQ__RenewalPricingMethod__c ='List'));
            }
         }
            //update account record
            If(!accListUpdate.isEmpty()){
                update accListUpdate;
            }
            //update Contract record
            if (!contractListUpdateTrue.isEmpty() && !contractListUpdateFalse.isEmpty()) {
                update contractListUpdateFalse;
                update contractListUpdateTrue;
            } else if (!contractListUpdateTrue.isEmpty() && contractListUpdateFalse.isEmpty()) {
                update contractListUpdateTrue;
            }
           response ='Success';
         } catch (Exception ex) {
             response = 'Error';
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
          } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
      return response;
    }
    
    /**
    * @name  prepareContract
    * @description This method is called from updateRenewalQuoted to prepare Contract List
    * @param contractId for the Contracts Id
    * @param isRenewalQuoted flag for the Renewal Quote
    * @return This method returning list<Contact> records
    **/
    public static List<Contract> prepareContract(Id contractId, Boolean isRenewalQuoted) {
        methodName = 'prepareContract';
        List<Contract> contractListToUpdate = new List<Contract>();
        Contract contractToupdate = new Contract();
        contractToupdate.Id = contractId;
        contractToupdate.SBQQ__RenewalQuoted__c = isRenewalQuoted;
        contractListToUpdate.add(contractToupdate);
        //Return Contract list to update
        return contractListToUpdate;
    }

}