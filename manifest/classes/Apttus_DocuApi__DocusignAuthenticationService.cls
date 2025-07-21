/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DocusignAuthenticationService {
    global DocusignAuthenticationService() {

    }
    global static Apttus_DocuApi.DocusignAuthenticationService.AuthenticationResponse getAccessToken() {
        return null;
    }
    global static Apttus_DocuApi.DocusignAuthenticationService.AuthenticationResponse getImpersonatedAccessTokenByEmail(String userEmail) {
        return null;
    }
    global static Apttus_DocuApi.DocusignAuthenticationService.AuthenticationResponse getImpersonatedAccessTokenByUserGUID(String userGUID) {
        return null;
    }
global class AuthenticationResponse {
    global String accessToken {
        get;
        set;
    }
    global String errorMessage {
        get;
        set;
    }
    global Integer statusCode {
        get;
        set;
    }
    global AuthenticationResponse() {

    }
}
}
