/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/clm/*')
global class CLMRestApiDispatcher {
    global CLMRestApiDispatcher() {

    }
    @HttpDelete
    global static void onDelete() {

    }
    @HttpGet
    global static void onGet() {

    }
    @HttpPatch
    global static void onPatch() {

    }
    @HttpPost
    global static void onPost() {

    }
    @HttpPut
    global static void onPut() {

    }
global class Response {
    global Object data;
    global Integer status;
    global String title;
    global Response(Integer status, String title, Exception e) {

    }
    global Response(Integer status, String title, Object data) {

    }
    global void send() {

    }
}
}
