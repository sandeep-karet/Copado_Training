/**
 * @description This is a Mock class created to provide response to the GET callout
 * @param NA
 * Author InfoSys Developer,
**/
@isTest
Public class APTS_getformDatamock_Test implements HttpCalloutMock {
    /**
     * @description This method is used to supply the response to test the Rest API class
     * @param req is the Request from the Get callout
     * @return response for the HTTP Request
     * Author InfoSys Developer
    **/
    Public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setBody('{"formData": [{"name": "Other Party Signed Title_2","value": ""},{"name": "Company Signed by_1","value": "Kareti Sandeep"},{"name": "Company Signed Title_1","value": "Legal Advisor"},{"name": "Company Signed Date_1","value": "3/27/2023"},{"name": "Other Party Signed by_2","value": "Yogesh Kumar"},{"name": "Other Party Signed Date_2","value": "3/27/2023"}],"prefillFormData": {"formData": []},"envelopeId": "4917f32e-ed9d-49f7-bf9e-ac0b7dadc89a","status": "completed","sentDateTime": "2023-03-27T16:39:50.0000000Z","recipientFormData": [{"formData": [{"name": "Company Signed by_1","value": "Kareti Sandeep"},{"name": "Company Signed Title_1","value": "Legal Advisor"},{"name": "Company Signed Date_1","value": "3/27/2023"}],"recipientId": "638ffb7b-0619-48a1-822f-3b6182557b8d","name": "Kareti Sandeep","email": "kareti.sandeep@teladochealth.com","SignedTime": "2023-03-27T09:39:49.5170000Z","DeliveredTime": "2023-03-27T09:39:43.3930000Z"},{"formData": [{"name": "Other Party Signed Title_2","value": ""},{"name": "Other Party Signed by_2","value": "Yogesh Kumar"},{"name": "Other Party Signed Date_2","value": "3/27/2023"}],"recipientId": "8cb05f15-c765-44e8-a7e5-f2b0cadb710b","name": "Yogesh Kumar","email": "yogesh.kumar_ext@teladochealth.com","SignedTime": "2023-03-27T09:43:10.2970000Z","DeliveredTime": "2023-03-27T09:43:04.9200000Z"}]}');
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        return response;
    }
}