global class SumoLogicHttpMockImpl implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse httpResp = new HTTPResponse();
            httpResp.setStatusCode(200);
            return httpResp;
        }
    }