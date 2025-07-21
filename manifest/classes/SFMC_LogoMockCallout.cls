@isTest
global class SFMC_LogoMockCallout implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    String response_body = '';
    String fileupload =
      '{' +
      '"Name": "testfileSfsc",' +
      '"assetType": {' +
      '"name":"jpg",' +
      '"id": 23},' +
      '"category": {' +
      '"id":354780,' +
      '"name":"API Testing"' +
      '},' +
      '"FileProperties": {' +
      '"filename": "testfileSfsc.jpg"' +
      '},' +
      '"file":' +
      '"' +
      '/9j/7QAsUGhvdG9zaG9wIDMuMAA4QklNA+0AAAAAABACWAAAAAEAAQJYAAAAAQAB/+FFgGh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8APD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN”' +
      '"' +
      '}';
    response.setHeader('Content-Type', 'application/json');

    if (request.getEndpoint().contains('authentication/login')) {
      response_body = 'accesstoken';
    } else {
      response_body = fileupload;
    }
    response.setBody(response_body);
    response.setStatusCode(200);
    return response;
  }
}