/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class CustomClass {
    global CustomClass() {

    }
global class ActionParams {
    global String ActionName {
        get;
        set;
    }
    global Map<String,String> CustomParams {
        get;
        set;
    }
    global String Data {
        get;
        set;
    }
    global String DataName {
        get;
        set;
    }
    global String OutputFormat {
        get;
        set;
    }
    global Id RecordId {
        get;
        set;
    }
    webService String SessionId {
        get;
        set;
    }
    webService String SessionUrl {
        get;
        set;
    }
    global ActionParams() {

    }
}
global class EditionInfo {
    global Integer Apps {
        get;
    }
    global Integer AppsAvail {
        get;
    }
    global Integer AppsUsed {
        get;
    }
    global String Description {
        get;
    }
    global String Name {
        get;
    }
    global String RefId {
        get;
    }
    global Integer Seats {
        get;
    }
    global Integer SeatsAvail {
        get;
    }
    global Integer SeatsUsed {
        get;
    }
}
global interface IActionCallback {
    Id generateDoc(Apttus_XApps.CustomClass.ActionParams param0);
}
}
