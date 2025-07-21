/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global interface ITurboPricingReverseSyncJobHandler {
    List<System.HttpRequest> createSyncRequests(Apttus_Base2.TurboPricingReverseSyncJobData param0, List<SObject> param1);
    void processSyncResponse(Apttus_Base2.TurboPricingReverseSyncJobData param0, List<System.HttpRequest> param1, List<System.HttpResponse> param2);
}
