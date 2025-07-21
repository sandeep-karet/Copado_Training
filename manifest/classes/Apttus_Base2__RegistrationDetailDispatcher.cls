/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/v1/getRegistrationDetails/*')
global class RegistrationDetailDispatcher {
    global RegistrationDetailDispatcher() {

    }
    @HttpGet
    global static Apttus_Base2.RegistrationDetailDispatcher.IntegrationSettingWrapper getRegistrationDetail() {
        return null;
    }
global class IntegrationSettingWrapper {
    global String additionalSettings {
        get;
        set;
    }
    global String apiToken {
        get;
        set;
    }
    global String endpoint {
        get;
        set;
    }
    global Boolean isLargeFileSupported {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String tenant {
        get;
        set;
    }
    global IntegrationSettingWrapper() {

    }
}
}
