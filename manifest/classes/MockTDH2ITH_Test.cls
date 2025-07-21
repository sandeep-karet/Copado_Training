/*************************************************************************     
* @description This class is used as Test class for testing 200 error code
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class MockTDH2ITH_Test implements HTTPCalloutMock {
/**
* @description This method is being called by TDH_Lead_ControllerTest
* @param request is HTTPRequest object coming from TDH_Lead_ControllerTest
* @return response is response for httprequest object
**/    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody('"{\"result\":\"fine\",\"isInsert\":\"true\"}"');
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        return response;
    }
}