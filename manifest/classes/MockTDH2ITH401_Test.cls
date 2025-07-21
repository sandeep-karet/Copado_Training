@isTest
global class MockTDH2ITH401_Test implements HTTPCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setBody(
      '"{\"result\":\"INVALID_SESSION_ID\",\"isInsert\":\"false\"}"'
    );
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(401);
    return response;
  }
}