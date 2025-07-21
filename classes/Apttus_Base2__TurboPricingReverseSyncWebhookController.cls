/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/reverse-sync')
global class TurboPricingReverseSyncWebhookController {
    global TurboPricingReverseSyncWebhookController() {

    }
    @HttpPost
    global static String initiateReverseSync(Apttus_Base2.TurboPricingReverseSyncWebhookController.InitiateReverseSyncRequest request) {
        return null;
    }
global class InitiateReverseSyncRequest {
    global String cartId {
        get;
        set;
    }
    global InitiateReverseSyncRequest() {

    }
}
}
