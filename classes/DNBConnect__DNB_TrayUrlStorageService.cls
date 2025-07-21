/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/DNB_StoreTrayUrl/*')
global class DNB_TrayUrlStorageService {
    global DNB_TrayUrlStorageService() {

    }
    @HttpPost
    global static DNBConnect.DNB_TrayUrlStorageService.MessageResponse storeTrayURL(String inputTrayURL) {
        return null;
    }
global class MessageResponse {
    global Boolean isTrayUrlRecordPresent;
    global String oldTrayURL;
    global DNBConnect__PackageInfoProtected__c packageInfoObj;
    global String resultMessage;
    global MessageResponse() {

    }
}
}
