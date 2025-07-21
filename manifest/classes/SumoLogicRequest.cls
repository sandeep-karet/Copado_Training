public with sharing class SumoLogicRequest {
    public Map<String, Object> request {get;set;}
    public SumoLogicRequest(string sfdcId, string sfdcContext, string title, Integer errorCode) {
        request = new Map<String,Object>();
        request.put('timestamp',datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        request.put('error_code', errorCode);
        request.put('dedup_key', UserInfo.getOrganizationId()+'_'+ sfdcId);
        request.put('context', '[' + sfdcContext + '] - ' + title);
        request.put('context_url', URL.getOrgDomainUrl().toExternalForm() + '/' + sfdcId);
    }
}