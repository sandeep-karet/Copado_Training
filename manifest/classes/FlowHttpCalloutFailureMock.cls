global class FlowHttpCalloutFailureMock implements HttpCalloutMock {
  // Implement this interface method
  global HTTPResponse respond(HTTPRequest request) {
    // Create a fake response
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    String response_body = '';

    // Check which type of response we need to provide

    if (request.getEndpoint().contains('authentication/login')) {
      TDAuthResponse tdar = new TDAuthResponse();
      tdar.auth_token = 'AUTHTOKEN';
      response_body = JSON.serialize(tdar);
    } else {
      response_body = '{"errors":"INTENDED ERROR IN TESTING"}';
    }
    response.setBody(response_body);
    response.setStatusCode(422);
    return response;
  }
}