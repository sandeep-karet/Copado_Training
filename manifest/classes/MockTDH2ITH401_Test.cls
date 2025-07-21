/*************************************************************************     
* @description This class is used as Test class for testing 401 Error
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class MockTDH2ITH401_Test implements HTTPCalloutMock {
/**
* @description This method is being called by TDH_Lead_ControllerTest
* @param request is HTTPRequest object coming from TDH_Lead_ControllerTest
* @return response is response for httprequest object
**/
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody('"{\"result\":\"INVALID_SESSION_ID\",\"isInsert\":\"false\"}"');
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(401);
        return response;
    }
}