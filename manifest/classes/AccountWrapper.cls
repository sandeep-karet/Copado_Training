/**
 * Build the Account Structure in this Wrapper class that will passed from the GET request
 */
global with sharing class AccountWrapper {
  global Account theAccount { get; set; }
  //global List<RelationshipWrapper> accountRelationships {get;set;}

  // global class RelationshipWrapper {
  // 	global Acct_Rel__c accountRelationship {get;set;}
  // 	global Account relatedAccount 		   {get;set;}
  // }
}