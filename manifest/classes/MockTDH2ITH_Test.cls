@isTest
global class MockTDH2ITH_Test implements HTTPCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setBody('"{\"result\":\"fine\",\"isInsert\":\"true\"}"');
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(200);
    return response;
  }
}