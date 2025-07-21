/**
* Company : PwC.
* @description : L2O_RunTerritoryRulesQueueable will be executed from the L2O_QuoteTriggerHandler and will extend the L2O_TriggerHandler class .
* ************************************************************************************************************************************
* History : 
* @date 30/03/2022
* @author Neha Sharma
*/
public class L2O_RunTerritoryRulesQueueable implements Queueable, Database.AllowsCallouts  {
    
    //Exception log variables
    public static String className = 'L2O_RunTerritoryRulesQueueable';
    public static String methodName = '';
    
    public Set<String> accntIds = null;
    private String sessionId = null;
    //Prepare the accountTag String
    String accountTag = '<urn:sObjects> '+'<urn1:type>Account</urn1:type>  '+
        '<urn1:Id>{ACCID}</urn1:Id>   '+'</urn:sObjects> ' ;  
    //Prepare the requestTemplate String
    String requestTemplate = '<soapenv:Envelope '+
        'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
        ' xmlns:urn="urn:partner.soap.sforce.com"'+
        ' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
        '<soapenv:Header> '+ '<urn:AssignmentRuleHeader> '+ 
        '<urn:useDefaultRule>true</urn:useDefaultRule> '+
        '<urn:assignmentRuleId></urn:assignmentRuleId> '+
        '</urn:AssignmentRuleHeader>  '+'<urn:SessionHeader> '+
        '<urn:sessionId>{SESSID}</urn:sessionId> '+
        '</urn:SessionHeader> '+ '</soapenv:Header> '+'<soapenv:Body> '+
        '<urn:update> '+' {ACCLISTS}'+ '</urn:update> '+'</soapenv:Body> '+ '</soapenv:Envelope>'; 
    
    /**
    * @name  execute
    * @description execute
    * @param  context for context
    **/                         
    public void execute(QueueableContext context) {
        methodName = 'execute';
        // Get session Id
        // Replace requestTemaplate session Id
        // Exception Handling
        try{
            sessionId = Page.L2O_TerritoryRule_Session.getContent().toString(); 
            requestTemplate = requestTemplate.replace('{SESSID}', sessionId) ;
        }
        catch (Exception ex) {
             SDF_LGR_LoggerManager.DBufLogger.error(ex,className,methodName);
        } finally{
        	SDF_LGR_LoggerManager.DBufLogger.flush();
        }
        List<String> lstAccString = new List<String>();
        if(accntIds != null){
            // Replace Account Id
            for(String accId:accntIds){
                lstAccString.add(accountTag.replace('{ACCID}', accId)); 
            }
        } 
        //Prepare the request
        requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(lstAccString, ' ')) ;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody(requestTemplate);
        // Get Body Document String
        if(!Test.isRunningTest()){
        String.valueOf(new Http().send(request).getBodyDocument());
        }
    }
        
}