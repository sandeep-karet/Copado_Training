/**
* Company : PwC.
* @description : QuoteExtController for enabling Quote object for Advanced Approval.
* ************************************************************************************************************************************
* History : 
* @date 10/03/2022
* @author Utkarsh Chaurasia
*/

public with sharing class QuoteExtController {
	private Id quoteId;

	/**
    * @name  QuoteExtController
    * @description Controller
	* @param stdController To get the Quote Id
    **/
	public QuoteExtController(ApexPages.StandardController stdController) {
		quoteId = stdController.getId();
	}

	/**
    * @name  onSubmit
    * @description Action behind Quote Submit Approval
	* @return PageReference
    **/
	public PageReference onSubmit() {
		if (quoteId != null) {
			SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
		}
		return new PageReference('/' + quoteId);
	}

	/**
    * @name  onRecall
    * @description Action behind Quote Recall Approval
	* @return PageReference
    **/
	public PageReference onRecall() {
		if (quoteId != null) {
			SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
		}
		return new PageReference('/' + quoteId);
	}
}