/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AttachmentFileWrapper {
    global static String ATTACHMENT_OBJECT_NAME;
    global Blob body {
        get;
        set;
    }
    global Integer BodyLength {
        get;
        set;
    }
    global String ContentType {
        get;
        set;
    }
    global Id CreatedById {
        get;
        set;
    }
    global Datetime CreatedDate {
        get;
        set;
    }
    global String Description {
        get;
        set;
    }
    global String DocumentType {
        get;
        set;
    }
    global static String FILE_OBJECT_NAME;
    global static String FORMAT_AGREEMENTREVIEW_SCREEN_DATEFORMAT;
    global Id Id {
        get;
        set;
    }
    global Id LastModifiedByID {
        get;
        set;
    }
    global String LastModifiedDate {
        get;
        set;
    }
    global Id LatestPublishedVersionid {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global Id OwnerId {
        get;
        set;
    }
    global Id ParentId {
        get;
        set;
    }
    global String ParentName {
        get;
        set;
    }
    global Datetime SystemModstamp {
        get;
        set;
    }
    global AttachmentFileWrapper() {

    }
    global AttachmentFileWrapper(Id id, String name, String ContentType, Integer BodyLength, Id CreatedById, Id LastModifiedByID, Id OwnerId, Id ParentId, Datetime LastModifiedDate, Datetime SystemModstamp, String ParentName) {

    }
    global AttachmentFileWrapper(Id id, String name, String ContentType, Integer BodyLength, Id CreatedById, Id LastModifiedByID, Id OwnerId, Id ParentId, Datetime LastModifiedDate, Datetime SystemModstamp, Blob body, String ParentName) {

    }
}
