/*************************************************************************     
* @description This class is used as Test class for testing 200 Error
* @param NA
* @Author InfoSys Developer
**************************************************************************/
@isTest
public class FailMockTDH2ITH_Test implements HTTPCalloutMock {
/**
* @description This method is being called by TDH_Lead_ControllerTest
* @param request is HTTPRequest object coming from TDH_Lead_ControllerTest
* @return response
**/    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody('"{\"result\":\"DUPLICATE_VALUE\",\"isInsert\":\"false\"}"');
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        return response;
    }
}