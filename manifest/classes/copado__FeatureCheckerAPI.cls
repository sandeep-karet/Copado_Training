/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/featurecheck')
global class FeatureCheckerAPI {
    global FeatureCheckerAPI() {

    }
    @HttpPost
    global static copado.FeatureCheckerAPI.FeatureEvaluatorResponse doPost() {
        return null;
    }
global class FeatureEvaluatorItem {
    global String name {
        get;
        set;
    }
    global Boolean value {
        get;
        set;
    }
}
global class FeatureEvaluatorResponse {
    global List<copado.FeatureCheckerAPI.FeatureEvaluatorItem> customPermissions {
        get;
        set;
    }
    global List<copado.FeatureCheckerAPI.FeatureEvaluatorItem> featureParameters {
        get;
        set;
    }
    global FeatureEvaluatorResponse() {

    }
}
}
