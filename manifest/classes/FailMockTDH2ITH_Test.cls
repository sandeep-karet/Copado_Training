@isTest
global class FailMockTDH2ITH_Test implements HTTPCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setBody(
      '"{\"result\":\"DUPLICATE_VALUE\",\"isInsert\":\"false\"}"'
    );
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(200);
    return response;
  }
}