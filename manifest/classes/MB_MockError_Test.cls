@isTest
global class MB_MockError_Test implements HTTPCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setBody(
      '{"dml_errors" : {"a508A000000cPU5QAM" : {"Exception_Type__c" : "DML_ERROR"}}, "parsing_errors" : {"test":"test"}}'
    );
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(500);
    return response;
  }
}