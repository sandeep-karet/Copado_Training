global class FlowHttpCalloutMock implements HttpCalloutMock {
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
      response_body = '{"errors":[],"data":{"friendlyName":"Bayer","id":"2","benefitSponsors":[{"friendlyName":"Bayer","id":"2"}],"groups":[{"id":"171","legacyGroupId":"100171","registrationCode":"23e0e36d-2ada-456c-a4dd-7839592c6e5a","guid":"37DA9620-329A-B03E-ACE3-DE509BD825E7","name":"Bayer - HMSA","effectiveStartDate":"2018-12-18T18:00:00-06:00","effectiveEndDate":null},{"id":"187","legacyGroupId":"100187","registrationCode":"728c6de9-c282-4529-9f09-8e49dd535df5","guid":"2F6224B2-66A5-7A95-F2F6-0889182F5F6C","name":"Bayer - Humana","effectiveStartDate":"2017-12-31T18:00:00-06:00","effectiveEndDate":null}]}}';
    }
    response.setBody(response_body);
    response.setStatusCode(200);
    return response;
  }
}