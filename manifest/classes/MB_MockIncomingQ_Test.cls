@isTest
global class MB_MockIncomingQ_Test implements HTTPCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setBody('{"isCreated" : "True",  "qItemError" : "None"}');
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(200);
    return response;
  }
}