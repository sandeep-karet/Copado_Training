/**
* Company : PwC.
* @description : L2O_RunTerritoryCalloutMock_Test will be executed from the L2O_QuoteTriggerHandler and will extend the L2O_TriggerHandler class .
* ************************************************************************************************************************************
* History : 
* @date 30/03/2022
* @author Neha Sharma
*/
@isTest
Public class L2O_RunTerritoryCalloutMock_Test implements HttpCalloutMock{
    /**
* @name  respond()
* @description Create mock response
* @param req for request
* @return res returns the response
*/ 
  Public HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(
               '<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"> <soap:Body> <PassThroughReqResponse xmlns=\"http://amsservices.com/\"> <PassThroughReqResult> <PickResponse> <Files> <File sagfile=\"WORK.7864470\"> <Item sagitem=\"WEBSERVICE.TAGS*WORK.7864470\"> <a1>POLICY.NUMBER</a1> <a2>CLIENT.CODE</a2> <a3>EFF.DATE</a3> <a4>EXP.DATE</a4> <a5>COV</a5> <a6>INS</a6> <a7>TERM</a7> <a8>POLICY.STATUS</a8> <a9>BILLING.METHOD</a9> <a10>31</a10> <a11>32</a11> <a12>33</a12> <a13>POLICY.STATUS</a13> <a14>NEW.REN</a14> <a15>CHG.TIME</a15> </Item> </File> <File sagfile=\"WORK.7864470\"> <Item sagitem=\"579615\"> <a1>TESTINGNEW</a1> <a2>ZIMJO1</a2> <a3>08/08/16</a3> <a4>08/08/17</a4> <a5>ARA</a5> <a6>CER</a6> <a7>A</a7> <a9>Agency Bill</a9> <a14>NEW</a14> <a15>12:06:46</a15> </Item> </File> </Files> </PickResponse></PassThroughReqResult> </PassThroughReqResponse> </soap:Body></soap:Envelope>');
    return res;
  }
}