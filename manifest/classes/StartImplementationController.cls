public with Sharing class StartImplementationController {
    
    @AuraEnabled
    public static void startImplementation(String recordId){
        RecordType oppProvider = [select ID,SobjectType from RecordType where developername = 'Provider_Platform' and SObjectType = 'Opportunity'];
        RecordType oppReadOnly = [select ID,SobjectType from RecordType where developername = 'Read_Only' and SObjectType = 'Opportunity'];

        Opportunity opp = [Select Id,OwnerId, StageName,recordtypeId, CPQ_Pricebook__c,CPQ_Contracted_Date__c, SBQQ__Contracted__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.Approvals__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c from Opportunity where Id = :recordId] ;
        User currentUser = [select profile.name, UserRoleId, UserRole.name from user where id =:userinfo.getUserId()];
        
        validate(Opp,currentUser);
        
        opp.SBQQ__Contracted__c = true;
        opp.CPQ_Contracted_Date__c = System.today();
        opp.Request_CIM__c = true;
        System.debug('Updated Opportunity Contracted checbox to TRUE');
        if(opp.recordtypeId != oppProvider.Id && opp.CPQ_Pricebook__c != 'Broker'){
            opp.recordtypeId = oppReadOnly.Id;
            System.debug('Updated Opportunity RecordType to ReadOnly');
        }
        try {
            update opp ;
        }catch(Exception e){
            throw new AuraHandledException('Opportunity update failed '+ e.getMessage());
        }
       	
    }
    
    @AuraEnabled
    public static void validate(Opportunity opp, User currentUser){
        //User must be a System Administrator or have Contracting Permission
        System.debug('OwnerId'+opp.OwnerId);
        System.debug('CurrentUserId'+ currentUser.Id);
        If(currentUser.UserRoleId != null && !currentUser.Profile.Name.contains('System Administrator') && !currentUser.Profile.Name.contains('Client Operations') && !currentUser.Profile.Name.contains('Client Manager') && !currentUser.UserRole.Name.contains('Contracts') && opp.ownerId != currentUser.Id){
            throw new AuraHandledException('Access Denied. You do not have authorization to start implementation');
        }
        //Opportunity must have PrimaryQuote
        If(opp.SBQQ__PrimaryQuote__c == null){
            throw new AuraHandledException('Missing Primary Quote');
        }
        //Opportunity Primary Quote must be in Approved Status
        If(opp.SBQQ__PrimaryQuote__r.Approvals__c != null && opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c != 'Approved'){
            throw new AuraHandledException('Primary Quote is not Approved');            
        }
        //Opportunity Stage must be either in Contracting or Closed Won
        If(opp.StageName != 'Contracting' && opp.StageName != 'Closed Won'){
            throw new AuraHandledException('You cannot begin implementation until this opportunity is in Contracting stage');
        }
    }
}