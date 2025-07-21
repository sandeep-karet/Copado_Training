public with sharing class msuLookupLwcController {   
   	@AuraEnabled
    public static string recordName(Id recordId){
        Id idToProccess = recordId;              
		Schema.sObjectType entityType = idToProccess.getSObjectType();
		String name;
        if(entityType == Contact.sObjectType) {
            Contact con = [SELECT Id, Name FROM Contact WHERE Id =: recordId];
            name = con.Name;
        } else {
            Mbr_Group__c mbrGrp = [SELECT Id, Name__c From Mbr_Group__c WHERE Id =: recordId];
            name = mbrGrp.Name__c;
        }      
        return name;
    }
    
    @AuraEnabled
    public static boolean sObjectType(Id recordId){
        Id idToProccess = recordId;              
		Schema.sObjectType entityType = idToProccess.getSObjectType();
		boolean isContact;
        if(entityType == Contact.sObjectType) {
            isContact = true;
        } else {
            isContact = false;
        }      
        return isContact;
    }
    
    @AuraEnabled
    public static string checkRecord(Id recordId){
        boolean isContact = msuLookupLwcController.sObjectType(recordId);
        string error;
        if(isContact) {
            List<Contact> con = [SELECT Id,Contact_Status__c,Marketing_Site_User__c,Marketing_Site_Username__c,Account.Name FROM Contact WHERE Id =: recordId];
            if(con[0]!= null && con[0].Contact_Status__c == 'ACTIVE' && con[0].Marketing_Site_User__c) {
                   error = null;            
               } else if(!con[0].Marketing_Site_User__c) {
                   error = 'Contact is not a marketing site user.';
               } else if (con[0].Contact_Status__c != 'Active') {
                   error = 'Contact is not active.';
               }
        }
        return error;
    }
    
    @AuraEnabled
    public static List<MSUWrapper> getMsuList(Id recordId){
        List<MSUWrapper> calcMSUsList = new List<MSUWrapper>();
        boolean isContact = msuLookupLwcController.sObjectType(recordId);
        if(isContact) {
            Contact con = [SELECT Id,Name,AccountId,Account.Name FROM Contact WHERE Id =:recordId];
            List<Mkt_Site_User__c> oddDucks = [SELECT Id,Name,Contact__r.Name,Mbr_Group__r.Name,Contact__c,Mbr_Group__c,Mbr_Group__r.Status__c,Contact__r.AccountId,Contact__r.Account.Name,
                                               Mbr_Group__r.Group_Number__c, Mbr_Group__r.Client_Account__r.Name, Mbr_Group__r.Client_Account__c, Mbr_Group__r.Name__c
                                               FROM Mkt_Site_User__c
                                               WHERE Contact__c = :con.Id
                                               AND Contact__r.Contact_Status__c = 'ACTIVE'
                                               AND Contact__r.Marketing_Site_User__c = TRUE
                                               AND Mbr_Group__r.Is_Valid_MSU_Group__c = TRUE
                                              ]; 
            if (oddDucks != null) {
                for (Mkt_Site_User__c msu : oddDucks) {
                    calcMSUsList.add(new MSUWrapper(msu));
                }
            }
            
            List<Mbr_Group__c> baseGroups = [SELECT Id, Name, Client_Account__r.Name, Client_Account__c, Group_Number__c, Name__c, Status__c
                                             FROM Mbr_Group__c
                                             WHERE Is_Valid_MSU_Group__c = TRUE AND Client_account__c = :con.AccountId
                                            ];
            List<Mbr_Group__c> validGroups = [SELECT Id, Name, Client_Account__r.Name, Client_Account__c, Group_Number__c, Name__c, Status__c
                                              FROM Mbr_Group__c
                                              WHERE Is_Valid_MSU_Group__c = TRUE
                                              AND Id IN (SELECT Mbr_Group__c FROM Mbr_Group_Role__c WHERE Source_Account__c = :con.AccountId 
                                                         AND Role_Type__c IN ('Payer', 'Benefit Sponsor', 'MSU Access'))
                                             ];
            
            validGroups.addAll(baseGroups);
            if (validGroups != null) {
                for (Mbr_Group__c g : validGroups) {
                    calcMSUsList.add(new MSUWrapper(g, con));
                }
            }
        } else {
            List<Mbr_Group__c> mbrGrp =  [SELECT Id,Name,Group_Number__c,Name__c,Client_Account__c,Client_Account__r.Name,Status__c
                                    FROM Mbr_Group__c
                                    WHERE Id =: recordId and Is_Valid_MSU_Group__c = TRUE
                                   ];
            if (!mbrGrp.IsEmpty()) {
            List<Mkt_Site_User__c> oddDucks = [SELECT Id,Name,Contact__r.Name,Mbr_Group__r.Name,Mbr_Group__r.Status__c,Contact__c,Mbr_Group__c,
                                               Mbr_Group__r.Client_Account__c, Mbr_Group__r.Client_Account__r.Name,
                                               Contact__r.AccountId,Contact__r.Account.Name,Mbr_Group__r.Group_Number__c,Mbr_Group__r.Name__c
                                               FROM Mkt_Site_User__c
                                               WHERE Mbr_Group__c = :mbrGrp[0].Id
                                               AND Contact__r.Contact_Status__c = 'ACTIVE'
                                               AND Contact__r.Marketing_Site_User__c = TRUE
                                               AND Mbr_Group__r.Is_Valid_MSU_Group__c = TRUE
                                              ];
            if (oddDucks != null) {
                for (Mkt_Site_User__c msu : oddDucks) {
                    calcMSUsList.add(new MSUWrapper(msu));
                }
            }
            
            List<Contact> baseContacts = [SELECT Id,Name,AccountId,Account.Name
                                          FROM Contact
                                          WHERE Marketing_Site_User__c = TRUE AND Contact_Status__c = 'ACTIVE' 
                                          AND AccountId = :mbrGrp[0].Client_Account__c];        
            List<Contact> validContacts = [
                SELECT Id,Name,AccountId,Account.Name
                FROM Contact
                WHERE Marketing_Site_User__c = TRUE AND Contact_Status__c = 'ACTIVE' 
                AND AccountId IN (SELECT Source_Account__c FROM Mbr_Group_Role__c WHERE Mbr_Group__c = :mbrGrp[0].Id AND Mbr_Group__r.Is_Valid_MSU_Group__c = TRUE AND Role_Type__c IN ('Payer', 'Benefit Sponsor', 'MSU Access'))
            ];
            
            validContacts.addAll(baseContacts);
            if (validContacts != null) {
                for (Contact c : validContacts) {
                    calcMSUsList.add(new MSUWrapper(mbrGrp[0], c));
                }
            }
          }
        }
        return calcMSUsList;
    }
    
    public class MSUWrapper {
    	@AuraEnabled
        public String groupName { get; set; }
        @AuraEnabled
        public Boolean oddDuck { get; set; }
    	@AuraEnabled
        public Mkt_Site_User__c msu { get; set; }
        
        public MSUWrapper(Mkt_Site_User__c oddDuckMSU) {
            msu = oddDuckMSU;
            oddDuck = true;
            groupName = msu.Mbr_Group__r.Name__c;
        }

        public MSUWrapper(Mbr_Group__c grp, Contact con) {
            msu = new Mkt_Site_User__c();
            msu.Mbr_Group__c = grp.Id;
            msu.Contact__c = con.Id;
            msu.Contact__r = con;
            msu.Mbr_Group__r = grp;
            oddDuck = false;
            groupName = grp.Name__c;
        }
        
    }  
}